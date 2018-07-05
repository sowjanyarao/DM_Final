<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<%
	String sCommentId = request.getParameter("cmtId");
	String sFrom = request.getParameter("from");
	String sBatchNo = request.getParameter("bNo");
	String bGlobal = request.getParameter("global");
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
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
                <h3 class="text-primary visible-lt-ie10"><strong>Loading..</strong></h3>
            </div>
        </div>
       
            <!-- Main Container -->
            <div id="main-container">

                <!-- Page content -->
                <div id="page-content">
                    <div class="block">
                       
	<form name="frm" method="post" action="processAttachments.jsp" enctype="multipart/form-data" enctype="multipart/form-data" class="form-horizontal form-bordered">
		<input type="hidden" id="cmtId" name="cmtId" value="<%= sCommentId %>">
		<input type="hidden" id="mode" name="mode" value="update">
		<input type="hidden" id="from" name="from" value="<%= sFrom %>">		
		<input type="hidden" id="folder" name="folder" value="<%= sCommentId %>">
		<input type="hidden" id="replace" name="replace" value="">
		<input type="hidden" id="processPage" name="processPage" value="manageCommentsProcess.jsp">
		
		<table id="example-datatable" class="table table-striped table-bordered table-vcenter">
			<tr>
				<td colspan="2" align="center"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Update_Comments") %></b></td>
			</tr>
			<tr><td>
			 	<label width="30%" class="col-md-3 control-label" for="comments"><%=  resourceBundle.getProperty("DataManager.DisplayText.Review_Comments") %></label>
			 	</td>
				<td class="input" width="70%">
					<textarea id="comments" name="comments" rows="5" cols="35"></textarea>
				</td>
			</tr>
			
			<tr>
				<td>
			 	<label width="30%" class="col-md-3 control-label" for="attachment"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Attachments") %></b></label>
			 	</td>
				<td class="input" width="70%">
					<input type="file" id="attachment" name="attachment" class="btn btn-effect-ripple btn-primary"><br>
					<input type="radio" id="fileaction" name="fileaction" value="yes" checked><%= resourceBundle.getProperty("DataManager.DisplayText.Replace") %>
					<input type="radio" id="fileaction" name="fileaction" value="no"><%= resourceBundle.getProperty("DataManager.DisplayText.Append") %>
				</td>
			</tr>
			
			<tr>
				<td colspan="2">
					&nbsp;
				</td>
			</tr>
			<tr>
				<td colspan="2" align="right">
					<input type="button" name="Save" class="btn btn-effect-ripple btn-primary" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Save") %>" onClick="submitForm()">&nbsp;&nbsp;&nbsp;
					<input type="button" name="Cancel" class="btn btn-effect-ripple btn-primary" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Cancel") %>" onClick="javascript:top.window.close()">
				</td>
			</tr>
		</table>
	</form>
	</div>
	</div>
	</div>
	</div>
</body>
</html>
