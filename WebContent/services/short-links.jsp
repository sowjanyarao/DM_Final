<%@page contentType="text/html;charset=UTF-8"%>
<%
	request.setCharacterEncoding("UTF-8");
%>

<%@page import="java.util.*"%>
<%@page import="com.client.*"%>
<%@page import="com.client.util.*"%>

<jsp:useBean id="RDMSession" scope="session"
	class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp"%>

<!DOCTYPE html>
<html class="no-js" lang="en">

<head>
<meta charset="utf-8">

<title>Inventaa</title>

<meta name="description" content="Datamanager">
<meta name="author" content="Inventaa">
<meta name="robots" content="noindex, nofollow">
<meta name="viewport"
	content="width=device-width,initial-scale=1.0,user-scalable=0">

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
	function loadContent(url) {
		document.location.href = url;
	}

	function popupContent(url, h, w) {
		var retval = window.open(url, '',
				'left=200,top=100,resizable=no,scrollbars=no,status=no,toolbar=no,height='
						+ h + ',width=' + w);
	}

	function updateHomePage() {
		var name = "";
		var ele = document.getElementsByName('shortLink');
		for (var i = 0; i < ele.length; i++) {
			if (ele[i].checked) {
				name = ele[i].value;
			}
		}

		document.frmuser.submit();
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
				<h3 class="text-primary visible-lt-ie10">
					<strong>Loading..</strong>
				</h3>
			</div>
		</div>

		<!-- Main Container -->
		<div id="main-container">
			<!-- Page content -->
			<div id="page-content">
				<form name="frmuser" method="post" action="manageUserProcess.jsp">
					<input type="hidden" id="mode" name="mode" value="setHomePage">
					<div class="row">
						<div class="form-group form-actions">
							<div class="col-md-12">
								<button type="submit" id="save" name="save"
									class="btn btn-effect-ripple btn-primary"
									style="overflow: hidden; position: relative;"
									value="<%=resourceBundle.getProperty("DataManager.DisplayText.Update")%>"
									onClick="javascript:updateHomePage()">Update</button>
							</div>
						</div>
					</div>
					<!-- Toggle Menu Content -->
					<ul class="toggle-menu">
						<li>
							<div class="radio">
								<label for="shortLink"> <input type="radio"
									name="shortLink" id="shortLink"
									value="<%=RDMServicesConstants.HOME%>"
									<%=sHomePage.equals(RDMServicesConstants.HOME) ? "checked" : ""%>>
									<%=resourceBundle.getProperty("DataManager.DisplayText.Home")%>
									<%=sHomePage.equals(RDMServicesConstants.HOME)
					? "(" + resourceBundle.getProperty("DataManager.DisplayText.Default_View") + ")" : ""%>
								</label>
							</div>
						</li>
						<li>
							<div class="radio">
								<label for="shortLink"> <input type="radio"
									name="shortLink" id="shortLink"
									value="<%=RDMServicesConstants.SHORTLINKS%>"
									<%=sHomePage.equals(RDMServicesConstants.SHORTLINKS) ? "checked" : ""%>>
									<%=resourceBundle.getProperty("DataManager.DisplayText.Short_Links")%>
									<%=sHomePage.equals(RDMServicesConstants.SHORTLINKS)
					? "(" + resourceBundle.getProperty("DataManager.DisplayText.Default_View") + ")" : ""%>
								</label>
							</div>

						</li>

						<%
							boolean bCreateTask1 = u.hasViewAccess(RDMServicesConstants.ACTIONS_CREATE_TASK);
							boolean bUpdateBNO1 = u.hasViewAccess(RDMServicesConstants.ACTIONS_UPDATE_BNO);

							if (bCreateTask1 || bUpdateBNO1) {
						%>
						<li class="open"><a href="javascript:void(0)" class="submenu"><i
								class="fa fa-angle-right"></i> <%=resourceBundle.getProperty("DataManager.DisplayText.Actions")%></a>
							<%
								if (bCreateTask1) {
							%>
							<ul>
								<li><div class="radio">
										<label for="shortLink"> <input type="radio"
											id="shortLink" name="shortLink"
											value="<%=RDMServicesConstants.ACTIONS_CREATE_TASK%>"
											<%=sHomePage.equals(RDMServicesConstants.ACTIONS_CREATE_TASK) ? "checked" : ""%>>
											<a
											href="javascript:popupContent('addUserTaskView.jsp', '550', '400')"><%=resourceBundle.getProperty("DataManager.DisplayText.Create_Task")%></a>
											<%=sHomePage.equals(RDMServicesConstants.ACTIONS_CREATE_TASK)
							? "(" + resourceBundle.getProperty("DataManager.DisplayText.Default_View") + ")" : ""%>
										</label>
									</div></li>
							</ul> <%
 	}
 		if (bUpdateBNO1) {
 %>
							<ul>
								<li><div class="radio">
										<label for="shortLink"> <input type="radio"
											id="shortLink" name="shortLink"
											value="<%=RDMServicesConstants.ACTIONS_UPDATE_BNO%>"
											<%=sHomePage.equals(RDMServicesConstants.ACTIONS_UPDATE_BNO) ? "checked" : ""%>>
											<a href="javascript:loadContent('manageBatchNosView.jsp')"><%=resourceBundle.getProperty("DataManager.DisplayText.Update_Batch_Nos")%></a>
											<%=sHomePage.equals(RDMServicesConstants.ACTIONS_UPDATE_BNO)
							? "(" + resourceBundle.getProperty("DataManager.DisplayText.Default_View") + ")" : ""%>
										</label>
									</div></li>
							</ul> <%
 	}
 %></li>
						<%
							}

							boolean bViewGrwDB1 = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_GROWER);
							boolean bViewBnkDB1 = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_BUNKER);
							boolean bViewTnlDB1 = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_TUNNEL);
							boolean bViewSingle1 = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_SINGLE_ROOM);
							boolean bViewMultiGrw1 = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_GROWER);
							boolean bViewMultiBnk1 = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_BUNKER);
							boolean bViewMultiTnl1 = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_TUNNEL);

							if ((bViewGrwDB1 || bViewBnkDB1 || bViewTnlDB1) || bViewSingle1
									|| (bViewMultiGrw1 || bViewMultiBnk1 || bViewMultiTnl1)) {
						%>


						<li class="open"><a href="javascript:void(0)" class="submenu"><i
								class="fa fa-angle-right"></i> <%=resourceBundle.getProperty("DataManager.DisplayText.Rooms_View")%></a>



							<%
								if (bViewGrwDB1 || bViewBnkDB1 || bViewTnlDB1) {
							%>
							<ul>
								<li class="open"><a href="javascript:void(0)"
									class="submenu"><i class="fa fa-angle-right"></i> <%=resourceBundle.getProperty("DataManager.DisplayText.Dashboard")%>
								</a> <%
 	if (bViewGrwDB1) {
 %>

									<ul>
										<li><div class="radio">
												<label for="shortLink"> <input type="radio"
													id="shortLink" name="shortLink"
													value="<%=RDMServicesConstants.ROOMS_VIEW_DASHBOARD_GROWER%>"
													<%=sHomePage.equals(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_GROWER) ? "checked" : ""%>>
													<a
													href="javascript:loadContent('dashboardView.jsp?cntrlType=Grower')"><%=resourceBundle.getProperty("DataManager.DisplayText.Grower")%></a>
													<%=sHomePage.equals(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_GROWER)
								? "(" + resourceBundle.getProperty("DataManager.DisplayText.Default_View") + ")" : ""%>
												</label>
											</div></li>
									</ul> <%
 	}
 			if (bViewBnkDB1) {
 %>

									<ul>
										<li><div class="radio">
												<label for="shortLink"> <input type="radio"
													id="shortLink" name="shortLink"
													value="<%=RDMServicesConstants.ROOMS_VIEW_DASHBOARD_BUNKER%>"
													<%=sHomePage.equals(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_BUNKER) ? "checked" : ""%>>
													<a
													href="javascript:loadContent('dashboardView.jsp?cntrlType=Bunker')"><%=resourceBundle.getProperty("DataManager.DisplayText.Bunker")%></a>
													<%=sHomePage.equals(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_BUNKER)
								? "(" + resourceBundle.getProperty("DataManager.DisplayText.Default_View") + ")" : ""%>
												</label>
											</div></li>
									</ul> <%
 	}
 			if (bViewTnlDB1) {
 %>
									<ul>
										<li><div class="radio">
												<label for="shortLink"> <input type="radio"
													id="shortLink" name="shortLink"
													value="<%=RDMServicesConstants.ROOMS_VIEW_DASHBOARD_TUNNEL%>"
													<%=sHomePage.equals(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_TUNNEL) ? "checked" : ""%>>
													<a
													href="javascript:loadContent('dashboardView.jsp?cntrlType=Tunnel')"><%=resourceBundle.getProperty("DataManager.DisplayText.Tunnel")%></a>
													<%=sHomePage.equals(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_TUNNEL)
								? "(" + resourceBundle.getProperty("DataManager.DisplayText.Default_View") + ")" : ""%>
												</label>
											</div></li>
									</ul> <%
 	}
 %></li>
							</ul> <%
 	}
 		if (bViewSingle1) {
 %>


							<ul>
								<li class="open">
									<div class="radio">
										<label for="shortLink"> <input type="radio"
											id="shortLink" name="shortLink"
											value="<%=RDMServicesConstants.ROOMS_VIEW_SINGLE_ROOM%>"
											<%=sHomePage.equals(RDMServicesConstants.ROOMS_VIEW_SINGLE_ROOM) ? "checked" : ""%>>
											<a href="javascript:loadContent('singleRoomView.jsp')"
											class="submenu"><%=resourceBundle.getProperty("DataManager.DisplayText.Single_Room")%></a>
											<%=sHomePage.equals(RDMServicesConstants.ROOMS_VIEW_SINGLE_ROOM)
							? "(" + resourceBundle.getProperty("DataManager.DisplayText.Default_View") + ")" : ""%>
										</label>
									</div>
								</li>
							</ul> <%
 	}
 		if (bViewMultiGrw1 || bViewMultiBnk1 || bViewMultiTnl1) {
 %>
							<ul>
								<li class="open"><a href="javascript:void(0)"
									class="submenu"><i class="fa fa-angle-right"></i> <%=resourceBundle.getProperty("DataManager.DisplayText.Multi_Room")%></a>

									<%
										if (bViewMultiGrw1) {
									%>
									<ul>
										<li><div class="radio">
												<label for="shortLink"> <input type="radio"
													id="shortLink" name="shortLink"
													value="<%=RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_GROWER%>"
													<%=sHomePage.equals(RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_GROWER) ? "checked" : ""%>>
													<a
													href="javascript:loadContent('multiRoomView.jsp?cntrlType=Grower')"><%=resourceBundle.getProperty("DataManager.DisplayText.Grower")%></a>
													<%=sHomePage.equals(RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_GROWER)
								? "(" + resourceBundle.getProperty("DataManager.DisplayText.Default_View") + ")" : ""%>
												</label>
											</div></li>
									</ul> <%
 	}
 			if (bViewMultiBnk1) {
 %>

									<ul>
										<li><div class="radio">
												<label for="shortLink"> <input type="radio"
													id="shortLink" name="shortLink"
													value="<%=RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_BUNKER%>"
													<%=sHomePage.equals(RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_BUNKER) ? "checked" : ""%>>
													<a
													href="javascript:loadContent('multiRoomView.jsp?cntrlType=Bunker')"><%=resourceBundle.getProperty("DataManager.DisplayText.Bunker")%></a>
													<%=sHomePage.equals(RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_BUNKER)
								? "(" + resourceBundle.getProperty("DataManager.DisplayText.Default_View") + ")" : ""%>
												</label>
											</div></li>
									</ul> <%
 	}
 			if (bViewMultiTnl1) {
 %>

									<ul>
										<li><div class="radio">
												<label for="shortLink"> <input type="radio"
													id="shortLink" name="shortLink"
													value="<%=RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_TUNNEL%>"
													<%=sHomePage.equals(RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_TUNNEL) ? "checked" : ""%>>
													<a
													href="javascript:loadContent('multiRoomView.jsp?cntrlType=Tunnel')"><%=resourceBundle.getProperty("DataManager.DisplayText.Tunnel")%></a>
													<%=sHomePage.equals(RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_TUNNEL)
								? "(" + resourceBundle.getProperty("DataManager.DisplayText.Default_View") + ")" : ""%>
												</label>
											</div></li>
									</ul> <%
 	}
 %></li>
							</ul> <%
 	}
 %></li>
						<%
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

							if (bViewAttrGraph1 || bViewProdGraph1 || bViewBatchLoad1 || bViewAlarms1 || bViewLogs1 || bViewComments1
									|| bViewTasks1 || bViewYields1 || bViewTimesheets1 || bViewReports1 || bViewProductvity1) {
						%>

						<li class="open"><a href="javascript:void(0)" class="submenu"><i
								class="fa fa-angle-right"></i> <%=resourceBundle.getProperty("DataManager.DisplayText.Views")%></a>
							<ul>
								<%
									if (bViewAttrGraph1 || bViewProdGraph1 || bViewBatchLoad1) {
								%>

								<li class="open"><a href="javascript:void(0)"
									class="submenu"><i class="fa fa-angle-right"></i> <%=resourceBundle.getProperty("DataManager.DisplayText.Graph")%>
								</a>
									<ul>
										<%
											if (bViewAttrGraph1) {
										%>
										<li><div class="radio">
												<label for="shortLink"> <input type="radio"
													name="shortLink" id="shortLink"
													value="<%=RDMServicesConstants.VIEWS_GRAPH_ATTRDATA%>"
													<%=sHomePage.equals(RDMServicesConstants.VIEWS_GRAPH_ATTRDATA) ? "checked" : ""%>>
													<a href="javascript:loadContent('attrDataGraphView.jsp')">
													<%=resourceBundle.getProperty("DataManager.DisplayText.Attribute_Data")%></a>
													<%=sHomePage.equals(RDMServicesConstants.VIEWS_GRAPH_ATTRDATA)? "(" + resourceBundle.getProperty("DataManager.DisplayText.Default_View") + ")" : ""%>
												</label>
											</div></li>


										<%
											}
													if (bViewProdGraph1) {
										%>

										<li><div class="radio">
												<label for="shortLink"> <input type="radio"
													name="shortLink" id="shortLink"
													value="<%=RDMServicesConstants.VIEWS_GRAPH_PRODUCTIVITY%>"
													<%=sHomePage.equals(RDMServicesConstants.VIEWS_GRAPH_PRODUCTIVITY) ? "checked" : ""%>>
													<a
													href="javascript:loadContent(productivityGraphView.jsp')"><%=resourceBundle.getProperty("DataManager.DisplayText.Productivity")%></a>
													<%=sHomePage.equals(RDMServicesConstants.VIEWS_GRAPH_PRODUCTIVITY)
								? "(" + resourceBundle.getProperty("DataManager.DisplayText.Default_View") + ")" : ""%>
												</label>
											</div></li>




										<%
											}
													if (bViewBatchLoad1) {
										%>

										<li><div class="radio">
												<label for="shortLink"> <input type="radio"
													name="shortLink" id="shortLink"
													value="<%=RDMServicesConstants.VIEWS_GRAPH_BATCHLOAD%>"
													<%=sHomePage.equals(RDMServicesConstants.VIEWS_GRAPH_BATCHLOAD) ? "checked" : ""%>>
													<a href="javascript:loadContent('batchPhaseLoadsView.jsp')"><%=resourceBundle.getProperty("DataManager.DisplayText.Batch_Phase_Loads")%></a>
													<%=sHomePage.equals(RDMServicesConstants.VIEWS_GRAPH_BATCHLOAD)
								? "(" + resourceBundle.getProperty("DataManager.DisplayText.Default_View") + ")" : ""%>
												</label>
											</div></li>

										<%
											}
										%>
									</ul></li>
								<%
									}
										if (bViewAlarms1) {
								%>


								<li><div class="radio">
										<label for="shortLink"> <input type="radio"
											name="shortLink" id="shortLink"
											value="<%=RDMServicesConstants.VIEWS_ALARMS%>"
											<%=sHomePage.equals(RDMServicesConstants.VIEWS_ALARMS) ? "checked" : ""%>>
											<a href="javascript:loadContent('alarmView.jsp')"><%=resourceBundle.getProperty("DataManager.DisplayText.Alarms")%></a>
											<%=sHomePage.equals(RDMServicesConstants.VIEWS_ALARMS)
							? "(" + resourceBundle.getProperty("DataManager.DisplayText.Default_View") + ")" : ""%>
										</label>
									</div></li>


								<%
									}
										if (bViewLogs1) {
								%>


								<li><div class="radio">
										<label for="shortLink"> <input type="radio"
											name="shortLink" id="shortLink"
											value="<%=RDMServicesConstants.VIEWS_LOGS%>"
											<%=sHomePage.equals(RDMServicesConstants.VIEWS_LOGS) ? "checked" : ""%>>
											<a href="javascript:loadContent('logView.jsp')"><%=resourceBundle.getProperty("DataManager.DisplayText.Logs")%></a>
											<%=sHomePage.equals(RDMServicesConstants.VIEWS_LOGS)
							? "(" + resourceBundle.getProperty("DataManager.DisplayText.Default_View") + ")" : ""%>
										</label>
									</div></li>


								<%
									}
										if (bViewComments1) {
								%>


								<li><div class="radio">
										<label for="shortLink"> <input type="radio"
											name="shortLink" id="shortLink"
											value="<%=RDMServicesConstants.VIEWS_COMMENTS%>"
											<%=sHomePage.equals(RDMServicesConstants.VIEWS_COMMENTS) ? "checked" : ""%>>
											<a href="javascript:loadContent('userCommentsView.jsp')"><%=resourceBundle.getProperty("DataManager.DisplayText.Comments")%></a>
											<%=sHomePage.equals(RDMServicesConstants.VIEWS_COMMENTS)
							? "(" + resourceBundle.getProperty("DataManager.DisplayText.Default_View") + ")" : ""%>
										</label>
									</div></li>




								<%
									}
										if (bViewTasks1) {
								%>

								<li><div class="radio">
										<label for="shortLink"> <input type="radio"
											name="shortLink" id="shortLink"
											value="<%=RDMServicesConstants.VIEWS_TASKS%>"
											<%=sHomePage.equals(RDMServicesConstants.VIEWS_TASKS) ? "checked" : ""%>>
											<a href="javascript:loadContent('userTasksView.jsp')"> <%=resourceBundle.getProperty("DataManager.DisplayText.Tasks")%></a>
											<%=sHomePage.equals(RDMServicesConstants.VIEWS_TASKS)
							? "(" + resourceBundle.getProperty("DataManager.DisplayText.Default_View") + ")" : ""%>
										</label>
									</div></li>


								<%
									}
										if (bViewYields1) {
								%>

								<li><div class="radio">
										<label for="shortLink"> <input type="radio"
											name="shortLink" id="shortLink"
											value="<%=RDMServicesConstants.VIEWS_YIELDS%>"
											<%=sHomePage.equals(RDMServicesConstants.VIEWS_YIELDS) ? "checked" : ""%>>
											<a href="javascript:loadContent('viewYields.jsp')"><%=resourceBundle.getProperty("DataManager.DisplayText.Yields")%></a>
											<%=sHomePage.equals(RDMServicesConstants.VIEWS_YIELDS)
							? "(" + resourceBundle.getProperty("DataManager.DisplayText.Default_View") + ")" : ""%>
										</label>
									</div></li>

								<%
									}
										if (bViewReports1) {
								%>

								<li><div class="radio">
										<label for="shortLink"> <input type="radio"
											name="shortLink" id="shortLink"
											value="<%=RDMServicesConstants.VIEWS_REPORTS%>"
											<%=sHomePage.equals(RDMServicesConstants.VIEWS_REPORTS) ? "checked" : ""%>>
											<a href="javascript:loadContent('viewReportsView.jsp')">
												<%=resourceBundle.getProperty("DataManager.DisplayText.Reports")%></a>
											<%=sHomePage.equals(RDMServicesConstants.VIEWS_REPORTS)
							? "(" + resourceBundle.getProperty("DataManager.DisplayText.Default_View") + ")" : ""%>
										</label>
									</div></li>


								<%
									}
										if (bViewTimesheets1) {
								%>

								<li><div class="radio">
										<label for="shortLink"> <input type="radio"
											name="shortLink" id="shortLink"
											value="<%=RDMServicesConstants.VIEWS_TIMESHEETS%>"
											<%=sHomePage.equals(RDMServicesConstants.VIEWS_TIMESHEETS) ? "checked" : ""%>>
											<a href="javascript:loadContent('manageTimesheetsView.jsp')">
												<%=resourceBundle.getProperty("DataManager.DisplayText.Manage_Timesheets")%></a>
											<%=sHomePage.equals(RDMServicesConstants.VIEWS_TIMESHEETS)
							? "(" + resourceBundle.getProperty("DataManager.DisplayText.Default_View") + ")" : ""%>
										</label>
									</div></li>


								<%
									}
										if (bViewProductvity1) {
								%>

								<li><div class="radio">
										<label for="shortLink"> <input type="radio"
											name="shortLink" id="shortLink"
											value="<%=RDMServicesConstants.VIEWS_PRODUCTIVITY%>"
											<%=sHomePage.equals(RDMServicesConstants.VIEWS_PRODUCTIVITY) ? "checked" : ""%>>
											<a href="javascript:loadContent('userProductivity.jsp')">
												<%=resourceBundle.getProperty("DataManager.DisplayText.Productivity")%></a>
											<%=sHomePage.equals(RDMServicesConstants.VIEWS_PRODUCTIVITY)
							? "(" + resourceBundle.getProperty("DataManager.DisplayText.Default_View") + ")" : ""%>
										</label>
									</div></li>

								<%
									}
								%>
							</ul> 
							<%
 	}
 %></li>
					</ul>

				</form>

			</div>
			<!-- END Page Content -->
		</div>
		<!-- END Main Container -->

	</div>
	<!-- END Page Container -->

	<form name="frm2" method="post" action="../LogoutServlet" target="_top">
		<input type="hidden" id="ip" name="ip" value=""> <input
			type="hidden" id="hostname" name="hostname" value=""> <input
			type="hidden" id="city" name="city" value=""> <input
			type="hidden" id="region" name="region" value=""> <input
			type="hidden" id="country" name="country" value="">
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
