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
Map<String, String> mTask = userTasks.userTaskDetails(sTaskId);

String sRoom = mTask.get(RDMServicesConstants.ROOM_ID);
String sStatus = mTask.get(RDMServicesConstants.STATUS);
String sTaskAdmId = mTask.get(RDMServicesConstants.TASK_ID);
String sTaskAdmName = mTask.get(RDMServicesConstants.TASK_NAME);
String sAssignee = mTask.get(RDMServicesConstants.ASSIGNEE);

String[] HOUR = new String[] {"00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", 
								"12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"};
String[] MIN = new String[] {"00", "05", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"};

Map<String, String> mUserNames = RDMServicesUtils.getUserNames();

boolean bCanAddEdit = (RDMServicesConstants.ROLE_SUPERVISOR.equals(u.getRole()) && 
	!(RDMServicesConstants.TASK_STATUS_COMPLETED.equals(sStatus) || 
		RDMServicesConstants.TASK_STATUS_CANCELLED.equals(sStatus)));

SimpleDateFormat sdfIn = new SimpleDateFormat("dd-MM-yyyy", Locale.ENGLISH);
Date currDt = new Date();
String sDate = sdfIn.format(currDt);

Map<String, String> mInfo = new HashMap<String, String>();
mInfo.put(RDMServicesConstants.USER_ID, sAssignee);
mInfo.put(RDMServicesConstants.FIRST_NAME, "");
mInfo.put(RDMServicesConstants.LAST_NAME, "");
mInfo.put(RDMServicesConstants.DEPT_NAME, "");
mInfo.put("fromDate", sDate);
mInfo.put("endDate", sDate);
mInfo.put("loggedIn", "Y");
mInfo.put("loggedOut", "");
Map<String, Map<String, MapList>> mUserLogs = RDMServicesUtils.getTimesheets(mInfo);
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
	<title></title>
	<link type="text/css" href="../styles/dygraph.css" rel="stylesheet" />
	<link type="text/css" href="../styles/calendar.css" rel="stylesheet" />
	<link type="text/css" href="../styles/bootstrap.min.css" rel="stylesheet" />
	<link type="text/css" href="../styles/select2.min.css" rel="stylesheet" />
	
	<script language="javaScript" type="text/javascript" src="../scripts/calendar.js"></script>
	<script language="javaScript" type="text/javascript" src="../scripts/jquery.min.js"></script>
	<script language="javaScript" type="text/javascript" src="../scripts/select2.full.js"></script>
	<script language="javaScript" type="text/javascript" src="../scripts/bootstrap.min.js"></script>
	
	<style type="text/css">	
	
		td.txtLabel
		{
			/* border: solid 1px #ffffff; */
			text-align: left;
			/* background-color: #888888; */
			color: #3e3e3e;
			font-size:12px;
			font-family:Arial,sans-serif;
			font-weight: bold;
			line-height: 2em;
		}
		td.input{color:#3e3e3e !important;}
		tr{border-bottom:1px solid #ec3237;}
	</style>

	<script type="text/javascript">
		//<![CDATA[
		$(document).ready(function(){
			$(".js-example-basic-multiple").select2();
		});
		//]]>
	</script>
	
	<script language="javascript">
		function viewAttachments(taskname, imageName)
		{
			var url = "../ViewAttachments?folder="+taskname+"&imageName="+imageName;
			parent.frames['hidden'].document.location.href =  url;
		}
		
		function addChildTask()
		{
			window.open('addUserTaskView.jsp?parentTask=<%= sTaskId %>', '', 'left=250,top=150,resizable=no,scrollbars=no,status=no,toolbar=no,height=550,width=400');			
		}
		
		function submitForm()
		{
			var currentStatus = document.getElementById("currentStatus").value;
			var status = document.getElementById("status").value;

			if(currentStatus == "<%= RDMServicesConstants.TASK_STATUS_NOT_STARTED %>" && status != "<%= RDMServicesConstants.TASK_STATUS_NOT_STARTED %>" && status != "<%= RDMServicesConstants.TASK_STATUS_CANCELLED %>")
			{
				var assignee = document.getElementById("assignee");
				if(assignee.value == "")
				{
					alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Select_Assignee") %>");
					assignee.focus();
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
		
		function showTaskWBS()
		{
			window.open('userTaskWBSView.jsp?taskName=<%= sTaskId %>&taskId=<%= sTaskAdmId %>', '', 'left=25,top=25,resizable=yes,scrollbars=yes,status=no,toolbar=no,height=800,width=1200');			
		}
		
		function setDateFields()
		{
			var fromDate = new Date("<%= mTask.get(RDMServicesConstants.ESTIMATED_START) %>");
			var toDate = new Date("<%= mTask.get(RDMServicesConstants.ESTIMATED_END) %>");

			var dd = fromDate.getDate();
			if(dd < 10)
			{
				dd = '0' + dd;
			}
			
			var mm = fromDate.getMonth() + 1;
			if(mm < 10)
			{
				mm = '0' + mm;
			}

			var yy = fromDate.getFullYear();

			var hr = fromDate.getHours();
			if(hr < 10)
			{
				hr = '0' + hr;
			}

			var min = fromDate.getMinutes();
			if(min < 10)
			{
				min = '0' + min;
			}
			
			document.getElementById('start_date').value = dd + "-" + mm + "-" + yy;
			document.getElementById('start_hr').value = hr;
			document.getElementById('start_min').value = min;

			dd = toDate.getDate();
			if(dd < 10)
			{
				dd = '0' + dd;
			}
			
			mm = toDate.getMonth() + 1;
			if(mm < 10)
			{
				mm = '0' + mm;
			}
			
			yy = toDate.getFullYear();

			hr = toDate.getHours();
			if(hr < 10)
			{
				hr = '0' + hr;
			}

			min = toDate.getMinutes();
			if(min < 10)
			{
				min = '0' + min;
			}

			document.getElementById('end_date').value = dd + "-" + mm + "-" + yy;
			document.getElementById('end_hr').value = hr;
			document.getElementById('end_min').value = min;
		}
	</script>
</head>
	
<body <%= (bCanAddEdit && RDMServicesConstants.TASK_STATUS_NOT_STARTED.equals(sStatus) ? "onLoad=\"javascript:setDateFields()\"" : "") %> style="background-color:#ffffff !important;">
	<form name="frm" method="post" action="processAttachments.jsp" enctype="multipart/form-data">
		<input type="hidden" id="mode" name="mode" value="edit">
		<input type="hidden" id="taskAutoName" name="taskAutoName" value="<%= sTaskId %>">
		<input type="hidden" id="currentStatus" name="currentStatus" value="<%= sStatus %>">
		<input type="hidden" id="currentRoom" name="currentRoom" value="<%= sRoom %>">
		<input type="hidden" id="currentAssignee" name="currentAssignee" value="<%= sAssignee %>">
		<input type="hidden" id="replace" name="replace" value="">
		<input type="hidden" id="folder" name="folder" value="<%= sTaskId %>">
		<input type="hidden" id="processPage" name="processPage" value="manageUserTaskProcess.jsp">
		<table border="0" align="center" cellpadding="2" cellspacing="0" width="90%">
			<tr>
				<td align="left">
<%
				if(bCanAddEdit)
				{
%>
					<input type="button" name="addTask" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Create_Task") %>" onClick="javascript:addChildTask()">
<%
				}
%>
					<input type="button" name="wbs" value="<%= resourceBundle.getProperty("DataManager.DisplayText.View_WBS") %>" onClick="javascript:showTaskWBS()">
				</td>
			</tr>
		</table>
		<table border="0" align="center" cellpadding="2" cellspacing="0" width="100%">
			<tr>
				<td class="txtLabel" style="text-align:left" width="30%"><%= resourceBundle.getProperty("DataManager.DisplayText.Task_Name") %></th>
				<td class="input" width="70%"><%= sTaskId %></td>
			</tr>
			<tr>
				<td class="txtLabel" style="text-align:left" width="30%"><%= resourceBundle.getProperty("DataManager.DisplayText.Task_Id") %></th>
				<td class="input" width="70%"><%= mTask.get(RDMServicesConstants.TASK_ID) %>&nbsp;<%= "".equals(sTaskAdmName) ? "" : "(" + mTask.get(RDMServicesConstants.TASK_NAME) + ")" %></td>
			</tr>
			<tr>
				<td class="txtLabel" style="text-align:left" width="30%"><%= resourceBundle.getProperty("DataManager.DisplayText.Room_No") %></th>
				<td class="input" width="70%">
<%
				if(bCanAddEdit && RDMServicesConstants.TASK_STATUS_NOT_STARTED.equals(sStatus))
				{
%>
					<select id="room" name="room">
                        <option value=""><%= resourceBundle.getProperty("DataManager.DisplayText.Please_choose_one") %></option>
<%
						MapList mlControllers = RDMServicesUtils.getRoomsList();
						String cntrlType = null;
						String controller = null;

						for(int i=0, iSz=mlControllers.size(); i<iSz; i++)
						{
							mInfo = mlControllers.get(i);
							controller = mInfo.get(RDMServicesConstants.ROOM_ID);
							cntrlType = mInfo.get(RDMServicesConstants.CNTRL_TYPE);
							if(!(RDMServicesConstants.TYPE_GENERAL_GROWER.equals(cntrlType) || 
								RDMServicesConstants.TYPE_GENERAL_BUNKER.equals(cntrlType) ||
									RDMServicesConstants.TYPE_GENERAL_TUNNEL.equals(cntrlType)))
							{
%>
								<option value="<%= controller %>" <%= controller.equals(sRoom) ? "selected" : "" %> ><%= controller %></option>
<%
							}
						}
%>
                    </select>
<%
				}
				else
				{
%>
					<%= sRoom %>
					<input type="hidden" id="room" name="room" value="<%= sRoom %>">
<%
				}
%>
				</td>		
			</tr>
			<tr>
				<td class="txtLabel" style="text-align:left" width="30%"><%= resourceBundle.getProperty("DataManager.DisplayText.Status") %></th>
				<td class="input" width="70%">
<%
				if(bCanAddEdit)
				{
%>
					<select id="status" name="status">
<%
						if(RDMServicesConstants.TASK_STATUS_NOT_STARTED.equals(sStatus))
						{
%>
							<option value="<%= RDMServicesConstants.TASK_STATUS_NOT_STARTED %>" selected><%= resourceBundle.getProperty("DataManager.DisplayText.Task_Status_Not_Started") %></option>
<%
						}
						
						if(mUserLogs.containsKey(sAssignee) || !RDMServicesConstants.TASK_STATUS_NOT_STARTED.equals(sStatus))
						{
%>
							<option value="<%= RDMServicesConstants.TASK_STATUS_STARTED %>" <%= RDMServicesConstants.TASK_STATUS_STARTED.equals(sStatus) ? "selected" : "" %>><%= resourceBundle.getProperty("DataManager.DisplayText.Task_Status_Started") %></option>
							<option value="<%= RDMServicesConstants.TASK_STATUS_WIP_25 %>" <%= RDMServicesConstants.TASK_STATUS_WIP_25.equals(sStatus) ? "selected" : "" %>><%= resourceBundle.getProperty("DataManager.DisplayText.Task_Status_WIP_25") %></option>
							<option value="<%= RDMServicesConstants.TASK_STATUS_WIP_50 %>" <%= RDMServicesConstants.TASK_STATUS_WIP_50.equals(sStatus) ? "selected" : "" %>><%= resourceBundle.getProperty("DataManager.DisplayText.Task_Status_WIP_50") %></option>
							<option value="<%= RDMServicesConstants.TASK_STATUS_WIP_75 %>" <%= RDMServicesConstants.TASK_STATUS_WIP_75.equals(sStatus) ? "selected" : "" %>><%= resourceBundle.getProperty("DataManager.DisplayText.Task_Status_WIP_75") %></option>
							<option value="<%= RDMServicesConstants.TASK_STATUS_COMPLETED %>"><%= resourceBundle.getProperty("DataManager.DisplayText.Task_Status_Completed") %></option>
<%
						}
%>
						<option value="<%= RDMServicesConstants.TASK_STATUS_CANCELLED %>"><%= resourceBundle.getProperty("DataManager.DisplayText.Task_Status_Cancelled") %></option>
					</select>
<%
				}
				else
				{
%>
					<%= sStatus %>
<%
				}
%>
				</td>
			</tr>
<%
			String sOwner = mTask.get(RDMServicesConstants.OWNER);
			
			StringList slCoOwners = new StringList();
			String sCoOwners = mTask.get(RDMServicesConstants.CO_OWNERS);
			if(sCoOwners != null && !"".equals(sCoOwners))
			{
				String[] saCoOwners = sCoOwners.split("\\|");
				for(int i=0; i<saCoOwners.length; i++)
				{
					slCoOwners.add(saCoOwners[i]);
				}
			}
			
			String sTaskDept = RDMServicesUtils.getAdminTask(sTaskAdmId).get(RDMServicesConstants.DEPARTMENT_NAME);
			StringList slTaskDepts = StringList.split(sTaskDept, "\\|");
%>	
			<tr>
				<td class="txtLabel" style="text-align:left" width="30%"><%= resourceBundle.getProperty("DataManager.DisplayText.Owner") %></th>
				<td class="input" width="70%">
					<%= mUserNames.get(sOwner) %>&nbsp;(<%= sOwner %>)
					<input type="hidden" id="owner" name="owner" value="<%= sOwner %>">
				</td>
			</tr>
			<tr>
				<td class="txtLabel"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Co_Owners") %></b></td>
				<td class="input" colspan="2">
<%
				String userId = null;
				String userName = null;
					
				if(bCanAddEdit)
				{
%>	
					<select id="CoOwners" name="CoOwners" style="width:250px" class="js-example-basic-multiple" multiple="multiple">
<%
						MapList mlOwners = RDMServicesUtils.getTaskOwners(slTaskDepts, false);
						for(int j=0, iSz=mlOwners.size(); j<iSz; j++)
						{
							mInfo = mlOwners.get(j);
							userId = mInfo.get(RDMServicesConstants.USER_ID);
							userName = mInfo.get(RDMServicesConstants.DISPLAY_NAME);
%>
							<option value="<%= userId %>" <%= slCoOwners.contains(userId) ? "selected" : "" %>><%= userName %>&nbsp;(<%= userId %>)</option>
<%
						}
%>
					</select>
<%
				}
				else
				{
					for(int i=0, iSz=slCoOwners.size(); i<iSz; i++)
					{
%>
						<%= (i > 0) ? "<br>" : "" %><%= mUserNames.get(slCoOwners.get(i)) %>&nbsp;(<%= slCoOwners.get(i) %>)
<%
					}
				}
%>
				</td>
			</tr>
			<tr>
				<td class="txtLabel" style="text-align:left" width="30%"><%= resourceBundle.getProperty("DataManager.DisplayText.Assignee") %></th>
				<td class="input" width="70%">
<%
				if(bCanAddEdit && RDMServicesConstants.TASK_STATUS_NOT_STARTED.equals(sStatus))
				{
%>
					<select id="assignee" name="assignee" style="width:250px" class="js-example-basic-multiple">
<%
						MapList mlAssignees = RDMServicesUtils.getAssigneeList(slTaskDepts, false);	
						for(int j=0, iSz=mlAssignees.size(); j<iSz; j++)
						{
							mInfo = mlAssignees.get(j);
							userId = mInfo.get(RDMServicesConstants.USER_ID);
							userName = mInfo.get(RDMServicesConstants.DISPLAY_NAME);
%>
							<option value="<%= userId %>" <%= sAssignee.equals(userId) ? "selected" : "" %>><%= userName %>&nbsp;(<%= userId %>)</option>
<%
						}
%>
					</select>
<%
				}
				else
				{
%>
					<%= mUserNames.get(sAssignee) %>&nbsp;(<%= sAssignee %>)
					<input type="hidden" id="assignee" name="assignee" value="<%= sAssignee %>">
<%
				}
%>
				</td>
			</tr>
			<tr>
				<td class="txtLabel" id="a" style="text-align:left" width="30%"><%= resourceBundle.getProperty("DataManager.DisplayText.Estimated_Start") %></th>
				<td class="input" width="70%">
<%
				if(bCanAddEdit && RDMServicesConstants.TASK_STATUS_NOT_STARTED.equals(sStatus))
				{
%>
					<input type="text" size="10" id="start_date" name="start_date" readonly>
					<a href="#" onClick="setYears(2000, 2025);showCalender('a', 'start_date');"><img src="../images/calender.png"></a>
					<a href="#" onClick="javascript:document.getElementById('start_date').value=''"><img src="../images/clear.png"></a>
					&nbsp;HH&nbsp;
					<select id="start_hr" name="start_hr">
<%					
					for(int i=0; i<HOUR.length; i++)
					{
%>
						<option value="<%= HOUR[i] %>"><%= HOUR[i] %></option>
<%
					}
%>
					</select>
					&nbsp;MM&nbsp;
					<select id="start_min" name="start_min">
<%					
					for(int i=0; i<MIN.length; i++)
					{
%>
						<option value="<%= MIN[i] %>"><%= MIN[i] %></option>
<%
					}
%>
					</select>
<%
				}
				else
				{
%>
					<%= mTask.get(RDMServicesConstants.ESTIMATED_START) %>
<%
				}
%>
				</td>
			</tr>
			<tr>
				<td class="txtLabel" id="b" style="text-align:left" width="30%"><%= resourceBundle.getProperty("DataManager.DisplayText.Estimated_End") %></th>
				<td class="input" width="70%">
<%
				if(bCanAddEdit && RDMServicesConstants.TASK_STATUS_NOT_STARTED.equals(sStatus))
				{
%>
					<input type="text" size="10" id="end_date" name="end_date" readonly>
					<a href="#" onClick="setYears(2000, 2025);showCalender('b', 'end_date');"><img src="../images/calender.png"></a>
					<a href="#" onClick="javascript:document.getElementById('end_date').value=''"><img src="../images/clear.png"></a>
					&nbsp;HH&nbsp;
					<select id="end_hr" name="end_hr">
<%					
					for(int i=0; i<HOUR.length; i++)
					{
%>
						<option value="<%= HOUR[i] %>"><%= HOUR[i] %></option>
<%
					}
%>
					</select>
					&nbsp;MM&nbsp;
					<select id="end_min" name="end_min">
<%					
					for(int i=0; i<MIN.length; i++)
					{
%>
						<option value="<%= MIN[i] %>"><%= MIN[i] %></option>
<%
					}
%>
					</select>
<%
				}
				else
				{
%>
					<%= mTask.get(RDMServicesConstants.ESTIMATED_END) %>
<%
				}
%>
				</td>
			</tr>
			<tr>
				<td class="txtLabel" style="text-align:left" width="30%"><%= resourceBundle.getProperty("DataManager.DisplayText.Actual_Start") %></th>
				<td class="input" width="70%"><%= mTask.get(RDMServicesConstants.ACTUAL_START) %></td>
			</tr>
			<tr>
				<td class="txtLabel" style="text-align:left" width="30%"><%= resourceBundle.getProperty("DataManager.DisplayText.Actual_End") %></th>
				<td class="input" width="70%"><%= mTask.get(RDMServicesConstants.ACTUAL_END) %></td>
			</tr>
			<tr>
				<td class="txtLabel" style="text-align:left" width="30%"><%= resourceBundle.getProperty("DataManager.DisplayText.Parent_Task") %></th>
				<td class="input" width="70%"><%= mTask.get(RDMServicesConstants.PARENT_TASK) %></td>
			</tr>
			<tr>
				<td class="txtLabel" style="text-align:left" width="30%"><%= resourceBundle.getProperty("DataManager.DisplayText.Notes") %></th>
				<td class="input" valign="top" height="80" width="70%">
<%
				String sNotes = mTask.get(RDMServicesConstants.NOTES);
				sNotes = ((sNotes == null || "null".equals(sNotes)) ? "" : sNotes);
				if(bCanAddEdit)
				{
%>
					<textarea id="notes" name="notes" rows="4" cols="40"><%= sNotes %></textarea>
<%
				}
				else
				{
%>
					<%= sNotes.trim().replaceAll("\n", "<br>") %>
<%
				}
%>
				</td>
			</tr>
			<tr>
<%
				String sSysLog = mTask.get(RDMServicesConstants.SYSTEM_LOG);
				sSysLog = ((sSysLog == null || "null".equals(sSysLog)) ? "" : sSysLog.trim().replaceAll("\n", "<br>"));
%>
				<td class="txtLabel" style="text-align:left" width="30%"><%= resourceBundle.getProperty("DataManager.DisplayText.System_Log") %></th>
				<td class="input" valign="top" height="80" width="70%">
					<%= sSysLog %>
				</td>
			</tr>
			<tr>
				<td class="txtLabel"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Attachments") %></b></td>
				<td class="input">
<%
				if(bCanAddEdit)
				{
%>
					<input type="file" id="attachment" name="attachment">
					<input type="radio" id="fileaction" name="fileaction" value="yes" checked><%= resourceBundle.getProperty("DataManager.DisplayText.Replace") %>
					<input type="radio" id="fileaction" name="fileaction" value="no"><%= resourceBundle.getProperty("DataManager.DisplayText.Append") %><br>
<%
				}
				
				String sAttachments = mTask.get(RDMServicesConstants.ATTACHMENTS);
				String[] saAttachments = sAttachments.split(",");
				for(int x=0; x<saAttachments.length; x++)
				{
					if(saAttachments[x] != null && !"".equals(saAttachments[x]))
					{
%>
						<a href="javascript:viewAttachments('<%= sTaskId %>', '<%= saAttachments[x] %>')"><%= saAttachments[x] %></a>&nbsp;
<%
					}
				}
%>
				</td>
			</tr>
			<tr>
				<td colspan="2" align="right">
<%
				if(bCanAddEdit)
				{
%>
					<input type="button" name="Save" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Save") %>" onClick="submitForm()">&nbsp;&nbsp;&nbsp;
<%
				}
%>
					<input type="button" name="Close" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Close") %>" onClick="javascript:top.window.close()">
				</td>
			</tr>
		</table>
	</form>
	
	
	
	
	
	<%-- <table id="calenderTable">
		<tbody id="calenderTableHead">
			<tr>
				<td colspan="4" align="center">
					<select onChange="showCalenderBody(createCalender(document.getElementById('selectYear').value, this.selectedIndex, false));" id="selectMonth">
						<option value="0"><%= resourceBundle.getProperty("DataManager.DisplayText.January") %></option>
						<option value="1"><%= resourceBundle.getProperty("DataManager.DisplayText.February") %></option>
						<option value="2"><%= resourceBundle.getProperty("DataManager.DisplayText.March") %></option>
						<option value="3"><%= resourceBundle.getProperty("DataManager.DisplayText.April") %></option>
						<option value="4"><%= resourceBundle.getProperty("DataManager.DisplayText.May") %></option>
						<option value="5"><%= resourceBundle.getProperty("DataManager.DisplayText.June") %></option>
						<option value="6"><%= resourceBundle.getProperty("DataManager.DisplayText.July") %></option>
						<option value="7"><%= resourceBundle.getProperty("DataManager.DisplayText.August") %></option>
						<option value="8"><%= resourceBundle.getProperty("DataManager.DisplayText.September") %></option>
						<option value="9"><%= resourceBundle.getProperty("DataManager.DisplayText.October") %></option>
						<option value="10"><%= resourceBundle.getProperty("DataManager.DisplayText.November") %></option>
						<option value="11"><%= resourceBundle.getProperty("DataManager.DisplayText.December") %></option>

					</select>
				</td>
				<td colspan="2" align="center">
					<select onChange="showCalenderBody(createCalender(this.value, document.getElementById('selectMonth').selectedIndex, false));" id="selectYear">
					</select>
				</td>
				<td align="center">
					<a href="#" onClick="closeCalender();"><font color="#003333" size="2">X</font></a>
				</td>
			</tr>
		</tbody>
		<tbody id="calenderTableDays">
			<tr style="">
				<td><%= resourceBundle.getProperty("DataManager.DisplayText.Sunday") %></td>
				<td><%= resourceBundle.getProperty("DataManager.DisplayText.Monday") %></td>
				<td><%= resourceBundle.getProperty("DataManager.DisplayText.Tuesday") %></td>
				<td><%= resourceBundle.getProperty("DataManager.DisplayText.Wednesday") %></td>
				<td><%= resourceBundle.getProperty("DataManager.DisplayText.Thursday") %></td>
				<td><%= resourceBundle.getProperty("DataManager.DisplayText.Friday") %></td>
				<td><%= resourceBundle.getProperty("DataManager.DisplayText.Saturday") %></td>
			</tr>
		</tbody>
		<tbody id="calender"></tbody>
	</table> --%>
	
	
	
	
</body>
</html>
