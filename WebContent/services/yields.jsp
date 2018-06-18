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
			today.setDate(today.getDate()+2);	

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
			
			var yy1 = today.getFullYear();
			
			var date = new Date();
			date.setDate(date.getDate()-5);	
			
			var dd2 = date.getDate();
			if(dd2 < 10)
			{
				dd2 = '0' + dd2;
			}
			
			var mm2 = date.getMonth() + 1;
			if(mm2 < 10)
			{
				mm2 = '0' + mm2;
			}
			
			var yy2 = date.getFullYear();

			document.getElementById('end_date').value = dd1 + "-" + mm1 + "-" + yy1;
			document.getElementById('start_date').value = dd2 + "-" + mm2 + "-" + yy2;
		}
		
		function showYields()
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
				
				if(fg)
				{
					if (date1 > date2)
					{
						alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Start_date_Invalid") %>");
						return false;
					}
				}
			}
			
			var yield = document.getElementById('yield').value;
			if(yield != "")
			{
				if(isNaN(yield))
				{
					alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Yield_NAN") %>");
					return false;
				}				
			}
			
			document.frm.target = "results";
			document.frm.submit();
		}
	</script>
</head>

	<%
	StringList slControllers = RDMSession.getControllers();
	slControllers.addAll(RDMSession.getInactiveControllers());
	slControllers.sort();
%>
<body onLoad="setDate()">
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
          
            <!-- Main Container -->
            <div id="main-container">
                <jsp:include page="header.jsp" />
				  <jsp:include page="header-sidebar.jsp">
					<jsp:param name="u" value="${u}" />
				  </jsp:include>
			 	<jsp:include page="sidebar.jsp" />
               

                <!-- Page content -->
                <div id="page-content">
                    <div class="block">
                        <!-- General Elements Title -->
                        <div class="block-title">

                            <h2>Yields</h2>
                        </div>
                        <!-- END General Elements Title -->

                        <!-- General Elements Content -->
                        <form action="page_forms_components.html" method="post" enctype="multipart/form-data" class="form-horizontal form-bordered" onsubmit="return false;">
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="lstController"><%= resourceBundle.getProperty("DataManager.DisplayText.Room") %></label>
                                <div class="col-md-6">
                                   <select id="lstController" name="lstController" multiple size="5">
						<option value=""><%= resourceBundle.getProperty("DataManager.DisplayText.All_Rooms") %></option>
						<optgroup label="<%= resourceBundle.getProperty("DataManager.DisplayText.Select_Rooms") %>">
<%
						String sCntrl = "";
						for(int i=0; i<slControllers.size(); i++)
						{
							sCntrl =  slControllers.get(i);
							if(!RDMServicesUtils.isGeneralController(sCntrl))
							{
%>
								<option value="<%= sCntrl %>" ><%= sCntrl %></option>
<%
							}
						}
%>
					</select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="BatchNo"><%= resourceBundle.getProperty("DataManager.DisplayText.Batch_No") %><br>
					<font color="blue">(<%= resourceBundle.getProperty("DataManager.DisplayText.Batch_No_New_line") %>).</font></label>
                                <div class="col-md-6">
                                    <textarea id="BatchNo" name="BatchNo" rows="5" cols="15"></textarea>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="cond"><%= resourceBundle.getProperty("DataManager.DisplayText.Yield") %></label>
                                <div class="col-md-6">
                                    <select id="cond" name="cond">
						<option value="equals"></option>
						<option value="morethan"><%= resourceBundle.getProperty("DataManager.DisplayText.More_Than") %></option>
						<option value="lessthan"><%= resourceBundle.getProperty("DataManager.DisplayText.Less_Than") %></option>&nbsp;
					</select>
					<input type="text" id="yield" name="yield" value="" size="5">
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
                                <label class="col-md-3 control-label"  id="groupBy"><%= resourceBundle.getProperty("DataManager.DisplayText.Group_By") %></label>
                                <div class="col-md-9">
                                                   <input type="radio" name="groupBy" id="groupBy" value="batch">
					<%= resourceBundle.getProperty("DataManager.DisplayText.Batch") %>
                                                  <input type="radio" name="groupBy" id="groupBy" value="date" checked>
					<%= resourceBundle.getProperty("DataManager.DisplayText.Date") %>

                                </div>
                            </div>
                            <div class="form-group form-actions">
                                <div class="col-md-9 col-md-offset-3">
									<input type="button" class="btn btn-effect-ripple btn-primary" style="overflow: hidden; position: relative;" name="ViewYields" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Show_Yields") %>" onClick="showYields()">
                                </div>
                            </div>

                        </form>
                        <!-- END General Elements Content -->
                    </div>
                    <div class="block full"> 
                        
                        <div class="table-responsive">
                          <iframe name="results" src="viewYieldsResult.jsp" align="middle" frameBorder="0" width="100%" height="<%= winHeight * 0.7 %>px"/>
                        </div>
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
