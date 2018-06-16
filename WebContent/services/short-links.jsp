<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<!DOCTYPE html>
<html class="no-js" lang="en">

<head>
    <meta charset="utf-8">

    <title>Inventaa</title>

    <meta name="description" content="Datamanager">
    <meta name="author" content="Inventaa">
    <meta name="robots" content="noindex, nofollow">
    <meta name="viewport" content="width=device-width,initial-scale=1.0,user-scalable=0">

    <!-- Icons -->
    <!-- The following icons can be replaced with your own, they are used by desktop and mobile browsers -->
    <link rel="shortcut icon" href="../img/fav-icon.jpg">
    <!-- END Icons -->
    <!-- Stylesheets -->
    <!-- Bootstrap is included in its original form, unaltered -->
    <link rel="stylesheet" href="../css/bootstrap.min.css">

    <!-- Related styles of various icon packs and plugins -->
    <link rel="stylesheet" href="../css/plugins.css">

    <!-- The main stylesheet of this template. All Bootstrap overwrites are defined in here -->
    <link rel="stylesheet" href="../css/main.css">

    <!-- Include a specific file here from css/themes/ folder to alter the default theme of the template -->

    <!-- The themes stylesheet of this template (for using specific theme color in individual elements - must included last) -->
    <link rel="stylesheet" href="../css/themes.css">
    <!-- END Stylesheets -->

    <!-- Modernizr (browser feature detection library) -->
    <script src="../js/vendor/modernizr-3.3.1.min.js"></script>
    <script language="javascript">
		function loadContent(url)
		{
			document.location.href = url;
		}
		
				
		function updateHomePage()
		{
			var name = "";
			var ele = document.getElementsByName('shortLink');
			for(var i=0; i<ele.length; i++)
			{
				if(ele[i].checked)
				{
					name = ele[i].value;
				}
			}
			
			document.frm1.submit(); 
		}
	</script>
	
	<script language="javascript">
		window.onresize = function() {
			var winW = 630, winH = 460;
			if(top.document.body && top.document.body.offsetWidth) 
			{
				winW = top.document.body.offsetWidth;
				winH = top.document.body.offsetHeight;
			}
			if(top.document.compatMode == "CSS1Compat" && top.document.documentElement && top.document.documentElement.offsetWidth)
			{
				winW = top.document.documentElement.offsetWidth;
				winH = top.document.documentElement.offsetHeight;
			}
			if(top.window.innerWidth && top.window.innerHeight) 
			{
				winW = top.window.innerWidth;
				winH = top.window.innerHeight;
			}
		};
	</script>
	
	<script type="text/javascript">
		function setLogData()
		{
			var script = document.createElement("script");
			script.type = "text/javascript";
			script.src = "http://ipinfo.io/?callback=apiResponse";
			document.getElementsByTagName("head")[0].appendChild(script);
		}

		function apiResponse(response) 
		{
			document.getElementById("ip").value = response.ip;
			document.getElementById("hostname").value = response.hostname;
			document.getElementById("city").value = response.city;
			document.getElementById("region").value = response.region;
			document.getElementById("country").value = response.country;
		}
	</script>

	<script language="javascript">
		
		
		function reloadHeader(url)
		{
			document.location.href = "dashboard.jsp?showContent="+url;
		}
		
		function popupContent(url, h, w)
		{
			var retval = window.open(url, '', 'left=200,top=100,resizable=no,scrollbars=no,status=no,toolbar=no,height='+h+',width='+w);			
		}

		function logout()
		{
			document.frm2.submit();
		}
		
		function resetContext(userId)
		{
			top.window.document.location.href = "../LoginServlet?U="+userId+"&resetContext=yes";
		}
	</script>
	<script language="javascript">
		if (!String.prototype.trim) 
		{
			String.prototype.trim = function() {
				return this.replace(/^\s+|\s+$/g,'');
			}
		}
	
		function chngPwd()
		{
			if(!checkPassword())
			{
				return false;
			}
			
			document.frm.submit();
		}
		
		function checkPassword()
		{
			var password = document.getElementById("password");
			password.value = password.value.trim();

			if(password.value.length < 6)
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Password_length_Mismatch") %>");
				password.focus();
				return false;
			}
			
			var CPassword = document.getElementById("CPassword");
			CPassword.value = CPassword.value.trim();
			
			if(password.value != CPassword.value)
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Password_Mismatch") %>");
				password.focus();
				return false;
			}
			
			return true;
		}

		function passwordChanged()
		{
			var strongRegex = new RegExp("^(?=.{10,})(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*\\W).*$", "g");
			var mediumRegex = new RegExp("^(?=.{8,})(((?=.*[A-Z])(?=.*[a-z]))|((?=.*[A-Z])(?=.*[0-9]))|((?=.*[a-z])(?=.*[0-9]))).*$", "g");
			var weakRegex = new RegExp("(?=.{6,}).*", "g");
			
			var strength = document.getElementById("strength");
			var pwd = document.getElementById("password");
			pwd.value = pwd.value.trim();
			if (pwd.value.length == 0) 
			{
				strength.innerHTML = "";
			} 
			else if (strongRegex.test(pwd.value)) 
			{
				strength.innerHTML = '<span style="color:green"><b>Strong</b></span>';
			} 
			else if (mediumRegex.test(pwd.value))
			{
				strength.innerHTML = '<span style="color:blue"><b>Medium</b></span>';
			} 
			else if (weakRegex.test(pwd.value))
			{
				strength.innerHTML = '<span style="color:red"><b>Weak</b></span>';
			}
		}
	</script>
</head>
<%
	String sHomePage = u.getHomePage();
	sHomePage = (sHomePage == null || "".equals(sHomePage) ? RDMServicesConstants.HOME : sHomePage);
%>


<body>
    <div id="page-wrapper" class="page-loading">
        <!-- Preloader -->
        <!-- Preloader functionality (initialized in js/app.js) - pageLoading() -->
        <!-- Used only if page preloader enabled from inc/config (PHP version) or the class 'page-loading' is added in #page-wrapper element (HTML version) -->
        <div class="preloader">
            <div class="inner">
                <!-- Animation spinner for all modern browsers -->
                <div class="preloader-spinner themed-background hidden-lt-ie10"></div>

                <!-- Text for IE9 -->
                <h3 class="text-primary visible-lt-ie10"><strong>Loading..</strong></h3>
            </div>
        </div>
        
        
		<div id="page-container"
			class="header-fixed-top sidebar-visible-lg-full">

			<jsp:include page="header.jsp" />			
			<!-- Alternative Sidebar -->
			<jsp:include page="header-sidebar.jsp">
				<jsp:param name="u" value="${u}" />
			</jsp:include>
			<!-- Main Sidebar -->
			<jsp:include page="sidebar.jsp" />

            <!-- Main Container -->
            <div id="main-container">
                <!-- Page content -->
				<div id="page-content">
					<form name="frm1" method="post" action="manageUserProcess.jsp">
						<input type="hidden" id="mode" name="mode" value="setHomePage">
						<table align="left" border="0" cellpadding="1" cellspacing="0"
							width="20%">
							<tr>
								<td align="left"><input type="button" id="save" name="save"
									value="<%=resourceBundle.getProperty("DataManager.DisplayText.Update")%>"
									onClick="javascript:updateHomePage()"></td>
							</tr>
							<tr>
								<td class="label" style="font-size: 10pt"><input
									type="radio" name="shortLink" id="shortLink"
									value="<%=RDMServicesConstants.HOME%>"
									<%=sHomePage.equals(RDMServicesConstants.HOME) ? "checked" : ""%>>
									<b>&raquo;&nbsp;<%=resourceBundle.getProperty("DataManager.DisplayText.Home")%></b>
									<%=sHomePage.equals(RDMServicesConstants.HOME)
					? "(" + resourceBundle.getProperty("DataManager.DisplayText.Default_View") + ")" : ""%>
								</td>
							</tr>
							<tr>
								<td class="label" style="font-size: 10pt"><input
									type="radio" name="shortLink" id="shortLink"
									value="<%=RDMServicesConstants.SHORTLINKS%>"
									<%=sHomePage.equals(RDMServicesConstants.SHORTLINKS) ? "checked" : ""%>>
									<b>&raquo;&nbsp;<%=resourceBundle.getProperty("DataManager.DisplayText.Short_Links")%></b>
									<%=sHomePage.equals(RDMServicesConstants.SHORTLINKS)
					? "(" + resourceBundle.getProperty("DataManager.DisplayText.Default_View") + ")" : ""%>
								</td>
							</tr>
							<%
			String tabSpace = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
			boolean bCreateTask1 = u.hasViewAccess(RDMServicesConstants.ACTIONS_CREATE_TASK);
			boolean bUpdateBNO1 = u.hasViewAccess(RDMServicesConstants.ACTIONS_UPDATE_BNO);

			if(bCreateTask1 || bUpdateBNO1)
			{
%>
							<tr>
								<td>&nbsp;</td>
							</tr>
							<tr>
								<td class="label" style="font-size: 10pt">
									&nbsp;&nbsp;&nbsp;&nbsp; <b>&raquo;&nbsp;<%= resourceBundle.getProperty("DataManager.DisplayText.Actions") %></b>
								</td>
							</tr>
							<%
				if(bCreateTask1)
				{
%>
							<tr>
								<td class="input"><input type="radio" name="shortLink"
									id="shortLink"
									value="<%= RDMServicesConstants.ACTIONS_CREATE_TASK %>"
									<%= sHomePage.equals(RDMServicesConstants.ACTIONS_CREATE_TASK) ? "checked" : "" %>>
									<%= tabSpace %> <b>&raquo;&nbsp;<a
										href="javascript:popupContent('addUserTaskView.jsp', '550', '400')"><%= resourceBundle.getProperty("DataManager.DisplayText.Create_Task") %></a></b>
									<%= sHomePage.equals(RDMServicesConstants.ACTIONS_CREATE_TASK) ? "("+resourceBundle.getProperty("DataManager.DisplayText.Default_View")+")" : "" %>
								</td>
							</tr>
							<%
				}
				if(bUpdateBNO1)
				{
%>
							<tr>
								<td class="input"><input type="radio" name="shortLink"
									id="shortLink"
									value="<%= RDMServicesConstants.ACTIONS_UPDATE_BNO %>"
									<%= sHomePage.equals(RDMServicesConstants.ACTIONS_UPDATE_BNO) ? "checked" : "" %>>
									<%= tabSpace %> <b>&raquo;&nbsp;<a
										href="javascript:loadContent('manageBatchNosView.jsp')"><%= resourceBundle.getProperty("DataManager.DisplayText.Update_Batch_Nos") %></a>
								</b><%= sHomePage.equals(RDMServicesConstants.ACTIONS_UPDATE_BNO) ? "("+resourceBundle.getProperty("DataManager.DisplayText.Default_View")+")" : "" %>
								</td>
							</tr>
							<%
				}
			}
			
			boolean bViewGrwDB1 = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_GROWER);
			boolean bViewBnkDB1 = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_BUNKER);
			boolean bViewTnlDB1 = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_TUNNEL);
			boolean bViewSingle1 = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_SINGLE_ROOM);
			boolean bViewMultiGrw1 = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_GROWER);
			boolean bViewMultiBnk1 = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_BUNKER);
			boolean bViewMultiTnl1 = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_TUNNEL);
			
			if((bViewGrwDB1 || bViewBnkDB1 || bViewTnlDB1) || bViewSingle1 || (bViewMultiGrw1 || bViewMultiBnk1 || bViewMultiTnl1))
			{
%>
							<tr>
								<td>&nbsp;</td>
							</tr>
							<tr>
								<td class="label" style="font-size: 10pt">
									&nbsp;&nbsp;&nbsp;&nbsp; <b>&raquo;&nbsp;<%= resourceBundle.getProperty("DataManager.DisplayText.Rooms_View") %></b>
								</td>
							</tr>
							<%
				if(bViewGrwDB1 || bViewBnkDB1 || bViewTnlDB1)
				{
%>
							<tr>
								<td class="input"><%= tabSpace %><%= tabSpace %> <b>&raquo;&nbsp;<%= resourceBundle.getProperty("DataManager.DisplayText.Dashboard") %></b>
								</td>
							</tr>
							<%
					if(bViewGrwDB1)
					{
%>
							<tr>
								<td class="input"><input type="radio" name="shortLink"
									id="shortLink"
									value="<%= RDMServicesConstants.ROOMS_VIEW_DASHBOARD_GROWER %>"
									<%= sHomePage.equals(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_GROWER) ? "checked" : "" %>>
									<%= tabSpace %><%= tabSpace %> <b>&raquo;&nbsp;<a
										href="javascript:loadContent('dashboardView.jsp?cntrlType=Grower')"><%= resourceBundle.getProperty("DataManager.DisplayText.Grower") %></a></b>
									<%= sHomePage.equals(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_GROWER) ? "("+resourceBundle.getProperty("DataManager.DisplayText.Default_View")+")" : "" %>
								</td>
							</tr>
							<%
					}
					if(bViewBnkDB1)
					{
%>
							<tr>
								<td class="input"><input type="radio" name="shortLink"
									id="shortLink"
									value="<%= RDMServicesConstants.ROOMS_VIEW_DASHBOARD_BUNKER %>"
									<%= sHomePage.equals(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_BUNKER) ? "checked" : "" %>>
									<%= tabSpace %><%= tabSpace %> <b>&raquo;&nbsp;<a
										href="javascript:loadContent('dashboardView.jsp?cntrlType=Bunker')"><%= resourceBundle.getProperty("DataManager.DisplayText.Bunker") %></a></b>
									<%= sHomePage.equals(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_BUNKER) ? "("+resourceBundle.getProperty("DataManager.DisplayText.Default_View")+")" : "" %>
								</td>
							</tr>
							<%
					}
					if(bViewTnlDB1)
					{
%>
							<tr>
								<td class="input"><input type="radio" name="shortLink"
									id="shortLink"
									value="<%= RDMServicesConstants.ROOMS_VIEW_DASHBOARD_TUNNEL %>"
									<%= sHomePage.equals(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_TUNNEL) ? "checked" : "" %>>
									<%= tabSpace %><%= tabSpace %> <b>&raquo;&nbsp;<a
										href="javascript:loadContent('dashboardView.jsp?cntrlType=Tunnel')"><%= resourceBundle.getProperty("DataManager.DisplayText.Tunnel") %></a></b>
									<%= sHomePage.equals(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_TUNNEL) ? "("+resourceBundle.getProperty("DataManager.DisplayText.Default_View")+")" : "" %>
								</td>
							</tr>
							<%
					}
				}
				if(bViewSingle1)
				{
%>
							<tr>
								<td class="input"><input type="radio" name="shortLink"
									id="shortLink"
									value="<%= RDMServicesConstants.ROOMS_VIEW_SINGLE_ROOM %>"
									<%= sHomePage.equals(RDMServicesConstants.ROOMS_VIEW_SINGLE_ROOM) ? "checked" : "" %>>
									<%= tabSpace %> <b>&raquo;&nbsp;<a
										href="javascript:loadContent('singleRoomView.jsp')"><%= resourceBundle.getProperty("DataManager.DisplayText.Single_Room") %></a></b>
									<%= sHomePage.equals(RDMServicesConstants.ROOMS_VIEW_SINGLE_ROOM) ? "("+resourceBundle.getProperty("DataManager.DisplayText.Default_View")+")" : "" %>
								</td>
							</tr>
							<%
				}
				if(bViewMultiGrw1 || bViewMultiBnk1 || bViewMultiTnl1)
				{
%>
							<tr>
								<td class="input"><%= tabSpace %><%= tabSpace %> <b>&raquo;&nbsp;<%= resourceBundle.getProperty("DataManager.DisplayText.Multi_Room") %></b>
								</td>
							</tr>
							<%
					if(bViewMultiGrw1)
					{
%>
							<tr>
								<td class="input"><input type="radio" name="shortLink"
									id="shortLink"
									value="<%= RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_GROWER %>"
									<%= sHomePage.equals(RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_GROWER) ? "checked" : "" %>>
									<%= tabSpace %><%= tabSpace %> <b>&raquo;&nbsp;<a
										href="javascript:loadContent('multiRoomView.jsp?cntrlType=Grower')"><%= resourceBundle.getProperty("DataManager.DisplayText.Grower") %></a></b>
									<%= sHomePage.equals(RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_GROWER) ? "("+resourceBundle.getProperty("DataManager.DisplayText.Default_View")+")" : "" %>
								</td>
							</tr>
							<%
					}
					if(bViewMultiBnk1)
					{
%>
							<tr>
								<td class="input"><input type="radio" name="shortLink"
									id="shortLink"
									value="<%= RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_BUNKER %>"
									<%= sHomePage.equals(RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_BUNKER) ? "checked" : "" %>>
									<%= tabSpace %><%= tabSpace %> <b>&raquo;&nbsp;<a
										href="javascript:loadContent('multiRoomView.jsp?cntrlType=Bunker')"><%= resourceBundle.getProperty("DataManager.DisplayText.Bunker") %></a></b>
									<%= sHomePage.equals(RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_BUNKER) ? "("+resourceBundle.getProperty("DataManager.DisplayText.Default_View")+")" : "" %>
								</td>
							</tr>
							<%
					}
					if(bViewMultiTnl1)
					{
%>
							<tr>
								<td class="input"><input type="radio" name="shortLink"
									id="shortLink"
									value="<%= RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_TUNNEL %>"
									<%= sHomePage.equals(RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_TUNNEL) ? "checked" : "" %>>
									<%= tabSpace %><%= tabSpace %> <b>&raquo;&nbsp;<a
										href="javascript:loadContent('multiRoomView.jsp?cntrlType=Tunnel')"><%= resourceBundle.getProperty("DataManager.DisplayText.Tunnel") %></a></b>
									<%= sHomePage.equals(RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_TUNNEL) ? "("+resourceBundle.getProperty("DataManager.DisplayText.Default_View")+")" : "" %>
								</td>
							</tr>
							<%
					}
				}
			}
			
			boolean bViewAttrGraph1 = u.hasViewAccess(RDMServicesConstants.VIEWS_GRAPH_ATTRDATA);
			boolean bViewProdGraph1 = u.hasViewAccess(RDMServicesConstants.VIEWS_GRAPH_PRODUCTIVITY);
			boolean bViewBatchLoad1 = u.hasViewAccess(RDMServicesConstants.VIEWS_GRAPH_BATCHLOAD);
			boolean bViewAlarms1 = u.hasViewAccess(RDMServicesConstants.VIEWS_ALARMS);
			boolean bViewLogs1 = u.hasViewAccess(RDMServicesConstants.VIEWS_LOGS);
			boolean bViewComments1 = u.hasViewAccess(RDMServicesConstants.VIEWS_COMMENTS);
			boolean bViewTasks1 = u.hasViewAccess(RDMServicesConstants.VIEWS_TASKS);
			boolean bViewYields1 = u.hasViewAccess(RDMServicesConstants.VIEWS_YIELDS);
			boolean bViewTimesheets1 = u.hasViewAccess(RDMServicesConstants.VIEWS_TIMESHEETS);
			boolean bViewReports1 = u.hasViewAccess(RDMServicesConstants.VIEWS_REPORTS);
			boolean bViewProductvity1 = u.hasViewAccess(RDMServicesConstants.VIEWS_PRODUCTIVITY);
			
			if(bViewAttrGraph1 || bViewProdGraph1 || bViewBatchLoad1 || bViewAlarms1 || bViewLogs1 || bViewComments1 
				|| bViewTasks1 || bViewYields1 || bViewTimesheets1 || bViewReports1 || bViewProductvity1)
			{
%>
							<tr>
								<td>&nbsp;</td>
							</tr>
							<tr>
								<td class="label" style="font-size: 10pt">
									&nbsp;&nbsp;&nbsp;&nbsp; <b>&raquo;&nbsp;<%= resourceBundle.getProperty("DataManager.DisplayText.Views") %></b>
								</td>
							</tr>
							<%
				if(bViewAttrGraph1 || bViewProdGraph1 || bViewBatchLoad1)
				{
%>
							<tr>
								<td class="input"><%= tabSpace %><%= tabSpace %> <b>&raquo;&nbsp;<%= resourceBundle.getProperty("DataManager.DisplayText.Graph") %></b>
								</td>
							</tr>
							<%
					if(bViewAttrGraph1)
					{
%>
							<tr>
								<td class="input"><input type="radio" name="shortLink"
									id="shortLink"
									value="<%= RDMServicesConstants.VIEWS_GRAPH_ATTRDATA %>"
									<%= sHomePage.equals(RDMServicesConstants.VIEWS_GRAPH_ATTRDATA) ? "checked" : "" %>>
									<%= tabSpace %><%= tabSpace %> <b>&raquo;&nbsp;<a
										href="javascript:loadContent('attrDataGraphView.jsp')"><%= resourceBundle.getProperty("DataManager.DisplayText.Attribute_Data") %></a></b>
									<%= sHomePage.equals(RDMServicesConstants.VIEWS_GRAPH_ATTRDATA) ? "("+resourceBundle.getProperty("DataManager.DisplayText.Default_View")+")" : "" %>
								</td>
							</tr>
							<%
					}
					if(bViewProdGraph1)
					{
%>
							<tr>
								<td class="input"><input type="radio" name="shortLink"
									id="shortLink"
									value="<%= RDMServicesConstants.VIEWS_GRAPH_PRODUCTIVITY %>"
									<%= sHomePage.equals(RDMServicesConstants.VIEWS_GRAPH_PRODUCTIVITY) ? "checked" : "" %>>
									<%= tabSpace %><%= tabSpace %> <b>&raquo;&nbsp;<a
										href="javascript:loadContent('productivityGraphView.jsp')"><%= resourceBundle.getProperty("DataManager.DisplayText.Productivity") %></a></b>
									<%= sHomePage.equals(RDMServicesConstants.VIEWS_GRAPH_PRODUCTIVITY) ? "("+resourceBundle.getProperty("DataManager.DisplayText.Default_View")+")" : "" %>
								</td>
							</tr>
							<%
					}
					if(bViewBatchLoad1)
					{
%>
							<tr>
								<td class="input"><input type="radio" name="shortLink"
									id="shortLink"
									value="<%= RDMServicesConstants.VIEWS_GRAPH_BATCHLOAD %>"
									<%= sHomePage.equals(RDMServicesConstants.VIEWS_GRAPH_BATCHLOAD) ? "checked" : "" %>>
									<%= tabSpace %><%= tabSpace %> <b>&raquo;&nbsp;<a
										href="javascript:loadContent('batchPhaseLoadsView.jsp')"><%= resourceBundle.getProperty("DataManager.DisplayText.Batch_Phase_Loads") %></a></b>
									<%= sHomePage.equals(RDMServicesConstants.VIEWS_GRAPH_BATCHLOAD) ? "("+resourceBundle.getProperty("DataManager.DisplayText.Default_View")+")" : "" %>
								</td>
							</tr>
							<%
					}
				}
				if(bViewAlarms1)
				{
%>
							<tr>
								<td class="input"><input type="radio" name="shortLink"
									id="shortLink" value="<%= RDMServicesConstants.VIEWS_ALARMS %>"
									<%= sHomePage.equals(RDMServicesConstants.VIEWS_ALARMS) ? "checked" : "" %>>
									<%= tabSpace %> <b>&raquo;&nbsp;<a
										href="javascript:loadContent('alarmView.jsp')"><%= resourceBundle.getProperty("DataManager.DisplayText.Alarms") %></a></b>
									<%= sHomePage.equals(RDMServicesConstants.VIEWS_ALARMS) ? "("+resourceBundle.getProperty("DataManager.DisplayText.Default_View")+")" : "" %>
								</td>
							</tr>
							<%
				}
				if(bViewLogs1)
				{
%>
							<tr>
								<td class="input"><input type="radio" name="shortLink"
									id="shortLink" value="<%= RDMServicesConstants.VIEWS_LOGS %>"
									<%= sHomePage.equals(RDMServicesConstants.VIEWS_LOGS) ? "checked" : "" %>>
									<%= tabSpace %> <b>&raquo;&nbsp;<a
										href="javascript:loadContent('logView.jsp')"><%= resourceBundle.getProperty("DataManager.DisplayText.Logs") %></a></b>
									<%= sHomePage.equals(RDMServicesConstants.VIEWS_LOGS) ? "("+resourceBundle.getProperty("DataManager.DisplayText.Default_View")+")" : "" %>
								</td>
							</tr>
							<%
				}
				if(bViewComments1)
				{
%>
							<tr>
								<td class="input"><input type="radio" name="shortLink"
									id="shortLink"
									value="<%= RDMServicesConstants.VIEWS_COMMENTS %>"
									<%= sHomePage.equals(RDMServicesConstants.VIEWS_COMMENTS) ? "checked" : "" %>>
									<%= tabSpace %> <b>&raquo;&nbsp;<a
										href="javascript:loadContent('userCommentsView.jsp')"><%= resourceBundle.getProperty("DataManager.DisplayText.Comments") %></a></b>
									<%= sHomePage.equals(RDMServicesConstants.VIEWS_COMMENTS) ? "("+resourceBundle.getProperty("DataManager.DisplayText.Default_View")+")" : "" %>
								</td>
							</tr>
							<%
				}
				if(bViewTasks1)
				{
%>
							<tr>
								<td class="input"><input type="radio" name="shortLink"
									id="shortLink" value="<%= RDMServicesConstants.VIEWS_TASKS %>"
									<%= sHomePage.equals(RDMServicesConstants.VIEWS_TASKS) ? "checked" : "" %>>
									<%= tabSpace %> <b>&raquo;&nbsp;<a
										href="javascript:loadContent('userTasksView.jsp')"><%= resourceBundle.getProperty("DataManager.DisplayText.Tasks") %></a></b>
									<%= sHomePage.equals(RDMServicesConstants.VIEWS_TASKS) ? "("+resourceBundle.getProperty("DataManager.DisplayText.Default_View")+")" : "" %>
								</td>
							</tr>
							<%
				}
				if(bViewYields1)
				{
%>
							<tr>
								<td class="input"><input type="radio" name="shortLink"
									id="shortLink" value="<%= RDMServicesConstants.VIEWS_YIELDS %>"
									<%= sHomePage.equals(RDMServicesConstants.VIEWS_YIELDS) ? "checked" : "" %>>
									<%= tabSpace %> <b>&raquo;&nbsp;<a
										href="javascript:loadContent('viewYields.jsp')"><%= resourceBundle.getProperty("DataManager.DisplayText.Yields") %></a></b>
									<%= sHomePage.equals(RDMServicesConstants.VIEWS_YIELDS) ? "("+resourceBundle.getProperty("DataManager.DisplayText.Default_View")+")" : "" %>
								</td>
							</tr>
							<%
				}
				if(bViewReports1)
				{
%>
							<tr>
								<td class="input"><input type="radio" name="shortLink"
									id="shortLink"
									value="<%= RDMServicesConstants.VIEWS_REPORTS %>"
									<%= sHomePage.equals(RDMServicesConstants.VIEWS_REPORTS) ? "checked" : "" %>>
									<%= tabSpace %> <b>&raquo;&nbsp;<a
										href="javascript:loadContent('viewReportsView.jsp')"><%= resourceBundle.getProperty("DataManager.DisplayText.Reports") %></a></b>
									<%= sHomePage.equals(RDMServicesConstants.VIEWS_REPORTS) ? "("+resourceBundle.getProperty("DataManager.DisplayText.Default_View")+")" : "" %>
								</td>
							</tr>
							<%
				}
				if(bViewTimesheets1)
				{
%>
							<tr>
								<td class="input"><input type="radio" name="shortLink"
									id="shortLink"
									value="<%= RDMServicesConstants.VIEWS_TIMESHEETS %>"
									<%= sHomePage.equals(RDMServicesConstants.VIEWS_TIMESHEETS) ? "checked" : "" %>>
									<%= tabSpace %> <b>&raquo;&nbsp;<a
										href="javascript:loadContent('manageTimesheetsView.jsp')"><%= resourceBundle.getProperty("DataManager.DisplayText.Manage_Timesheets") %></a></b>
									<%= sHomePage.equals(RDMServicesConstants.VIEWS_TIMESHEETS) ? "("+resourceBundle.getProperty("DataManager.DisplayText.Default_View")+")" : "" %>
								</td>
							</tr>
							<%
				}
				if(bViewProductvity1)
				{
%>
							<tr>
								<td class="input"><input type="radio" name="shortLink"
									id="shortLink"
									value="<%= RDMServicesConstants.VIEWS_PRODUCTIVITY %>"
									<%= sHomePage.equals(RDMServicesConstants.VIEWS_PRODUCTIVITY) ? "checked" : "" %>>
									<%= tabSpace %> <b>&raquo;&nbsp;<a
										href="javascript:loadContent('userProductivity.jsp')"><%= resourceBundle.getProperty("DataManager.DisplayText.Productivity") %></a></b>
									<%= sHomePage.equals(RDMServicesConstants.VIEWS_PRODUCTIVITY) ? "("+resourceBundle.getProperty("DataManager.DisplayText.Default_View")+")" : "" %>
								</td>
							</tr>
							<%
				}
			}
%>
						</table>
					</form>

				</div>
				<!-- END Page Content -->
            </div>
            <!-- END Main Container -->
 
 		</div>
		<!-- END Page Container -->
 	</div>
    <!-- END Page Wrapper -->
    
    
    <form name="frm2" method="post" action="../LogoutServlet" target="_top">
		<input type="hidden" id="ip" name="ip" value="">
		<input type="hidden" id="hostname" name="hostname" value="">	
		<input type="hidden" id="city" name="city" value="">
		<input type="hidden" id="region" name="region" value="">
		<input type="hidden" id="country" name="country" value="">
	</form>

    <!-- jQuery, Bootstrap, jQuery plugins and Custom JS code -->
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
</body>

</html>
