<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>
<%@page import="com.client.views.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<html>
<%
	String sErr = "";
	String sRet = "";
	String sAction = request.getParameter("mode");
	
	UserTasks userTasks = new UserTasks();
	StringList slTasksAdded = new StringList();
	try
	{
		String sTaskAutoName =  request.getParameter("taskAutoName");
		String sTaskId = request.getParameter("taskId");
		String sName = request.getParameter("name");
		String sRoom = request.getParameter("room");
		String sOwner = request.getParameter("owner");
		sOwner = ((sOwner == null || "".equals(sOwner)) ? u.getUser() : sOwner);
		String sStatus = request.getParameter("status");
		String sNotes = request.getParameter("notes");
		sNotes = ((sNotes == null || "null".equals(sNotes)) ? "" : sNotes);
		
		String sCoOwners = (sOwner.equals(u.getUser()) ? "" : u.getUser());
		String[] saCoOwners = request.getParameterValues("CoOwners");
		if(saCoOwners != null)
		{
			for(int i=0; i<saCoOwners.length; i++)
			{
				if(!"".equals(sCoOwners))
				{
					sCoOwners += "|";
				}
				sCoOwners += saCoOwners[i];
			}
		}

		String sParentTask = request.getParameter("parentTask");
		sParentTask = (sParentTask == null ? "" : sParentTask);

		String sEstStart = request.getParameter("start_date");
		String sEstEnd = request.getParameter("end_date");
		if(sEstStart != null && sEstEnd != null)
		{
			sEstStart = sEstStart + " " + request.getParameter("start_hr") + ":" + request.getParameter("start_min") + ":00";
			sEstEnd = sEstEnd + " " + request.getParameter("end_hr") + ":" + request.getParameter("end_min") + ":00";
		}
		else
		{
			sEstStart = "";
			sEstEnd = "";
		}

		Map<String, String> mTask = new HashMap<String, String>();
		if("add".equals(sAction))
		{
			String[] saAssignees = request.getParameterValues("assignee");
			if(saAssignees == null || saAssignees.length == 0)
			{
				saAssignees = new String[]{u.getUser()};
			}

			mTask.put(RDMServicesConstants.TASK_ID, sTaskId);
			mTask.put(RDMServicesConstants.TASK_NAME, sName);
			mTask.put(RDMServicesConstants.ROOM_ID, sRoom);
			mTask.put(RDMServicesConstants.ESTIMATED_START, sEstStart);
			mTask.put(RDMServicesConstants.ESTIMATED_END, sEstEnd);
			mTask.put(RDMServicesConstants.PARENT_TASK, sParentTask);
			mTask.put(RDMServicesConstants.STATUS, sStatus);
			mTask.put(RDMServicesConstants.OWNER, sOwner);
			mTask.put(RDMServicesConstants.CO_OWNERS, sCoOwners);
			mTask.put(RDMServicesConstants.CREATED_BY, u.getUser());
			
			slTasksAdded = userTasks.createUserTask(mTask, saAssignees);
		}
		else if("edit".equals(sAction))
		{
			String sAssignee = request.getParameter("assignee");

			mTask.put(RDMServicesConstants.TASK_AUTONAME, sTaskAutoName);
			mTask.put(RDMServicesConstants.ROOM_ID, sRoom);
			mTask.put(RDMServicesConstants.ASSIGNEE, sAssignee);
			mTask.put(RDMServicesConstants.ESTIMATED_START, sEstStart);
			mTask.put(RDMServicesConstants.ESTIMATED_END, sEstEnd);
			mTask.put(RDMServicesConstants.STATUS, sStatus);
			mTask.put(RDMServicesConstants.NOTES, sNotes);
			mTask.put(RDMServicesConstants.CO_OWNERS, sCoOwners);
			mTask.put("CURRENT_STATUS", request.getParameter("currentStatus"));
			mTask.put("CURRENT_ROOM", request.getParameter("currentRoom"));
			mTask.put("CURRENT_ASSIGNEE", request.getParameter("currentAssignee"));
			mTask.put(RDMServicesConstants.ATTACHMENTS, request.getParameter("attachment"));
			mTask.put("REPLACE", request.getParameter("replace"));
			
			if(!userTasks.updateUserTask(u.getUser(), mTask))
			{
				if(RDMServicesConstants.TASK_STATUS_COMPLETED.equals(sStatus))
				{
					sRet = resourceBundle.getProperty("DataManager.DisplayText.Complete_Task_Error");
				}
				else if(RDMServicesConstants.TASK_STATUS_CANCELLED.equals(sStatus))
				{
					sRet = resourceBundle.getProperty("DataManager.DisplayText.Cancel_Task_Error");
				}
			}
		}
		else if("start".equals(sAction))
		{
			StringList slTasks = new StringList();
			Enumeration enumeration = request.getParameterNames();
			while (enumeration.hasMoreElements())
			{
				sName = (String) enumeration.nextElement();
				if("mode".equals(sName) || "chk_all".equals(sName) || sName.endsWith("_Status"))
				{
					continue;
				}
				sStatus = request.getParameter(sName + "_Status");
				
				if(RDMServicesConstants.TASK_STATUS_NOT_STARTED.equals(sStatus))
				{
					slTasks.add(sName);
				}
			}
			
			if(slTasks.size() > 0)
			{
				userTasks.startUserTasks(u.getUser(), slTasks);
			}
		}
		else if("complete".equals(sAction))
		{
			StringList slTasks = new StringList();
			Enumeration enumeration = request.getParameterNames();
			while (enumeration.hasMoreElements())
			{
				sName = (String) enumeration.nextElement();
				if("mode".equals(sName) || "chk_all".equals(sName) || sName.endsWith("_Status"))
				{
					continue;
				}
				sStatus = request.getParameter(sName + "_Status");
				
				if(sStatus.startsWith(RDMServicesConstants.TASK_STATUS_WIP) 
					|| RDMServicesConstants.TASK_STATUS_STARTED.equals(sStatus))
				{
					slTasks.add(sName);
				}
			}
			
			if(slTasks.size() > 0)
			{
				sRet = userTasks.completeUserTasks(u.getUser(), slTasks);
			}
		}
		else if("delete".equals(sAction))
		{
			StringList slTasks = new StringList();
			Enumeration enumeration = request.getParameterNames();
			while (enumeration.hasMoreElements())
			{
				sName = (String) enumeration.nextElement();
				if("mode".equals(sName) || "chk_all".equals(sName) || sName.endsWith("_Status"))
				{
					continue;
				}				
				slTasks.add(sName);
			}
			if(slTasks.size() > 0)
			{
				userTasks.deleteUserTasks(slTasks);
			}
		}
		else if("copy".equals(sAction) || "moveToNew".equals(sAction))
		{
			String sTasks = request.getParameter("tasks");
			String[] saTasks = sTasks.split("\\|");

			String sAssignee = "";
			if("moveToNew".equals(sAction))
			{
				sAssignee = request.getParameter("assignee");
				sAssignee = ("".equals(sAssignee) ? u.getUser() : sAssignee);
			}
			
			mTask.put(RDMServicesConstants.ROOM_ID, sRoom);
			mTask.put(RDMServicesConstants.ESTIMATED_START, sEstStart);
			mTask.put(RDMServicesConstants.ESTIMATED_END, sEstEnd);
			mTask.put(RDMServicesConstants.OWNER, sOwner);
			mTask.put(RDMServicesConstants.CO_OWNERS, sCoOwners);
			mTask.put(RDMServicesConstants.CREATED_BY, u.getUser());
			mTask.put(RDMServicesConstants.ASSIGNEE, sAssignee);
			slTasksAdded = userTasks.copyUserTasks(mTask, saTasks);
		}
		else if("download".equals(sAction))
		{
			StringList slTasks = new StringList();
			Enumeration enumeration = request.getParameterNames();
			while (enumeration.hasMoreElements())
			{
				sName = (String) enumeration.nextElement();
				if("mode".equals(sName) || "chk_all".equals(sName) || sName.endsWith("_Status"))
				{
					continue;
				}
				
				slTasks.add(sName);
			}
			
			if(slTasks.size() > 0)
			{
				userTasks.downloadTaskDeliverables(u.getUser(), slTasks);
			}
		}
		
		if("moveToNew".equals(sAction) || "moveToExisting".equals(sAction))
		{
			StringList slDeliverableIds = (StringList)session.getAttribute("DeliverableIds");
			session.removeAttribute("DeliverableIds");

			if("moveToExisting".equals(sAction))
			{
				slTasksAdded.add(sTaskId);
			}
			
			String sSrcTaskId = request.getParameter("srcTaskId");
			userTasks.moveTaskDeliverables(u.getUser(), slTasksAdded.get(0), sSrcTaskId, slDeliverableIds);
		}
		
		if("add".equals(sAction) || "copy".equals(sAction) || "moveToNew".equals(sAction) || "moveToExisting".equals(sAction))
		{
%>
			<head>
				<link type="text/css" href="../styles/dygraph.css" rel="stylesheet" />				
			</head>
			<body>
				<table width="100%">
					<tr>
						<th class="label"><%= sAction.contains("move") ? resourceBundle.getProperty("DataManager.DisplayText.Deliverables_Moved") :  resourceBundle.getProperty("DataManager.DisplayText.User_Task_Created") %></th>
					</tr>
<%
					for(int i=0; i<slTasksAdded.size(); i++)
					{
%>
						<tr>
							<td class="input"><%= slTasksAdded.get(i) %></td>
						</tr>
<%
					}
%>
					<tr>
						<td align="right"><input type="button" name="close" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Close") %>" onClick="javascript:top.window.close()"></td>
					</tr>
				</table>
			</body>
<%
		}
	}
	catch(Exception e)
	{
		e.printStackTrace(System.out);
		sErr = e.getMessage();
		sErr = (sErr == null ? "null" : sErr.replaceAll("\"", "'").replaceAll("\r", " ").replaceAll("\n", " "));
	}
%>
	<script>
		var sErr = "<%= sErr %>";
		var sRet = "<%= sRet %>";
		var mode = "<%= sAction %>";
		if(sErr != "")
		{
			alert("Error: "+sErr);
			history.back(-1);
		}
		else
		{
			if(sRet != "")
			{
				if(mode == "complete")
				{
					alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Complete_Tasks_Failed") %>" + sRet.replace("<br>", "\n"));
				}
				else
				{
					alert(sRet);
					history.back(-1);
				}
			}
			else
			{
				if(mode == "edit")
				{
					try
					{
						top.opener.parent.searchTasks();
					}
					catch(e)
					{
						top.opener.document.location.href = top.opener.document.location.href;
					}
					
					top.window.close();
				}
				else if(mode == "start" || mode == "complete" || mode == "delete" || mode == "download")
				{
					
					try
					{
						top.opener.parent.frames.searchTasks();
					}
					catch(e)
					{
						top.document.location.href = top.document.location.href;
					}
					
					window.close();
				}
				else if(mode == "moveToNew" || mode == "moveToExisting")
				{
					top.opener.document.location.href = top.opener.document.location.href;
				}
			}
		}
		
	</script>

</html>