<%@page import="java.util.*"%>
<%@page import="com.client.util.*"%>

<%
	Locale locale = request.getLocale();
	LabelResourceBundle resourceBundle = new LabelResourceBundle(locale);
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
    <link rel="shortcut icon" href="../img/fav-icon.jpg">
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
</head>

<body>
	<!-- Login Container -->
	<div id="login-container">
		<!-- Reminder Header -->
		<h1
			class="h2 text-light text-center push-top-bottom animation-slideDown">
			<i class="fa fa-history"></i> <strong>Password Reminder</strong>
		</h1>
		<!-- END Reminder Header -->

		<!-- Reminder Block -->
		<div class="block animation-fadeInQuickInv">
			<!-- Reminder Title -->
			<div class="block-title">
				<div class="block-options pull-right">
					<a href="../login.jsp" class="btn btn-effect-ripple btn-primary"
						data-toggle="tooltip" data-placement="left" title="Back to login"><i
						class="fa fa-user"></i></a>
				</div>
				<h2>Reminder</h2>
			</div>
			<!-- END Reminder Title -->

			<!-- Reminder Form -->
			<form id="form-reminder" action="javascript: forgotPwd()" 
				method="post" class="form-horizontal">
				<div class="form-group">
					<div class="col-xs-12">
						<input type="text" id="reminder-email" name="reminder-email"
							class="form-control"
							placeholder="Enter user name to retrive the password..">
					</div>
				</div>
				<div class="form-group form-actions">
					<div class="col-xs-12 text-right">
						<button type="submit"
							class="btn btn-effect-ripple btn-sm btn-primary" id="remindPwd" >
							<i class="fa fa-check"></i> Remind Password
						</button>
					</div>
				</div>
			</form>
			<!-- END Reminder Form -->
		</div>
		<!-- END Reminder Block -->

		<!-- Footer -->
		<footer class="text-muted text-center animation-pullUp">
			<small><span id="year-copy"></span> &copy; <a href="#"
				target="_blank">Inventaa</a></small>
		</footer>
		<!-- END Footer -->
	</div>
	<!-- END Login Container -->

	<!-- jQuery, Bootstrap, jQuery plugins and Custom JS code -->
	<script src="../js/vendor/jquery-2.2.4.min.js"></script>
	<script src="../js/vendor/bootstrap.min.js"></script>
	<script src="../js/plugins.js"></script>
	<script src="../js/app.js"></script>

	<!-- Load and execute javascript code used only in this page -->
	<script src="../js/pages/readyReminder.js"></script>
	<script>
        $(function() {
        	$('#remindPwd').click(function() {
        		ReadyReminder.init();
        	});
        });

    </script>

	<script>
	function forgotPwd() {
		var user = document.getElementById("reminder-email").value;
		if(user == "")
		{
			alert("<%=resourceBundle.getProperty("DataManager.DisplayText.Retrive_Password")%>");
		} else {
			var url = "../Password?id=" + user + "&action=forgot.password";
			document.location.href = url;
		}
	}
    
	</script>
</body>

</html>