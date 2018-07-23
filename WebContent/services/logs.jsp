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
		
		function showLogs()
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
			
			document.frm1.target = "results";
			document.frm1.submit();
		}
		
		function setSelected()
		{
			if(document.frm1.sysLogs.checked)
			{
				document.frm1.sysLogs.value = "Yes";
				document.frm1.params.value = "";
				document.frm1.params.disabled = true;
			}
			else
			{
				document.frm1.sysLogs.value = "No";
				document.frm1.params.disabled = false;
			}			
		}
	</script>
</head>

<%
	StringList slControllers = RDMSession.getControllers(u);
	Map<String, ArrayList<String[]>> mTypePhases = RDMServicesUtils.getControllerTypeStages();
%>
<body onLoad="setToDate()">
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

                            <h2>Logs</h2>
                        </div>
                        <!-- END General Elements Title -->

                        <!-- General Elements Content -->
                        <form name="frm1" action="logResults.jsp" method="post" class="form-horizontal form-bordered" >

                            <div class="form-group">
                                <label class="col-md-3 control-label" for="lstController"><%= resourceBundle.getProperty("DataManager.DisplayText.Room") %></label>
                                <div class="col-md-6">
                                    <select id="lstController" class="form-control" name="lstController">
						<option value="" ><%= resourceBundle.getProperty("DataManager.DisplayText.Please_Select") %></option>
<%
						String sCntrlName = "";
						for(int i=0; i<slControllers.size(); i++)
						{
							sCntrlName = slControllers.get(i);
%>
							<option value="<%= sCntrlName %>" ><%= sCntrlName %></option>
<%
						}
%>
					</select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="lstStage"><%= resourceBundle.getProperty("DataManager.DisplayText.Stage") %></label>
                                <div class="col-md-6">
                                    <select id="lstStage" class="form-control" name="lstStage">
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
                                <label class="col-md-3 control-label" for="example-text-input"><%= resourceBundle.getProperty("DataManager.DisplayText.Batch_No") %><br>
					<font color="blue"><%= resourceBundle.getProperty("DataManager.DisplayText.Batch_No_New_line") %></font></label>
                                <div class="col-md-6">
                                    <textarea id="BatchNo" name="BatchNo" rows="5" cols="15" class="form-control" placeholder="Text"></textarea>
                                </div>
                            </div>

                            <div class="form-group">
                                <label class="col-md-3 control-label" for="start_date"><%= resourceBundle.getProperty("DataManager.DisplayText.From_Date") %></label>
                                <div class="col-md-5">
                                    <input type="text" id="start_date" name="start_date" class="form-control input-datepicker" data-date-format="dd-mm-yyyy" placeholder="dd-mm-yyyy">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="end_date"><%= resourceBundle.getProperty("DataManager.DisplayText.To_Date") %></label>
                                <div class="col-md-5">
                                    <input type="text" id="end_date" name="end_date" class="form-control input-datepicker" data-date-format="dd-mm-yyyy" placeholder="dd-mm-yyyy">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="example-textarea-input"><%= resourceBundle.getProperty("DataManager.DisplayText.Search_Parameters") %><br>
					<font color="blue"><%= resourceBundle.getProperty("DataManager.DisplayText.Parameter_new_line") %></label>
                                <div class="col-md-9">
                                	<textarea id="params" name="params" rows="7" cols="25" class="form-control" placeholder="Description.."></textarea>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label">View System logs</label>
                                <div class="col-md-9">
                                    <div class="checkbox">
                                        <label for="checkbox">
                                                       <input type="checkbox" id="sysLogs" name="sysLogs" value="No" onClick="javascript:setSelected()">
														<%= resourceBundle.getProperty("DataManager.DisplayText.Yes") %>
                                                    </label>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="example-text-input">Batch No.</label>
                                <div class="col-md-6">
                                	<input type="text" id="limit" name="limit" size="5" value="500" class="form-control" placeholder="Text">
                                </div>
                            </div>
                            <div class="form-group form-actions">
                                <div class="col-md-9 col-md-offset-3">
                                    <button onClick="showLogs()" name="ViewLogs" type="submit" class="btn btn-effect-ripple btn-primary" style="overflow: hidden; position: relative;"><%= resourceBundle.getProperty("DataManager.DisplayText.Show_Logs") %></button>
                                </div>
                            </div>
						<input type="hidden" id="mode" name="mode" value="searchLogs">
                        </form>
                        <!-- END General Elements Content -->
                    </div>
                    <div class="block full"> 
                        
                        <div class="table-responsive">
                            <iframe name="results" src="logResults.jsp" align="middle" frameBorder="0" width="100%" height="<%= winHeight * 0.7 %>px"/>
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
