<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="java.text.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>
<%@page import="com.client.db.*" %>
<%@page import="com.client.views.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
	<title></title>

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
	function updateComments(id, bNo, bGlobal)
	{
		var retval = window.open('updateUserComments.jsp?cmtId='+id+'&bNo='+bNo+'&global='+bGlobal+'&from=homeView', 'Comments', 'left=250,top=250,resizable=no,scrollbars=no,status=no,toolbar=no,height=300,width=500');
	}
	
	function closeComments(id)
	{
		parent.frames['hiddenFrame'].document.location.href = "manageCommentsProcess.jsp?cmtId="+id+"&mode=close&from=homeView";
	}
	
	function openController(sCntrl)
	{
		if(sCntrl == "General")
		{
			parent.document.location.href = "generalParamsView.jsp?controller="+sCntrl;
		}
		else
		{
			parent.document.location.href = "singleRoomView.jsp?controller="+sCntrl;
		}
	}
	
	function viewAttachments(taskname)
	{
		var url = "../ViewAttachments?folder="+taskname;
		document.location.href =  url;
	}
	</script>
</head>

<body>
	<form name="frm">

			<!-- Main Container -->
			<div id="main-container">

				<!-- Page content -->
				<div id="page-content">
					<div class="block full">
						<div class="block-title">
							<h2>Dashboard</h2>
						</div>
						<div class="table-responsive">
							<table id="example-datatable"
								class="table table-striped table-bordered table-vcenter">
								<thead>
									<tr>
										<th class="text-center" style="width: 15px;">ATT</th>
										<th><%= resourceBundle.getProperty("DataManager.DisplayText.Room") %></th>
										<th><%= resourceBundle.getProperty("DataManager.DisplayText.Stage") %></th>
										<th><%= resourceBundle.getProperty("DataManager.DisplayText.Batch_No") %></th>
										<th><%= resourceBundle.getProperty("DataManager.DisplayText.Logged_By") %></th>
										<th><%= resourceBundle.getProperty("DataManager.DisplayText.Logged_On") %></th>
										<th><%= resourceBundle.getProperty("DataManager.DisplayText.Text") %></th>
										<th><%= resourceBundle.getProperty("DataManager.DisplayText.Comments") %></th>
										<th><%= resourceBundle.getProperty("DataManager.DisplayText.Department") %></th>
										<th style="width: 15px;">Status</th>
									</tr>
								</thead>
								<tbody>
								<%
			Comments comments = new Comments();
			StringList slUserDept = new StringList();
			slUserDept.add(u.getDepartment());
			slUserDept.addAll(u.getSecondaryDepartments());
			
			MapList mlComments = comments.getGlobalAlerts(slUserDept);
			int iSz = mlComments.size();
			if(iSz > 0)
			{
				StringList slInactiveCntrl = RDMSession.getInactiveControllers();

				Map<String, String> mUsers = RDMServicesUtils.getUserNames();
				Map<String, String> mComment = null;
				String sCmtId = null;
				String sRoomId = null;
				String sBatchNo = null;
				String sLoggedBy = null;
				String sNoDays = null;
				String sAttachments = null;
				for(int i=0; i<iSz; i++)
				{
					mComment = mlComments.get(i);
					sCmtId = mComment.get(RDMServicesConstants.COMMENT_ID);
					sRoomId = mComment.get(RDMServicesConstants.ROOM_ID);
					sBatchNo = mComment.get(RDMServicesConstants.BATCH_NO);
					sBatchNo = (sBatchNo.startsWith("auto_") ? "" : sBatchNo);
					sLoggedBy = mComment.get(RDMServicesConstants.LOGGED_BY);
					if(mUsers.containsKey(sLoggedBy))
					{
						sLoggedBy = mUsers.get(sLoggedBy);
					}
					sNoDays = mComment.get(RDMServicesConstants.RUNNING_DAY);
					sNoDays = ((sNoDays == null || "0".equals(sNoDays)) ? "" : " ("+sNoDays+")");
					sAttachments = mComment.get(RDMServicesConstants.ATTACHMENTS);
					sAttachments = ((sAttachments == null || "null".equals(sAttachments)) ? "" : sAttachments);
%>

								
									<tr>

										<td class="text-center">
											<%
							if(!"".equals(sAttachments))
							{
%> 
								<a href="javascript:viewAttachments('<%= sCmtId %>')"><img src="../img/attachments.png"></img></a> 
<%
							}
							else
							{
%> 
								&nbsp;
<%
							}
%>
										</td>

										<%
						if(slInactiveCntrl.contains(sRoomId))
						{
%>
										<td><strong><%= sRoomId %></strong></td>
										<%
						}
						else
						{
%>
										<td><strong><a
												href="javascript:openController('<%= sRoomId %>')"><%= sRoomId %></a></strong></td>
										<%
						}
%>
										<td><%= mComment.get(RDMServicesConstants.STAGE_NUMBER) %><%= sNoDays %></td>
										<td><%= sBatchNo %></td>
										<td><%= sLoggedBy %></td>
										<td><%= mComment.get(RDMServicesConstants.LOGGED_ON) %></td>
										<td><%= mComment.get(RDMServicesConstants.CATEGORY) %>&nbsp;(<%= mComment.get(RDMServicesConstants.LOG_TEXT) %>)</td>
										<td><%= mComment.get(RDMServicesConstants.REVIEW_COMMENTS) %></td>
										<td><%= (mComment.get(RDMServicesConstants.DEPARTMENT_NAME)).replaceAll("\\|", "<br>") %></td>
										<td class="text-center">
											<a href="javascript:updateComments('<%= sCmtId %>', '<%= sBatchNo %>', 'true')"
												data-toggle="tooltip" title="<%= resourceBundle.getProperty("DataManager.DisplayText.Update") %>"
												class="btn btn-effect-ripple btn-xs btn-success"><i class="fa fa-pencil"></i></a> 
											<a href="javascript:closeComments('<%= sCmtId %>')"
												data-toggle="tooltip" title="<%= resourceBundle.getProperty("DataManager.DisplayText.Close") %>"
												class="btn btn-effect-ripple btn-xs btn-danger"><i class="fa fa-times"></i></a>
										</td>
									</tr>

									<%
				}
			}
			else
			{
%>
									<tr>
										<td class="text-center" style="text-align: center"
											colspan="10"><%= resourceBundle.getProperty("DataManager.DisplayText.No_Alerts") %></td>
									</tr>

									<%
			}
%>
								</tbody>
							</table>
						</div>
					</div>
					<!-- END Datatables Block -->
					
				</div>
				<!-- END Page Content -->
			</div>
			<!-- END Main Container -->
	
	</form>
</body>
</html>
