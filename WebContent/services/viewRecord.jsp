<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.db.*" %>
<%@page import="com.client.util.*" %>
<%@page import="com.client.reports.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
	<title></title>
	<link type="text/css" href="../styles/dygraph.css" rel="stylesheet" />
	<script language="javascript">
		function loadValues()
		{
			document.frm.submit();
		}
		
		function viewAttachments(dir, file)
		{
			var url = "../ViewAttachments?folder="+dir+"&imageName="+file;
			document.location.href =  url;
		}
	</script>
</head>

<%
	ReportDAO reportDAO = new ReportDAO();

	String sReport = request.getParameter("report");
	String sAction = request.getParameter("action");
	String sMode = request.getParameter("mode");
	String sDate = request.getParameter("date");
	String sTime = request.getParameter("time");
	sTime = (sTime == null ? "00:00:00" : sTime);
	
	String sColumn = "";
	String sName = "";
	String sValue = "";
	String sDateTime = "";
	String sFormula = "";
	String[] sRanges = null;
	StringList slTimestamps = null;

	if("search".equals(sMode))
	{
		String[] saDateCol = null;
		Map<String, String[]> mDateCols = new HashMap<String, String[]>();
		Map<String, String> mSearchCriteria = new HashMap<String, String>();

		Enumeration enumeration = request.getParameterNames();
		while (enumeration.hasMoreElements())
		{
			sName = (String) enumeration.nextElement();
			if(sName.startsWith("Column"))
			{
				sValue = request.getParameter(sName);
				if("".equals(sValue))
				{
					continue;
				}
				if(sName.endsWith("_From") || sName.endsWith("_To"))
				{
					sColumn = sName.substring(0, sName.indexOf("_"));						
					saDateCol = (mDateCols.containsKey(sColumn) ? mDateCols.get(sColumn) : new String[] {"", ""});
					
					if(sName.endsWith("_From"))
					{
						saDateCol[0] = sValue;
					}
					else if(sName.endsWith("_To"))
					{
						saDateCol[1] = sValue;
					}
					
					mDateCols.put(sColumn, saDateCol);						
				}
				else
				{
					if(sName.endsWith("_Manual"))
					{
						sName = sName.substring(0, sName.indexOf("_"));
					}
					
					if(mSearchCriteria.containsKey(sName))
					{
						if("".equals(mSearchCriteria.get(sName)))
						{
							mSearchCriteria.put(sName, sValue);
						}
					}
					else
					{
						mSearchCriteria.put(sName, sValue);
					}
				}
			}
		}
		
		Iterator<String> itrDateCols = mDateCols.keySet().iterator();
		while(itrDateCols.hasNext())
		{
			sName = itrDateCols.next();

			saDateCol = mDateCols.get(sName);
			sValue = ("".equals(saDateCol[0]) ? "NA" : saDateCol[0]) + "|" + ("".equals(saDateCol[1]) ? "NA" : saDateCol[1]);
			if(!sValue.equals("NA|NA"))
			{
				mSearchCriteria.put(sName, sValue);
			}
		}
		
		if(!(mSearchCriteria.isEmpty() || mSearchCriteria.size() == 0))
		{
			slTimestamps = reportDAO.getRecordTimestamps(sReport, mSearchCriteria);
			if(slTimestamps.size() > 0)
			{
				sDateTime = slTimestamps.get(0);
			}
			
			session.setAttribute("RecordTimestamps", slTimestamps);
		}
	}
	else
	{
		slTimestamps = (StringList)session.getAttribute("RecordTimestamps");
		if("00:00:00".equals(sTime) && (slTimestamps.size() > 0))
		{
			sTime = slTimestamps.get(0);
		}
		
		if(sDate != null && !"".equals(sDate) && !"null".equalsIgnoreCase(sDate))
		{
			sDateTime = sDate + " " + sTime;
		}
		else
		{
			sDateTime = sTime;
		}
	}

	if("".equals(sDateTime))
	{
%>
		<body>
			<table align="center" border="0" cellpadding="1" cellspacing="1" width="90%">
				<tr>
					<th class="label"><%= resourceBundle.getProperty("DataManager.DisplayText.No_Record_Found") %></th>
				</tr>
			</table>
		</body>
<%
		return;
	}
	
	Map<String, String> mRecord = reportDAO.getRecord(sReport, sDateTime);
	Map<String, String> mReportColumns = reportDAO.getReportColumnHeaders(sReport);
	Map<String, String> mReportFormulae = reportDAO.getReportColumnFormulae(sReport);
	Map<String, String[]> mReportRanges = reportDAO.getReportColumnRanges(sReport);	
	StringList slColumns = reportDAO.getReportColumns(sReport);
	
	SimpleDateFormat input = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault());
	SimpleDateFormat output = new java.text.SimpleDateFormat("dd-MMM-yyyy HH:mm", Locale.getDefault());
	SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd-MM-yyyy HH:mm", Locale.getDefault());

	Map<String, String> mUsers = RDMServicesUtils.getUserNames(true);
	
	if(mRecord.isEmpty() || (mRecord.size() == 0))
	{
%>
		<body>
			<table align="center" border="0" cellpadding="1" cellspacing="1" width="90%">
				<tr>
					<th class="label"><%= resourceBundle.getProperty("DataManager.DisplayText.No_Record_Found") %></th>
				</tr>
			</table>
		</body>
<%
		return;
	}
%>

<body>
	<form name="frm" method="post" action="viewRecord.jsp">
		<input type="hidden" id="report" name="report" value="<%= sReport %>">
		<input type="hidden" id="action" name="action" value="<%= sAction %>">
		<input type="hidden" id="date" name="date" value="<%= sDate %>">
		<table align="center" border="0" cellpadding="1" cellspacing="1" width="90%">
			<tr>
				<th class="label" width="30%">
					<%= resourceBundle.getProperty("DataManager.DisplayText.Record_Timestamps") %>
					<select id="time" name="time" onChange="javascript:loadValues()">
<%
					String sTimestamp = null;
					for(int i=0; i<slTimestamps.size(); i++)
					{
						sTimestamp = slTimestamps.get(i);
						sTimestamp = sTimestamp.substring(0, sTimestamp.lastIndexOf(":"));
						if(sDate != null && !"".equals(sDate) && !"null".equalsIgnoreCase(sDate))
						{
%>
							<option value="<%= slTimestamps.get(i) %>" <%= (sTime.equals(slTimestamps.get(i)) ? "selected" : "") %>><%= sTimestamp %></option>
<%
						}
						else
						{
%>
							<option value="<%= slTimestamps.get(i) %>" <%= (sTime.equals(slTimestamps.get(i)) ? "selected" : "") %>><%= output.format(sdf.parse(sTimestamp)) %></option>
<%
						}
					}
%>
					</select>
				</th>
				<th width="70%">&nbsp;</th>
			</tr>
			<tr>
				<th class="label" width="30%"><%= resourceBundle.getProperty("DataManager.DisplayText.Name") %></th>
				<th class="label" width="70%"><%= resourceBundle.getProperty("DataManager.DisplayText.Value") %></th>
			</tr>
<%
		for(int i=0; i<slColumns.size(); i++)
		{
			sColumn = slColumns.get(i);
			sName = mReportColumns.get(sColumn);
			sValue = mRecord.get(sColumn);
			sValue = (sValue == null ? "" : sValue);
			sFormula = mReportFormulae.get(sColumn);			
			sRanges = mReportRanges.get(sColumn);
			
			if(sName.equals(RDMServicesConstants.IS_UPDATED))
			{
				continue;
			}
%>
			<tr>
				<td class="label" width="30%"><%= sName %></td>
				<td class="input" width="70%">
<%
				if((sName.contains("Date") && sName.contains("Time")) || sName.equals(RDMServicesConstants.MODIFIEDON))
				{
					try
					{
						sValue = ((sValue != null && !"".equals(sValue)) ? output.format(input.parse(sValue)) : "&nbsp;");
					}
					catch(Exception e)
					{
						//do nothing
					}
%>
					<%= sValue %>
<%
				}
				else if(sName.equals(RDMServicesConstants.LOGGEDBY) || sName.equals(RDMServicesConstants.MODIFIEDBY) || 
					(sRanges != null && (sRanges[0].equals("#LOGGEDUSER") || sRanges[0].equals("#SYSTEMUSERS"))))
				{
					if(mUsers.containsKey(sValue))
					{
%>
						<%= mUsers.get(sValue) %>&nbsp;(<%= sValue %>)
<%
					}
					else
					{
%>
						<%= sValue %>
<%
					}				
				}
				else if(sFormula != null && !"".equals(sFormula))
				{
%>
					<%= sValue %><br>
					<font style="font-family:sans serif;font-size:10pt;color:#0000FF"><%= ReportDAO.convertFormulaExpr(sReport, sFormula) %></font>
<%
				}
				else if(sRanges != null && sRanges[0].equals("#FILEUPLOAD"))
				{
					String[] saFiles = null;
					String[] saAttachments = sValue.split("\\|");
					for(int z=0; z<saAttachments.length; z++)
					{
						saFiles = saAttachments[z].split("/");
						if(saFiles.length > 1)
						{
%>
							<a href="javascript:viewAttachments('<%= saFiles[0] %>', '<%= saFiles[1] %>')"><%= saFiles[1] %></a><br>
<%
						}
					}
				}
				else
				{
%>				
					<%= sValue %>
<%
				}
%>
				</td>
			</tr>
<%
		}
%>
		</table>
	</form>
</body>
</html>