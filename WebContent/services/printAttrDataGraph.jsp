<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>
<%@page import="java.text.*" %>
<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>
<%@page import="com.client.views.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<%
String sRoom = request.getParameter("room");
%>

<html>
	<head>
		<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE6; IE=EmulateIE7; IE=EmulateIE8; IE=EmulateIE9">
		<title></title>
		<link type="text/css" href="../styles/dygraph.css" rel="stylesheet" />
		<script type="text/javascript" src="../scripts/excanvas.js"></script>
		<script type="text/javascript" src="../scripts/dygraph-combined.js"></script>
		<script type="text/javascript" src="../scripts/dygraph-extra.js"></script>		
	</head>

	<body>
		<table>
			<tr>				
				<td style="font-family:Arial; font-size:0.8em; font-weight:bold; color:#0000FF; text-align:center">
					<%= sRoom %>
				</td>
			</tr>
			<tr>
				<td>
					<img id="graphImg">
				</td>
			</tr>
		</table>
		
		<script type="text/javascript">

			function printImg()
			{
				var graphImg = document.getElementById('graphImg');
				Dygraph.Export.asPNG(parent.g, graphImg);
				window.print();
			}
			
			setTimeout("printImg()", 100);
		</script>
	</body>
</html>