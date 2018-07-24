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
	<meta name="description" content="Datamanager"/>
    <meta name="author" content="Inventaa"/>
    <meta name="robots" content="noindex, nofollow"/>
    <meta name="viewport" content="width=device-width,initial-scale=1.0,user-scalable=0"/>

    <!-- Icons -->
    <!-- The following icons can be replaced with your own, they are used by desktop and mobile browsers -->
    <link rel="shortcut icon" href="../img/fav-icon.jpg"/>
    <!-- END Icons -->

    <!-- Stylesheets -->
    <!-- Bootstrap is included in its original form, unaltered -->
    <link rel="stylesheet" href="../css/bootstrap.min.css"/>

    <!-- Related styles of various icon packs and plugins -->
    <link rel="stylesheet" href="../css/plugins.css"/>

    <!-- The main stylesheet of this template. All Bootstrap overwrites are defined in here -->
    <link rel="stylesheet" href="../css/main.css"/>

    <!-- Include a specific file here from ../css/themes/ folder to alter the default theme of the template -->

    <!-- The themes stylesheet of this template (for using specific theme color in individual elements - must included last) -->
    <link rel="stylesheet" href="../css/themes.css"/>
    <!-- END Stylesheets -->
    <link type="text/css" href="../styles/calendar.css" rel="stylesheet" />
    
    <!-- Modernizr (browser feature detection library) -->
    <script src="../js/vendor/modernizr-3.3.1.min.js"/>
  
	<script language="javaScript" type="text/javascript" src="../scripts/calendar.js"></script>
	<script src="../js/vendor/jquery-2.2.4.min.js"></script>
    <script src="../js/vendor/bootstrap.min.js"></script>
    <script src="../js/plugins.js"></script>
    <script src="../js/app.js"></script>
    <!-- Load and execute javascript code used only in this page -->
    <script src="../js/pages/readyDashboard.js"></script>
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
		<div class="table table-responsive table-hover">
		<%
			if(mlLogs != null && mlLogs.size() > 0)
			{
%>
				<div class="row pad_bot"  style="padding-left:10px">
						<input type="button" class="btn btn-effect-ripple btn-primary" id="expLogs" name="expLogs"  value="<%= resourceBundle.getProperty("DataManager.DisplayText.Export_to_File") %>" onClick="exportLogs()"/>
					
				</div>
<%
			}
%>
		
        <table id="datatable" class="table table-striped table-bordered table-vcenter">
		<thead>
			<tr>
				<th width="10%"><%= resourceBundle.getProperty("DataManager.DisplayText.Room") %></th>
				<th width="5%"><%= resourceBundle.getProperty("DataManager.DisplayText.Stage") %></th>
				<th width="5%"><%= resourceBundle.getProperty("DataManager.DisplayText.Batch_No") %></th>
				<th width="15%"><%= resourceBundle.getProperty("DataManager.DisplayText.Logged_By") %></th>
				<th width="15%"><%= resourceBundle.getProperty("DataManager.DisplayText.Logged_On") %></th>
				<th width="20%"><%= resourceBundle.getProperty("DataManager.DisplayText.Parameter") %></th>
				<th width="30%"><%= resourceBundle.getProperty("DataManager.DisplayText.Text") %></th>
			</tr>
		</thead>
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
								<td><%= sRoomId %></td>
<%
							}
							else
							{
%>
								<td><a href="javascript:openController('<%= sRoomId %>')"><%= sRoomId %></a></td>
<%
							}
%>
							<td><%= mLog.get(RDMServicesConstants.STAGE_NUMBER) %></td>
							<td><%= sBatchNo %></td>
							<td><%= sLoggedBy %></td>
							<td><%= mLog.get(RDMServicesConstants.LOGGED_ON) %></td>
							<td><%= mLog.get(RDMServicesConstants.PARAM_NAME) %></td>
							<td><%= mLog.get(RDMServicesConstants.LOG_TEXT) %></td>
						</tr>
<%
					}
				}
				else
				{
%>					
					<tr>
						<td style="text-align:center" colspan="7">
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
						<td style="text-align:center" colspan="7">
							<%= resourceBundle.getProperty("DataManager.DisplayText.Logs_Search_Msg") %>
						</td>
				</tr>
<%
			}
%>
		</table>
		</div>
	</form>
</body>
</html>
