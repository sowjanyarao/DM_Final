<%@page import="java.util.*"%>
<%@page import="com.client.*"%>
<%@page import="java.text.*"%>
<%@page import="com.client.util.*"%>
<%@page import="com.client.db.*"%>
<%@page import="com.client.views.*"%>

<jsp:useBean id="RDMSession" scope="session"
	class="com.client.ServicesSession" />

<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>
<%@include file="commonUtils.jsp"%>
<%
System.out.println("********************"+request.getParameter("u"));
%>
<!DOCTYPE html>
<html class="no-js" lang="en">
<head>
<script language="javascript">
		if (!String.prototype.trim) 
		{
			String.prototype.trim = function() {
				return this.replace(/^\s+|\s+$/g,'');
			}
		}
	
		function chngPwd()
		{
		
			 if(!checkPassword())
			{
				return false;
			} 
			
			document.frm1.action="manageUserProcess.jsp";
			document.frm1.submit();
		}
		
		function checkPassword()
		{
			var password = document.getElementById("password");
			password.value = password.value.trim();

			if(password.value.length < 6)
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Password_length_Mismatch") %>");
				password.focus();
				return false;
			}
			
			var CPassword = document.getElementById("CPassword");
			CPassword.value = CPassword.value.trim();
			
			
			if(password.value != CPassword.value)
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Password_Mismatch") %>");
				password.focus(); 
				return false;
			}
			
			return true;
		}

		function passwordChanged()
		{
			var strongRegex = new RegExp("^(?=.{10,})(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*\\W).*$", "g");
			var mediumRegex = new RegExp("^(?=.{8,})(((?=.*[A-Z])(?=.*[a-z]))|((?=.*[A-Z])(?=.*[0-9]))|((?=.*[a-z])(?=.*[0-9]))).*$", "g");
			var weakRegex = new RegExp("(?=.{6,}).*", "g");
			
			var strength = document.getElementById("strength");
			var pwd = document.getElementById("password");
			pwd.value = pwd.value.trim();
			if (pwd.value.length == 0) 
			{
				strength.innerHTML = "";
			} 
			else if (strongRegex.test(pwd.value)) 
			{
				strength.innerHTML = '<span style="color:green"><b>Strong</b></span>';
			} 
			else if (mediumRegex.test(pwd.value))
			{
				strength.innerHTML = '<span style="color:blue"><b>Medium</b></span>';
			} 
			else if (weakRegex.test(pwd.value))
			{
				strength.innerHTML = '<span style="color:red"><b>Weak</b></span>';
			}
		}
	</script>
</head>
<body>
<!-- Alternative Sidebar -->
<div id="sidebar-alt" tabindex="-1" aria-hidden="true">
	<!-- Toggle Alternative Sidebar Button (visible only in static layout) -->
	<a href="javascript:void(0)" id="sidebar-alt-close"
		onclick="App.sidebar('toggle-sidebar-alt');"><i
		class="fa fa-times"></i></a>

	<!-- Wrapper for scrolling functionality -->
	<div id="sidebar-scroll-alt">
		<!-- Sidebar Content -->
		<div class="sidebar-content">
			<!-- Profile -->
			<div class="sidebar-section">
				<h2 class="text-light">Profile</h2>
				<%com.client.util.User contextUser = (com.client.util.User)session.getAttribute("contextUser");%>
				
					<div class="form-group">
						<label for="side-profile-name">Name</label> <input type="text"
							id="side-profile-name" name="side-profile-name"
							class="form-control" value='<%= u.getLastName() %>,&nbsp;<%= u.getFirstName() %>' readonly="readonly"/>
					</div>
					<div class="form-group">
						<label for="side-profile-email">Email</label> <input type="email"
							id="side-profile-email" name="side-profile-email"
							class="form-control" value="<%= u.getEmail() %>" readonly="readonly">
					</div>
					 
					<div class="form-group">
						<label for="side-profile-password"><%= resourceBundle.getProperty("DataManager.DisplayText.New_Password") %></label>
						<input type="password" id="password" name="password"
							class="form-control" maxlength="15" size="15"
							onkeyup="return passwordChanged();" value=""> <span
							id="strength"></span>
					</div>
					<div class="form-group">
						<label for="side-profile-password-confirm"><%= resourceBundle.getProperty("DataManager.DisplayText.Confirm_Password") %></label>
						<input type="password" id="CPassword" name="CPassword"
							maxlength="15" size="15" value="" class="form-control">

					</div>
					<div class="form-group remove-margin">
						<input type="button" class="btn btn-effect-ripple btn-primary" name="changePassword" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Change_Password") %>" onClick="chngPwd()"/>
						
					</div>
					<input type="hidden" id="mode" name="mode" value="chgPwd">
			</div>
		</div>
		<!-- END Sidebar Content -->
	</div>
	<!-- END Wrapper for scrolling functionality -->
</div>
</body>
</html>