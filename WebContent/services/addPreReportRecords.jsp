<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.io.*" %>
<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>
<%@page import="com.client.reports.*" %>
<%@page import="org.apache.commons.fileupload.FileItem" %>
<%@page import="org.apache.commons.fileupload.FileItemFactory" %>
<%@page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<%
	boolean bErr = false;
	String sErr = "";
	String sAction = "";
	String sReport = "";
	String sDate = "";
	String sReportRecords = "";
	Map<String, String> mRecord = new HashMap<String, String>();

	try
	{
		FileItem item = null;
		String sField = "";
		boolean isMultipart = ServletFileUpload.isMultipartContent(request);
		if (isMultipart)
		{
			FileItemFactory factory = new DiskFileItemFactory();
			ServletFileUpload upload = new ServletFileUpload(factory);
		
			List<FileItem> fields = upload.parseRequest(request);
			Iterator<FileItem> itr = fields.iterator();
			while (itr.hasNext()) 
			{
				item = (FileItem) itr.next();
				if (item.isFormField())
				{
					sField = item.getFieldName();
					if("report".equals(sField))
					{
						sReport = item.getString().split("\\|")[0];
					}
					else if("selAction".equals(sField))
					{
						sAction = item.getString();
					}
					else if("mod_date".equals(sField))
					{
						sDate = item.getString();
					}
				}
				else
				{
					sReportRecords = item.getName();
					if(sReportRecords != null && !"".equals(sReportRecords))
					{
						File reportsDir = new File(getServletContext().getRealPath("/reports/records")); 
						File reportRecords = new File(reportsDir, sReportRecords); 
						if(reportRecords.exists())
						{
							reportRecords.delete();
						}
						reportRecords.createNewFile();
						item.write(reportRecords);
					}
				}
			}
		}
	}
	catch(Exception e)
	{
		bErr = true;
		sErr = e.getMessage();
	}

	String sURL = "";
	ReportDAO reportDAO = new ReportDAO();
	Map<String, String> mReport = reportDAO.getReport(u.getUser(), sReport);

	String[] saWriteAccess = mReport.get(RDMServicesConstants.WRITE_ACCESS).split("\\|");
	StringList slWriteAccess = new StringList();
	slWriteAccess.addAll(saWriteAccess);
	
	String[] saWriteDept = mReport.get(RDMServicesConstants.WRITE_DEPT).split("\\|");
	StringList slWriteDept = new StringList();
	slWriteDept.addAll(saWriteDept);

	StringList slUserDept = new StringList();
	slUserDept.add(u.getDepartment());
	slUserDept.addAll(u.getSecondaryDepartments());
	if(slWriteAccess.contains(u.getRole()) && (slUserDept.isEmpty() || slWriteDept.contains(slUserDept)))
	{
		if("addRecord".equals(sAction))
		{
			sURL = "addRecord.jsp";
		}
		else if("addMultiRecords".equals(sAction))
		{
			sURL = "addReportRecords.jsp";
		}
	}
	else
	{
		bErr = true;
		sErr = resourceBundle.getProperty("DataManager.DisplayText.No_Add_Record_Access");
	}
%>
<html>
	<head>
		<link type="text/css" href="../styles/dygraph.css" rel="stylesheet" />
	</head>
	<body>
<%
	if(bErr)
	{
%>
		<table width="80%">
			<tr>
				<th><%= resourceBundle.getProperty("DataManager.DisplayText.Add_Record_Failed") %></th>
			</tr>
			<tr>
				<td class="text"><font color="red"><%= sErr %></font></td>
			</tr>
		</table>
		<iframe name="results" src="showProductivityGraph.jsp" align="middle" frameBorder="0" width="100%" height="<%= winHeight * 0.8 %>px">
<%
	}
	else
	{	
%>
		<form name="frm" method="post" action="<%= sURL %>">
			<input type="hidden" id="report" name="report" value="<%= sReport %>">
			<input type="hidden" id="action" name="action" value="<%= sAction %>">
			<input type="hidden" id="recordFile" name="recordFile" value="<%= sReportRecords %>">
			<input type="hidden" id="date" name="date" value="<%= sDate %>">
		</form>
		<script language="javascript">
			document.frm.submit();
		</script>
<%
	}
%>
	</body>
</html>