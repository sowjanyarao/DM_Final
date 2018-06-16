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

<%
String[] saTaskIds = request.getParameterValues("taskId");
String sRoom = request.getParameter("room");
String sOwner = request.getParameter("owner");
String sAssignee = request.getParameter("assignee");
String sFromDate = "";//request.getParameter("start_date");
String sToDate = "";//request.getParameter("end_date");
String sStatus = request.getParameter("status");
String mode = request.getParameter("mode");
String batch = request.getParameter("batch");
if(batch==null)
	batch="";
String stage = request.getParameter("stage");
String sDept = request.getParameter("dept");
boolean childTasks = "Y".equals(request.getParameter("childTasks"));
boolean parentTasks = "Y".equals(request.getParameter("parentTasks"));
boolean coOwners = "Y".equals(request.getParameter("coOwners"));
String limit = request.getParameter("limit");
String searchType = request.getParameter("searchType");
boolean bUserBased = RDMServicesConstants.USER_BASED.equals(searchType);

StringBuilder sbTasksIds = new StringBuilder();
if(saTaskIds != null)
{
	int idx = 0;
	for(int n=0, iCnt=saTaskIds.length; n<iCnt; n++)
	{
		if(!"".equals(saTaskIds[n]))
		{
			if(idx > 0)
			{
				sbTasksIds.append("','");
			}
			sbTasksIds.append(saTaskIds[n]);
			idx++;
		}
	}
}
String sTaskId = sbTasksIds.toString();

int iLimit = -1;
if(limit != null && !"".equals(limit))
{
	iLimit = Integer.parseInt(limit.trim());
}

List<String> lSorted = null;
Map<String, UserTasks.TaskInfo> mTasks = null;
UserTasks userTasks = new UserTasks();
if(mode != null)
{
	mTasks = userTasks.searchTasks(sRoom, sTaskId, sDept, sOwner, sAssignee, sFromDate, sToDate, 
		sStatus, batch, stage, childTasks, parentTasks, coOwners, iLimit, searchType);
	
	lSorted = userTasks.sort(mTasks, searchType);
}

Map<String, String> mUserNames = RDMServicesUtils.getUserNames();

boolean bChangeStatus = RDMServicesConstants.ROLE_SUPERVISOR.equals(u.getRole());
boolean bDownloadTask = !(RDMServicesConstants.ROLE_HELPER.equals(u.getRole()));
boolean bDeleteTask = RDMServicesConstants.ROLE_ADMIN.equals(u.getRole());

StringList slInactiveCntrl = RDMSession.getInactiveControllers();
%>
<!DOCTYPE html>
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
    <script>
        $('.collapse').collapse()
    </script>
    
    <style type="text/css">		
		td.txtLabel
		{
			border: solid 1px #ffffff;
			text-align: left;
			background-color: #888888;
			color: #ffffff;
			font-size:12px;
			font-family:Arial,sans-serif;
			font-weight: bold;
		}
		
	</style>

	<script language="javascript">
	if (typeof String.prototype.startsWith != 'function') {
		String.prototype.startsWith = function (str) {
			return this.slice(0, str.length) == str;
		};
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
	
	function showTaskDetails(sTaskId)
	{
		window.open('userTaskDetailsView.jsp?taskId='+sTaskId, '', 'left=200,top=100,resizable=yes,scrollbars=yes,status=no,toolbar=no,height=650,width=600');			
	}
	
	function showTaskDeliverables(sTaskId)
	{
		window.open('userTaskDeliverablesView.jsp?taskId='+sTaskId, '', 'left=25,top=25,resizable=yes,scrollbars=yes,status=no,toolbar=no,height=600,width=800');			
	}
	
	function showTaskWBS(sTaskName, sTaskId)
	{
		window.open('userTaskWBSView.jsp?taskName='+sTaskName+'&taskId='+sTaskId, '', 'left=25,top=25,resizable=yes,scrollbars=yes,status=no,toolbar=no,height=800,width=1200');			
	}
	
	function checkAll () 
	{
		var check = document.getElementById('chk_all').checked;
		var val = "";
		if(check)
		{
			val = "Y";
		}
		else
		{
			val = "N";
		}

		var inputs = document.getElementsByTagName("input");
		for(var i=0; i<inputs.length; i++)
		{
			var e = inputs[i];
			if(e.type == "checkbox")
			{
				if((e.name == 'chk_all') || (e.disabled))
				{
					//do nothing
				}
				else
				{
					e.checked = check;
					e.value = val;
				}
			}  
		}
	}
	
	function check (e) 
	{
		if(e.checked)
		{
			e.value = "Y";
		}
		else
		{
			e.value = "N";
		}
	}
	
	function startTasks()
	{
		document.getElementById("mode").value = "start";
		document.frm.submit();
	}
	
	function completeTasks()
	{
		document.getElementById("mode").value = "complete";
		document.frm.submit();
	}

	function deleteTasks()
	{
		alert("delete");
		var conf = confirm("<%= resourceBundle.getProperty("DataManager.DisplayText.Delete_Task") %>");
		if(conf == true)
		{
			document.getElementById("mode").value = "delete";
			document.frm.submit();
		}
	}
	
	function download()
	{
		document.getElementById("mode").value = "download";
		document.frm.submit();
	}
	
	function copyTasks()
	{
		var fg = false;
		var inputs = document.getElementsByTagName("input");
		for(var i=0; i<inputs.length; i++)
		{
			var e = inputs[i];
			if(e.type == "checkbox")
			{
				if((e.name == 'chk_all') || (e.disabled))
				{
					//do nothing
				}
				else
				{
					if(e.checked)
					{
						fg = true;
					}
				}
			}  
		}
		
		if(fg)
		{
			var w = window.open('', 'Popup_Window', 'toolbar=0,scrollbars=0,location=0,statusbar=0,menubar=0,resizable=0,width=400,height=450,left=300,top=200');

			document.frm.target = 'Popup_Window';
			document.frm.action = 'copyUserTasks.jsp';
			document.frm.submit();
		}
		else
		{
			alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Select_Copy_Tasks") %>");
		}
	}
	
	function toggleDisplay(divId)
	{
		var divs = document.getElementsByTagName("div");
		for(var i = 0; i < divs.length; i++)
		{
			if(divs[i].id == "noTasks" || divs[i].id == "totalDeliverables" || divs[i].id == "NotDownloadDeliverables" || divs[i].id.startsWith("Room_"))
			{
				continue;
			}
			
			if(divs[i].id == divId)
			{
				var display = divs[i].style.display;
				if(display == "block")
				{
					display = "none";
				}
				else
				{
					display = "block";
				}
				divs[i].style.display = display;
			}
			else
			{
				divs[i].style.display = "none";
			}
		}		
	}
	
	function showTaskInfo(id, notes, size)
	{
		parent.document.getElementById('taskInfo_id').style.display = "block";
		parent.document.getElementById('taskInfo_id').innerHTML = id;
		
		parent.document.getElementById('taskInfo_notes').style.display = "block";
		parent.document.getElementById('taskInfo_notes').innerHTML = notes;
		
		parent.document.getElementById('taskInfo_size').style.display = "block";
		parent.document.getElementById('taskInfo_size').innerHTML = "<b>" + size + "</b>";
	}
	
	function hideTaskInfo()
	{
		parent.document.getElementById('taskInfo_id').style.display = "none";
		parent.document.getElementById('taskInfo_id').innerHTML = "";
		
		parent.document.getElementById('taskInfo_notes').style.display = "none";
		parent.document.getElementById('taskInfo_notes').innerHTML = "";
		
		parent.document.getElementById('taskInfo_size').style.display = "none";
		parent.document.getElementById('taskInfo_size').innerHTML = "";
	}
	
	function showDetails(userId)
	{
		var retval = window.open('employeeInOut.jsp?userId='+userId, '', 'left=250,top=250,resizable=no,scrollbars=no,status=no,toolbar=no,height=300,width=420');
	}
	
	function viewAttachments(taskname)
	{
		var url = "../ViewAttachments?folder="+taskname;
		document.location.href =  url;
	}
	</script>
</head>

<body style="background-color: #ffffff !important;">
<%	
	boolean bFlag = (bChangeStatus && RDMServicesConstants.TASK_STATUS_CANCELLED.equals(sStatus));
%>
	<form name="frm" action="manageUserTaskProcess.jsp" method="post" target="hiddenFrame">
		<input type="hidden" id="mode" name="mode" value="">
			
		<div class="table table-responsive table-hover">
		
        <table id="datatable" class="table table-striped table-bordered table-vcenter">
			<tr>
				<td class="text-center" width="5%" style="font-size:14px;font-weight:bold;text-align:center"><div id="noTasks"></div></td>
				<td class="text-center" width="95%" colspan="17" style="font-size:12px;font-weight:bold;text-align:left"><div id="totalDeliverables"></div></td>
			</tr>
<%
		int iSz = 0;
		Iterator<String> itrTask = null;
		Iterator<String> itrDel = null;
		Map<String, String> mTask = null;
		MapList mlTasks = null;
		
		String sAttrName = null;
		String sGroupName = null;
		String sTaskAdmId = null;
		String sParent = null;
		String sBatchNo = null;
		String sAttachments = null;
		String sTaskAdmName = null;
		String sTaskInfo = null;
		String sNotes = null;
		StringBuilder sbGroupHeader = null;
		StringBuilder sbOverage = null;
		
		UserTasks.TaskInfo taskInfo = null;
		Map<String, Integer> mTaskDuration = null;
		Map<String, Integer[]> mDeliverableCnt = null;
		Map<String, Double[]> mDeliverableQty = null;
		Map<String, Integer> mTotalDelCnt = new HashMap<String, Integer>();
		Map<String, Double> mTotalDelQty = new HashMap<String, Double>();
		Map<String, Double> mTotalOverage = new HashMap<String, Double>();
		
		long totalTime = 0;
		int iTotalTasks = 0;
		int iDelCnt = 0;
		double dDelQty = 0;
		double dOverage = 0;	
		double dTaskOverage = 0;
		double dTaskTotal = 0;
		Integer iTotalDelCnt = null;
		Double dTotalDelQty = null;
		Double dTotalOverage = null;
		Double dTotalQuantity = null;
		StringBuilder sbNotDownloaded = null;
		DecimalFormat df = new DecimalFormat("#.###");
		DecimalFormat dfPercent = new DecimalFormat("#.##");

		if(mode != null)
		{
			SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy HH:mm", Locale.ENGLISH);
			Date currDt = new Date();
			Date lastDt = null;
			
			SimpleDateFormat sdfIn = new SimpleDateFormat("dd-MM-yyyy", Locale.ENGLISH);
			if("".equals(sFromDate))
			{
				Calendar cal = Calendar.getInstance();
				cal.add(Calendar.DAY_OF_YEAR, -7);
				sFromDate = sdfIn.format(cal.getTime());
			}
			if("".equals(sToDate))
			{
				sToDate = sdfIn.format(currDt);
			}
			
			boolean bUserNotLoggedIn = false;
			int iDurationAlert = 0;
			long lMin = 0;
			String sDate = null;
			String sInTime = null;
			String sLastTime = null;
			MapList mlUserLogs = null;
			Map<String, MapList> mLogs = null;
			Map<String, String> mLogData = null;
			Map<String, String> mInfo = new HashMap<String, String>();
			mInfo.put(RDMServicesConstants.USER_ID, sAssignee);
			mInfo.put(RDMServicesConstants.FIRST_NAME, "");
			mInfo.put(RDMServicesConstants.LAST_NAME, "");
			mInfo.put(RDMServicesConstants.DEPT_NAME, "");
			mInfo.put("fromDate", sFromDate);
			mInfo.put("endDate", sToDate);
			mInfo.put("loggedIn", "Y");
			mInfo.put("loggedOut", "Y");
			Map<String, Map<String, MapList>> mUserLogs = RDMServicesUtils.getTimesheets(mInfo);
			
			sdfIn = new SimpleDateFormat("MM/dd/yyyy", Locale.ENGLISH);
			SimpleDateFormat sdfOut = new SimpleDateFormat("dd-MMM-yyyy", Locale.ENGLISH);
			SimpleDateFormat sdfIn1 = new SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.ENGLISH);
			SimpleDateFormat sdfOut1 = new SimpleDateFormat("MM/dd/yyyy HH:mm", Locale.ENGLISH);
			for(int x=0; x<lSorted.size(); x++)
			{
				sGroupName = lSorted.get(x);
				taskInfo = mTasks.get(sGroupName);
				mlTasks = taskInfo.getTasks();
				
				iSz = mlTasks.size();
				if(iSz > 0)
				{
					iTotalTasks += iSz;
					for(int i=0; i<iSz; i++)
					{
						mTask = mlTasks.get(i);
						sRoom = mTask.get(RDMServicesConstants.ROOM_ID);
						sTaskId = mTask.get(RDMServicesConstants.TASK_AUTONAME);
						sTaskAdmId = mTask.get(RDMServicesConstants.TASK_ID);
						sStatus = mTask.get(RDMServicesConstants.STATUS);
						sAssignee = mTask.get(RDMServicesConstants.ASSIGNEE);
						sParent = mTask.get(RDMServicesConstants.PARENT_TASK);
						sParent = ((sParent == null || "null".equals(sParent)) ? "" : sParent);
						sBatchNo = mTask.get(RDMServicesConstants.BATCH_NO);
						sBatchNo = ((sBatchNo == null || "null".equals(sBatchNo)) ? "" : sBatchNo);
						sAttachments = mTask.get(RDMServicesConstants.ATTACHMENTS);
						sAttachments = ((sAttachments == null || "null".equals(sAttachments)) ? "" : sAttachments);
						sTaskAdmName = mTask.get(RDMServicesConstants.TASK_NAME);
						
						if(i == 0)
						{
							mDeliverableCnt = taskInfo.getSize();
							mDeliverableQty = taskInfo.getQuantity();
							sbGroupHeader = new StringBuilder();
							sbOverage = new StringBuilder();
							dTaskOverage = 0;
							dTaskTotal = 0;
							
							sbNotDownloaded = new StringBuilder();
							itrDel = mDeliverableCnt.keySet().iterator();
							while(itrDel.hasNext())
							{
								sAttrName = itrDel.next();
								iDelCnt = mDeliverableCnt.get(sAttrName)[0];
								dDelQty = mDeliverableQty.get(sAttrName)[0];
								dOverage = mDeliverableQty.get(sAttrName)[2];
								dTaskOverage += dOverage;
								dTaskTotal += dDelQty;
								
								if(mTotalDelCnt.containsKey(sAttrName))
								{
									iTotalDelCnt = mTotalDelCnt.get(sAttrName);
									iTotalDelCnt += iDelCnt;
									
									dTotalDelQty = mTotalDelQty.get(sAttrName);
									dTotalDelQty += dDelQty;
									
									dTotalOverage = mTotalOverage.get(sAttrName);
									dTotalOverage += dOverage;
								}
								else
								{
									iTotalDelCnt = iDelCnt;
									dTotalDelQty = dDelQty;
									dTotalOverage = dOverage;
								}
								mTotalDelCnt.put(sAttrName, iTotalDelCnt);
								mTotalDelQty.put(sAttrName, dTotalDelQty);
								mTotalOverage.put(sAttrName, dTotalOverage);
								sbGroupHeader.append(sAttrName);
								sbGroupHeader.append(" (");
								sbGroupHeader.append(RDMServicesUtils.getAttributeUnits().get(sAttrName));
								sbGroupHeader.append("): ");
								sbGroupHeader.append("<font color='#fff782'>");
								sbGroupHeader.append(df.format(dDelQty));
								sbGroupHeader.append(" (");
								sbGroupHeader.append(iDelCnt);
								sbGroupHeader.append(")");
								sbGroupHeader.append("</font>");
								sbGroupHeader.append("  ");
								
								sbNotDownloaded.append(sAttrName);
								sbNotDownloaded.append(" (");
								sbNotDownloaded.append(RDMServicesUtils.getAttributeUnits().get(sAttrName));
								sbNotDownloaded.append("): ");
								sbNotDownloaded.append("<font color='#fff782'>");
								sbNotDownloaded.append(df.format(mDeliverableQty.get(sAttrName)[1]));
								sbNotDownloaded.append(" (");
								sbNotDownloaded.append(mDeliverableCnt.get(sAttrName)[1]);
								sbNotDownloaded.append(")");
								sbNotDownloaded.append("</font>");
								sbNotDownloaded.append("  ");
								
								sbOverage.append(sAttrName);
								sbOverage.append(" (");
								sbOverage.append(RDMServicesUtils.getAttributeUnits().get(sAttrName));
								sbOverage.append("): ");
								sbOverage.append("<font color='#fff782'>");
								sbOverage.append(df.format(dOverage));
								sbOverage.append(" (");
								sbOverage.append(dfPercent.format((dOverage / dDelQty) * 100));
								sbOverage.append("%)</font>");
								sbOverage.append("  ");
							}
							
							if(dTaskOverage > 0)
							{
								sbGroupHeader.append("<br>");
								sbGroupHeader.append(resourceBundle.getProperty("DataManager.DisplayText.Overage"));
								sbGroupHeader.append(":&nbsp;");
								sbGroupHeader.append("<font color='#fff782'>");
								sbGroupHeader.append(df.format(dTaskOverage));
								sbGroupHeader.append("&nbsp;(");
								sbGroupHeader.append(dfPercent.format((dTaskOverage / dTaskTotal) * 100));
								sbGroupHeader.append("%)</font>");
								sbGroupHeader.append("&nbsp;&nbsp;&nbsp;");
								sbGroupHeader.append(sbOverage.toString());
							}
			
							sbGroupHeader.append("</td>");
							if(bUserBased)
							{
								totalTime = taskInfo.getTime();
								sbGroupHeader.append("<td class='input' width='38%' style='font-size:12px;font-weight:bold;text-align:left' colspan='7'>");
								sbGroupHeader.append(resourceBundle.getProperty("DataManager.DisplayText.Duration"));
								sbGroupHeader.append(": <font color='#fff782'>");
								sbGroupHeader.append((totalTime / 60) + " hr : " + (totalTime % 60) + " mm");
								sbGroupHeader.append("</font>");
								sbGroupHeader.append("&nbsp;&nbsp;&nbsp;&nbsp;");
								sbGroupHeader.append(resourceBundle.getProperty("DataManager.DisplayText.Productivity"));
								sbGroupHeader.append(": <font color='#fff782'>");
								sbGroupHeader.append(df.format(taskInfo.getProductivity()));
								sbGroupHeader.append("</font>");
							}
							else
							{
								sbGroupHeader.append("<td class='input task_in_name' width='38%' style='font-size:12px;font-weight:bold;text-align:left' colspan='7'>");
								sbGroupHeader.append(sbNotDownloaded.toString());
							}
%>
							<tr class="task_rw_bg">
							
								<td class="input" width="8%" style="font-size:12px;font-weight:bold;text-align:center" colspan="2">
									<a id="<%= sGroupName %>" class="noblink task_rw_head" href="javascript:toggleDisplay('div_<%= sGroupName %>')">
										<%= mUserNames.containsKey(sGroupName) ? (mUserNames.get(sGroupName)+"&nbsp;("+sAssignee+")") : sGroupName %>
									</a>
								</td>
<%
								if(bUserBased)
								{
%>
									<td class='input task_in_name' width='54%' style='font-size:12px;font-weight:bold;text-align:left;' colspan='8'>
<%
								}
								else
								{
%>
									<td class='input task_in_name' width='92%' style='font-size:12px;font-weight:bold;text-align:left' colspan='15'>
<%
								}
								
								if(dTaskTotal > 0)
								{
%>
									<%= resourceBundle.getProperty("DataManager.DisplayText.Total") %>:&nbsp;
									<font color='#fff782'><%= df.format(dTaskTotal) %></font>&nbsp;&nbsp;&nbsp;
<%
								}
								
%>
									<%= sbGroupHeader.toString() %>
								</td>
							</tr>
							<tr>
								<td colspan="18">
									<div id="div_<%= sGroupName %>" style="display:block">
										  <table id="example-datatable2" class="table table-striped table-bordered table-vcenter">
										  
											<tr>
												<th class="text-center" ><input type="checkbox" id="chk_all" name="chk_all" <%= bFlag ? "disabled" : "" %> onClick="javascript:checkAll()"></th>
												<th class="text-center">ATT</th>
												<th class="text-center" ><%= resourceBundle.getProperty("DataManager.DisplayText.Task_Name") %></th>
												<th class="text-center"><%= resourceBundle.getProperty("DataManager.DisplayText.Task_Id") %></th>
												<th class="text-center"><%= resourceBundle.getProperty("DataManager.DisplayText.Room_No") %></th>
												<th class="text-center" ><%= resourceBundle.getProperty("DataManager.DisplayText.Batch_No") %></th>
												<th class="text-center"><%= resourceBundle.getProperty("DataManager.DisplayText.Status") %></th>
												<th class="text-center"><%= resourceBundle.getProperty("DataManager.DisplayText.Owner") %></th>
												<th class="text-center"><%= resourceBundle.getProperty("DataManager.DisplayText.Assignee") %></th>
												<th class="text-center"><%= resourceBundle.getProperty("DataManager.DisplayText.In_Time") %></th>
												<th class="text-center"><%= resourceBundle.getProperty("DataManager.DisplayText.Estimated_Start").replaceAll(" ", "<br>") %></th>
												<th class="text-center"><%= resourceBundle.getProperty("DataManager.DisplayText.Estimated_End").replaceAll(" ", "<br>") %></th>
												<th class="text-center"><%= resourceBundle.getProperty("DataManager.DisplayText.Actual_Start").replaceAll(" ", "<br>") %></th>
												<th class="text-center"><%= resourceBundle.getProperty("DataManager.DisplayText.Actual_End").replaceAll(" ", "<br>") %></th>
												<th class="text-center"><%= resourceBundle.getProperty("DataManager.DisplayText.First_Del_CreatedOn").replaceAll(" ", "<br>") %></th>
												<th class="text-center"><%= resourceBundle.getProperty("DataManager.DisplayText.Last_Del_CreatedOn").replaceAll(" ", "<br>") %></th>
												<th class="text-center"><%= resourceBundle.getProperty("DataManager.DisplayText.Deliverables") %></th>
												<th class="text-center"><%= resourceBundle.getProperty("DataManager.DisplayText.WBS") %></th>
											</tr>
											
<%
						}
						
						sInTime = "";
						bUserNotLoggedIn = false;
						mLogs = mUserLogs.get(sAssignee);
						if(mLogs != null)
						{
							sDate = mTask.get(RDMServicesConstants.ACTUAL_START);
							if("".equals(sDate))
							{
								sDate = mTask.get(RDMServicesConstants.ESTIMATED_START);
							}
							sDate = sDate.substring(0, sDate.indexOf(" "));
							sDate = sdfOut.format(sdfIn.parse(sDate));
							
							mlUserLogs = mLogs.get(sDate);
							if(mlUserLogs != null && mlUserLogs.size() > 0)
							{
								mLogData = mlUserLogs.get(mlUserLogs.size() - 1);
								sInTime = mLogData.get(RDMServicesConstants.LOG_IN);
								sInTime = sdfOut1.format(sdfIn1.parse(sInTime));
							}
							
							mlUserLogs = mLogs.get(sdfOut.format(currDt));
							if(mlUserLogs != null && mlUserLogs.size() > 0)
							{
								mLogData = mlUserLogs.get(mlUserLogs.size() - 1);
								bUserNotLoggedIn = ("".equals(mLogData.get(RDMServicesConstants.LOG_IN)) && "".equals(mLogData.get(RDMServicesConstants.LOG_OUT)));
							}
						}
						
						bFlag = (bChangeStatus && ((bUserNotLoggedIn && RDMServicesConstants.TASK_STATUS_NOT_STARTED.equals(sStatus)) || 
							RDMServicesConstants.TASK_STATUS_CANCELLED.equals(sStatus)));
						
						sNotes = mTask.get(RDMServicesConstants.NOTES);
						sNotes = "<b>" + resourceBundle.getProperty("DataManager.DisplayText.Notes") + ":&nbsp;</b>" 
							+ ((sNotes == null || "null".equalsIgnoreCase(sNotes)) ? "" : sNotes.replaceAll("\"", "").replaceAll("'", ""));
%>
						<tr onMouseOver="showTaskInfo('<%= sTaskId %>', '<%= sNotes.replaceAll("\r", " ").replaceAll("\n", " ") %>', '<%= mTask.get(RDMServicesConstants.TASK_DELIVERABLES) %>'); this.style.color='blue'" onMouseOut="hideTaskInfo(); this.style.color='black'">
							<td class="input">
								<input type="checkbox" id="<%= sTaskId %>" name="<%= sTaskId %>" <%= bFlag ? "disabled" : "" %> value="N" onClick="javascript:check(this)">
								<input type="hidden" id="<%= sTaskId %>_Status" name="<%= sTaskId %>_Status" value="<%= sStatus %>">
							</td>
							<td class="input">
<%
							if(!"".equals(sAttachments))
							{
%>
								<a href="javascript:viewAttachments('<%= sTaskId %>')"><img src="../images/attachments.png"></img></a>
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
							<td class="input"><a href="javascript:showTaskDetails('<%= sTaskId %>')"><%= sTaskId %></a></td>
							<td class="input"><%= sTaskAdmId %> <%= "".equals(sTaskAdmName) ? "" : "(" + sTaskAdmName + ")" %></td>
<%
							if(slInactiveCntrl.contains(sRoom))
							{
%>
								<td class="input"><%= sRoom %></td>
<%
							}
							else
							{
%>
								<td class="input"><a href="javascript:openController('<%= sRoom %>')"><%= sRoom %></a></td>
<%
							}
%>
							<td class="input"><%= sBatchNo %></td>
							<td class="input"><%= sStatus %></td>
							<td class="input">
								<a style="text-decoration:underline;color:black" href="javascript:showDetails('<%= mTask.get(RDMServicesConstants.OWNER) %>')">
									<%= mUserNames.get(mTask.get(RDMServicesConstants.OWNER)) %> (<%= mTask.get(RDMServicesConstants.OWNER) %>)
								</a>
							</td>
							<td class="input">
								<a style="text-decoration:underline;color:black" href="javascript:showDetails('<%= sAssignee %>')">
									<%= ("".equals(sAssignee) ? "" : mUserNames.get(sAssignee) + " (" + sAssignee +")") %>
								</a>
							</td>							
							<td class="input"><%= sInTime %></td>
							<td class="input"><%= mTask.get(RDMServicesConstants.ESTIMATED_START) %></td>
							<td class="input"><%= mTask.get(RDMServicesConstants.ESTIMATED_END) %></td>
							<td class="input"><%= mTask.get(RDMServicesConstants.ACTUAL_START) %></td>
							<td class="input"><%= mTask.get(RDMServicesConstants.ACTUAL_END) %></td>
							<td class="input"><%= mTask.get(RDMServicesConstants.FIRST_DELIVERABLE_CREATED_ON) %></td>
							<td class="input"><%= mTask.get(RDMServicesConstants.LAST_DELIVERABLE_CREATED_ON) %></td>
							<td class="input" style="font-size:14px;text-align:center">
<%
							if(RDMServicesConstants.TASK_STATUS_NOT_STARTED.equals(sStatus))
							{
%>
								&nbsp;
<%
							}
							else
							{
								sLastTime =  mTask.get(RDMServicesConstants.LAST_DELIVERABLE_CREATED_ON);
								if("".equals(sLastTime))
								{
									sLastTime =  mTask.get(RDMServicesConstants.ACTUAL_START);
								}
								
								lMin = 0;
								if(!"".equals(sLastTime))
								{
									lastDt = sdf.parse(sLastTime);
									lMin = (currDt.getTime() - lastDt.getTime()) / (60 * 1000);
								}
								
								mTaskDuration = RDMServicesUtils.getTaskAlertDuration();
								iDurationAlert = (mTaskDuration.containsKey(sTaskAdmId) ? mTaskDuration.get(sTaskAdmId) : 0);
								if("".equals(mTask.get(RDMServicesConstants.ACTUAL_END)) && (iDurationAlert > 0 && lMin > iDurationAlert))
								{
%>
									<a href="javascript:showTaskDeliverables('<%= sTaskId %>')" style="text-decoration:underline;color:red">
										<blink><font color='red'>
										<%= mTask.get(RDMServicesConstants.NOT_DOWNLOADED) %>(<%= mTask.get(RDMServicesConstants.DELIVERABLE_CNT) %>)
										</font></blink>
									</a>
									
									<script language="javascript">
										document.getElementById('<%= sGroupName %>').className = "blink";
									</script>
<%
								}
								else
								{
%>
									<a href="javascript:showTaskDeliverables('<%= sTaskId %>')">
										<%= mTask.get(RDMServicesConstants.NOT_DOWNLOADED) %>(<%= mTask.get(RDMServicesConstants.DELIVERABLE_CNT) %>)
									</a>
<%
								}
							}
%>
							</td>
							<td class="input" style="font-size:14px;text-align:center">
								<a href="javascript:showTaskWBS('<%= sTaskId %>', '<%= sTaskAdmId %>')">
									<%= mTask.get(RDMServicesConstants.NO_CHILD_TASKS) %>(<%= mTask.get(RDMServicesConstants.NO_CHILD_TASKS_CLOSED) %>)
								</a>
							</td>
						</tr>
<%
						if(i == (iSz - 1))
						{
%>
										</table>
									</div>
								</td>
							</tr>
<%
						}
					}
				}
				else
				{
%>
					<tr>
						<td class="input" style="text-align:center" colspan="17">
							<%= resourceBundle.getProperty("DataManager.DisplayText.No_User_Tasks") %>
						</td>
					</tr>
<%
				}
			}
		}
		else
		{
%>
			<tr>
				<td class="input" style="text-align:center" colspan="17">
					<%= resourceBundle.getProperty("DataManager.DisplayText.Tasks_Search_Msg") %>
				</td>
			</tr>
<%
		}
%>
		</table>
		</div>
	</form>
	<script language="javascript">
		parent.document.getElementById('start').disabled = true;				
		parent.document.getElementById('complete').disabled = true;	
		parent.document.getElementById('copy').disabled = true;		
		parent.document.getElementById('delete').disabled = true;
		parent.document.getElementById('download').disabled = true;
		parent.document.getElementById('start').style.display = "none";
		parent.document.getElementById('complete').style.display = "none";
		parent.document.getElementById('copy').style.display = "none";
		parent.document.getElementById('delete').style.display = "none";
		parent.document.getElementById('download').style.display = "none";
		parent.document.getElementById('actions').style.display = "none";
		parent.document.getElementById('copybtn').style.display = "none";
		parent.document.getElementById('downloadbtn').style.display = "none";
<%
		sStatus = request.getParameter("status");
		if(mlTasks != null && mlTasks.size() > 0)
		{
%>
			parent.document.getElementById('actions').style.display = "block";
<%
			if(bChangeStatus)
			{
				if(!(RDMServicesConstants.TASK_STATUS_CANCELLED.equals(sStatus) || 
					RDMServicesConstants.TASK_STATUS_NOT_STARTED.equals(sStatus)))
				{
%>
					parent.document.getElementById('copybtn').style.display = "block";
					parent.document.getElementById('copy').disabled = false;
					parent.document.getElementById('copy').style.display = "block";
					
					parent.document.getElementById('downloadbtn').style.display = "block";
					parent.document.getElementById('download').disabled = false;
					parent.document.getElementById('download').style.display = "block";
<%
				}

				if(RDMServicesConstants.TASK_STATUS_NOT_STARTED.equals(sStatus))
				{
%>
					parent.document.getElementById('start').disabled = false;
					parent.document.getElementById('start').style.display = "block";
<%
				}
				else if(RDMServicesConstants.TASK_STATUS_WIP.equals(sStatus))
				{
%>
					parent.document.getElementById('complete').disabled = false;
					parent.document.getElementById('complete').style.display = "block";
<%
				}
			}
			
			if(bDownloadTask)
			{
				if(!(RDMServicesConstants.TASK_STATUS_CANCELLED.equals(sStatus) || 
					RDMServicesConstants.TASK_STATUS_NOT_STARTED.equals(sStatus)))
				{
%>
					parent.document.getElementById('downloadbtn').style.display = "block";
					parent.document.getElementById('download').disabled = false;
					parent.document.getElementById('download').style.display = "block";
<%
				}
			}
			
			if(bDeleteTask)
			{
%>
				parent.document.getElementById('delete').disabled = false;
				parent.document.getElementById('delete').style.display = "block";
<%
			}
		}

		dTotalQuantity = 0.0;
		dTotalOverage = 0.0;
		dTaskOverage = 0.0;
		String sTotalDisplay = "";
		String sTotalOverage = "";
		Iterator<String> itr = mTotalDelCnt.keySet().iterator();
		while(itr.hasNext())
		{
			sAttrName = itr.next();
			dDelQty = mTotalDelQty.get(sAttrName);
			iDelCnt = mTotalDelCnt.get(sAttrName);
			dOverage = mTotalOverage.get(sAttrName);
			
			sTotalDisplay += sAttrName + "&nbsp;("+RDMServicesUtils.getAttributeUnits().get(sAttrName)+"):&nbsp;";
			sTotalDisplay += "<font color='blue'>";
			sTotalDisplay += df.format(dDelQty)+"&nbsp;("+iDelCnt+")</font>&nbsp;&nbsp;&nbsp;";

			dTotalQuantity += dDelQty;
			
			if(dOverage > 0)
			{
				sTotalOverage += sAttrName + "&nbsp;("+RDMServicesUtils.getAttributeUnits().get(sAttrName)+"):&nbsp;";
				sTotalOverage += "<font color='blue'>";
				sTotalOverage += df.format(dOverage) + "&nbsp;(" + dfPercent.format((dOverage / dDelQty) * 100) +"%)</font>&nbsp;&nbsp;&nbsp;";
				
				dTotalOverage += dOverage;
				dTaskOverage += dDelQty;
			}
		}
%>
		document.getElementById('noTasks').innerHTML = "<%= iTotalTasks %>";
		
<%
		if(dTotalQuantity > 0)
		{
%>
			document.getElementById('totalDeliverables').innerHTML = "<%= resourceBundle.getProperty("DataManager.DisplayText.Total") %>" +
				":&nbsp;<font color='blue'> <%= df.format(dTotalQuantity) %> </font>&nbsp;&nbsp;&nbsp; <%= sTotalDisplay %>";	
<%
		}
		
		if(dTotalOverage > 0)
		{
%>
 			document.getElementById('totalDeliverables').innerHTML += "<br>" +
				"<%= resourceBundle.getProperty("DataManager.DisplayText.Overage") %> :&nbsp;<font color='blue'>" + 
					"<%= df.format(dTotalOverage) %>&nbsp;(<%= dfPercent.format((dTotalOverage / dTaskOverage) * 100) %>%)</font>&nbsp;&nbsp;&nbsp;" + 
						"<%= sTotalOverage %>";
<%
		}
%>
</script>
</body>
</html>
