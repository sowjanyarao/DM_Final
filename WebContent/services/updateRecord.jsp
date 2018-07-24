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
	<link type="text/css" href="../styles/calendar.css" rel="stylesheet" />
	
	<script language="javaScript" type="text/javascript" src="../scripts/calendar.js"></script>
	
	<style type="text/css">		
		th.txtLabel
		{
			border: solid 1px #ffffff;
			text-align: center;
			background-color: #888888;
			color: #ffffff;
			font-size:14px;
			font-family:Arial,sans-serif;
			font-weight:bold;
		}
		td.txtLabel
		{
			border: solid 1px #ffffff;
			text-align: left;
			background-color: #888888;
			color: #ffffff;
			font-size:12px;
			font-family:Arial,sans-serif;
			font-weight:bold;
		}
	</style>

	<script type="text/javascript">
		//<![CDATA[
		$(document).ready(function(){
			$(".js-example-basic-multiple").select2();
		});
		//]]>
	</script>
	
	<script language="javascript">	
		function submitAction()
		{
			document.frm.enctype = "multipart/form-data";
			document.frm.action = "addReportRecords.jsp";
			document.frm.submit();
		}
		
		function loadValues()
		{
			document.frm.action = "updateRecord.jsp";
			document.frm.submit();
		}

		function getWeights(sColumn, scaleIP, port)
		{
			frames['hidden'].document.location.href = "readWeighingScale.jsp?scaleIP="+scaleIP+"&port="+port+"&attrName="+sColumn;
			
			document.getElementById(sColumn+'_weights').style.display = "none";
			document.getElementById(sColumn+'_loading').style.display = "block";
		}
		
		function toggleDateTime(column)
		{
			var col_dt = document.getElementById(column.name+'_dt');
			var col_hr = document.getElementById(column.name+'_hr');
			var col_min = document.getElementById(column.name+'_min');
			
			if(column.checked)
			{
				col_dt.value = "";
				col_hr.selectedIndex = 0;
				col_min.selectedIndex = 0;
				
				col_dt.disabled = true;
				col_hr.disabled = true;
				col_min.disabled = true;
			}
			else
			{
				col_dt.disabled = false;				
				col_hr.disabled = false;				
				col_min.disabled = false;
			}
		}
		
		function toggleRanges(column, type)
		{
			if(type == "text")
			{
				document.getElementById(column).value = "";
			}
			else if(type == "select")
			{
				document.getElementById(column).selectedIndex = 0;
			}
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
	
	boolean bEmptyCriteria = true;
	String sColumn = "";
	String sName = "";
	String sValue = "";	
	String sUser = "";
	String sFormula = "";
	String sDateTime = "";
	String[] sRanges = null;
	String[] saTime = null;
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
					<th class="txtLabel"><%= resourceBundle.getProperty("DataManager.DisplayText.No_Record_Found") %></th>
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
	StringList slReadOnlyCols = reportDAO.getReadOnlyColumns(sReport);
	StringList slColumns = reportDAO.getReportColumns(sReport);

	Map<String, String> mUsers = RDMServicesUtils.getUserNames(false);
	List<String> lKeys = new ArrayList<String>(mUsers.keySet());
	Collections.sort(lKeys, String.CASE_INSENSITIVE_ORDER);
	
	Map <String, String> mDepartments = RDMServicesUtils.getDepartments();
	List<String> lDepartments = new ArrayList<String>(mDepartments.keySet());
	Collections.sort(lDepartments, String.CASE_INSENSITIVE_ORDER);
	
	String[] HOUR = new String[] {"00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", 
									"12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"};
	String[] MIN = new String[] {"00", "05", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"};
	
	SimpleDateFormat input = new java.text.SimpleDateFormat("dd-MMM-yyyy HH:mm", Locale.getDefault());
	SimpleDateFormat output = new java.text.SimpleDateFormat("dd-MM-yyyy HH:mm", Locale.getDefault());	
	SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.getDefault());

	if(mRecord.isEmpty() || (mRecord.size() == 0))
	{
%>
		<body>
			<table align="center" border="0" cellpadding="1" cellspacing="1" width="90%">
				<tr>
					<th class="txtLabel"><%= resourceBundle.getProperty("DataManager.DisplayText.No_Record_Found") %></th>
				</tr>
			</table>
		</body>
<%
		return;
	}
%>

<body>
	<form name="frm" method="post">
		<input type="hidden" id="report" name="report" value="<%= sReport %>">
		<input type="hidden" id="action" name="action" value="<%= sAction %>">
		<input type="hidden" id="date" name="date" value="<%= sDate %>">
		  <div class="block full"> 
                        
                            <table id="example-datatable" class="table table-responsive table-hover table table-striped table-bordered table-vcenter">
			<tr>
				<td class="input" colspan="2">
					<b><%= resourceBundle.getProperty("DataManager.DisplayText.Record_Timestamps") %></b>
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
							<option value="<%= slTimestamps.get(i) %>" <%= (sTime.equals(slTimestamps.get(i)) ? "selected" : "") %>><%= input.format(output.parse(sTimestamp)) %></option>
<%
						}
					}
%>
					</select>
				</td>
			</tr>
			<tr>
				<th width="30%"><%= resourceBundle.getProperty("DataManager.DisplayText.Name") %></th>
				<th width="70%"><%= resourceBundle.getProperty("DataManager.DisplayText.Value") %></th>
			</tr>
<%
		boolean isUpdated = "TRUE".equals(mRecord.get(RDMServicesConstants.IS_UPDATED));
		Map<String, String> mReport = reportDAO.getReport(u.getUser(), sReport);
		boolean bAllowUpdates = "TRUE".equals(mReport.get(RDMServicesConstants.ALLOW_MULTIPLE_UPDATES));

		if(isUpdated && !bAllowUpdates && !RDMServicesConstants.ROLE_ADMIN.equals(u.getRole()))
		{
%>
			<body>
				<table align="center" border="0" cellpadding="1" cellspacing="1" width="90%">
					<tr>
						<th class="txtLabel"><%= resourceBundle.getProperty("DataManager.DisplayText.Multiple_Updated_NotAllowed") %></th>
					</tr>
				</table>
			</body>
<%
			return;
		}
	
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
				<td width="30%">&nbsp;<%= sName %></td>
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
					<td class="input" width="70%">
						<%= sValue %>
						<input type="hidden" id="<%= sColumn %>" name="<%= sColumn %>" value="<%= sValue %>">
					</td>
<%
				}
				else if(sName.equals(RDMServicesConstants.LOGGEDBY) || sName.equals(RDMServicesConstants.MODIFIEDBY))
				{
%>
					<td class="input" width="70%">
<%
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
%>
						<input type="hidden" id="<%= sColumn %>" name="<%= sColumn %>" value="<%= sValue %>">
					</td>
<%
				}
				else if(sFormula != null && !"".equals(sFormula))
				{
%>
					<td class="input" width="70%">
						<input type="text" id="<%= sColumn %>" name="<%= sColumn %>" value="<%= sValue %>" disabled><br>
						<font style="font-family:sans serif;font-size:10pt;color:#0000FF"><%= ReportDAO.convertFormulaExpr(sReport, sFormula) %></font>
					</td>
<%
				}
				else if(sName.equals(RDMServicesConstants.REMARKS))
				{
%>
					<td class="input" width="70%">
						<textarea id="<%= sColumn %>" name="<%= sColumn %>" cols="30" rows="3"><%= sValue %></textarea>
					</td>
<%
				}
				else if(sRanges != null)
				{
					if(sRanges[0].equals("#DATETIME"))
					{
						if(slReadOnlyCols.contains(sColumn))
						{
%>
							<td class="input">
								<%= sValue %><br>
								<input type="checkbox" id="<%= sColumn %>" name="<%= sColumn %>" value="SystemDateTime">System Date & Time
							</td>
<%
						}
						else
						{
							sDate = ""; saTime = new String[] {"00", "00"};
							if(!"".equals(sValue))
							{
								sDate = output.format(input.parse(sValue));
								saTime = (sDate.substring(sDate.indexOf(" ") + 1)).split(":");
								sDate = sDate.substring(0, sDate.indexOf(" "));
							}
%>
							<td id="<%= sColumn %>_pos" class="input">
								<input type="checkbox" id="<%= sColumn %>" name="<%= sColumn %>" value="SystemDateTime" onChange="javascript:toggleDateTime(this, '<%= sColumn %>')">System Date & Time<br>
								<input type="text" size="10" id="<%= sColumn %>_dt" name="<%= sColumn %>_dt" value="<%= sDate %>" readonly>
								<a href="#" onClick="setYears(2000, 2025);showCalender('<%= sColumn %>_pos', '<%= sColumn %>_dt');"><img src="../images/calender.png"></a>
								<a href="#" onClick="javascript:document.getElementById('<%= sColumn %>_dt').value=''"><img src="../images/clear.png"></a>

								&nbsp;HH:&nbsp;
								<select id="<%= sColumn %>_hr" name="<%= sColumn %>_hr">
<%					
								for(int x=0; x<HOUR.length; x++)
								{
%>
									<option value="<%= HOUR[x] %>" <%= HOUR[x].equals(saTime[0]) ? "selected" : "" %>><%= HOUR[x] %></option>
<%
								}
%>
								</select>
								&nbsp;MM:&nbsp;
								<select id="<%= sColumn %>_min" name="<%= sColumn %>_min">
<%
								boolean bExists = false;
								for(int x=0; x<MIN.length; x++)
								{
									if(MIN[x].equals(saTime[1]))
									{
										bExists = true;
									}
%>
									<option value="<%= MIN[x] %>" <%= MIN[x].equals(saTime[1]) ? "selected" : "" %>><%= MIN[x] %></option>
<%
								}
								if(!bExists)
								{
%>
									<option value="<%= saTime[1] %>" selected><%= saTime[1] %></option>
<%
								}
%>
								</select>
							</td>
<%
						}
					}
					else if(sRanges[0].equals("#LOGGEDUSER"))
					{
%>
						<td class="input">
							<%= mUsers.get(u.getUser()) %>
							<input type="hidden" id="<%= sColumn %>" name="<%= sColumn %>" value="<%= u.getUser() %>">
						</td>
<%
					}
					else if(sRanges[0].equals("#READWEIGHT"))
					{
						String[] saScale = sRanges[1].split(":"); 
%>
						<td class="input">
							<input type="text" id="<%= sColumn %>" name="<%= sColumn %>" value="<%= sValue %>" size="12" readonly>

							<div id="<%= sColumn %>_weights">
								<a href="javascript:getWeights('<%= sColumn %>', '<%= saScale[0] %>', '<%= saScale[1] %>')"><img src="../images/readWeights.jpg" border="0"></a>
							</div>
							<div id="<%= sColumn %>_loading" style="display:none">
								<img src="../images/loading_icon.gif" border="0">
							</div>
						</td>
<%
					}
					else if(sRanges[0].equals("#SYSTEMUSERS"))
					{
%>
						<td class="input">
							<select id="<%= sColumn %>" name="<%= sColumn %>" style="width:250px" class="js-example-basic-multiple" onChange="javascript:toggleRanges('<%= sColumn %>_Manual', 'text')">
								<option value=""><%= resourceBundle.getProperty("DataManager.DisplayText.Please_Select") %></option>
<%
							for(int x=0; x<lKeys.size(); x++)
							{
								sUser = lKeys.get(x);
%>								
								<option value="<%= sUser %>" <%= (sValue.equals(sUser) ? "selected" : "") %>><%= mUsers.get(sUser) %> (<%= sUser %>)</option>
<%
							}
%>
							</select>

							<input type="text" id="<%= sColumn %>_Manual" name="<%= sColumn %>_Manual" value="<%= (mUsers.containsKey(sValue) ? "" : sValue) %>" onKeyPress="javascript:toggleRanges('<%= sColumn %>', 'select')">
						</td>
<%
					}
					else if(sRanges[0].equals("#DEPARTMENTS"))
					{
%>
						<td class="input">
							<select id="<%= sColumn %>" name="<%= sColumn %>">
								<option value=""><%= resourceBundle.getProperty("DataManager.DisplayText.Please_Select") %></option>
<%
							String sDept = "";
							for(int x=0; x<lDepartments.size(); x++)
							{
								sDept = lDepartments.get(x);
%>
								<option  value="<%= sDept %>" <%= (sValue.equals(sDept) ? "selected" : "") %>><%= sDept %></option>
<%
							}
%>
							</select>
						</td>
<%
					}
					else if(sRanges[0].equals("#AUTONAME"))
					{
%>
						<td class="input"><%= sValue %></td>
<%
					}
					else if(sRanges[0].equals("#FILEUPLOAD"))
					{
%>
						<td class="input">
<%
						String sAttachDir = "";
						String[] saFiles = null;
						String[] saAttachments = sValue.split("\\|");
						for(int z=0; z<saAttachments.length; z++)
						{
							saFiles = saAttachments[z].split("/");
							if(saFiles.length > 1)
							{
								sAttachDir = saFiles[0];
%>
								<a href="javascript:viewAttachments('<%= saFiles[0] %>', '<%= saFiles[1] %>')"><%= saFiles[1] %></a><br>
<%
							}
						}
%>
							<input type="hidden" id="AttachDir" name="AttachDir" value="<%= sAttachDir %>">
							<input type="file" id="<%= sColumn %>" name="<%= sColumn %>">
						</td>
<%
					}
					else
					{
%>
						<td class="input">
							<select id="<%= sColumn %>" name="<%= sColumn %>" onChange="javascript:toggleRanges('<%= sColumn %>_Manual', 'text')">
								<option value=""><%= resourceBundle.getProperty("DataManager.DisplayText.Please_Select") %></option>
<%
							boolean bManual = false;
							boolean hasRange = false;
							for(int k=0; k<sRanges.length; k++)
							{
								if("#Manual".equalsIgnoreCase(sRanges[k]))
								{
									bManual = true;
								}
								else
								{
									if(sValue.equals(sRanges[k]))
									{
										hasRange = true;
									}
%>								
									<option value="<%= sRanges[k] %>" <%= (sValue.equals(sRanges[k]) ? "selected" : "") %>><%= sRanges[k] %></option>
<%
								}
							}
%>
							</select>
<%
							if(bManual)
							{
%>
								<input type="text" id="<%= sColumn %>_Manual" name="<%= sColumn %>_Manual" value="<%= (hasRange ? "" : sValue) %>" onKeyPress="javascript:toggleRanges('<%= sColumn %>', 'select')">
<%
							}
%>
						</td>
<%
					}
				}
				else
				{
%>
					<td class="input"><input type="text" id="<%= sColumn %>" name="<%= sColumn %>" value="<%= sValue %>"></td>
<%
				}
			}
%>
			</tr>

			<tr>
				<td colspan="2" align="center">
					<input type="button" class="btn btn-primary" name="btn" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Submit") %>" onClick="javascript:submitAction()">
				</td>
			</tr>
		</table>
		</div>
	</form>
	
	<table id="calenderTable">
		<tbody id="calenderTableHead">
			<tr>
				<td colspan="4" align="center">
					<select onChange="showCalenderBody(createCalender(document.getElementById('selectYear').value, this.selectedIndex, false));" id="selectMonth">
						<option value="0"><%= resourceBundle.getProperty("DataManager.DisplayText.January") %></option>
						<option value="1"><%= resourceBundle.getProperty("DataManager.DisplayText.February") %></option>
						<option value="2"><%= resourceBundle.getProperty("DataManager.DisplayText.March") %></option>
						<option value="3"><%= resourceBundle.getProperty("DataManager.DisplayText.April") %></option>
						<option value="4"><%= resourceBundle.getProperty("DataManager.DisplayText.May") %></option>
						<option value="5"><%= resourceBundle.getProperty("DataManager.DisplayText.June") %></option>
						<option value="6"><%= resourceBundle.getProperty("DataManager.DisplayText.July") %></option>
						<option value="7"><%= resourceBundle.getProperty("DataManager.DisplayText.August") %></option>
						<option value="8"><%= resourceBundle.getProperty("DataManager.DisplayText.September") %></option>
						<option value="9"><%= resourceBundle.getProperty("DataManager.DisplayText.October") %></option>
						<option value="10"><%= resourceBundle.getProperty("DataManager.DisplayText.November") %></option>
						<option value="11"><%= resourceBundle.getProperty("DataManager.DisplayText.December") %></option>

					</select>
				</td>
				<td colspan="2" align="center">
					<select onChange="showCalenderBody(createCalender(this.value, document.getElementById('selectMonth').selectedIndex, false));" id="selectYear">
					</select>
				</td>
				<td align="center">
					<a href="#" onClick="closeCalender();"><font color="#003333" size="2">X</font></a>
				</td>
			</tr>
		</tbody>
		<tbody id="calenderTableDays">
			<tr style="">
				<td><%= resourceBundle.getProperty("DataManager.DisplayText.Sunday") %></td>
				<td><%= resourceBundle.getProperty("DataManager.DisplayText.Monday") %></td>
				<td><%= resourceBundle.getProperty("DataManager.DisplayText.Tuesday") %></td>
				<td><%= resourceBundle.getProperty("DataManager.DisplayText.Wednesday") %></td>
				<td><%= resourceBundle.getProperty("DataManager.DisplayText.Thursday") %></td>
				<td><%= resourceBundle.getProperty("DataManager.DisplayText.Friday") %></td>
				<td><%= resourceBundle.getProperty("DataManager.DisplayText.Saturday") %></td>
			</tr>
		</tbody>
		<tbody id="calender"></tbody>
	</table>
	
	<iframe name="hidden" src="" frameBorder="0" width="0px" height="0px">
</body>
</html>