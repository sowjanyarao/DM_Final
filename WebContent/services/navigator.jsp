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
		window.onresize = function() {
			var winW = 630, winH = 460;
			if(top.document.body && top.document.body.offsetWidth) 
			{
				winW = top.document.body.offsetWidth;
				winH = top.document.body.offsetHeight;
			}
			if(top.document.compatMode == "CSS1Compat" && top.document.documentElement && top.document.documentElement.offsetWidth)
			{
				winW = top.document.documentElement.offsetWidth;
				winH = top.document.documentElement.offsetHeight;
			}
			if(top.window.innerWidth && top.window.innerHeight) 
			{
				winW = top.window.innerWidth;
				winH = top.window.innerHeight;
			}
		};
	</script>

<script type="text/javascript">
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

<script language="javascript">
	
		function loadContent(url) {
			document.frm1.action=url;
			document.frm1.target = "displayContent";
			
			frames['displayContent'].location.href = url;
			//document.getElementByTag("body").location.href = url;
			//document.location.href = url;
		}
		

		/* function reloadHeader(url) {
			document.location.href = "dashboard.jsp?showContent="+ url;
			
		}  

		function popupContent(url, h, w) {
			var retval = window.open(url, '','left=200,top=100,resizable=no,scrollbars=no,status=no,toolbar=no,height='	+ h + ',width=' + w);
		} */

		function logout() {
			document.frmlogout.submit();
		}

		function resetContext(userId) {
			top.window.document.location.href = "../LoginServlet?U=" + userId+ "&resetContext=yes";
		}
	</script>
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
			
			document.frm.submit();
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
<script language="javascript">
	function updateComments(id, bNo, bGlobal)
	{
		var retval = window.open('onclick-editcomments.jsp?cmtId='+id+'&bNo='+bNo+'&global='+bGlobal+'&from=homeView', 'Comments', 'left=250,top=250,resizable=no,scrollbars=no,status=no,toolbar=no,height=300,width=500');
	}
	
	function closeComments(id)
	{
		//parent.frames['hiddenFrame'].document.location.href = "manageCommentsProcess.jsp?cmtId="+id+"&mode=close&from=homeView";
		document.location.href = "manageCommentsProcess.jsp?cmtId="+id+"&mode=close&from=homeView";
		
	}
	
	function openController(sCntrl)
	{
		if(sCntrl == "General")
		{
			document.location.href = "generalParamsView.jsp?controller="+sCntrl;
		}
		else
		{
			document.location.href = "singleRoomView.jsp?controller="+sCntrl;
		}
	}
	
	function viewAttachments(taskname)
	{
		var url = "../ViewAttachments?folder="+taskname;
		document.location.href =  url;
	}
	</script>
</head>
<%
String showContent = request.getParameter("showContent");
if(showContent == null || "".equals(showContent))
{
	String sHomePage = u.getHomePage();
	System.out.println("****sHomePage : "+sHomePage);
	sHomePage = (sHomePage == null || "".equals(sHomePage) ? RDMServicesConstants.HOME : sHomePage);
	
	Map<String, String> mHomePage = new HashMap<String, String>();
	mHomePage.put(RDMServicesConstants.HOME, "showGlobalAlerts.jsp");
	mHomePage.put(RDMServicesConstants.SHORTLINKS, "short-links.jsp");
	mHomePage.put(RDMServicesConstants.ACTIONS_CREATE_TASK, "addUserTaskView.jsp");
	mHomePage.put(RDMServicesConstants.ACTIONS_UPDATE_BNO, "manageBatchNosView.jsp");
	mHomePage.put(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_GROWER, "dashboardView.jsp?cntrlType=Grower");
	mHomePage.put(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_BUNKER, "dashboardView.jsp?cntrlType=Bunker");
	mHomePage.put(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_TUNNEL, "dashboardView.jsp?cntrlType=Tunnel");
	mHomePage.put(RDMServicesConstants.ROOMS_VIEW_SINGLE_ROOM, "singleRoomView.jsp");
	mHomePage.put(RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_GROWER, "multiRoomView.jsp?cntrlType=Grower");
	mHomePage.put(RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_BUNKER, "multiRoomView.jsp?cntrlType=Bunker");
	mHomePage.put(RDMServicesConstants.ROOMS_VIEW_MULTI_ROOM_TUNNEL, "multiRoomView.jsp?cntrlType=Tunnel");
	mHomePage.put(RDMServicesConstants.VIEWS_GRAPH_ATTRDATA, "attribute-data.jsp");
	mHomePage.put(RDMServicesConstants.VIEWS_GRAPH_PRODUCTIVITY, "productivity.jsp");
	mHomePage.put(RDMServicesConstants.VIEWS_GRAPH_BATCHLOAD, "batchPhaseLoadsView.jsp");
	mHomePage.put(RDMServicesConstants.VIEWS_ALARMS, "alarms.jsp");
	mHomePage.put(RDMServicesConstants.VIEWS_LOGS, "logView.jsp");
	mHomePage.put(RDMServicesConstants.VIEWS_COMMENTS, "comments.jsp");
	mHomePage.put(RDMServicesConstants.VIEWS_TASKS, "tasks.jsp");
	mHomePage.put(RDMServicesConstants.VIEWS_YIELDS, "yields.jsp");
	mHomePage.put(RDMServicesConstants.VIEWS_REPORTS, "viewReportsView.jsp");
	mHomePage.put(RDMServicesConstants.VIEWS_TIMESHEETS, "timesheets.jsp");
	mHomePage.put(RDMServicesConstants.VIEWS_PRODUCTIVITY, "userProductivity.jsp");

	if(RDMServicesConstants.ROLE_TIMEKEEPER.equals(u.getRole()))
	{
		showContent = "employeeInOutView.jsp";
	}
	else
	{
		showContent = mHomePage.get(sHomePage);
	}	
}
%>

<body style="background-color: #ffffff !important;" onLoad="javascript:loadContent('<%= showContent %>'); setLogData()">
<form name="frm1" method="post" target="displayContent" action="">
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

		<div id="page-container"
			class="header-fixed-top sidebar-visible-lg-full">
			<jsp:include page="header.jsp" />
			<jsp:include page="header-sidebar.jsp">
			  <jsp:param name="u" value="${u}" />
			</jsp:include>
			<jsp:include page="sidebar.jsp" />

			<!-- Main Container -->
			<div id="main-container">

				<!-- Page content -->
				<div style="border:0px" id="page-content">
					
					<iframe style="border:0px" border="0px" name="displayContent" src="" width="100%" height="<%= winHeight * 0.9 %>px" ></iframe>
				</div>
				<!-- END Page Content -->
			</div>
			<!-- END Main Container -->
		</div>
		<!-- END Page Container -->
	</div>
	<!-- END Page Wrapper -->
	
	  </form>
	<form name="frmlogout" method="post" action="../LogoutServlet" target="_top">
		<input type="hidden" id="ip" name="ip" value=""> <input
			type="hidden" id="hostname" name="hostname" value=""> <input
			type="hidden" id="city" name="city" value=""> <input
			type="hidden" id="region" name="region" value=""> <input
			type="hidden" id="country" name="country" value="">

	</form>
	

	<!-- jQuery, Bootstrap, jQuery plugins and Custom JS code -->
	<script src="../js/vendor/jquery-2.2.4.min.js"></script>
	<script src="../js/vendor/bootstrap.min.js"></script>
	<script src="../js/plugins.js"></script>
	<script src="../js/app.js"></script>

	<!-- Load and execute javascript code used only in this page -->
	<script src="../js/pages/uiTables.js"></script>
	<script>
        $(function() {
            UiTables.init();
        });

    </script>
  
</body>

</html>
