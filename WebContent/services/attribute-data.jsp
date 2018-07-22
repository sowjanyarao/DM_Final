<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<html>

	<div style="width:100%;" >
	<div style="float:left;width:100%;overflow: hidden; position:relative;" >
			<iframe name="select" src="attrDataGraphSelection.jsp" align="middle" frameBorder="0" width="100%" height="<%= winHeight * 0.9 %>px"/>
	</div>
	</div>
</html>