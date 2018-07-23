<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>

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
		function setDate()
		{
			var today = new Date();

			var dd1 = today.getDate();
			if(dd1 < 10)
			{
				dd1 = '0' + dd1;
			}
			
			var mm1 = today.getMonth() + 1;
			if(mm1 < 10)
			{
				mm1 = '0' + mm1;
			}
			
			var yy = today.getFullYear();
			
			var date = new Date();
			date.setDate(date.getDate()-1);	
			
			var dd2 = date.getDate();
			if(dd2 < 10)
			{
				dd2 = '0' + dd2;
			}
			
			var mm2 = today.getMonth();
			if(parseInt(dd2, 10) < parseInt(dd1, 10))
			{
				mm2 = mm2 + 1;
			}
			if(mm2 < 10)
			{
				mm2 = '0' + mm2;
			}

			document.getElementById('end_date').value = dd1 + "-" + mm1 + "-" + yy;
			document.getElementById('start_date').value = dd2 + "-" + mm2 + "-" + yy;
		}
		
		function validate()
		{
			if(document.getElementById('start_date').value == "")
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Please_Select_StartDate") %>");
				return false;
			}
			
			if(document.getElementById('end_date').value == "")
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Please_Select_EndDate") %>");
				return false;
			}
			
			var startDt = document.getElementById("start_date").value;
			var endDt = document.getElementById("end_date").value;
			var dt1  = parseInt(startDt.substring(0,2),10); 
			var mon1 = parseInt(startDt.substring(3,5),10);
			var yr1  = parseInt(startDt.substring(6,10),10); 
			var dt2  = parseInt(endDt.substring(0,2),10); 
			var mon2 = parseInt(endDt.substring(3,5),10); 
			var yr2  = parseInt(endDt.substring(6,10),10); 
			mon1 = mon1 - 1;
			mon2 = mon2 - 1;
			var date1 = new Date(yr1, mon1, dt1); 
			var date2 = new Date(yr2, mon2, dt2); 
			var today = new Date(); 

			if((date1 > today) || (date2 > today))
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Select_Date_Invalid") %>");
				return false;
			}

			if (date1 > date2)
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Start_date_Invalid") %>");
				return false;
			}
			
			return true;
		}
		
		function showGraph()
		{
			if(validate())
			{
				document.frm.target = "results";
				document.frm.submit();
			}
		}		
	</script>
</head>

<body onLoad="setDate()" style="background-color: #ffffff !important;">
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
       
            <!-- Main Container -->
            <div id="main-container">
              

                <!-- Page content -->
                <div id="page-content">

                    <div class="block">
                        <!-- General Elements Title -->
                        <div class="block-title">

                            <h2>Productivity</h2>
                        </div>
                        <!-- END General Elements Title -->

                        <!-- General Elements Content -->
                        <form action="showProductivityGraph.jsp" method="post" enctype="multipart/form-data" class="form-horizontal form-bordered" onsubmit="return false;">
                            <div class="form-group">
                                <label class="col-sm-3 control-label" for="userId"><b><%= resourceBundle.getProperty("DataManager.DisplayText.User_ID") %></b></label>
                                <div class="col-sm-6">
                                    <input type="text" id="userId" name="userId" value="" size="15" class="form-control" placeholder="Enter your User id">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="dept"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Department") %></b></label>
                                <div class="col-md-6">
                                <%
			Map <String, String> mDepartments = RDMServicesUtils.getDepartments();
			List<String> lDepartments = new ArrayList<String>(mDepartments.keySet());
			Collections.sort(lDepartments, String.CASE_INSENSITIVE_ORDER);
			String sDeptName = null;
			StringList slUserDept = new StringList();
			slUserDept.add(u.getDepartment());
			slUserDept.addAll(u.getSecondaryDepartments());
%>
                                                <select id="dept" name="dept" class="form-control">	
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
                                <label class="col-sm-3 control-label" for="example-input-normal"><b><%= resourceBundle.getProperty("DataManager.DisplayText.First_Name") %></b></label>
                                <div class="col-sm-6">
                                	<input type="text" id="FName" name="FName" value="" size="15" class="form-control" placeholder="First Name">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label" for="example-input-normal"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Last_Name") %></b></label>
                                <div class="col-sm-6">
                                	<input type="text" id="LName" name="LName" value="" size="15" class="form-control" placeholder="Last Name">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="start_date"><%= resourceBundle.getProperty("DataManager.DisplayText.Start_Date") %></label>
                                <div class="col-md-5">
                                	<input type="text" size="10" id="start_date" name="start_date" class="form-control input-datepicker" data-date-format="dd-mm-yyyy" placeholder="dd-mm-yyyy">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="example-datepicker"><%= resourceBundle.getProperty("DataManager.DisplayText.End_Date") %></label>
                                <div class="col-md-5">
                                    <input type="text" id="end_date" name="end_date" class="form-control input-datepicker" data-date-format="dd-mm-yyyy" placeholder="dd-mm-yyyy">
                                </div>
                            </div>
                            <div class="form-group form-actions">
                                <div class="col-md-9 col-md-offset-3">
                                	<input type="button" class="btn btn-effect-ripple btn-primary" name="search" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Show_Graph") %>" onClick="showGraph()">
                                </div>
                            </div>
                        </form>
                        <iframe name="results" src="showProductivityGraph.jsp" align="middle" frameBorder="0" width="100%" height="<%= winHeight * 0.8 %>px">
                        <!-- END General Elements Content -->
                    </div>
                </div>
                <!-- END Page Content -->
            </div>
            <!-- END Main Container -->
        </div>
        <!-- END Page Container -->

</body>

</html>
