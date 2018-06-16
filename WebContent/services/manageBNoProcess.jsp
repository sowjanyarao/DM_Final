<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<html>
<%
	String sAction = request.getParameter("mode");
	String sErr = "";
	
	try
	{
		String sRoomId = request.getParameter("roomId");
		String sBatchNo = request.getParameter("BNo");

		if("add".equals(sAction))
		{		
			RDMServicesUtils.addBatchNo(sRoomId, sBatchNo);
		}
		else if("edit".equals(sAction))
		{
			RDMServicesUtils.updateBatchNo(sRoomId, sBatchNo);
		}
		else if("close".equals(sAction))
		{
			RDMServicesUtils.closeBatchNo(sRoomId);
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
		var mode = "<%= sAction %>";
		if(sErr != "")
		{
			alert("Error: "+sErr);
		}
		else
		{
			alert("<%= resourceBundle.getProperty("DataManager.DisplayText.BatchNo_Updated") %>");
			//parent.frames['content'].document.location.href = parent.frames['content'].document.location.href;
			parent.location.href = parent.location.href;
		}
		
	</script>
</html>