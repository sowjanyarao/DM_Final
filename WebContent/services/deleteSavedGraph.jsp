<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="com.client.graphs.*" %>
<%@include file="commonUtils.jsp" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />

<%
String sSavedGraph = request.getParameter("savedGraph");
u.deleteSavedGraph(sSavedGraph);
%>

<html>
	<head>
		<script language="javascript">
			//alert("<%= sSavedGraph %> deleted successfully");
			parent.frames['select'].location.href = parent.frames['select'].location.href;
		</script>
	</head>
</html>