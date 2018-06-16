<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*"%>
<%@page import="com.client.*"%>
<%@page import="com.client.util.*"%>

<jsp:useBean id="RDMSession" scope="session"
	class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp"%>

<%
	String sCommentId = request.getParameter("cmtId");
	String sFrom = request.getParameter("from");
	String sBatchNo = request.getParameter("bNo");
	String bGlobal = request.getParameter("global");
%>

<!DOCTYPE html>
<html class="no-js" lang="en">

<head>
<meta charset="utf-8">
<title>Inventaa</title>
<meta name="description" content="Datamanager">
<meta name="author" content="Inventaa">
<meta name="robots" content="noindex, nofollow">
<meta name="viewport"
	content="width=device-width,initial-scale=1.0,user-scalable=0">
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

<!-- Include a specific file here from css/themes/ folder to alter the default theme of the template -->

<!-- The themes stylesheet of this template (for using specific theme color in individual elements - must included last) -->
<link rel="stylesheet" href="../css/themes.css">
<!-- END Stylesheets -->

<!-- Modernizr (browser feature detection library) -->
<script src="../js/vendor/modernizr-3.3.1.min.js"></script>
<script language="javascript">
		if (!String.prototype.trim) 
		{
			String.prototype.trim = function() {
				return this.replace(/^\s+|\s+$/g,'');
			}
		}
		
		function submitForm()
		{			
			var comments = document.getElementById("comments");
			if(comments != undefined && comments != null)
			{
				comments.value = comments.value.trim();
				if(comments.value == "")
				{
					alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Enter_Comments") %>");
					comments.focus();
					return false;
				}
			}
			
			var fileaction = document.getElementsByName("fileaction");
			for(var i=0; i<fileaction.length; i++)
			{
				if(fileaction[i].checked)
				{
					document.getElementById("replace").value = fileaction[i].value;
				}
			}
			document.frm.submit();
		}
	</script>
</head>

<body>


		<div id="page-wrapper" class="page-loading">
			<div class="preloader">
				<div class="inner">
					<!-- Animation spinner for all modern browsers -->
					<div class="preloader-spinner themed-background hidden-lt-ie10"></div>

					<!-- Text for IE9 -->
					<h3 class="text-primary visible-lt-ie10">
						<strong>Loading..</strong>
					</h3>
				</div>
			</div>
			<!-- END Preloader -->
			<!-- <div id="page-container" class="header-fixed-top sidebar-visible-lg-full"> -->

			<div id="page-container">
				<!-- Main Container -->
				<div id="main-container">
					<!-- Page content -->
					<div id="page-content">
						<div class="block">
							<!-- General Elements Title -->
							<div class="block-title">
								<h2><%= resourceBundle.getProperty("DataManager.DisplayText.Update_Comments") %></h2>
							</div>
							<!-- END General Elements Title -->

						<!-- General Elements Content -->

						<form name="frm" method="post" action="processAttachments.jsp" enctype="multipart/form-data" class="form-horizontal form-bordered">
							<input type="hidden" id="cmtId" name="cmtId" value="<%=sCommentId%>"> 
							<input type="hidden" id="mode" name="mode" value="update"> 
							<input type="hidden" id="from" name="from" value="<%=sFrom%>"> 
							<input type="hidden" id="folder" name="folder" value="<%=sCommentId%>"> 
							<input type="hidden" id="replace" name="replace" value=""> 
							<input type="hidden" id="processPage" name="processPage" value="manageCommentsProcess.jsp">

							<div class="form-group">
								<label class="col-md-3 control-label"
									for="example-textarea-input"><%=resourceBundle.getProperty("DataManager.DisplayText.Review_Comments")%></label>
								<div class="col-md-9">
									<textarea id="comments" name="comments" rows="7"
										class="form-control" placeholder="Description.."></textarea>
								</div>
							</div>
							<div class="form-group">
								<label class="col-md-3 control-label" for="example-file-input"><%= resourceBundle.getProperty("DataManager.DisplayText.Attachments") %>
								</label>
								<div class="col-md-9">
									<input type="file" id="attachment" name="attachment">
								</div>
								<div class="form-group">
									<div class="col-md-9">
										<label class="radio-inline" for="example-inline-radio1">
											<input type="radio" id="fileaction" name="fileaction"
											value="yes" checked> <%= resourceBundle.getProperty("DataManager.DisplayText.Replace") %>
										</label> <label class="radio-inline" for="example-inline-radio2">
											<input type="radio" id="fileaction" name="fileaction"
											value="no"> <%= resourceBundle.getProperty("DataManager.DisplayText.Append") %>
										</label>
									</div>
								</div>
							</div>

							<div class="form-group form-actions">
								<div class="col-md-9 col-md-offset-3">
									<button type="submit" class="btn btn-effect-ripple btn-primary"
										style="overflow: hidden; position: relative;" name="Save"
										value="<%=resourceBundle.getProperty("DataManager.DisplayText.Save")%>"
										onClick="submitForm()">Save</button>
									<button type="reset" class="btn btn-effect-ripple btn-danger"
										style="overflow: hidden; position: relative;" name="Cancel"
										value="<%=resourceBundle.getProperty("DataManager.DisplayText.Cancel")%>"
										onClick="javascript:top.window.close()">Cancel</button>
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
		</div>
		<!-- END Page Wrapper -->


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

</html>
