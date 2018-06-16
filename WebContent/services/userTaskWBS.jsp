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
String sTaskId = request.getParameter("taskId");
String sTaskName = request.getParameter("taskName");

UserTasks userTasks = new UserTasks();
MapList mlTasks = userTasks.getTaskWBS(sTaskName);

Map<String, String> mUserNames = RDMServicesUtils.getUserNames();

boolean bChangeStatus = RDMServicesConstants.ROLE_SUPERVISOR.equals(u.getRole());
boolean bDeleteTask = RDMServicesConstants.ROLE_ADMIN.equals(u.getRole());

boolean bFlag = false;
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
	<title></title>
	<link type="text/css" href="../styles/dygraph.css" rel="stylesheet" />
	<script language="javascript">
	function showTaskDetails(sTaskId)
	{
		window.open('userTaskDetailsView.jsp?taskId='+sTaskId, '', 'left=200,top=100,resizable=yes,scrollbars=yes,status=no,toolbar=no,height=650,width=600');		
	}
	
	function reloadWin()
	{
		document.location.href = document.location.href;
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
	
	function showTaskDeliverables(sTaskId)
	{
		window.open('userTaskDeliverablesView.jsp?taskId='+sTaskId, '', 'left=25,top=25,resizable=yes,scrollbars=yes,status=no,toolbar=no,height=600,width=800');			
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
		document.getElementById("mode").value = "delete";
		document.frm.submit();
	}
	
	function exportTasks()
	{
		var url = "../ExportUserTasks";
		url += "?taskName=<%= sTaskName %>";
		url += "&taskId=<%= sTaskId %>";
		url += "&room=";
		url += "&owner="; 
		url += "&assignee=";
		url += "&status=";
		url += "&start_date=";
		url += "&end_date=";
		url += "&batch=";
		url += "&stage=";
		url += "&childTasks=true";

		document.location.href = url;
	}
	</script>
</head>

<body>
	<form name="frm" action="manageUserTaskProcess.jsp" method="post" target="hiddenFrame">
		<input type="hidden" id="mode" name="mode" value="">
		<table border="0" cellpadding="0" align="center" cellspacing="0" width="100%">
			<tr>
				<td colspan="7" align="left">
<%
					if(bChangeStatus)
					{
%>
						<input type="button" id="start" name="start" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Task_Start") %>" onClick="startTasks()">
						<input type="button" id="complete" name="complete" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Task_Complete") %>" onClick="completeTasks()">
<%
					}
					else if(bDeleteTask)
					{
%>
						<input type="button" id="delete" name="delete" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Task_Delete") %>" onClick="deleteTasks()">
<%
					}
%>
				</td>
				<td colspan="6" align="right">
					<input type="button" id="ExportTasks" name="ExportTasks" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Export_Tasks") %>" onClick="exportTasks()">
					<input type="button" id="refresh" name="refresh" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Refresh") %>" onClick="javascript:reloadWin()">
				</td>
			</tr>
			<tr>
				<th class="label" width="3%"><input type="checkbox" id="chk_all" name="chk_all" <%= bFlag ? "disabled" : "" %> onClick="javascript:checkAll()"></th>
				<th class="label" width="10%"><%= resourceBundle.getProperty("DataManager.DisplayText.Task_Name") %></th>
				<th class="label" width="8%"><%= resourceBundle.getProperty("DataManager.DisplayText.Task_Id") %></th>
				<th class="label" width="7%"><%= resourceBundle.getProperty("DataManager.DisplayText.Room_No") %></th>
				<th class="label" width="7%"><%= resourceBundle.getProperty("DataManager.DisplayText.Status") %></th>
				<th class="label" width="10%"><%= resourceBundle.getProperty("DataManager.DisplayText.Owner") %></th>
				<th class="label" width="10%"><%= resourceBundle.getProperty("DataManager.DisplayText.Assignee") %></th>		
				<th class="label" width="10%"><%= resourceBundle.getProperty("DataManager.DisplayText.Estimated_Start") %></th>
				<th class="label" width="10%"><%= resourceBundle.getProperty("DataManager.DisplayText.Estimated_End") %></th>
				<th class="label" width="10%"><%= resourceBundle.getProperty("DataManager.DisplayText.Actual_Start") %></th>
				<th class="label" width="10%"><%= resourceBundle.getProperty("DataManager.DisplayText.Actual_End") %></th>
				<th class="label" width="5%"><%= resourceBundle.getProperty("DataManager.DisplayText.Deliverables") %></th>
			</tr>
<%
			int iSz = mlTasks.size();
			int iLevel = 0;
			String sRoom = null;
			String sAssignee = null;
			String sStatus = null;
			String sWBSTaskId = null;
			String sTaskAdmName = null;
			Map<String, String> mTask = null;

			for(int i=0; i<iSz; i++)
			{
				mTask = mlTasks.get(i);
				
				sWBSTaskId = mTask.get(RDMServicesConstants.TASK_AUTONAME);
				if(sWBSTaskId == null)
				{
					continue;
				}
				
				sRoom = mTask.get(RDMServicesConstants.ROOM_ID);
				iLevel = Integer.parseInt(mTask.get(RDMServicesConstants.TASK_WBS_LEVEL));
				sStatus = mTask.get(RDMServicesConstants.STATUS);
				sAssignee = mTask.get(RDMServicesConstants.ASSIGNEE);
				sTaskAdmName = mTask.get(RDMServicesConstants.TASK_NAME);		
				
				bFlag = (bChangeStatus && (RDMServicesConstants.TASK_STATUS_COMPLETED.equals(sStatus) ||
							RDMServicesConstants.TASK_STATUS_CANCELLED.equals(sStatus) || "".equals(sTaskAdmName)));
%>
				<tr>
					<td class="input">
						<input type="checkbox" id="<%= sWBSTaskId %>" name="<%= sWBSTaskId %>" <%= bFlag ? "disabled" : "" %> value="N" onClick="javascript:check(this)">
						<input type="hidden" id="<%= sWBSTaskId %>_Status" name="<%= sWBSTaskId %>_Status" value="<%= sStatus %>">
					</td>
					<td class="input">
<%
					if(iLevel > 0)
					{
						for(int l=0; l<iLevel; l++)
						{					
%>
							&nbsp;&nbsp;
<%
						}
%>
						<font style="font-size:14px;font-weight:bold">=></font>
<%
					}
%>				
					<a href="javascript:showTaskDetails('<%= sWBSTaskId %>')"><%= sWBSTaskId %></a></td>
					<td class="input"><%= mTask.get(RDMServicesConstants.TASK_ID) %>&nbsp;<%= "".equals(sTaskAdmName) ? "" : "(" + mTask.get(RDMServicesConstants.TASK_NAME) + ")" %></td>
					<td class="input"><%= sRoom %></td>
					<td class="input"><%= sStatus %></td>
					<td class="input"><%= mUserNames.get(mTask.get(RDMServicesConstants.OWNER)) %>&nbsp;(<%= mTask.get(RDMServicesConstants.OWNER) %>)</td>
					<td class="input"><%= ("".equals(sAssignee) ? "" : mUserNames.get(sAssignee)+"&nbsp;("+sAssignee+")") %></td>
					<td class="input"><%= mTask.get(RDMServicesConstants.ESTIMATED_START) %></td>
					<td class="input"><%= mTask.get(RDMServicesConstants.ESTIMATED_END) %></td>
					<td class="input"><%= mTask.get(RDMServicesConstants.ACTUAL_START) %></td>
					<td class="input"><%= mTask.get(RDMServicesConstants.ACTUAL_END) %></td>
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
%>
						<a href="javascript:showTaskDeliverables('<%= sWBSTaskId %>')"><%= mTask.get(RDMServicesConstants.DELIVERABLE_CNT) %></a>
<%
					}
%>
					</td>
				</tr>
<%
			}
%>
		</table>
	</form>
</body>
</html>
