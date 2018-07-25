<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>
<%@page import="java.io.*" %>
<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>
<%@page import="org.apache.commons.fileupload.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<html>
<%
	String sErr = "";
	try
	{
		String sUserId = request.getParameter("userId");
		String sOID = request.getParameter("OID");
		String sInDt = request.getParameter("log_in");
		String sInHH = request.getParameter("in_hr");
		String sInMM = request.getParameter("in_min"); 
		String sOutDt = request.getParameter("log_out");
		String sOutHH = request.getParameter("out_hr");
		String sOutMM = request.getParameter("out_min");
		String shift = request.getParameter("shift");
		String sMode = request.getParameter("mode");
		
		if("delete".equals(sMode))
		{
			RDMServicesUtils.deleteTimesheet(sUserId, sOID);
		}
		else
		{
			SimpleDateFormat sdfin = new SimpleDateFormat("dd-MM-yyyy", Locale.ENGLISH);
			SimpleDateFormat sdfout = new SimpleDateFormat("yyyy-MM-dd", Locale.ENGLISH);

			String sInTime = "";
			if(!("".equals(sInDt) || "".equals(sInHH) || "".equals(sInMM)))
			{
				sInTime = sdfout.format(sdfin.parse(sInDt))+" "+sInHH+":"+sInMM;
			}
			
			String sOutTime = "";
			if(!("".equals(sOutDt) || "".equals(sOutHH) || "".equals(sOutMM)))
			{
				sOutTime = sdfout.format(sdfin.parse(sOutDt))+" "+sOutHH+":"+sOutMM;
			}

			if(!"".equals(sInTime) || !"".equals(sOutTime))
			{
				RDMServicesUtils.updateTimesheet(sUserId, sOID, sInTime, sOutTime, shift);
			}
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
			history.back(-1);
		}
		else
		{	
			try
			{
				top.opener.parent.searchUsers();
			}
			catch(e)
			{
				top.opener.document.location.href = top.opener.document.location.href;
			}
			
			top.window.close();
		}
		
	</script>
</html>
