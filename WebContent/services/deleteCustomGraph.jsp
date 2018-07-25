<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="com.client.views.*" %>
<%@include file="commonUtils.jsp" %>
 
<%
String sGraphFile = request.getParameter("GraphFile");
AttrDataGraph graph = new AttrDataGraph();
graph.deleteCustomGraph(sGraphFile);
%>

<html>
	<head>
		<script language="javascript">
			//alert("<%= sGraphFile %> deleted successfully");
			parent.frames['custom'].location.href = parent.frames['custom'].location.href;
		</script>
	</head>
</html>