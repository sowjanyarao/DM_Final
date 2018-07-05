<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<%
	String sController = request.getParameter("controller");
%>

<html>
	<frameset rows="99%,1%" frameborder="0">
		<frame name="content" src="generalParameters.jsp?controller=<%= sController %>" />
		<frame name="hiddenFrame" src="blank.jsp" />
	</frameset>
</html>