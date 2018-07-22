<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
	<title></title>
	<link type="text/css" href="../styles/dygraph.css" rel="stylesheet" />
	<script language="javascript">
		function muteAlarm(roomId, serialId)
		{
			document.location.href = "alarmClear.jsp?roomId="+roomId+"&serialId="+serialId+"&mute=Yes&refresh=true";
		}
		
		function closeAlarm(roomId, serialId)
		{
			document.location.href = "alarmClear.jsp?roomId="+roomId+"&serialId="+serialId+"&clearAll=No&refresh=true";
		}
	</script>
</head>

<body>
		<table border="1" cellpadding="0" cellspacing="0">
			<tr>
				<th width="10%" class="label"><%= resourceBundle.getProperty("DataManager.DisplayText.Serial_No") %></th>
				<th width="30%" class="label"><%= resourceBundle.getProperty("DataManager.DisplayText.Description") %></th>
				<th width="17%" class="label"><%= resourceBundle.getProperty("DataManager.DisplayText.Occurred_On") %></th>
				<th width="17%" class="label"><%= resourceBundle.getProperty("DataManager.DisplayText.Muted_By") %></th>
                <th width="17%" class="label"><%= resourceBundle.getProperty("DataManager.DisplayText.Last_Notified") %>
				<th width="5%" class="label"><%= resourceBundle.getProperty("DataManager.DisplayText.Close_Alarm") %></th>
				<th width="5%" class="label"><%= resourceBundle.getProperty("DataManager.DisplayText.Mute_Alarm") %></th>
			</tr>
<%
			String sRoomId = request.getParameter("controller");
			PLCServices client = new PLCServices(RDMSession, sRoomId);
			MapList mlAlarms = client.getAlarmList();
			Map<String, String> mUsers = RDMServicesUtils.getUserNames();
			Map<String, String> mAlarm = null;
			String sSerialId = null;
			String sAcceptedBy = null;
			String sMutedBy = null;
			String sLastNotified = null;
			
			int iSz = mlAlarms.size();
			if(iSz > 0)
			{
				for(int m=0; m<iSz; m++)
				{
					mAlarm = mlAlarms.get(m);
					sSerialId = mAlarm.get(RDMServicesConstants.SERIAL_ID);
					sMutedBy = mAlarm.get(RDMServicesConstants.MUTED_BY);
					if(mUsers.containsKey(sMutedBy))
					{
						sMutedBy = mUsers.get(sMutedBy);
					}
					sLastNotified = mAlarm.get(RDMServicesConstants.LAST_NOTIFIED);
					if(!"".equals(sLastNotified))
					{
						if(!"0".equals(mAlarm.get(RDMServicesConstants.LEVEL3_ATTEMPTS)))
						{
							sLastNotified = sLastNotified + "<br>(Level 3)";
						}
						else if(!"0".equals(mAlarm.get(RDMServicesConstants.LEVEL2_ATTEMPTS)))
						{
							sLastNotified = sLastNotified + "<br>(Level 2)";
						}
						else if(!"0".equals(mAlarm.get(RDMServicesConstants.LEVEL1_ATTEMPTS)))
						{
							sLastNotified = sLastNotified + "<br>(Level 1)";
						}
					}
%>
					<tr>
						<td width="10%" class="text"><%= sSerialId %></td>
						<td width="30%" class="text"><%= mAlarm.get(RDMServicesConstants.ALARM_TEXT) %></td>
						<td width="17%" class="text"><%= mAlarm.get(RDMServicesConstants.OCCURED_ON) %></td>
						<td width="17%" class="text"><%= sMutedBy %></td>
                        <td width="17%" class="text"><%= sLastNotified %></td>
						<td width="5%" class="text" style="text-align:center"><a href="javascript:closeAlarm('<%= sRoomId %>', '<%= sSerialId %>')"><img border="0" src="../images/delete.png" alt="<%= resourceBundle.getProperty("DataManager.DisplayText.Delete") %>"></a></td>
<%
						if("TRUE".equals(mAlarm.get(RDMServicesConstants.NOTIFY_ALARM)) && "".equals(sMutedBy))
						{
%>
							<td width="5%" class="text" style="text-align:center"><a href="javascript:muteAlarm('<%= sRoomId %>', '<%= sSerialId %>')"><img border="0" src="../images/mute.png" alt="<%= resourceBundle.getProperty("DataManager.DisplayText.Mute") %>"></a></td>
<%
						}
						else
						{
%>
							<td width="5%" class="text">&nbsp;</td>
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
					<td colspan="7" align="center"><%= resourceBundle.getProperty("DataManager.DisplayText.No_Open_Alarms") %></td>
				</tr>
<%
			}
%>
		</table>
	
</body>
</html>	