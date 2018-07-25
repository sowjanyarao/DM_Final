<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>
<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>
<%@page import="com.client.views.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<html>
<%
	String sRoomId = request.getParameter("roomId");
	String sSerialId = request.getParameter("serialId");
	String sStage = request.getParameter("stage");
	String sBatchNo = request.getParameter("batch");
	String sTypes = request.getParameter("types");
	String sFromDt = request.getParameter("fromDt");
	String sToDt = request.getParameter("toDt");
	String sClearAll = request.getParameter("clearAll");
	String sMute = request.getParameter("mute");
	String sRefresh = request.getParameter("refresh");
	String sUser = u.getUser();
	String sErr = "";
	try
	{
		if("Yes".equals(sMute))
		{
			Alarms alarms = new Alarms();
			alarms.muteOpenAlarm(sUser, sRoomId, sSerialId);
		}
		else
		{
			Map<String, String> mInfo = new HashMap<String, String>();
			mInfo.put("RoomId", sRoomId);
			mInfo.put("SerialId", sSerialId);
			mInfo.put("Stage", sStage);
			mInfo.put("Batch", sBatchNo);
			mInfo.put("Types", sTypes);
			mInfo.put("FromDate", sFromDt);
			mInfo.put("ToDate", sToDt);		
			
			Alarms alarms = new Alarms();
			alarms.clearOpenAlarms(sUser, sClearAll, mInfo);
		}
	}
	catch(Exception e)
	{
		sErr = e.getMessage();
		sErr = (sErr == null ? "null" : sErr.replaceAll("\"", "'").replaceAll("\r", " ").replaceAll("\n", " "));
	}
%>

	<script>
		var sErr = "<%= sErr %>";
		if(sErr != "")
		{
			alert("Error: "+sErr);
		}
		else
		{
<%
			if("true".equals(sRefresh))
			{
%>
				document.location.href = "showAlarms.jsp?controller=<%= sRoomId %>";
<%
			}
			else
			{
%>
				parent.showAlarms();
<%
			}
%>
		}
	</script>
</html>