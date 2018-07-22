<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<%
	String sController = request.getParameter("controller");
	sController = (sController == null ? "" : sController);
	
	StringList slAllControllers = RDMSession.getControllers(u);	
%>
<!DOCTYPE html>

<html class="no-js" lang="en">

<%
if("".equals(sController))
{
%>
	<head>
		<script language="javascript">			
			function selectController(obj)
			{
				var sCntrl = obj.value;
				if(sCntrl == "Bunker" || sCntrl == "Tunnel" || sCntrl == "Grower")
				{
					document.location.href = "defaultParamsView.jsp?controller="+sCntrl;
				}
				else
				{
					document.location.href = "singleRoomView.jsp?controller="+sCntrl;
				}
			}
		</script>
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

                            <h2>Single-Room</h2>
                        </div>
                        <!-- END General Elements Title -->

                        <!-- General Elements Content -->
                        <form action="page_forms_components.html" method="post" enctype="multipart/form-data" class="form-horizontal form-bordered" onsubmit="return false;">

                            <div class="form-group">
                                <label class="col-md-3 control-label" for="example-select"><%= resourceBundle.getProperty("DataManager.DisplayText.Select_Room") %>:&nbsp;</label>
                                <div class="col-md-6">
                                  					<select id="SelController" name="SelController" onChange="javascript:selectController(this)" class="form-control">
						<option value=""><%= resourceBundle.getProperty("DataManager.DisplayText.Please_choose_one") %></option>
<%
						if(RDMServicesConstants.ROLE_ADMIN.equals(u.getRole()) || RDMServicesConstants.ROLE_MANAGER.equals(u.getRole()))
						{
%>
							<optgroup label="<%= resourceBundle.getProperty("DataManager.DisplayText.Default_Values") %>">
<%
							boolean bViewGrwDB = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_GROWER);
							if(bViewGrwDB && (RDMSession.getControllers(RDMServicesConstants.TYPE_GROWER).size() > 0))
							{
%>
								<option value="<%= RDMServicesConstants.TYPE_GROWER %>"><%= resourceBundle.getProperty("DataManager.DisplayText.Grower") %></option>
<%
							}
							boolean bViewBnkDB = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_BUNKER);
							if(bViewBnkDB && (RDMSession.getControllers(RDMServicesConstants.TYPE_BUNKER).size() > 0))
							{
%>
								<option value="<%= RDMServicesConstants.TYPE_BUNKER %>"><%= resourceBundle.getProperty("DataManager.DisplayText.Bunker") %></option>
<%
							}
							boolean bViewTnlDB = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_TUNNEL);
							if(bViewTnlDB && (RDMSession.getControllers(RDMServicesConstants.TYPE_TUNNEL).size() > 0))
							{
%>
								<option value="<%= RDMServicesConstants.TYPE_TUNNEL %>"><%= resourceBundle.getProperty("DataManager.DisplayText.Tunnel") %></option>
<%
							}
%>
							<optgroup label="<%= resourceBundle.getProperty("DataManager.DisplayText.Controllers") %>">
<%
						}

						String sCntrlName = "";
						String sSelected = "";
						for(int i=0; i<slAllControllers.size(); i++)
						{
							sCntrlName = slAllControllers.get(i);
							sSelected = (sCntrlName.equals(sController) ? "selected" : "");
%>
							<option value="<%= sCntrlName %>" <%= sSelected %>><%= sCntrlName %></option>
<%
						}
%>
					</select>
                                </div>
                            </div>

                            <div class="form-group form-actions">
                                <div class="col-md-9 col-md-offset-3">
                                    <button type="submit" class="btn btn-effect-ripple btn-primary" style="overflow: hidden; position: relative;">Submit</button>

                                </div>
                            </div>

                        </form>
                        <!-- END General Elements Content -->
                    </div>
                </div>

                <!-- END Page Content -->
            </div>
            <!-- END Main Container -->
        </div>
        <!-- END Page Container -->

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
<%
}
else
{
	String url = "";
	if(RDMServicesUtils.isGeneralController(sController))
	{
%>
		<script language="javascript">	
			document.location.href = "generalParamsView.jsp?controller=<%= sController %>";
		</script>
<%
	}
	else
	{
%>
	<frameset rows="99%,1%" frameborder="0">
		<frame name="content" src="roomParameters.jsp?controller=<%= sController %>" />
		<frame name="hiddenFrame" src="blank.jsp" />
	</frameset>
<%
	}
}
%>
</html>
