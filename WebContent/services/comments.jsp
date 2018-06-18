<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>
<%@page import="com.client.reports.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<!DOCTYPE html>
<!--[if IE 9]>         <html class="no-js lt-ie10" lang="en"> <![endif]-->
<!--[if gt IE 9]><!-->
<html class="no-js" lang="en">
<!--<![endif]-->

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
    <script language="javascript">
		function setToDate()
		{
			var today = new Date();
			
			var dd = today.getDate();
			if(dd < 10)
			{
				dd = '0' + dd;
			}
			
			var mm = today.getMonth() + 1;
			if(mm < 10)
			{
				mm = '0' + mm;
			}
			
			var yy = today.getFullYear();

			document.getElementById('end_date').value = dd + "-" + mm + "-" + yy;
		}
		
		function showComments()
		{
			var date1;
			var fg = false;
			var today = new Date();
			
			if(document.getElementById('start_date').value != "")
			{
				var startDt = document.getElementById("start_date").value;
				var dt1  = parseInt(startDt.substring(0,2),10); 
				var mon1 = parseInt(startDt.substring(3,5),10);
				var yr1  = parseInt(startDt.substring(6,10),10); 
				mon1 = mon1 - 1;
				date1 = new Date(yr1, mon1, dt1);

				if(date1 > today)
				{
					alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Select_Date_Invalid") %>");
					return false;
				}
				fg = true;
			}
			
			if(document.getElementById('end_date').value != "")
			{
				var endDt = document.getElementById("end_date").value;
				var dt2  = parseInt(endDt.substring(0,2),10); 
				var mon2 = parseInt(endDt.substring(3,5),10); 
				var yr2  = parseInt(endDt.substring(6,10),10); 
				mon2 = mon2 - 1;
				var date2 = new Date(yr2, mon2, dt2); 
				
				if(date2 > today)
				{
					alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Select_Date_Invalid") %>");
					return false;
				}
				
				if(fg)
				{
					if (date1 > date2)
					{
						alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Start_date_Invalid") %>");
						return false;
					}
				}
			}
			
			document.frm.target = "results";
			document.frm.submit();
		}

		function setGlobal()
		{
			if(document.frm.global.checked)
			{
				document.frm.global.value = "Y";
			}
			else
			{
				document.frm.global.value = "N";
				document.frm.closed.value = "N";
				document.frm.closed.checked = false;
			}			
		}

		function setClosed()
		{
			if(document.frm.closed.checked)
			{
				document.frm.closed.value = "Y";
				document.frm.global.value = "Y";
				document.frm.global.checked = true;
			}
			else
			{
				document.frm.closed.value = "N";
			}			
		}

		function setLogByMe()
		{
			if(document.frm.logByMe.checked)
			{
				document.frm.logByMe.value = "Y";
			}
			else
			{
				document.frm.logByMe.value = "N";
			}			
		}
	</script>
</head>
<%
	StringList slControllers = RDMSession.getControllers();
	slControllers.addAll(RDMSession.getInactiveControllers());
	slControllers.sort();

	Map<String, ArrayList<String[]>> mTypePhases = RDMServicesUtils.getControllerTypeStages();
	
	StringList slUserDept = new StringList();
	slUserDept.add(u.getDepartment());
	slUserDept.addAll(u.getSecondaryDepartments());
	
	MapList mlTasks = RDMServicesUtils.getCommentTasks(slUserDept);
%>
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
                    <div class="block">
                        <!-- General Elements Title -->
                        <div class="block-title">

                            <h2><%= resourceBundle.getProperty("DataManager.DisplayText.Search_Comments") %></h2>
                        </div>
                        <!-- General Elements Content -->
                        <form name="frm" method="post" target="results" enctype="multipart/form-data" class="form-horizontal form-bordered" action="userCommentsResult.jsp">

                            <div class="form-group">
                                <label class="col-md-3 control-label" for="lstController"><%= resourceBundle.getProperty("DataManager.DisplayText.Room") %></label>
                                <div class="col-md-6">
                                    <select id="lstController" name="lstController">
						<option value=""><%= resourceBundle.getProperty("DataManager.DisplayText.Please_Select") %></option>
<%
						for(int i=0; i<slControllers.size(); i++)
						{
%>
							<option value="<%= slControllers.get(i) %>" ><%= slControllers.get(i) %></option>
<%
						}
%>
					</select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="lstStage"><%= resourceBundle.getProperty("DataManager.DisplayText.Stage") %></label>
                                <div class="col-md-6">
                                  <select id="lstStage" name="lstStage">
						<option value=""><%= resourceBundle.getProperty("DataManager.DisplayText.Please_Select") %></option>
<%
						String sPhaseSeq = "";
						String stageName = "";
						String sPhase = "";
						String sCntrlType = "";
						ArrayList<String[]> alPhases = null;

						Iterator<String> itr = mTypePhases.keySet().iterator();
						while(itr.hasNext())
						{
							sCntrlType = itr.next();
							alPhases = mTypePhases.get(sCntrlType);
%>
							<optgroup label="<%= resourceBundle.getProperty("DataManager.DisplayText."+sCntrlType) %>">
<%
							for(int i=0; i<alPhases.size(); i++)
							{
								sPhaseSeq = alPhases.get(i)[0];
								stageName = alPhases.get(i)[1];
								sPhase = (sPhaseSeq.equals(stageName) ? sPhaseSeq : stageName+"&nbsp;("+sPhaseSeq+")");
%>					
								<option value="<%= sPhaseSeq %>|<%= sCntrlType %>"><%= sPhase %></option>
<%
							}
						}
%>
					</select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="dept"><%= resourceBundle.getProperty("DataManager.DisplayText.Department") %></label>
                                <div class="col-md-6">
                                <%		
			Map <String, String> mDepartments = RDMServicesUtils.getDepartments();
			List<String> lDepartments = new ArrayList<String>(mDepartments.keySet());
			Collections.sort(lDepartments, String.CASE_INSENSITIVE_ORDER);
			String sDeptName = null;
%>
                                   <select id="dept" name="dept" style="width:125px">	
<%
					if(slUserDept.size() != 1)
					{
%>
						<option value="<%= ((slUserDept.size() == 0) ? "" : slUserDept.join('|')) %>" selected><%= resourceBundle.getProperty("DataManager.DisplayText.All") %></option>
<%
					}
					for(int j=0; j<lDepartments.size(); j++)
					{
						sDeptName = lDepartments.get(j);
						if(slUserDept.isEmpty() || slUserDept.contains(sDeptName))
						{
%>
							<option  value="<%= sDeptName %>"><%= sDeptName %></option>
<%
						}
					}
%>
					</select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="BatchNo"><%= resourceBundle.getProperty("DataManager.DisplayText.Batch_No") %><br/>
                                 <font color="blue">(<%= resourceBundle.getProperty("DataManager.DisplayText.Batch_No_New_line") %>)</font></label>
                               
                                <div class="col-md-6">
                                    <textarea id="BatchNo" name="BatchNo" rows="5" cols="15"></textarea>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="abbr"><%= resourceBundle.getProperty("DataManager.DisplayText.Text") %><br>
					<font color="blue">(<%= resourceBundle.getProperty("DataManager.DisplayText.Short_Description") %>)</label>
                                <div class="col-md-6">
                                   <select id="abbr" name="abbr" style="width:145px">
						<option value=""><%= resourceBundle.getProperty("DataManager.DisplayText.Please_choose_one") %></option>
<%
					Map<String, String> mTask = null;
					String sTaskId = "";
					String sTaskName = "";
					for(int i=0; i<mlTasks.size(); i++)
					{
						mTask = mlTasks.get(i);
						sTaskId = mTask.get(RDMServicesConstants.TASK_ID);
						sTaskName = mTask.get(RDMServicesConstants.TASK_NAME);
%>
						<option value="<%= sTaskId %>"><%= sTaskId %> (<%= sTaskName %>)</option>
<%
					}
%>
					</select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="start_date"><%= resourceBundle.getProperty("DataManager.DisplayText.From_Date") %></label>
                                <div class="col-md-5">
                                 <input type="text" size="10" id="start_date" name="start_date" readonly>
					<a href="#" onClick="setYears(2000, 2025);showCalender('a', 'start_date');"><img src="../images/calender.png"></a>
					<a href="#" onClick="javascript:document.getElementById('start_date').value=''"><img src="../images/clear.png"></a>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="end_date"><%= resourceBundle.getProperty("DataManager.DisplayText.To_Date") %></label>
                                <div class="col-md-5">
                                   <input type="text" size="10" id="end_date" name="end_date" readonly>
					<a href="#" onClick="setYears(2000, 2025);showCalender('b', 'end_date');"><img src="../images/calender.png"></a>
					<a href="#" onClick="javascript:document.getElementById('end_date').value=''"><img src="../images/clear.png"></a>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label"><%= resourceBundle.getProperty("DataManager.DisplayText.Logged_By_Me") %></label>
                                <div class="col-md-9">
                                    <div class="checkbox">
                                        <label for="logByMe">
                                                       	<input type="checkbox" id="logByMe" name="logByMe" value="N" onClick="javascript:setLogByMe()">
					<%= resourceBundle.getProperty("DataManager.DisplayText.Yes") %> 
                                                    </label>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label"><%= resourceBundle.getProperty("DataManager.DisplayText.Show_Alerts") %></label>
                                <div class="col-md-9">
                                    <div class="checkbox">
                                        <label for="global">
                                                        <input type="checkbox" id="global" name="global" value="N" onClick="javascript:setGlobal()">
					<%= resourceBundle.getProperty("DataManager.DisplayText.Yes") %>
                                                    </label>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label"><%= resourceBundle.getProperty("DataManager.DisplayText.Include_Closed") %></label>
                                <div class="col-md-9">
                                    <div class="checkbox">
                                        <label for="closed">
                                                       <input type="checkbox" id="closed" name="closed" value="N" onClick="javascript:setClosed()">
					<%= resourceBundle.getProperty("DataManager.DisplayText.Yes") %>		
                                                    </label>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="limit"><%= resourceBundle.getProperty("DataManager.DisplayText.Limit_Results") %></label>
                                <div class="col-md-6">
                                    <input type="text" id="limit" name="limit" size="5" value="500">
                                </div>
                            </div>
                            <div class="form-group form-actions">
                                <div class="col-md-9 col-md-offset-3">
                                	<input type="button" name="ViewComments" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Show_Comments") %>" onClick="showComments()" class="btn btn-effect-ripple btn-primary" style="overflow: hidden; position: relative;">
                                </div>
                            </div>
							<input type="hidden" id="mode" name="mode" value="searchComments">
                        </form>
                        <!-- END General Elements Content -->
                        <!-- General Elements Content -->
						     <div class="block full"> 
                        
                        	<div class="table-responsive">
								<iframe name="results" src="userCommentsResult.jsp" align="middle" frameBorder="0" width="100%" height="<%= winHeight * 0.7 %>px"/>
							</div>
						</div>
                        <!-- END General Elements Content -->
                    </div>
                                       
                </div>
                <!-- END Page Content -->
            </div>
            <!-- END Main Container -->
        </div>
        <!-- END Page Container -->
    </div>
    <!-- END Page Wrapper -->

</body>

</html>
