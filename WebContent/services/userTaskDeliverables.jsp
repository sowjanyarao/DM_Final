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

UserTasks userTasks = new UserTasks();
Map<String, String> mTaskInfo = userTasks.userTaskDetails(sTaskId);
String sRoom = mTaskInfo.get(RDMServicesConstants.ROOM_ID);
sRoom = ("".equals(sRoom) ? RDMServicesConstants.NO_ROOM : sRoom);
String sTaskAdmId = mTaskInfo.get(RDMServicesConstants.TASK_ID);
String sTaskAdmName = mTaskInfo.get(RDMServicesConstants.TASK_NAME);
String sOwner = mTaskInfo.get(RDMServicesConstants.OWNER);
String sAssignee = mTaskInfo.get(RDMServicesConstants.ASSIGNEE);
String sStatus = mTaskInfo.get(RDMServicesConstants.STATUS);

String sDeliverableId = null;
Map<String, String> mDeliverable = null;
MapList mlDeliverables = userTasks.getTaskDeliverables(sTaskId);
int iCnt = mlDeliverables.size();

StringList slTaskAttrs = new StringList();
Map<String, String> mAdminTaskInfo = RDMServicesUtils.getAdminTask(sTaskAdmId);
if(mAdminTaskInfo != null)
{
	String sTaskAttrs = mAdminTaskInfo.get(RDMServicesConstants.TASK_ATTRIBUTES);
	String[] saTaskAttrs = sTaskAttrs.split("\\|");	

	for(int i=0; i<saTaskAttrs.length; i++)
	{
		if(saTaskAttrs[i] != null && !"".equals(saTaskAttrs[i]))
		{
			slTaskAttrs.add(saTaskAttrs[i]);
		}
	}
	slTaskAttrs.sort();
}
else
{
	if(iCnt > 0)
	{
		String sAttrName = null;
		Iterator<String> itr = null;
		for(int i=0; i<mlDeliverables.size(); i++)
		{
			mDeliverable = mlDeliverables.get(i);
			itr = mDeliverable.keySet().iterator();
			while(itr.hasNext())
			{
				sAttrName = itr.next();
				if(slTaskAttrs.contains(sAttrName) || RDMServicesConstants.DELIVERABLE_ID.equals(sAttrName) 
					|| RDMServicesConstants.CREATED_ON.equals(sAttrName) || RDMServicesConstants.DOWNLOAD_FLAG.equals(sAttrName)
						|| RDMServicesConstants.DOWNLOAD_BY.equals(sAttrName) || RDMServicesConstants.DOWNLOAD_ON.equals(sAttrName))
				{
					continue;
				}
				slTaskAttrs.add(sAttrName);
			}
		}
	}
}

Map<String, String> mInfo = null;
Map<String, String> mAdminAttrs = new HashMap<String, String>();
MapList mlAdminAttrs = RDMServicesUtils.getAdminAttributes();
for(int i=0; i<mlAdminAttrs.size(); i++)
{
	mInfo = mlAdminAttrs.get(i);
	mAdminAttrs.put(mInfo.get(RDMServicesConstants.ATTRIBUTE_NAME), mInfo.get(RDMServicesConstants.ATTRIBUTE_UNIT));
}

boolean bCanAddEdit = (RDMServicesConstants.ROLE_SUPERVISOR.equals(u.getRole()) && 
						!(RDMServicesConstants.TASK_STATUS_COMPLETED.equals(sStatus) || 
							RDMServicesConstants.TASK_STATUS_CANCELLED.equals(sStatus)));

boolean bCanDelete = RDMServicesConstants.ROLE_ADMIN.equals(u.getRole());

Map<String, String> mUserNames = RDMServicesUtils.getUserNames();

String sAdminTaskId = null;
String sTaskName = null;
String sKey = null;
Map<String, String> mTask = null;
Map<String, MapList> mUserTasks = new HashMap<String, MapList>();
MapList mlValues = null;

StringList slUserDept = new StringList();
slUserDept.add(u.getDepartment());
slUserDept.addAll(u.getSecondaryDepartments());

MapList mlTasks = userTasks.searchUserTasks(sRoom, "", slUserDept, u.getUser(), "", "", "", RDMServicesConstants.TASK_STATUS_WIP, "", "", true, false, true, -1);
for(int i=0; i<mlTasks.size(); i++)
{
	mTask = mlTasks.get(i);
	sAdminTaskId = mTask.get(RDMServicesConstants.TASK_ID);
	sTaskName = mTask.get(RDMServicesConstants.TASK_NAME);
	
	sKey = sAdminTaskId + ("".equals(sTaskName) ? "" : "("+sTaskName+")");
	mlValues = mUserTasks.get(sKey);
	if(mlValues == null)
	{
		mlValues = new MapList();
	}
	mlValues.add(mTask);
	mUserTasks.put(sKey, mlValues);
}

List<String> lKeys = new ArrayList<String>(mUserTasks.keySet());
Collections.sort(lKeys, String.CASE_INSENSITIVE_ORDER);
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title></title>
	<link type="text/css" href="../styles/dygraph.css" rel="stylesheet" />
	<script language="javascript">
	function manageDeliverable(sDeliverableId)
	{
		window.open('manageTaskDeliverableView.jsp?taskId=<%= sTaskId %>&taskAdmId=<%= sTaskAdmId %>&deliverableId='+sDeliverableId+'&room=<%= sRoom %>', '', 'left=100,top=150,resizable=yes,scrollbars=yes,status=no,toolbar=no,height=400,width=500');
	}
	
	function deleteDeliverable(sDeliverableId)
	{
		var conf = confirm("<%= resourceBundle.getProperty("DataManager.DisplayText.Delete_Deliverable") %>");
		if(conf == true)
		{
			parent.frames['hiddenFrame'].document.location.href = "manageTaskDeliverableProcess.jsp?taskId=<%= sTaskId %>&deliverableId="+sDeliverableId+"&mode=delete";
		}		
	}
	
	function showTaskDeliverables()
	{
		var sTaskId = document.getElementById("taskId").value;
		parent.document.location.href = 'userTaskDeliverablesView.jsp?taskId='+sTaskId;			
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
				if(e.name == 'chk_all')
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
	
	function moveDeliverables()
	{
		var checked = false;
		var inputs = document.getElementsByTagName("input");
		for(var i=0; i<inputs.length; i++)
		{
			var e = inputs[i];
			if(e.type == "checkbox" && e.checked)
			{
				checked = true;
			}
		}
		
		if(checked)
		{
			var w = window.open('', 'Popup_Window', 'toolbar=0,scrollbars=0,location=0,statusbar=0,menubar=0,resizable=0,width=400,height=450,left=300,top=200');

			document.frm.target = 'Popup_Window';
			document.frm.submit();
		}
		else
		{
			alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Choose_Deliverables") %>");
		}
	}
	</script>
</head>

<body>
	<table border="0" cellpadding="2" align="center" cellspacing="2" width="90%">
		<tr>
<%
		int iSz = slTaskAttrs.size();
		if(mlTasks.size() > 0)
		{
%>
			<th style="font-size:16px;text-align:left" colspan="10">
				<select id="taskId" name="taskId" onChange="javascript:showTaskDeliverables()">
<%
				String sTaskAutoId = null;
				String sTaskAssignee = null;
				for(int i=0; i<lKeys.size(); i++)
				{
					sKey = lKeys.get(i);
					mlValues = mUserTasks.get(sKey);
%>
					<optgroup label="<%= sKey %>">
<%
					for(int j=0; j<mlValues.size(); j++)
					{
						mTask = mlValues.get(j);					
						sTaskAutoId = mTask.get(RDMServicesConstants.TASK_AUTONAME);
						sTaskAssignee = mTask.get(RDMServicesConstants.ASSIGNEE);
%>
						<option value="<%= sTaskAutoId %>" <%= sTaskAutoId.equals(sTaskId) ? "selected" : "" %>><%= mUserNames.get(sTaskAssignee) %>&nbsp;(<%= sTaskAssignee %>)</option>
<%
					}
				}
%>
				</select>
			</th>
<%
		}
%>
		</tr>
		<tr>
			<td colspan="9" align="left">
<%
			if(bCanAddEdit && (iSz > 0))
			{
%>
				<input type="button" name="add" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Create_Deliverable") %>" onClick="manageDeliverable('')">&nbsp;
<%
			}
			
			if(!RDMServicesConstants.TASK_STATUS_CANCELLED.equals(sStatus) && (iCnt > 0))
			{
%>
				<input type="button" name="move" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Move_Deliverable") %>" onClick="moveDeliverables()">&nbsp;
<%
			}
%>
			</td>
			<td align="right">	
				<input type="button" name="Close" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Close") %>" onClick="javascript:top.window.close()">
			</td>
		</tr>
		<tr>
			<th class="label" width="10%"><%= resourceBundle.getProperty("DataManager.DisplayText.Task_Name") %></th>
			<td class="input" width="15%"><%= sTaskId %></td>

			<th class="label" width="10%"><%= resourceBundle.getProperty("DataManager.DisplayText.Task_Id") %></th>
			<td class="input" width="15%"><%= sTaskAdmId %>&nbsp;<%= "".equals(sTaskAdmName) ? "" : "("+sTaskAdmName+")" %></td>

			<th class="label" width="10%"><%= resourceBundle.getProperty("DataManager.DisplayText.Room_No") %></th>
			<td class="input" width="15%"><%= sRoom %></td>
			
			<th class="label" width="10%"><%= resourceBundle.getProperty("DataManager.DisplayText.Owner") %></th>
			<td class="input" width="15%"><%= mUserNames.get(sOwner) %>&nbsp;(<%= sOwner %>)</td>

			<th class="label" width="10%"><%= resourceBundle.getProperty("DataManager.DisplayText.Assignee") %></th>
			<td class="input" width="15%"><%= ("".equals(sAssignee) ? "" : mUserNames.get(sAssignee) + "&nbsp;(" + sAssignee +")") %></td>
		<tr>
	</table>
	
	<form name="frm" action="moveTaskDeliverables.jsp" method="post">
	<input type="hidden" id="UserTaskId" name="UserTaskId" value="<%= sTaskId %>">
	<table border="0" cellpadding="0" align="center" cellspacing="0" width="90%">
		<tr>
			<th class="label" width="5%"><input type="checkbox" id="chk_all" name="chk_all" onClick="javascript:checkAll()"></th>
			<th class="label" width="10%"><%= resourceBundle.getProperty("DataManager.DisplayText.Deliverable_Id") %></th>
			<th class="label" width="10%"><%= resourceBundle.getProperty("DataManager.DisplayText.Created_On") %></th>
			<th class="label" width="10%"><%= resourceBundle.getProperty("DataManager.DisplayText.Download") %></th>
			<th class="label" width="10%"><%= resourceBundle.getProperty("DataManager.DisplayText.Download_By") %></th>
			<th class="label" width="10%"><%= resourceBundle.getProperty("DataManager.DisplayText.Download_On") %></th>
<%
		String sAttrName = null;
		String sAttrValue = null;
		String sAttrUnit = null;
		String sDownloadBy = null;
		for(int i=0; i<iSz; i++)
		{
			sAttrName = slTaskAttrs.get(i);
			sAttrUnit = mAdminAttrs.get(sAttrName);
%>
			<th class="label" width="10%"><%= sAttrName %>
<%
			if(!"".equals(sAttrUnit))
			{
%>
				&nbsp;(<%= sAttrUnit %>)
<%
			}
%>
			</th>		
<%
		}
		
		if(bCanAddEdit || bCanDelete)
		{
%>
			<th class="label" width="5%"><%= resourceBundle.getProperty("DataManager.DisplayText.Actions") %></th>
<%
		}
%>
		</tr>
<%
		if(iCnt > 0)
		{
			for(int i=0; i<iCnt; i++)
			{
				mDeliverable = mlDeliverables.get(i);
				sDeliverableId = mDeliverable.get(RDMServicesConstants.DELIVERABLE_ID);
				sDownloadBy = mDeliverable.get(RDMServicesConstants.DOWNLOAD_BY);
%>
				<tr>
					<td class="input" width="5%" style="text-align:center">
						<input type="checkbox" id="<%= sDeliverableId %>" name="<%= sDeliverableId %>" value="N" onClick="javascript:check(this)">
					</td>
					<td class="input" width="10%"><%= sDeliverableId %></td>
					<td class="input" width="10%"><%= mDeliverable.get(RDMServicesConstants.CREATED_ON) %></td>
					<td class="input" width="10%"><%= mDeliverable.get(RDMServicesConstants.DOWNLOAD_FLAG) %></td>
					<td class="input" width="10%"><%= ((sDownloadBy == null || "".equals(sDownloadBy)) ? "" : mUserNames.get(sDownloadBy) + "&nbsp;(" + sDownloadBy +")") %></td>
					<td class="input" width="10%"><%=  mDeliverable.get(RDMServicesConstants.DOWNLOAD_ON) %></td>
<%
					for(int j=0; j<iSz; j++)
					{
						sAttrName = slTaskAttrs.get(j);
						sAttrValue = mDeliverable.get(sAttrName);
						sAttrValue = ((sAttrValue == null || "".equals(sAttrValue)) ? "0" : sAttrValue);
%>
						<td class="input" width="10%"><%= sAttrValue %></td>
<%
					}

					if(bCanAddEdit)
					{
%>
						<td class="input" width="5%" style="text-align:center">
							<a href="javascript:manageDeliverable('<%= sDeliverableId %>')"><img border="0" src="../images/edit.jpg" height="20" alt="<%= resourceBundle.getProperty("DataManager.DisplayText.Edit") %>"></a>
						</td>
<%
					}
					else if(bCanDelete)
					{
%>
						<td class="input" style="text-align:center">
							<a href="javascript:deleteDeliverable('<%= sDeliverableId %>')"><img border="0" src="../images/delete.png" alt="<%= resourceBundle.getProperty("DataManager.DisplayText.Delete") %>"></a>
						</td>
<%
					}
%>
				</tr>
<%
			}
		}
		else
		{
%>
			<tr>
				<td class="input" style="text-align:center" colspan="<%= ((bCanAddEdit || bCanDelete) ? (iSz + 7) : (iSz + 6)) %>">
					<%= resourceBundle.getProperty("DataManager.DisplayText.No_Task_Deliverables") %>
				</td>
			</tr>
<%
		}
%>
	</table>
	</form>
</body>
</html>
