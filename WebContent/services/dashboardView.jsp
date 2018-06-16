<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<%
	String sCntrlType = request.getParameter("cntrlType");
%>

<html>
	<frameset rows="99%,1%" frameborder="0">
		<frame name="content" src="roomView.jsp?selRange=0&cntrlType=<%= sCntrlType %>" />
		<frame name="hiddenFrame" src="blank.jsp" />
	</frameset>
</html>