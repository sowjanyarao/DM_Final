<%@page import="java.util.*"%>
<%@page import="com.client.*"%>
<%@page import="java.text.*"%>
<%@page import="com.client.util.*"%>
<%@page import="com.client.db.*"%>
<%@page import="com.client.views.*"%>

<jsp:useBean id="RDMSession" scope="session"
	class="com.client.ServicesSession" />

<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>
<%@include file="commonUtils.jsp"%>

<!DOCTYPE html>
<html class="no-js" lang="en">
<body>
	<div id="sidebar">
		<!-- Sidebar Brand -->
		<div id="sidebar-brand" class="themed-background">
			<a href="#"> <img src="../img/inventaa-H50.jpg"
				class="sidebar-title" alt="image">
			</a>
		</div>
		<!-- END Sidebar Brand -->
		<div id="sidebar-scroll">
			<!-- Sidebar Content -->
			<div class="sidebar-content">
				<!-- Sidebar Navigation -->
				<ul class="sidebar-nav">
					<%
							if(RDMServicesConstants.ROLE_TIMEKEEPER.equals(u.getRole()))
							{
%>
					<li><a href="javascript:reloadHeader('employeeInOutView.jsp')" class=" active"><i
							class="gi gi-compass sidebar-nav-icon"></i><span
							class="sidebar-nav-mini-hide"><%= resourceBundle.getProperty("DataManager.DisplayText.Attendance") %></span></a></li>
					<li class="sidebar-separator"><i class="fa fa-ellipsis-h"></i>
					</li>

					<li><a href="javascript:reloadHeader('viewReportsView.jsp')" class=" active"><i
							class="gi gi-compass sidebar-nav-icon"></i><span
							class="sidebar-nav-mini-hide"><%= resourceBundle.getProperty("DataManager.DisplayText.Reports") %></span></a></li>
					<li class="sidebar-separator"><i class="fa fa-ellipsis-h"></i>
					</li>

					<%
							}
							else
							{
%>
					<li><a href="javascript:reloadHeader('showGlobalAlerts.jsp')" class=" active"><i
							class="gi gi-compass sidebar-nav-icon"></i><span
							class="sidebar-nav-mini-hide"><%= resourceBundle.getProperty("DataManager.DisplayText.Home") %></span></a></li>
					<li class="sidebar-separator"><i class="fa fa-ellipsis-h"></i>
					</li>

					<li><a href="javascript:reloadHeader('short-links.jsp')"><i
							class="fa fa-link sidebar-nav-icon"></i><span
							class="sidebar-nav-mini-hide"><%= resourceBundle.getProperty("DataManager.DisplayText.Short_Links") %></span></a></li>
							

					<%
							}

							boolean bCreateTask = u.hasViewAccess(RDMServicesConstants.ACTIONS_CREATE_TASK);
							boolean bUpdateBNO = u.hasViewAccess(RDMServicesConstants.ACTIONS_UPDATE_BNO);

							if(bCreateTask || bUpdateBNO)
							{
								%>
								<li><a href="#" class="sidebar-nav-menu"><i
									class="fa fa-chevron-left sidebar-nav-indicator sidebar-nav-mini-hide"></i><i
									class="fa fa-share sidebar-nav-icon"></i><span
									class="sidebar-nav-mini-hide"><%= resourceBundle.getProperty("DataManager.DisplayText.Actions") %></span></a>
								<ul>
								
<%
									if(bCreateTask)
									{
%>
										<li><a href="javascript:popupContent('addUserTaskView.jsp', '550', '400')"><%= resourceBundle.getProperty("DataManager.DisplayText.Create_Task") %></a></li>
<%
									}
									if(bUpdateBNO)
									{
%>
										<li><a href="javascript:reloadHeader('manageBatchNosView.jsp')"><%= resourceBundle.getProperty("DataManager.DisplayText.Update_Batch_Nos") %></a></li>
											
<%
									}
%>
									</ul>
								</li>
<%								
								
							}

							boolean bViewGrwDB = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_GROWER);
							boolean bViewBnkDB = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_BUNKER);
							boolean bViewTnlDB = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_TUNNEL);
							boolean bViewSingle = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_SINGLE_ROOM);
							boolean bViewMultiGrw = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_GROWER);
							boolean bViewMultiBnk = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_BUNKER);
							boolean bViewMultiTnl = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_TUNNEL);
							
							if((bViewGrwDB || bViewBnkDB || bViewTnlDB) || bViewSingle || (bViewMultiGrw || bViewMultiBnk || bViewMultiTnl))
							{
%>
								<li><a href="#" class="sidebar-nav-menu"><i
									class="fa fa-chevron-left sidebar-nav-indicator sidebar-nav-mini-hide"></i><i
									class="fa fa-eye sidebar-nav-icon"></i><span
									class="sidebar-nav-mini-hide"><%= resourceBundle.getProperty("DataManager.DisplayText.Rooms_View") %></span></a>
								<ul>
<%
									if(bViewGrwDB || bViewBnkDB || bViewTnlDB)
									{
%>
										<li><a href="#" class="sidebar-nav-submenu open"><span
											class="sidebar-nav-ripple animate"
											style="height: 201px; width: 201px; top: -80.5px; left: 10.5px;"></span><i
											class="fa fa-chevron-left sidebar-nav-indicator"></i><%= resourceBundle.getProperty("DataManager.DisplayText.Dashboard") %></a>
											<ul>
<%
											if(bViewGrwDB)
											{
%>
												<li><a href="javascript:reloadHeader('dashboardView.jsp?cntrlType=Grower')"><%= resourceBundle.getProperty("DataManager.DisplayText.Grower") %></a></li>
																			
<%
											}
											if(bViewBnkDB)
											{
%>
												<li><a href="javascript:reloadHeader('dashboardView.jsp?cntrlType=cntrlType=Bunker')">
													<%= resourceBundle.getProperty("DataManager.DisplayText.Bunker") %></a>
												</li>
<%
											}
											if(bViewTnlDB)
											{
%>
												<li><a href="javascript:reloadHeader('dashboardView.jsp?cntrlType=Tunnel')">
													<%= resourceBundle.getProperty("DataManager.DisplayText.Tunnel") %></a>
												</li>
<%
											}
%>
											</ul></li>
<%
									}
									
									if(bViewSingle)
									{
%>									
										<li><a href="javascript:reloadHeader('singleRoomView.jsp')"><%= resourceBundle.getProperty("DataManager.DisplayText.Single_Room") %></a></li>
										
<%
									}
									
									if(bViewMultiGrw || bViewMultiBnk || bViewMultiTnl)
									{
%>
										<li><a href="#" class="sidebar-nav-submenu open"><span
											class="sidebar-nav-ripple animate"
											style="height: 201px; width: 201px; top: -80.5px; left: 10.5px;"></span><i
											class="fa fa-chevron-left sidebar-nav-indicator"></i><%= resourceBundle.getProperty("DataManager.DisplayText.Multi_Room") %></a>
										<ul>
										
<%
											if(bViewMultiGrw)
											{
%>
												<li><a href="javascript:reloadHeader('multiRoomView.jsp?cntrlType=Grower')"><%= resourceBundle.getProperty("DataManager.DisplayText.Grower") %></a></li>
												
<%
											}
											if(bViewMultiBnk)
											{
%>
												<li><a href="javascript:reloadHeader('multiRoomView.jsp?cntrlType=Bunker')">
													<%= resourceBundle.getProperty("DataManager.DisplayText.Bunker") %></a>
												</li>
<%
											}
											if(bViewMultiTnl)
											{
%>
												<li><a href="javascript:reloadHeader('multiRoomView.jsp?cntrlType=Tunnel')">
													<%= resourceBundle.getProperty("DataManager.DisplayText.Tunnel") %></a>
												</li>
<%
											}
%>
											</ul>
										</li>
<%
									}
%>
									</ul>
								</li>
<%
							}
							
							
							
							
							boolean bViewAttrGraph = u.hasViewAccess(RDMServicesConstants.VIEWS_GRAPH_ATTRDATA);
							boolean bViewProdGraph = u.hasViewAccess(RDMServicesConstants.VIEWS_GRAPH_PRODUCTIVITY);
							boolean bViewBatchLoad = u.hasViewAccess(RDMServicesConstants.VIEWS_GRAPH_BATCHLOAD);
							boolean bViewAlarms = u.hasViewAccess(RDMServicesConstants.VIEWS_ALARMS);
							boolean bViewLogs = u.hasViewAccess(RDMServicesConstants.VIEWS_LOGS);
							boolean bViewComments = u.hasViewAccess(RDMServicesConstants.VIEWS_COMMENTS);
							boolean bViewTasks = u.hasViewAccess(RDMServicesConstants.VIEWS_TASKS);
							boolean bViewYields = u.hasViewAccess(RDMServicesConstants.VIEWS_YIELDS);
							boolean bViewTimesheets = u.hasViewAccess(RDMServicesConstants.VIEWS_TIMESHEETS);
							boolean bViewReports = u.hasViewAccess(RDMServicesConstants.VIEWS_REPORTS);							
							boolean bViewProductvity = u.hasViewAccess(RDMServicesConstants.VIEWS_PRODUCTIVITY);
							
							if(bViewAttrGraph || bViewProdGraph || bViewBatchLoad || bViewAlarms || bViewLogs || bViewComments 
								|| bViewTasks || bViewYields || bViewTimesheets || bViewReports || bViewProductvity)
							{
%>
								<li><a href="#" class="sidebar-nav-menu"><i
									class="fa fa-chevron-left sidebar-nav-indicator sidebar-nav-mini-hide"></i><i
									class="gi gi-more_items sidebar-nav-icon"></i><span
									class="sidebar-nav-mini-hide"><%= resourceBundle.getProperty("DataManager.DisplayText.Views") %></span></a>
								<ul>
								
<%
									if(bViewAttrGraph || bViewProdGraph || bViewBatchLoad)
									{
%>
									<li><a href="#" class="sidebar-nav-submenu open"><span
											class="sidebar-nav-ripple animate"
											style="height: 201px; width: 201px; top: -80.5px; left: 10.5px;"></span><i
											class="fa fa-chevron-left sidebar-nav-indicator"></i><%= resourceBundle.getProperty("DataManager.DisplayText.Graph") %></a>
										<ul>

											<%
											if(bViewAttrGraph)
											{
%>
											<li><a href="javascript:reloadHeader('attribute-data.jsp')"><%= resourceBundle.getProperty("DataManager.DisplayText.Attribute_Data") %></a></li>

											<%
											}
											if(bViewProdGraph)
												{
%>
											<li><a href="javascript:reloadHeader('productivity.jsp')"><%= resourceBundle.getProperty("DataManager.DisplayText.Productivity") %></a></li>
											
<%
											}
											if(bViewBatchLoad)
												{
%>
											<li><a href="javascript:reloadHeader('batchload-duration.jsp')"><%= resourceBundle.getProperty("DataManager.DisplayText.Batch_Phase_Loads") %></a></li>
													
											<%
											}
%>
										</ul></li>
									<%
									}
									if(bViewAlarms)
									{
%>
									<li><a href="javascript:reloadHeader('alarms.jsp')"><%= resourceBundle.getProperty("DataManager.DisplayText.Alarms") %></a></li>
									<%
									}
									if(bViewLogs)
									{
%>
									<li><a href="javascript:reloadHeader('logs.jsp')"><%= resourceBundle.getProperty("DataManager.DisplayText.Logs") %></a></li>
									<%
									}
									if(bViewComments)
									{
%>
										<li><a href="javascript:reloadHeader('comments.jsp')"><%= resourceBundle.getProperty("DataManager.DisplayText.Comments") %></a></li>
<%
									}	
									if(bViewTasks)
									{
%>	
										<li><a href="javascript:reloadHeader('tasks.jsp')"><%= resourceBundle.getProperty("DataManager.DisplayText.Tasks") %></a></li>
<%
									}
									if(bViewYields)
									{
%>
										<li><a href="javascript:reloadHeader('yields.jsp')"><%= resourceBundle.getProperty("DataManager.DisplayText.Yields") %></a></li>
<%
									}
									if(bViewReports)
									{
%>
										<li><a href="javascript:reloadHeader('viewReportsView.jsp')"><%= resourceBundle.getProperty("DataManager.DisplayText.Reports") %></a></li>
<%
									}
									if(bViewTimesheets)
									{									
%>
										<li><a href="javascript:reloadHeader('timesheets.jsp')"><%= resourceBundle.getProperty("DataManager.DisplayText.Manage_Timesheets") %></a></li>
<%
									}
									
									if(bViewProductvity)
									{									
%>
										<li><a href="javascript:reloadHeader('userProductivity.jsp')"><%= resourceBundle.getProperty("DataManager.DisplayText.Productivity") %></a></li>
<%
									}
									
									if(RDMServicesConstants.ROLE_ADMIN.equals(u.getRole()) || RDMServicesConstants.ROLE_MANAGER.equals(u.getRole()))
									{									
%>
										<li><a href="javascript:reloadHeader('../custom/polmonDL120Details.jsp')"></a></li>
										
<%
									}
%>
									</ul>
								</li>
<%
							}							
							
%>					
							</ul>

					</div>
					<!-- END Sidebar Content -->
				</div>
				<!-- END Wrapper for scrolling functionality -->

		<!-- Sidebar Extra Info -->
		<div id="sidebar-extra-info"
			class="sidebar-content sidebar-nav-mini-hide">
			<div class="text-center">
				<small><span id="year-copy"></span> &copy; <a href="#"
					target="_blank">Inventaa</a></small>
			</div>
		</div>
		<!-- END Sidebar Extra Info -->
	</div>
	  <!-- END Main Sidebar -->
</body>
<script language="javascript">
	
		function reloadHeader(url) {
			document.location.href = "dashboard.jsp?showContent="+ url;
			//parent.frames['header'].location.href = "dashboard.jsp?showContent="+url;
		}  

		function popupContent(url, h, w) {
			var retval = window.open(url, '','left=200,top=100,resizable=no,scrollbars=no,status=no,toolbar=no,height='	+ h + ',width=' + w);
		}
</script>
</html>