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
String BNo = request.getParameter("BatchNo");
String[] saAlarmTypes = request.getParameterValues("lstTypes");
String sFromDate = request.getParameter("start_date");
String sToDate = request.getParameter("end_date");
String showOpenAlarms = request.getParameter("openAlarms");
String mode = request.getParameter("mode");
MapList mlAlarms = null;

StringBuilder sbTypes = new StringBuilder();
if(saAlarmTypes != null)
{
	for(int i=0; i<saAlarmTypes.length; i++)
	{
		if(i > 0)
		{
			sbTypes.append(",");
		}
		sbTypes.append(saAlarmTypes[i]);
	}
}

BNo = ((BNo == null) ? "" : BNo.trim());
BNo = BNo.replaceAll("\\s", ",").replaceAll(",,", ",");

String limit = request.getParameter("limit");
int iLimit = 0;
if(limit != null && !"".equals(limit))
{
	iLimit = Integer.parseInt(limit.trim());
}

if(mode != null)
{	
	Alarms alarms = new Alarms();
	mlAlarms = alarms.getAlarmLogHistory(sRoom, sStage, BNo, sbTypes.toString(), sFromDate, sToDate, showOpenAlarms, iLimit);
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
	function exportAlarms()
	{
		var url = "../ExportAlarms";
		url += "?lstController=<%= sRoom %>";
		url += "&lstTypes=<%= sbTypes.toString() %>";
		url += "&lstStage=<%= sStage %>";
		url += "&BatchNo=<%=  BNo %>"; 
		url += "&start_date=<%= sFromDate %>";
		url += "&end_date=<%= sToDate %>";
		url += "&openAlarms=<%= showOpenAlarms %>";
		url += "&limit=<%= iLimit %>";

		parent.frames['hidden'].document.location.href =  url;
	}
	
	function muteAlarm(roomId, serialId)
	{
		parent.frames['hidden'].document.location.href = "alarmClear.jsp?roomId="+roomId+"&serialId="+serialId+"&mute=Yes";
	}
	
	function closeAlarm(roomId, serialId)
	{
		parent.frames['hidden'].document.location.href = "alarmClear.jsp?roomId="+roomId+"&serialId="+serialId+"&clearAll=No";
	}
	
	function closeAll()
	{
		parent.frames['hidden'].document.location.href = "alarmClear.jsp?roomId=<%= sRoom %>&stage=<%= sStage %>&batch=<%= BNo %>&types=<%= sbTypes.toString() %>&fromDt=<%= sFromDate %>&toDt=<%= sToDate %>&clearAll=Yes";
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
	<div class="table table-responsive table-hover">
		
        <table id="datatable" class="table table-striped table-bordered table-vcenter">
<%
		if(mlAlarms != null && mlAlarms.size() > 0)
		{
			if(RDMServicesConstants.ROLE_ADMIN.equals(u.getRole()))
			{
%>	
				<tr>
					<td colspan="5" align="left">
						<input type="button" id="clearAlarms" name="clearAlarms" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Close_All_Alarms") %>" onClick="closeAll()">
					</td>
					<td>
						&nbsp;
					</td>
					<td colspan="5" align="right">
						<input type="button" id="expAlarms" name="expAlarms" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Export_to_File") %>" onClick="exportAlarms()">
					</td>
				</tr>
<%
			}
			else
			{
%>
				<tr>
					<td colspan="11" align="right">
						<input type="button" id="expAlarms" name="expAlarms" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Export_to_File") %>" onClick="exportAlarms()">
					</td>
				</tr>
<%
			}
		}
%>			
		<tr>
			<th  width="5%"><%= resourceBundle.getProperty("DataManager.DisplayText.Room_No") %></th>
			<th  width="5%"><%= resourceBundle.getProperty("DataManager.DisplayText.Stage") %></th>
			<th  width="8%"><%= resourceBundle.getProperty("DataManager.DisplayText.Batch_No") %></th>
			<th  width="5%"><%= resourceBundle.getProperty("DataManager.DisplayText.Serial_No") %></th>
			<th  width="17%"><%= resourceBundle.getProperty("DataManager.DisplayText.Description") %></th>
			<th  width="12%"><%= resourceBundle.getProperty("DataManager.DisplayText.Occurred_On") %></th>
			<th  width="12%"><%= resourceBundle.getProperty("DataManager.DisplayText.Cleared_On") %></th>
			<th  width="14%"><%= resourceBundle.getProperty("DataManager.DisplayText.Accepted_By") %>
			&nbsp;<br/><%= resourceBundle.getProperty("DataManager.DisplayText.Muted_By") %></th>
			<th  width="12%"><%= resourceBundle.getProperty("DataManager.DisplayText.Last_Notified") %></th>
			<th  width="5%"><%= resourceBundle.getProperty("DataManager.DisplayText.Close_Alarm") %></th>
			<th  width="5%"><%= resourceBundle.getProperty("DataManager.DisplayText.Mute_Alarm") %></th>
		</tr>
<%
		if(mode != null)
		{
			int iSz = mlAlarms.size();
			if(iSz > 0)
			{
				Map<String, String> mLog = null;
				String sRoomId = null;
				String sSerialId = null;
				String sClearedOn = null;
				String sAcceptedBy = null;
				String sMutedBy = null;
				String sBatchNo = null;
				String sLastNotified = null;
				StringList slInactiveCntrl = RDMSession.getInactiveControllers();

				for(int i=0; i<iSz; i++)
				{
					mLog = mlAlarms.get(i);
					sRoomId = mLog.get(RDMServicesConstants.ROOM_ID);
					sSerialId = mLog.get(RDMServicesConstants.SERIAL_ID);
					sClearedOn = mLog.get(RDMServicesConstants.CLEARED_ON);
					sAcceptedBy = mLog.get(RDMServicesConstants.ACCEPTED_BY);
					if(mUsers.containsKey(sAcceptedBy))
					{
						sAcceptedBy = mUsers.get(sAcceptedBy);
					}
					sMutedBy = mLog.get(RDMServicesConstants.MUTED_BY);
					if(mUsers.containsKey(sMutedBy))
					{
						sMutedBy = mUsers.get(sMutedBy);
					}
					sLastNotified = mLog.get(RDMServicesConstants.LAST_NOTIFIED);
					if(!"".equals(sLastNotified))
					{
						if(!"0".equals(mLog.get(RDMServicesConstants.LEVEL3_ATTEMPTS)))
						{
							sLastNotified = sLastNotified + "<br>(Level 3)";
						}
						else if(!"0".equals(mLog.get(RDMServicesConstants.LEVEL2_ATTEMPTS)))
						{
							sLastNotified = sLastNotified + "<br>(Level 2)";
						}
						else if(!"0".equals(mLog.get(RDMServicesConstants.LEVEL1_ATTEMPTS)))
						{
							sLastNotified = sLastNotified + "<br>(Level 1)";
						}
					}
					sBatchNo = mLog.get(RDMServicesConstants.BATCH_NO);
					sBatchNo = (sBatchNo.startsWith("auto_") ? "" : sBatchNo);
%>
					<tr>
<%
						if(slInactiveCntrl.contains(sRoomId))
						{
%>
							<td ><%= sRoomId %></td>
<%
						}
						else
						{
%>
							<td ><a href="javascript:openController('<%= sRoomId %>')"><%= sRoomId %></a></td>
<%
						}
%>						
						<td ><%= mLog.get(RDMServicesConstants.STAGE_NUMBER) %></td>
						<td ><%= sBatchNo %></td>
						<td ><%= sSerialId %></td>
						<td ><%= mLog.get(RDMServicesConstants.ALARM_TEXT) %></td>
						<td ><%= mLog.get(RDMServicesConstants.OCCURED_ON) %></td>
						<td ><%= sClearedOn %></td>
						<td ><%= (!"".equals(sAcceptedBy) ? sAcceptedBy : sMutedBy) %></td>
						<td ><%= sLastNotified %></td>
<%
						if("".equals(sClearedOn))
						{
%>
							<td  style="text-align:center"><a href="javascript:closeAlarm('<%= sRoomId %>', '<%= sSerialId %>')"><img border="0" src="../images/delete.png" alt="<%= resourceBundle.getProperty("DataManager.DisplayText.Delete") %>"></a></td>
<%
						}
						else
						{
%>
							<td >&nbsp;</td>
<%
						}

						if("TRUE".equals(mLog.get(RDMServicesConstants.NOTIFY_ALARM)) && "".equals(sMutedBy) && "".equals(sClearedOn))
						{
%>
							<td  style="text-align:center"><a href="javascript:muteAlarm('<%= sRoomId %>', '<%= sSerialId %>')"><img border="0" src="../images/mute.png" alt="<%= resourceBundle.getProperty("DataManager.DisplayText.Mute") %>"></a></td>
<%
						}
						else
						{
%>
							<td >&nbsp;</td>
<%
						}
%>
						
					</tr>
<%
				}
			}
			else
			{
%>					
				<tr>
					<td  style="text-align:center" colspan="11">
						<%= resourceBundle.getProperty("DataManager.DisplayText.No_Alarms") %>
					</td>
				</tr>
<%
			}
		}
		else
		{
%>
			<tr>
					<td  style="text-align:center" colspan="11">
						<%= resourceBundle.getProperty("DataManager.DisplayText.Alarms_Search_Msg") %>
					</td>
			</tr>
<%
		}
%>
	</table>
	</div>
</body>
</html>
