<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<html>
	<frameset cols="30%,70%" frameborder="0">
		<frameset rows="40%,60%" frameborder="0">
			<frame name="filter" src="viewReportsFilter.jsp" />
			<frame name="search" src="blank.jsp" />
		</frameset>
		<frame name="content" src="blank.jsp" />
	</frameset>
</html>