<%@page import="java.util.*" %>
<%@page import="com.client.util.*" %>

<%
	Locale locale = request.getLocale();
	LabelResourceBundle resourceBundle = new LabelResourceBundle(locale);

	String sLogin = request.getParameter("login");
%>
<!doctype html>
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
<link rel="shortcut icon" href="img/fav-icon.jpg">
<!-- END Icons -->

<!-- Stylesheets -->
<!-- Bootstrap is included in its original form, unaltered -->
<link rel="stylesheet" href="css/bootstrap.min.css">

<!-- Related styles of various icon packs and plugins -->
<link rel="stylesheet" href="css/plugins.css">

<!-- The main stylesheet of this template. All Bootstrap overwrites are defined in here -->
<link rel="stylesheet" href="css/main.css">

<!-- Include a specific file here from css/themes/ folder to alter the default theme of the template -->

<!-- The themes stylesheet of this template (for using specific theme color in individual elements - must included last) -->
<link rel="stylesheet" href="css/themes.css">
<!-- END Stylesheets -->

<!-- Modernizr (browser feature detection library) -->
<script src="js/vendor/modernizr-3.3.1.min.js"></script>

</head>
<body bgcolor="#999999" onLoad="javascript:setWinDim(); setLogData()" style="background-color: #ec3237 !important;">
	<!-- Login Container -->
	<div id="login-container">
		<!-- Login Header -->
		<h1
			class="h2 text-light text-center push-top-bottom animation-slideDown">
			<a href="#"> <img src="img/login-logo.jpg" alt="image">
			</a>
		</h1>
		<!-- END Login Header -->

		<!-- Login Block -->
		<div class="block animation-fadeInQuickInv">
			<!-- Login Title -->
			<div class="block-title">
				<div class="block-options pull-right">
					<a href="./services/password-remainder.jsp"
						class="btn btn-effect-ripple btn-primary" data-toggle="tooltip"
						data-placement="left"
						title="<%= resourceBundle.getProperty("DataManager.DisplayText.Forgot_Password") %>"><i
						class="fa fa-exclamation-circle"></i></a>
				</div>
				<h2>Login</h2>
			</div>
			<!-- END Login Title -->

			<!-- Login Form -->
			<form name="frm" id="form-login" action="LoginServlet" method="post"
				class="form-horizontal">
				<div class="form-group">
					<div class="col-xs-12">
						<input type="text" id="U" name="U" class="form-control" required="required"
							placeholder="<%= resourceBundle.getProperty("DataManager.DisplayText.User_Name") %>">
					</div>
				</div>
				<div class="form-group">
					<div class="col-xs-12">
						<input type="password" id="P" name="P" class="form-control" required="required"
							placeholder="<%= resourceBundle.getProperty("DataManager.DisplayText.Password") %>">
					</div>
				</div>
				<div class="form-group form-actions">
					<div class="col-xs-8">
						<label class="csscheckbox csscheckbox-primary"> 
					</div>
					<div class="col-xs-4 text-right">
						<button type="submit"
							class="btn btn-effect-ripple btn-sm btn-primary" >
							<i class="fa fa-check"></i>
							<%= resourceBundle.getProperty("DataManager.DisplayText.Login") %></button>
					</div>
				</div>

				<input type="hidden" id="winW" name="winW" value=""> 
				<input type="hidden" id="winH" name="winH" value=""> 
				<input type="hidden" id="ip" name="ip" value=""> 
				<input type="hidden" id="hostname" name="hostname" value=""> 
				<input type="hidden" id="city" name="city" value=""> 
				<input type="hidden" id="region" name="region" value=""> 
				<input type="hidden" id="country" name="country" value="">
			</form>
			<!-- END Login Form -->
		</div>
		<!-- END Login Block -->

		<!-- Footer -->
		<footer class="text-muted text-center animation-pullUp">
			<small><span id="year-copy"></span> &copy; <a href="#" target="_blank">Inventaa</a></small>
		</footer>
		<!-- END Footer -->
	</div>
	<!-- END Login Container -->

	<!-- jQuery, Bootstrap, jQuery plugins and Custom JS code -->
	<script src="js/vendor/jquery-2.2.4.min.js"></script>
	<script src="js/vendor/bootstrap.min.js"></script>
	<script src="js/plugins.js"></script>
	<script src="js/app.js"></script>

	<!-- Load and execute javascript code used only in this page -->
	<script src="js/pages/readyLogin.js"></script> 
<script>
    $(function() {
        ReadyLogin.init();
    });
</script>	

<script language="javascript">

<%
if("fail".equals(sLogin))
{
%>
	alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Login_Failed") %>");
	
<%
}
else if("blocked".equals(sLogin))
{
%>
	alert("<%= resourceBundle.getProperty("DataManager.DisplayText.User_Blocked") %>");
<%
}
%>

	
	function setWinDim()
	{
		var winW = 630, winH = 460;
		if (document.body && document.body.offsetWidth) 
		{
			winW = document.body.offsetWidth;
			winH = document.body.offsetHeight;
		}
		if (document.compatMode == "CSS1Compat" && document.documentElement && document.documentElement.offsetWidth ) 
		{
			winW = document.documentElement.offsetWidth;
			winH = document.documentElement.offsetHeight;
		}
		if (window.innerWidth && window.innerHeight) 
		{
			winW = window.innerWidth;
			winH = window.innerHeight;
		}
		document.frm.winW.value = winW;
		document.frm.winH.value = winH;
	}
	
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

</body>
</html>
