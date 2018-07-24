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
String sUserId = request.getParameter("userId");

UserTasks userTasks = new UserTasks();
MapList mlTasks = userTasks.getOpenTasks(sUserId);

Map<String, String> mUserNames = RDMServicesUtils.getUserNames();

boolean bChangeStatus = RDMServicesConstants.ROLE_SUPERVISOR.equals(u.getRole());
boolean bDeleteTask = RDMServicesConstants.ROLE_ADMIN.equals(u.getRole());
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
	<title></title>
	<link type="text/css" href="../styles/dygraph.css" rel="stylesheet" />
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
		var conf = confirm("<%= resourceBundle.getProperty("DataManager.DisplayText.Delete_Task") %>");
		if(conf == true)
		{
			document.getElementById("mode").value = "delete";
			document.frm.submit();
		}
	}
	</script>
</head>

<body>
	<form name="frm" action="manageUserTaskProcess.jsp" method="post" target="hiddenFrame">
		<input type="hidden" id="mode" name="mode" value="">
		<table class="table table-striped table-bordered table-vcenter">
			<tr>
				<td colspan="12" align="left">
<%
					if(bChangeStatus)
					{
%>
						<input type="button" class="btn btn-effect-ripple btn-primary" id="start" name="start" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Task_Start") %>" onClick="startTasks()">
						<input type="button" class="btn btn-effect-ripple btn-primary" id="complete" name="complete" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Task_Complete") %>" onClick="completeTasks()">
<%
					}
					else if(bDeleteTask)
					{
%>
						<input type="button" class="btn btn-effect-ripple btn-primary" id="delete" name="delete" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Task_Delete") %>" onClick="deleteTasks()">
<%
					}
%>
				</td>
			</tr>
			<tr>
				<th width="3%"><input type="checkbox" id="chk_all" name="chk_all" onClick="javascript:checkAll()"></th>
				<th width="7%"><%= resourceBundle.getProperty("DataManager.DisplayText.Task_Name") %></th>
				<th width="10%"><%= resourceBundle.getProperty("DataManager.DisplayText.Task_Id") %></th>
				<th width="7%"><%= resourceBundle.getProperty("DataManager.DisplayText.Room_No") %></th>
				<th width="7%"><%= resourceBundle.getProperty("DataManager.DisplayText.Status") %></th>
				<th width="15%"><%= resourceBundle.getProperty("DataManager.DisplayText.Owner") %></th>
				<th width="7%"><%= resourceBundle.getProperty("DataManager.DisplayText.Parent_Task") %></th>		
				<th width="9%"><%= resourceBundle.getProperty("DataManager.DisplayText.Estimated_Start") %></th>
				<th width="9%"><%= resourceBundle.getProperty("DataManager.DisplayText.Estimated_End") %></th>
				<th width="9%"><%= resourceBundle.getProperty("DataManager.DisplayText.Actual_Start") %></th>
				<th width="9%"><%= resourceBundle.getProperty("DataManager.DisplayText.Actual_End") %></th>
				<th width="5%"><%= resourceBundle.getProperty("DataManager.DisplayText.Deliverables") %></th>
				<th width="4%"><%= resourceBundle.getProperty("DataManager.DisplayText.WBS") %></th>
			</tr>
<%
			boolean bFg = true;
			int iSz = mlTasks.size();
			String sTaskId = null;
			String sTaskAdmId = null;
			String sRoom = null;
			String sStatus = null;
			String sTaskAdmName = null;
			String sParent = null;
			String sChildTasks = null;
			Map<String, String> mTask = null;
			
			MapList mlChildTasks = new MapList();
			MapList mlParentTasks = new MapList();
			for(int i=0; i<iSz; i++)
			{
				mTask = mlTasks.get(i);
				sChildTasks = mTask.get(RDMServicesConstants.NO_CHILD_TASKS);
				
				if("".equals(sChildTasks) || "0".equals(sChildTasks))
				{
					mlChildTasks.add(mTask);
				}
				else
				{
					mlParentTasks.add(mTask);
				}
			}

			mlTasks = new MapList();
			mlTasks.addAll(mlChildTasks);
			mlTasks.addAll(mlParentTasks);

			for(int i=0; i<iSz; i++)
			{
				mTask = mlTasks.get(i);
				
				sTaskId = mTask.get(RDMServicesConstants.TASK_AUTONAME);
				sTaskAdmId = mTask.get(RDMServicesConstants.TASK_ID);
				sRoom = mTask.get(RDMServicesConstants.ROOM_ID);
				sStatus = mTask.get(RDMServicesConstants.STATUS);
				sTaskAdmName = mTask.get(RDMServicesConstants.TASK_NAME);
				sParent = mTask.get(RDMServicesConstants.PARENT_TASK);
				sChildTasks = mTask.get(RDMServicesConstants.NO_CHILD_TASKS);
				
				if(!("".equals(sChildTasks) || "0".equals(sChildTasks)) && bFg)
				{
					bFg = false;
%>
					<tr><th   colspan="13">&nbsp;</th></tr>
<%
				}
%>
				<tr>
					<td class="input">
						<input type="checkbox" id="<%= sTaskId %>" name="<%= sTaskId %>" value="N" onClick="javascript:check(this)">
						<input type="hidden" id="<%= sTaskId %>_Status" name="<%= sTaskId %>_Status" value="<%= sStatus %>">
					</td>
					<td class="input"><a href="javascript:showTaskDetails('<%= sTaskId %>')"><%= sTaskId %></a></td>
					<td class="input"><%= mTask.get(RDMServicesConstants.TASK_ID) %>&nbsp;<%= "".equals(sTaskAdmName) ? "" : "(" + mTask.get(RDMServicesConstants.TASK_NAME) + ")" %></td>
					<td class="input"><%= sRoom %></td>
					<td class="input"><%= sStatus %></td>
					<td class="input"><%= mUserNames.get(mTask.get(RDMServicesConstants.OWNER)) %>&nbsp;(<%= mTask.get(RDMServicesConstants.OWNER) %>)</td>
					<td class="input">
<%
					if(!"".equals(sParent))
					{
%>
						<a href="javascript:showTaskDetails('<%= sParent %>')"><%= sParent %><a>
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
						<a href="javascript:showTaskDeliverables('<%= sTaskId %>')"><%= mTask.get(RDMServicesConstants.DELIVERABLE_CNT) %></a>
<%
					}
%>
					</td>
					<td class="input" style="font-size:14px;text-align:center"><a href="javascript:showTaskWBS('<%= sTaskId %>', '<%= sTaskAdmId %>')"><%= sChildTasks %>(<%= mTask.get(RDMServicesConstants.NO_CHILD_TASKS_CLOSED) %>)</a></td>
				</tr>
<%
			}
%>
		</table>
	</form>
</body>
</html>
