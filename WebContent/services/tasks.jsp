<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>
<%
	StringList slUserDept = new StringList();
	slUserDept.add(u.getDepartment());
	slUserDept.addAll(u.getSecondaryDepartments());

	MapList mlControllers = RDMServicesUtils.getRoomsList();
	mlControllers.sort(RDMServicesConstants.ROOM_ID);
	MapList mlTasks = RDMServicesUtils.getAdminTasks(slUserDept);
%>
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

    <!-- Include a specific file here from ../css/themes/ folder to alter the default theme of the template -->

    <!-- The themes stylesheet of this template (for using specific theme color in individual elements - must included last) -->
    <link rel="stylesheet" href="../css/themes.css">
    <!-- END Stylesheets -->

    <!-- Modernizr (browser feature detection library) -->
    <script src="../js/vendor/modernizr-3.3.1.min.js"></script>
    
     <!-- jQuery, Bootstrap, jQuery plugins and Custom JS code -->
    <script src="../js/vendor/jquery-2.2.4.min.js"></script>
    <script src="../js/vendor/bootstrap.min.js"></script>
    <script src="../js/plugins.js"></script>
    <script src="../js/app.js"></script>

    <!-- Load and execute javascript code used only in this page -->
    <script src="../js/pages/uiTables.js"></script>
    <script>
        $(function() {
            UiTables.init();
        });

    </script>
    <script>
        $('.collapse').collapse()
    </script>
    
    <style type="text/css">		
		td.txtLabel
		{
			border: solid 1px #ffffff;
			text-align: left;
			background-color: #888888;
			color: #ffffff;
			font-size:12px;
			font-family:Arial,sans-serif;
			font-weight: bold;
		}
	</style>

	<script type="text/javascript">
		//<![CDATA[
		$(document).ready(function(){
			$(".js-example-basic-multiple").select2();
		});
		
		//]]>s
	</script>
	
	<script language="javascript">
		function searchTasks()
		{
			document.frm.target = "results";
			document.frm.submit();
		}
		function exportTasks() {
			var childTasks = document.getElementById('childTasks').checked;
			var parentTasks = document.getElementById('parentTasks').checked;
			var coOwners = document.getElementById('coOwners').checked;
			var limit = document.getElementById('limit').value;
			if (limit == "") {
				limit = "-1";
			}

			var cnt = 0;
			var sTaskIds = "";
			var selTaskIds = document.getElementById('taskId');
			for (i = 0; i < selTaskIds.length; i++) {
				if (selTaskIds[i].selected == true && selTaskIds[i].value != "") {
					if (cnt > 0) {
						sTaskIds += "','";
					}
					sTaskIds += selTaskIds[i].value;
					cnt++;
				}
			}

			var url = "../ExportUserTasks";
			url += "?taskName=";
			url += "&taskId=" + sTaskIds;
			url += "&room=" + document.getElementById('room').value;
			url += "&dept=" + document.getElementById('dept').value;
			url += "&owner=" + document.getElementById('owner').value;
			url += "&assignee=" + document.getElementById('assignee').value;
			url += "&status=" + document.getElementById('status').value;
			url += "&start_date=" + document.getElementById('start_date').value;
			url += "&end_date=" + document.getElementById('end_date').value;
			url += "&batch=" + document.getElementById('batch').value;
			url += "&stage=" + document.getElementById('stage').value;
			url += "&childTasks=" + childTasks;
			url += "&parentTasks=" + parentTasks;
			url += "&coOwners=" + coOwners;
			url += "&limit=" + limit;

			document.location.href = url;
		}
	</script>
</head>

<body onLoad="searchTasks()">
<form name="frm" method="post" target="results"
		action="userTasksResults.jsp">
		<input type="hidden" id="mode" name="mode" value="search">
    <div id="page-wrapper" class="page-loading">
        <div class="preloader">
            <div class="inner">
                <!-- Animation spinner for all modern browsers -->
                <div class="preloader-spinner themed-background hidden-lt-ie10"></div>

                <!-- Text for IE9 -->
                <h3 class="text-primary visible-lt-ie10"><strong>Loading..</strong></h3>
            </div>
        </div>
        <!-- END Preloader -->
        <div id="page-container" class="header-fixed-top sidebar-visible-lg-full">
           <jsp:include page="header.jsp" />
			<jsp:include page="header-sidebar.jsp">
			  <jsp:param name="u" value="${u}" />
			</jsp:include>
			<jsp:include page="sidebar.jsp" />
           
            <!-- Main Container -->
            <div id="main-container">
                
                <!-- Page content -->
                <div id="page-content">
                    <div class="row">
                        <div class="col-sm-4 col-md-2">
                            <!-- Input States Block -->
                            <div class="block">
                                <!-- Input States Title -->
                                <div class="block-title">

                                    <h2>TASK</h2>
                                </div>
                                <div class="form-group">

										<select  id="taskId" name="taskId" class="form-control" size="5"
											multiple="">
											<option value="" selected><%=resourceBundle.getProperty("DataManager.DisplayText.All")%></option>
											<%
												Map<String, String> mTask = null;
												String sTaskId = "";
												String sTaskName = "";
												for (int i = 0; i < mlTasks.size(); i++) {
													mTask = mlTasks.get(i);
													sTaskId = mTask.get(RDMServicesConstants.TASK_ID);
													sTaskName = mTask.get(RDMServicesConstants.TASK_NAME);
											%>
											<option value="<%=sTaskId%>"><%=sTaskId%> (<%=sTaskName%>)
											</option>
											<%
												}
											%>
										</select>
									</div>
                            </div>

                        </div>
                        <div class="col-sm-4 col-md-2">
                            <!-- Input States Block -->
                            <div class="block">
                                <!-- Input States Title -->
                                <div class="block-title">

                                    <h2>Please Select</h2>
                                </div>
                                <!-- END Input States Title -->

                                <!-- Input States Content -->

                                <div class="form-group">


										<select id="status" name="status"
											class="form-control" size="1">
											<option value=""><%=resourceBundle.getProperty("DataManager.DisplayText.All")%></option>
											<option
												value="<%=RDMServicesConstants.TASK_STATUS_NOT_STARTED%>"><%=resourceBundle.getProperty("DataManager.DisplayText.Task_Status_Not_Started")%></option>
											<option value="<%=RDMServicesConstants.TASK_STATUS_WIP%>"
												selected><%=resourceBundle.getProperty("DataManager.DisplayText.Task_Status_In_Progress")%></option>
											<option
												value="<%=RDMServicesConstants.TASK_STATUS_COMPLETED%>"><%=resourceBundle.getProperty("DataManager.DisplayText.Task_Status_Completed")%></option>
											<option
												value="<%=RDMServicesConstants.TASK_STATUS_CANCELLED%>"><%=resourceBundle.getProperty("DataManager.DisplayText.Task_Status_Cancelled")%></option>
										</select> 
										<select id="room" name="room"
											class="form-control" size="1">
											<option value=""><%=resourceBundle.getProperty("DataManager.DisplayText.All")%></option>
											<option value="<%=RDMServicesConstants.NO_ROOM%>"><%=resourceBundle.getProperty("DataManager.DisplayText.Not_Specified")%></option>
											<%
												Map<String, String> mInfo = null;
												String cntrlType = null;
												String controller = null;
												for (int i = 0, iSz = mlControllers.size(); i < iSz; i++) {
													mInfo = mlControllers.get(i);
													controller = mInfo.get(RDMServicesConstants.ROOM_ID);
													cntrlType = mInfo.get(RDMServicesConstants.CNTRL_TYPE);
													if (!(RDMServicesConstants.TYPE_GENERAL_GROWER.equals(cntrlType)
															|| RDMServicesConstants.TYPE_GENERAL_BUNKER.equals(cntrlType)
															|| RDMServicesConstants.TYPE_GENERAL_TUNNEL.equals(cntrlType))) {
											%>
											<option value="<%=controller%>"><%=controller%></option>
											<%
												}
												}
											%>
										</select>
										<%
											Map<String, String> mDepartments = RDMServicesUtils.getDepartments();
											List<String> lDepartments = new ArrayList<String>(mDepartments.keySet());
											Collections.sort(lDepartments, String.CASE_INSENSITIVE_ORDER);
											String sDeptName = null;
										%>
										<select id="dept" name="dept"
											class="form-control" size="1">
											<%
												if (slUserDept.size() != 1) {
											%>
											<option
												value="<%=((slUserDept.size() == 0) ? "" : slUserDept.join('|'))%>"
												selected><%=resourceBundle.getProperty("DataManager.DisplayText.All")%></option>
											<%
												}
												for (int j = 0; j < lDepartments.size(); j++) {
													sDeptName = lDepartments.get(j);
													if (slUserDept.isEmpty() || slUserDept.contains(sDeptName)) {
											%>
											<option value="<%=sDeptName%>"><%=sDeptName%></option>
											<%
												}
												}
											%>
										</select>

									</div>
                                <!-- END Input States Content -->
                            </div>
                        </div>
                        <div class="col-sm-4 col-md-2">
                            <!-- Input States Block -->
                            <div class="block">
                                <!-- Input States Title -->
                                <div class="block-title">

                                    <h2>Please Select</h2>
                                </div>
                                <div class="form-group">

										<div class="radio">
											<label for="searchType"> <input type="radio"
												name="searchType" id="searchType"
												value="<%=RDMServicesConstants.ROOM_BASED%>" checked>
												<%=resourceBundle.getProperty("DataManager.DisplayText.Room")%>
											</label>
										</div>
										<div class="radio">
											<label for="searchType"> <input type="radio"
												name="searchType" id="searchType"
												value="<%=RDMServicesConstants.USER_BASED%>"> <%=resourceBundle.getProperty("DataManager.DisplayText.User")%>
											</label>
										</div>
										<div class="radio">
											<label for="searchType"> <input type="radio"
												name="searchType" id="searchType"
												value="<%=RDMServicesConstants.DATE_BASED%>"> <%=resourceBundle.getProperty("DataManager.DisplayText.Date")%>
											</label>
										</div>

									</div>
                            </div>
                        </div>
                        <div class="col-sm-4 col-md-2">
                            <!-- Input States Block -->
                            <div class="block">
                                <!-- Input States Title -->
                                <div class="block-title">

                                    <h2>Please Select</h2>
                                </div>
									<div class="form-group">
										<div class="checkbox">
											<label for="parentTasks" > <input type="checkbox"
												id="parentTasks" name="parentTasks" value="Y">
											<%=resourceBundle.getProperty("DataManager.DisplayText.Include_Parent_Tasks")%>
											</label>
										</div>
										<div class="checkbox">
											<label for="childTasks"> <input type="checkbox"
												id="childTasks" name="childTasks" value="Y" checked>
												<%=resourceBundle.getProperty("DataManager.DisplayText.Include_Child_Tasks")%>
											</label>
										</div>
										<div class="checkbox">
											<label for="coOwners"> <input type="checkbox"
												id="coOwners" name="coOwners" value="Y">
												<%=resourceBundle.getProperty("DataManager.DisplayText.Search_CoOwners")%>
											</label>
										</div>
										<div class="form-control">
											<label for="limit"> <input type="text" id="limit"
												name="limit" size="5" value="500">
												<%=resourceBundle.getProperty("DataManager.DisplayText.Limit_Results")%>
											</label>
										</div>
									</div>
								</div>
                        </div>
                        <div class="col-sm-4 col-md-2">
                            <!-- Input States Block -->
                            <div class="block">
                                <!-- Input States Title -->
                                <div class="block-title">

                                    <h2>Please Select</h2>
                                </div>
									<div class="form-group">

										<label class="col-md-3 control-label" for="assignee"><%=resourceBundle.getProperty("DataManager.DisplayText.Assignee")%></label>
										<select id="assignee" name="assignee" class="form-control"
											size="1">
											<option value=""><%=resourceBundle.getProperty("DataManager.DisplayText.All")%></option>
											<%
												MapList mlAssignees = RDMServicesUtils.getAssigneeList(slUserDept, true);
												String userId = null;
												String userName = null;
												for (int i = 0, iSz = mlAssignees.size(); i < iSz; i++) {
													mInfo = mlAssignees.get(i);
													userId = mInfo.get(RDMServicesConstants.USER_ID);
													userName = mInfo.get(RDMServicesConstants.DISPLAY_NAME);
											%>
											<option value="<%=userId%>"><%=userName%>&nbsp;(<%=userId%>)
											</option>
											<%
												}
											%>
										</select>
										<%
										if (RDMServicesConstants.ROLE_ADMIN.equals(u.getRole())
										|| RDMServicesConstants.ROLE_MANAGER.equals(u.getRole())) {
										%>
										<label class="col-md-3 control-label" for="owner"><%=resourceBundle.getProperty("DataManager.DisplayText.Owner")%></label>
										<select id="owner" name="owner"
											class="form-control" size="1">
											<option value=""><%=resourceBundle.getProperty("DataManager.DisplayText.All")%></option>
											<%
											MapList mlOwners = RDMServicesUtils.getTaskOwners(slUserDept, true);
											for (int i = 0, iSz = mlOwners.size(); i < iSz; i++) {
											mInfo = mlOwners.get(i);
											userId = mInfo.get(RDMServicesConstants.USER_ID);
											userName = mInfo.get(RDMServicesConstants.DISPLAY_NAME);
											%>
											<option value="<%=userId%>"><%=userName%>&nbsp;(<%=userId%>)
											</option>
											<%
											}
											%>
										</select>
										<%
 										} else {
 										%> <input type="text" id="ownerName" name="ownerName"
										style="width: 125px"
										value="<%=u.getLastName()%>, <%=u.getFirstName()%>" readonly
										disabled> <input type="hidden" id="owner" name="owner"
										value="<%=u.getUser()%>"> <%
 										}
 										%>
									</div>
								</div>
                        </div>
                        <div class="col-sm-4 col-md-2">
                            <!-- Input States Block -->
                            <div class="block">
                                <!-- Input States Title -->
                                <div class="block-title">

                                    <h2>Input States</h2>
                                </div>
                                <div class="form-group">
                                    <div class="form-group">
                                        <input type="text" id="example-text-input" name="example-text-input" class="form-control" placeholder="Batch no.">
                                    </div>
                                    <select id="stage" name="stage" class="form-control" size="1">
											<option value=""><%=resourceBundle.getProperty("DataManager.DisplayText.All")%></option>
											<%
												Map<String, ArrayList<String[]>> mTypePhases = RDMServicesUtils.getControllerTypeStages();
												String sPhaseSeq = "";
												String stageName = "";
												String sPhase = "";
												String sCntrlType = "";
												ArrayList<String[]> alPhases = null;

												Iterator<String> itr = mTypePhases.keySet().iterator();
												while (itr.hasNext()) {
													sCntrlType = itr.next();
													alPhases = mTypePhases.get(sCntrlType);
											%>
											<optgroup
												label="<%=resourceBundle.getProperty("DataManager.DisplayText." + sCntrlType)%>">
												<%
													for (int i = 0; i < alPhases.size(); i++) {
															sPhaseSeq = alPhases.get(i)[0];
															stageName = alPhases.get(i)[1];
															sPhase = (sPhaseSeq.equals(stageName) ? sPhaseSeq : stageName + "&nbsp;(" + sPhaseSeq + ")");
												%>
												<option value="<%=sPhaseSeq%>|<%=sCntrlType%>"><%=sPhase%></option>
												<%
													}
													}
												%>
											
										</select>
                                </div>
                            </div>
                        </div>
                        <div>
								<table border="0" cellpadding="1" cellspacing="1" width="98%">
									<tr> 
									   <td width="2%"></td>
										<td align="left" width="5%">
											<div id="actions">
												<input type="button" id="start" name="start" class="btn btn-primary"
													value="<%=resourceBundle.getProperty("DataManager.DisplayText.Task_Start")%>"
													onClick="javascript:frames['results'].startTasks()">
												
												<input type="button" id="complete" name="complete" class="btn btn-primary"
													value="<%=resourceBundle.getProperty("DataManager.DisplayText.Task_Complete")%>"
													onClick="javascript:frames['results'].completeTasks()">
												
												<input type="button" id="delete" name="delete" class="btn btn-primary"
													value="<%=resourceBundle.getProperty("DataManager.DisplayText.Task_Delete")%>"
													onClick="javascript:frames['results'].deleteTasks()">
											</div>
										</td>
										<td>&nbsp;</td>
										<td align="left" width="5%">
											<div id="downloadbtn">
												<input type="button" id="download" name="download" class="btn btn-primary"
													value="<%=resourceBundle.getProperty("DataManager.DisplayText.Download")%>"
													onClick="javascript:frames['results'].download()">
											</div>
										</td>
										<td>&nbsp;</td>
										<td align="left" width="5%">
											<div id="copybtn">
												<input type="button" id="copy" name="copy" class="btn btn-primary"
													value="<%=resourceBundle.getProperty("DataManager.DisplayText.Task_Copy")%>"
													onClick="javascript:frames['results'].copyTasks()">
											</div>
										</td>
										<td align="right" width="70%"></td>
										<td align="right" width="5%">
											<%
												if (RDMServicesConstants.ROLE_ADMIN.equals(u.getRole())) {
											%> <input type="button" id="ExportTasks" name="ExportTasks" class="btn btn-primary"
											value="<%=resourceBundle.getProperty("DataManager.DisplayText.Export_Tasks")%>"
											onClick="exportTasks()"> <%
 	}
 %>
										</td>
										<td>&nbsp;</td>
										<td align="right" width="5%"><input type="button" class="btn btn-primary"
											name="SearchTasks"
											value="<%=resourceBundle.getProperty("DataManager.DisplayText.Search_Tasks")%>"
											onClick="searchTasks()"></td>
									</tr>
									<tr></tr>
							</table>
						</div>
                    </div>
                    
                   
   					 <div class="block full">

                        <div class="block-title">
                            <h2>Datatables</h2>
								<table class="table table-striped table-bordered table-vcenter">
									<tr height="25pt" width="100%">
										<td class="txtLabel" width="10%"><div id="taskInfo_id"></div></td>
										<td class="input" width="50%"><div id="taskInfo_notes"></div></td>
										<td class="input" width="40%"><div id="taskInfo_size"></div></td>
									</tr>
								</table>
								<iframe name="results" src="userTasksResults.jsp" align="middle" frameBorder="0" width="100%" height="<%= winHeight * 0.7 %>px">
                            <!--  <div id="datatables"><b>data will be displayed here</b></div>-->
                        </div>
                        
                    </div>
                    <!-- END Datatables Block -->
                </div>

                <!-- END Page Content -->
            </div>

            <!-- END Main Container -->
        </div>


        <!-- END Page Container -->
    </div>

    <!-- END Page Wrapper -->

   </form>
 
</body>

</html>
