<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.io.*" %>
<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>
<%@page import="org.apache.commons.fileupload.FileItem" %>
<%@page import="org.apache.commons.fileupload.FileItemFactory" %>
<%@page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>

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
    <script src="../js/vendor/modernizr-3.3.1.min.js"/>
  
	<script language="javaScript" type="text/javascript" src="../scripts/calendar.js"></script>
	<script src="../js/vendor/jquery-2.2.4.min.js"></script>
    <script src="../js/vendor/bootstrap.min.js"></script>
    <script src="../js/plugins.js"></script>
    <script src="../js/app.js"></script>
    <!-- Load and execute javascript code used only in this page -->
    <script src="../js/pages/readyDashboard.js"></script>
    <script language="javascript">		
		var idx = 0;
		function showGraph()
		{
			var val = validate();
			if(val)
			{
				idx = idx + 1;
				document.frm.target = "POPUPW_"+idx;
				POPUPW = window.open('about:blank','POPUPW_'+idx,'menubar=no,toolbar=no,location=no,resizable=yes,scrollbars=yes,status=no,height=<%= winHeight * 0.85 %>px,width=<%= winWidth * 0.90 %>px');			
				document.frm.submit();
			}
			
			return false;
		}
		
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
			
			var yy1 = today.getFullYear();
			
			var date = new Date();
			date.setDate(date.getDate()-1);	
			
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
		
		function validate()
		{
			if(document.getElementById('lstController').value == "")
			{
				alert("Please select a Room");
				return false;
			}
			
			if(document.getElementById('lstParams').value == "")
			{
				alert("Please select the Parameters");
				return false;
			}
			
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
		
		function loadSavedParams()
		{
			var name = document.getElementById('lstGraphs').value;
			var type = document.getElementById('cntrlType').value;
			if(name != "")
			{
				document.location.href = "loadSavedGraphParams.jsp?name="+name+"&type="+type;
			}
			else
			{
				document.getElementById('cntrlType').value = "";
				
				var rooms = document.getElementById('lstController');
				for(i=0; i<rooms.length; i++)
				{
					if(rooms[i].value == "")
					{
						rooms[i].selected = true;
					}
					else
					{
						rooms[i].selected = false;
					}
				}

				var lstParams = document.getElementById('lstParams');
				if(lstParams.options != null)
				{
					while(lstParams.options.length > 0)
					{
						lstParams.remove(0);
					}
				}
			}
		}
		
		function loadGraphParams()
		{
			var name = document.getElementById('lstController').value;
			var type = document.getElementById('cntrlType').value;
			if(name != "")
			{
				document.location.href = "loadGraphParams.jsp?name="+name+"&type="+type;
			}
			else
			{
				document.getElementById('cntrlType').value = "";
				
				var graphs = document.getElementById('lstGraphs');
				for(i=0; i<graphs.length; i++)
				{
					if(graphs[i].value == "")
					{
						graphs[i].selected = true;
					}
					else
					{
						graphs[i].selected = false;
					}
				}

				var lstParams = document.getElementById('lstParams');
				if(lstParams.options != null)
				{
					while(lstParams.options.length > 0)
					{
						lstParams.remove(0);
					}
				}
			}
		}
		
		function deleteGraph()
		{
			var name = document.getElementById('lstGraphs').value;
			if(name == "")
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Choose_Delete_Graph") %>");
				return;
			}

			document.location.href = "deleteSavedGraph.jsp?savedGraph="+name;
		}
		
		function setSelected()
		{
			if(document.frm.yield.checked)
			{
				document.frm.yield.value = "Yes";
			}
			else
			{
				document.frm.yield.value = "No";
			}			
		}
	</script>
</head>
<%
	StringList slControllers = RDMSession.getControllers(u);	
	StringList slGraphs = u.getSavedGraphs();
%>

<body onLoad="setDate()">
<input type="hidden" id="cntrlType" name="cntrlType" value="">
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

                            <h2>Attribute Data</h2>
                        </div>
                        <!-- END General Elements Title -->

                        <!-- General Elements Content -->
                        <form  name="frm" method="post" class="form-horizontal form-bordered" action="showAttrDataGraph.jsp">

                            <div class="form-group">
                                <label class="col-md-3 control-label" for="lstGraphs"><%= resourceBundle.getProperty("DataManager.DisplayText.Saved_Graphs") %></label>
                                <div class="col-md-6">
                                                <select id='lstGraphs' name='lstGraphs' class="form-control" onChange="loadSavedParams()">
						<option value="" ><%= resourceBundle.getProperty("DataManager.DisplayText.Please_Select") %></option>
<%
						String sGraph = "";
						for(int i=0; i<slGraphs.size(); i++)
						{
							sGraph = slGraphs.get(i);
%>
							<option value="<%= sGraph %>"><%= sGraph %></option>
<%
						}
%>
					</select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="lstController"><%= resourceBundle.getProperty("DataManager.DisplayText.Room") %></label>
                                <div class="col-md-6">
                                    <select id="lstController" name="lstController" onChange="loadGraphParams()">
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
                                <label class="col-md-3 control-label" for="start_date"><%= resourceBundle.getProperty("DataManager.DisplayText.Start_Date") %></label>
                                <div class="col-md-5">
                                    <input type="text" id="start_date" name="start_date" class="form-control input-datepicker" data-date-format="dd-mm-yyyy" placeholder="dd-mm-yyyy">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="end_date"><%= resourceBundle.getProperty("DataManager.DisplayText.End_Date") %></label>
                                <div class="col-md-5">
                                    <input type="text" id="end_date" name="end_date" class="form-control input-datepicker" data-date-format="dd-mm-yyyy" placeholder="dd-mm-yyyy">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label"><%= resourceBundle.getProperty("DataManager.DisplayText.Show_Yield") %></label>
                                <div class="col-md-9">
                                    <div class="checkbox">
                                        <label for="yield">
                                        <input type="checkbox" id="yield" name="yield" value="No" onClick="javascript:setSelected()">
					<%= resourceBundle.getProperty("DataManager.DisplayText.Yes") %>
                                                    </label>
                                    </div>
                                </div>
                            </div>

                            <div class="form-group">
                                <label class="col-md-3 control-label" for="example-textarea-input"><%= resourceBundle.getProperty("DataManager.DisplayText.Parameters") %></label>
                                <div class="col-md-9">
                                  <select id="lstParams" name="lstParams" size="10" style="width:200px" multiple>
								  </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="example-file-input"><%= resourceBundle.getProperty("DataManager.DisplayText.Save_Graph_As") %></label>

                                <div class="form-group">
                                    <div class="col-md-9">
                                        <label class="radio-inline" for="example-inline-radio1">
                                                    <input type="radio" id="access" name="access" value="Public"><%= resourceBundle.getProperty("DataManager.DisplayText.Public") %>
                                                </label>
                                        <label class="radio-inline" for="example-inline-radio2">
                                                    <input type="radio" id="access" name="access" value="Private" checked><%= resourceBundle.getProperty("DataManager.DisplayText.Private") %>
                                                </label>
                                    </div>
                                   <input type="text" size="25" id="saveAs" name="saveAs" value="">
                                </div>
                            </div>
                            <div class="form-group form-actions">
                                <div class="col-md-9 col-md-offset-3">
                                	<input type="button" class="btn btn-effect-ripple btn-primary" style="overflow: hidden; position: relative;" name="ShowGraph" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Show_Graph") %>" onClick="showGraph()">
                                    <input type="button" class="btn btn-effect-ripple btn-danger" style="overflow: hidden; position: relative;" name="DeleteGraph" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Delete_Graph") %>" onClick="deleteGraph()">
                                    
                                </div>
                            </div>
                        </form>
                        <!-- END General Elements Content -->
                    </div>
                    <% /* ---- removed additional cusotm graph buttons
                    <div class="block full">
                        <!-- Block Tabs Title -->
                       
                        <!-- END Block Tabs Title -->

						
                        <!-- Tabs Content -->
                        <div class="row">
                        <div class="col-xs-6">
                            <!-- Input States Block -->
                            <div class="block">
                                <!-- Input States Title -->
                                <div class="block-title">

                                    <h2>Select Date</h2>
                                </div>
                                <div class="form-group">

                                    <div class="form-group">

                                  
                                    <div class="tab-pane" id="block-tabs-home"><input type="text" id="example-datepicker" name="example-datepicker" class="form-control input-datepicker" data-date-format="dd-mm-yyyy" placeholder="dd-mm-yyyy"></div>
                                   
                                   
                                </div>
                                </div>
                            </div>

                        </div>
                        
                        
                        <div class="col-xs-6">
                            <!-- Input States Block -->
                            <div class="block">
                                <!-- Input States Title -->
                                <div class="block-title">

                                    <h2>Upload Custom Graph</h2>
                                </div>
                                <!-- END Input States Title -->

                                <!-- Input States Content -->

                                <div class="form-group">


                                    <label class="col-md-3 control-label" for="example-file-input">Attachments</label>

                                    <input type="file" id="example-file-input" name="example-file-input">


                          

                                </div>
                                <!-- END Input States Content -->
                            </div>
                        </div>
                    </div>
                    </div>
                    */ %>
<!-- Removed blank jsp iframe -->
                </div>

                <!-- END Page Content -->
            </div>
            <!-- END Main Container -->
        </div>
      
    <!-- END Page Wrapper -->

    <!-- jQuery, Bootstrap, jQuery plugins and Custom JS code -->
    <script src="js/vendor/jquery-2.2.4.min.js"></script>
    <script src="js/vendor/bootstrap.min.js"></script>
    <script src="js/plugins.js"></script>
    <script src="js/app.js"></script>
    <!-- Load and execute javascript code used only in this page -->
    <script src="js/pages/readyDashboard.js"></script>
    <script>
        $(function() {
            ReadyDashboard.init();
        });

    </script>
</body>

</html>
