<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>
<%@include file="commonUtils.jsp" %>
 
<%
String sGraphFile = request.getParameter("GraphFile");
%>

<html>
  <head>
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE6; IE=EmulateIE7; IE=EmulateIE8; IE=EmulateIE9">
    <title></title>
    <script type="text/javascript" src="../scripts/excanvas.js"></script>
    <script type="text/javascript" src="../scripts/dygraph-combined.js"></script>
  </head>

	<body>
		<table>
			<tr>
				<td>
					<div id="graphdiv" style="width:<%= winWidth * 0.75 %>px; height:<%= winHeight * 0.85 %>px;"></div>
				</td>
				<td valign="top">
					<div id="status" style="width:150px; font-size:0.8em; padding-top:5px;"></div>
				</td>
			</tr>
		</table>
		
		<script type="text/javascript">			
			var g = new Dygraph(document.getElementById("graphdiv"),
				'../graphs/CustomData/<%= sGraphFile %>',				
				{
					labelsDiv: document.getElementById('status'),					
					labelsSeparateLines: true,
					labelsKMB: true,
					legend: 'always',
					colors: ["Blue",
							"Brown",
							"Pink",
							"Green",
							"Magenta",
							"Red",
							"Orange",
							"Yellow",
							"Grey",
							"Purple"],
					width: 640,
					height: 480,
					title: '<%= resourceBundle.getProperty("DataManager.DisplayText.Custom_Data_Graph") %>',
					xlabel: '<%= resourceBundle.getProperty("DataManager.DisplayText.Date_Time") %>',
					ylabel: '<%= resourceBundle.getProperty("DataManager.DisplayText.Values") %>',
					axisLineColor: 'black'
				}
			);
		</script>
	</body> 
</html>