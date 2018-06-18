<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>
<%@page import="com.client.views.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<%
String sUserId = request.getParameter("userId");
String sFName = request.getParameter("FName");
String sLName = request.getParameter("LName");
String sDept = request.getParameter("dept");
String sStartDt = request.getParameter("start_date");
String sEndDt = request.getParameter("end_date");

ProductivityGraph graph = new ProductivityGraph();
String sGraphCSV = "";
StringList slUsers = new StringList();
if(sStartDt != null && sEndDt != null)
{
	sGraphCSV = graph.loadProductivityGraph(sUserId, sFName, sLName, sDept, sStartDt, sEndDt, slUsers);
}
else
{
	return;
}

StringBuilder sbUsers = new StringBuilder();
for(int i=0; i<slUsers.size(); i++)
{
	if(i > 0)
	{
		sbUsers.append(",");
	}
	sbUsers.append("\"");
	sbUsers.append(slUsers.get(i));
	sbUsers.append("\"");
}
%>

<html>
	<head>
		<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE6; IE=EmulateIE7; IE=EmulateIE8; IE=EmulateIE9">
		<title></title>
		<link type="text/css" href="../styles/dygraph.css" rel="stylesheet" />
		<script type="text/javascript" src="../scripts/excanvas.js"></script>
		<script type="text/javascript" src="../scripts/dygraph-combined.js"></script>
		<script type="text/javascript" src="../scripts/excanvas.js"></script>
		<script type="text/javascript" src="../scripts/dygraph-combined.js"></script>
		<meta name="description" content="Datamanager"/>
    <meta name="author" content="Inventaa"/>
    <meta name="robots" content="noindex, nofollow"/>
    <meta name="viewport" content="width=device-width,initial-scale=1.0,user-scalable=0"/>

    <!-- Icons -->
    <!-- The following icons can be replaced with your own, they are used by desktop and mobile browsers -->
    <link rel="shortcut icon" href="../img/fav-icon.jpg"/>
    <!-- END Icons -->

    <!-- Stylesheets -->
    <!-- Bootstrap is included in its original form, unaltered -->
    <link rel="stylesheet" href="../css/bootstrap.min.css"/>

    <!-- Related styles of various icon packs and plugins -->
    <link rel="stylesheet" href="../css/plugins.css"/>

    <!-- The main stylesheet of this template. All Bootstrap overwrites are defined in here -->
    <link rel="stylesheet" href="../css/main.css"/>

    <!-- Include a specific file here from ../css/themes/ folder to alter the default theme of the template -->

    <!-- The themes stylesheet of this template (for using specific theme color in individual elements - must included last) -->
    <link rel="stylesheet" href="../css/themes.css"/>
    
    <!-- Modernizr (browser feature detection library) -->
    <script src="../js/vendor/modernizr-3.3.1.min.js"/>
  
	<script src="../js/vendor/jquery-2.2.4.min.js"></script>
    <script src="../js/vendor/bootstrap.min.js"></script>
    <script src="../js/plugins.js"></script>
    <script src="../js/app.js"></script>
    <!-- Load and execute javascript code used only in this page -->
    <script src="../js/pages/readyDashboard.js"></script>
		<script type="text/javascript">
		function exportGraph()
		{
			var url = "../ExportProductivityGraph";
			url += "?userId=<%= sUserId %>";
			url += "&FName=<%= sFName %>";
			url += "&LName=<%= sLName %>";
			url += "&dept=<%= sDept %>";
			url += "&start_date=<%= sStartDt %>";
			url += "&end_date=<%= sEndDt %>";

			document.location.href =  url;
		}
		
		var arrUsers = new Array(<%= sbUsers.toString() %>);
		</script>
	</head>

	<body>
		<div class="table table-responsive table-hover">
		
        <table id="datatable" class="table table-striped table-bordered table-vcenter">
			<tr>
				<td valign="top">
					<div id="graphdiv" style="width:<%= winWidth * 0.75 %>px; height:<%= winHeight * 0.75 %>px;"></div>
				</td>
				<td valign="top">
					<table>						
						<tr>
							<td style="font-family:Arial; font-size:1.0em; font-weight:bold; color:#0000FF">
								<a href="javascript:exportGraph()"><%= resourceBundle.getProperty("DataManager.DisplayText.Export_Graph_Data") %></a>
							</td>
						</tr>
						<tr>
							<td>&nbsp;</td>
						</tr>
						<tr>
							<td>
								<div id="status" style="width:250px; font-size:1.0em; padding-top:5px;"></div>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
		</div>
		<script type="text/javascript">			
			var g = new Dygraph(document.getElementById("graphdiv"),
				'../graphs/ControllerData/<%= sGraphCSV %>',
				{
					labelsDiv: document.getElementById('status'),					
					labelsSeparateLines: false,
					labelsKMB: true,
					legend: 'always',
					colors: ["Blue"],
					drawPoints:true,
					pointSize:4,
					highlightCircleSize:6,
					xlabel: '<%= resourceBundle.getProperty("DataManager.DisplayText.Users") %>',
					ylabel: '<%= resourceBundle.getProperty("DataManager.DisplayText.Productivity") %>',
					axisLineColor: 'black',
					axes: {
						x: {
							valueFormatter: function(x) {
								return '<b>'+arrUsers[x]+'</b>';
							},
							axisLabelFormatter: function(x) {
								return x; 
							}
						}
					}
				}
			);
		</script>
	</body>
</html>