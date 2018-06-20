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

<!DOCTYPE html>
<html class="no-js" lang="en">
<head>
<script language="javascript">
		function logout() {
			document.frm.submit();
		}

		function resetContext(userId) {
			top.window.document.location.href = "../LoginServlet?U=" + userId+ "&resetContext=yes";
		}
	</script>
</head>
<body>

<header class="navbar navbar-inverse navbar-fixed-top">
	<!-- Left Header Navigation -->
	<ul class="nav navbar-nav-custom">
		<!-- Main Sidebar Toggle Button -->
		<li><a href="javascript:void(0)"
			onclick="App.sidebar('toggle-sidebar');this.blur();"> <i
				class="fa fa-ellipsis-v fa-fw animation-fadeInRight"
				id="sidebar-toggle-mini"></i> <i
				class="fa fa-bars fa-fw animation-fadeInRight"
				id="sidebar-toggle-full"></i>
		</a></li>
		<!-- END Main Sidebar Toggle Button -->

		<!-- Header Link -->
		<li class="hidden-xs animation-fadeInQuick"><a href=""><strong>Welcome</strong></a>
		</li>
		<!-- END Header Link -->
	</ul>
		<!-- END Left Header Navigation -->
		<!-- Right Header Navigation -->
	<ul class="nav navbar-nav-custom pull-right">
		<!-- Alternative Sidebar Toggle Button -->
		<li><a href="javascript:void(0)"
			onclick="App.sidebar('toggle-sidebar-alt');this.blur();"> <i
				class="gi gi-settings"></i>
		</a></li>
		<!-- END Alternative Sidebar Toggle Button -->

			<!-- User Dropdown -->
			<li class="dropdown"><a href="javascript:void(0)"
				class="dropdown-toggle" data-toggle="dropdown"> <img
					src="../img/placeholders/avatars/avatar9.jpg" alt="avatar">
			</a>
			
				<ul class="dropdown-menu dropdown-menu-right">
					<li class="dropdown-header"><strong><%= u.getLastName() %>,&nbsp;<%= u.getFirstName() %></strong></li>

					<li><a href="javascript:logout()"> <i
							class="fa fa-power-off fa-fw pull-right"></i><%=resourceBundle.getProperty("DataManager.DisplayText.Logout")%>
					</a></li>
				</ul></li>
			<!-- END User Dropdown -->
		</ul>
		<!-- END Right Header Navigation -->
		
	</header>
	<!-- END Header -->


	







</body>
</html>