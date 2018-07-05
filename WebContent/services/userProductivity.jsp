<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="java.text.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>
<%@page import="com.client.db.*" %>
<%@page import="com.client.views.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<%
UserTasks userTasks = new UserTasks();
Map<String, MapList> mTaskProductivity = userTasks.getProductivity();

double productivity;
long totalTime;
String sUserId = null;
Map<String, String> mProductivity = null;
Map<String, String> mUserNames = RDMServicesUtils.getUserNames();
DecimalFormat df = new DecimalFormat("#.###");

java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd-MMM-yyyy HH:mm");
String sDate = sdf.format(Calendar.getInstance().getTime());
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
	<title></title>
	<meta http-equiv="refresh" content="300;url=userProductivity.jsp"/>
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
    <!-- END Stylesheets -->
    <link type="text/css" href="../styles/calendar.css" rel="stylesheet" />
    
    <!-- Modernizr (browser feature detection library) -->
    <script src="../js/vendor/modernizr-3.3.1.min.js"></script>
  
	<script language="javaScript" type="text/javascript" src="../scripts/calendar.js"></script>
	<script src="../js/vendor/jquery-2.2.4.min.js"></script>
    <script src="../js/vendor/bootstrap.min.js"></script>
    <script src="../js/plugins.js"></script>
    <script src="../js/app.js"></script>
    <!-- Load and execute javascript code used only in this page -->
    <script src="../js/pages/readyDashboard.js"></script>
    <script>
        $(function() {
            ReadyDashboard.init();
        });

    </script>
	<style>
		td.label
		{
			text-align: center;
			background-color: #888888;
			color: #ffffff;
			font-size:16px;
			font-weight:bold;
			font-family:Arial,sans-serif;
		}
		td.text
		{
			text-align: center;
			background-color: #008080;
			color: #ffffff;
			font-size:14px;
			font-weight:bold;
			font-family:Arial,sans-serif;
		}
		th.text
		{
			text-align: center;
			background-color: #ff0000;
			color: #ffffff;
			font-size:15px;
			font-weight:bold;
			font-family:Arial,sans-serif;
		}
	</style>

	<script language="javascript">
	
	</script>
</head>

<body>
	<div id="page-wrapper" class="page-loading">
        <div class="preloader">
            <div class="inner">
                <!-- Animation spinner for all modern browsers -->
                <div class="preloader-spinner themed-background hidden-lt-ie10"></div>

                <!-- Text for IE9 -->
                <h3 class="text-primary visible-lt-ie10"><strong>Loading..</strong></h3>
            </div>
        </div>
    
            <!-- Main Container -->
            <div id="main-container">

                <!-- Page content -->
                <div id="page-content">
                    <div class="block">
                        <!-- General Elements Title -->
                        <div class="block-title">

                            <h2><%= resourceBundle.getProperty("DataManager.DisplayText.Search_Comments") %></h2>
                        </div>
                        <!-- General Elements Content -->
                        <div class="table table-responsive table-hover">
		
        				<table id="datatable" class="table table-striped table-bordered table-vcenter">
<%
		String sTask;
		MapList mlProductivity = null;
		
		Iterator<String> itr = mTaskProductivity.keySet().iterator();
		while(itr.hasNext())
		{
			sTask = itr.next();
			mlProductivity = mTaskProductivity.get(sTask);
%>
			<tr>
				<th  style="text-align:left" colspan="5"><%= sTask.toUpperCase() %></th>
				<th  style="text-align:right"><%= sDate %></th>
			</tr>			
			<tr>
				<td  width="5%">Top 5</td>
<%			
			int i=0;
			int iSz = mlProductivity.size();
			for(; i<iSz; i++)
			{
				if(i < 5)
				{
					mProductivity = mlProductivity.get(i);
					sUserId = mProductivity.get(RDMServicesConstants.ASSIGNEE);
					totalTime = Long.parseLong(mProductivity.get(RDMServicesConstants.DURATION));
					productivity = Double.parseDouble(mProductivity.get(RDMServicesConstants.PRODUCTIVITY));
%>
					<td>
						<table border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td  height="120" width="200">
									<img src="../UserImages/<%= sUserId %>.jpg" height="120" width="150"/>
								</td>
							</tr>
							<tr>
								<td  width="200">
									<%= mUserNames.get(mProductivity.get(RDMServicesConstants.ASSIGNEE)) %>
								</td>
							</tr>
							<tr>
								<td  width="200">
									<%= (totalTime / 60) + " hr : " + (totalTime % 60) + " mm" %>
								</td>
							</tr>
							<tr>
								<td  width="200">
									<%= df.format(productivity) %> kg
								</td>
							</tr>
						</table>
					</td>
<%			
				}
			}
%>
			</tr>			
			<tr>
				<td  width="5%">Last 5</td>
<%
			i = iSz - 5;
			i = ((i < 5) ? 5 : i);
			for(; i<iSz; i++)
			{
				mProductivity = mlProductivity.get(i);
				sUserId = mProductivity.get(RDMServicesConstants.ASSIGNEE);
				totalTime = Long.parseLong(mProductivity.get(RDMServicesConstants.DURATION));
				productivity = Double.parseDouble(mProductivity.get(RDMServicesConstants.PRODUCTIVITY));
%>
				<td>
					<table border="0" cellpadding="0" cellspacing="0">
						<tr>
							<td  height="120" width="200">
								<img src="../UserImages/<%= sUserId %>.jpg" height="120" width="150"/>
							</td>
						</tr>
						<tr>
							<td  width="200">
								<%= mUserNames.get(mProductivity.get(RDMServicesConstants.ASSIGNEE)) %>
							</td>
						</tr>
						<tr>
							<td  width="200">
								<%= (totalTime / 60) + " hr : " + (totalTime % 60) + " mm" %>
							</td>
						</tr>
						<tr>
							<td  width="200">
								<%= df.format(productivity) %> kg
							</td>
						</tr>
					</table>
				</td>
<%			
			}
%>
			</tr>
<%
		}
		
		if(mTaskProductivity.isEmpty())
		{
%>
			<tr>
				<td >
					<%= resourceBundle.getProperty("DataManager.DisplayText.No_In_Progress_Tasks") %>
				</td>
			</tr>
<%
		}
%>
	</table>
	</div>
	</div>
	</div>
                <!-- END Page Content -->
            </div>
            <!-- END Main Container -->
        </div>
        <!-- END Page Container -->

</body>
</html>
