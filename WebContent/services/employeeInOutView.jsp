<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<html>
	<frameset rows="99%,1%" frameborder="0">
		<frameset rows="7%,93%" frameborder="0">
			<frame name="filter" src="employeeInOutFilter.jsp" />
			<frame name="results" src="employeeInOutResults.jsp" />
		</frameset>
		<frame name="hiddenFrame" src="blank.jsp" />
	</frameset>
</html>