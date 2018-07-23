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
	String sController = request.getParameter("controller");
	String sEstYield = request.getParameter("EstYield");
	String sActYield = request.getParameter("ActYield");
	String sComments = request.getParameter("comments");
	String sDate = request.getParameter("date");
	String sMode = request.getParameter("mode");
	String sUser = u.getUser();
	String sErr = "";
	sActYield = ((sActYield == null || "".equals(sActYield)) ? "0.0" : sActYield);

	try
	{
		Yields yields = new Yields();
		if("add".equals(sMode) || "edit".equals(sMode))
		{
			yields.updateYield(sController, sEstYield, sActYield, sDate, sUser, sComments);
		}
		else if("delete".equals(sMode))
		{
			yields.deleteYield(sUser, sController, sDate);
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
		var mode = "<%= sMode %>";
		if(sErr != "")
		{
			alert("Error: "+sErr);
			history.back(-1);
		}
		else
		{
			if(mode == "add")
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Yield_Added") %>");
				parent.frames['filter'].showYields();
			}
			else
			{				
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Yield_Deleted") %>");
				parent.frames['filter'].showYields();
			}
		}
	</script>

</html>