<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="java.text.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>
<%@page import="com.client.db.*" %>
<%@page import="com.client.views.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<%
String sRoom = request.getParameter("lstController");
String sStage = request.getParameter("lstStage");
String sFromDate = request.getParameter("start_date");
String sToDate = request.getParameter("end_date");
String showSysLogs = request.getParameter("sysLogs");
String mode = request.getParameter("mode");

String sParams = request.getParameter("params");
sParams = ((sParams == null) ? "" : sParams.trim());
sParams = sParams.replaceAll("\\r", ",").replaceAll("\\n", ",").replaceAll(",,", ",");

String BNo = request.getParameter("BatchNo");
BNo = ((BNo == null) ? "" : BNo.trim());
BNo = BNo.replaceAll("\\s", ",").replaceAll(",,", ",");

String limit = request.getParameter("limit");
int iLimit = 0;
if(limit != null && !"".equals(limit))
{
	iLimit = Integer.parseInt(limit.trim());
}

MapList mlLogs = null;
if(mode != null)
{
	Logs logs = new Logs();
	mlLogs = logs.getLogHistory(sRoom, sStage, BNo, sFromDate, sToDate, sParams, showSysLogs, iLimit);
}

Map<String, String> mUsers = RDMServicesUtils.getUserNames();
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
	<title></title>
	<link type="text/css" href="../styles/dygraph.css" rel="stylesheet" />
	<script language="javascript">
	function exportLogs()
	{
		var url = "../ExportLogs";
		url += "?lstController=<%= sRoom %>";
		url += "&lstStage=<%= sStage %>";
		url += "&BatchNo=<%=  BNo %>"; 
		url += "&start_date=<%= sFromDate %>";
		url += "&end_date=<%= sToDate %>";
		url += "&params=<%= sParams %>";
		url += "&sysLogs=<%= showSysLogs %>";
		url += "&limit=<%= iLimit %>";
		
		parent.frames['results'].document.location.href =  url;
	}
	
	function openController(sCntrl)
	{
		if(sCntrl == "General")
		{
			parent.document.location.href = "generalParamsView.jsp?controller="+sCntrl;
		}
		else
		{
			parent.document.location.href = "singleRoomView.jsp?controller="+sCntrl;
		}
	}
	</script>
</head>

<body>
	<form name="frm">
		<table border="0" cellpadding="0" cellspacing="0" width="<%= winWidth * 0.65 %>">
<%
			if(mlLogs != null && mlLogs.size() > 0)
			{
%>
				<tr>
					<td colspan="9" align="right">
						<input type="button" id="expLogs" name="expLogs" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Export_to_File") %>" onClick="exportLogs()">
					</td>
				</tr>
<%
			}
%>
			<tr>
				<th class="label" width="10%"><%= resourceBundle.getProperty("DataManager.DisplayText.Room") %></th>
				<th class="label" width="5%"><%= resourceBundle.getProperty("DataManager.DisplayText.Stage") %></th>
				<th class="label" width="5%"><%= resourceBundle.getProperty("DataManager.DisplayText.Batch_No") %></th>
				<th class="label" width="15%"><%= resourceBundle.getProperty("DataManager.DisplayText.Logged_By") %></th>
				<th class="label" width="15%"><%= resourceBundle.getProperty("DataManager.DisplayText.Logged_On") %></th>
				<th class="label" width="20%"><%= resourceBundle.getProperty("DataManager.DisplayText.Parameter") %></th>
				<th class="label" width="30%"><%= resourceBundle.getProperty("DataManager.DisplayText.Text") %></th>
			</tr>
<%
			if(mode != null)
			{	
				int iSz = mlLogs.size();
				if(iSz > 0)
				{
					Map<String, String> mLog = null;
					String sRoomId = null;
					String sBatchNo = null;
					String sLoggedBy = null;
					StringList slInactiveCntrl = RDMSession.getInactiveControllers();

					for(int i=0; i<iSz; i++)
					{
						mLog = mlLogs.get(i);
						sRoomId = mLog.get(RDMServicesConstants.ROOM_ID);
						sLoggedBy = mLog.get(RDMServicesConstants.LOGGED_BY);
						if(mUsers.containsKey(sLoggedBy))
						{
							sLoggedBy = mUsers.get(sLoggedBy);
						}
						sBatchNo = mLog.get(RDMServicesConstants.BATCH_NO);
						sBatchNo = (sBatchNo.startsWith("auto_") ? "" : sBatchNo);
%>
						<tr>
<%
							if(slInactiveCntrl.contains(sRoomId))
							{
%>
								<td class="input"><%= sRoomId %></td>
<%
							}
							else
							{
%>
								<td class="input"><a href="javascript:openController('<%= sRoomId %>')"><%= sRoomId %></a></td>
<%
							}
%>
							<td class="input"><%= mLog.get(RDMServicesConstants.STAGE_NUMBER) %></td>
							<td class="input"><%= sBatchNo %></td>
							<td class="input"><%= sLoggedBy %></td>
							<td class="input"><%= mLog.get(RDMServicesConstants.LOGGED_ON) %></td>
							<td class="input"><%= mLog.get(RDMServicesConstants.PARAM_NAME) %></td>
							<td class="input"><%= mLog.get(RDMServicesConstants.LOG_TEXT) %></td>
						</tr>
<%
					}
				}
				else
				{
%>					
					<tr>
						<td class="input" style="text-align:center" colspan="7">
							<%= resourceBundle.getProperty("DataManager.DisplayText.No_Logs") %>
						</td>
					</tr>
<%
				}
			}
			else
			{
%>
				<tr>
						<td class="input" style="text-align:center" colspan="7">
							<%= resourceBundle.getProperty("DataManager.DisplayText.Logs_Search_Msg") %>
						</td>
				</tr>
<%
			}
%>
		</table>
	</form>
</body>
</html>
