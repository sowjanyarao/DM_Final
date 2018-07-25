<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>
<%@page import="com.client.views.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<%

String sUserId = request.getParameter("userId");
String sDept = request.getParameter("dept");
String FName = request.getParameter("FName");
String LName = request.getParameter("LName");
String start_date = request.getParameter("start_date");
String end_date = request.getParameter("end_date");

String loggedIn = request.getParameter("loggedIn");
String loggedOut = request.getParameter("loggedOut");
String sMode = request.getParameter("mode");

SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd", Locale.ENGLISH);
SimpleDateFormat sdfTime = new SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.ENGLISH);

StringList slUserDept = new StringList();
slUserDept.add(u.getDepartment());
slUserDept.addAll(u.getSecondaryDepartments());

ArrayList<String> alDates = null;
Map<String, Map<String, MapList>> mUserLogs = null;
Map<String, String> mUsrTskCnt = null;
if(sMode != null)
{
	Map<String, String> mInfo = new HashMap<String, String>();
	mInfo.put(RDMServicesConstants.USER_ID, sUserId);
	mInfo.put(RDMServicesConstants.FIRST_NAME, FName);
	mInfo.put(RDMServicesConstants.LAST_NAME, LName);
	mInfo.put(RDMServicesConstants.DEPT_NAME, sDept);
	mInfo.put("fromDate", start_date);
	mInfo.put("endDate", end_date);
	mInfo.put("loggedIn", loggedIn);
	mInfo.put("loggedOut", loggedOut);
	mInfo.put("isHRM", (slUserDept.contains("HRM") ? "Yes" : "No"));
	
	mUserLogs = RDMServicesUtils.getTimesheets(mInfo);
	
	alDates = RDMServicesUtils.getDatesBetween(start_date, end_date, "dd-MMM-yyyy");
	
	mUsrTskCnt = new UserTasks().getUserTaskCnt();
}

boolean isAdmin = RDMServicesConstants.ROLE_ADMIN.equals(u.getRole());
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
	<title></title>

	<link type="text/css" href="../styles/superTables.css" rel="stylesheet" />
    <script type="text/javascript" src="../scripts/superTables.js"></script>
	<style>
	#scrollDiv 
	{	
		margin: 2px 2px; 
		width: <%= winWidth * 0.95 %>px; 
		height: <%= winHeight * 0.7 %>px; 
		overflow: hidden; 
		font-size: 0.85em;
	}
	
	a:link {text-decoration:none;}
	a:visited {text-decoration:none;}
	a:hover {text-decoration:underline;}
	a:active {text-decoration:underline;}
	</style>

	<script language="javascript">
		function showDetails(userId)
		{
			var retval = window.open('employeeInOut.jsp?userId='+userId, '', 'left=250,top=250,resizable=no,scrollbars=no,status=no,toolbar=no,height=300,width=420');
		}
		
		function logInOut(userId, oid, inTime, outTime, shift)
		{
			var retval = window.open('updateTimesheets.jsp?userId='+userId+'&OID='+oid+'&inTime='+inTime+'&outTime='+outTime+'&shift='+shift, '', 'left=250,top=250,resizable=yes,scrollbars=no,status=no,toolbar=no,height=300,width=400');
		}
		
		function showOpenTasks(sUserId)
		{
			window.open('userOpenTasksView.jsp?userId='+sUserId, '', 'left=25,top=25,resizable=yes,scrollbars=yes,status=no,toolbar=no,height=800,width=1200');
		}
		
		function exportTimesheets()
		{
			var url = "../ExportTimesheets";
			url += "?userId=<%= sUserId %>";
			url += "&FName=<%= FName %>";
			url += "&LName=<%= LName %>";
			url += "&dept=<%= sDept %>";
			url += "&start_date=<%= start_date %>";
			url += "&end_date=<%= end_date %>";
			url += "&loggedIn=<%= loggedIn %>";
			url += "&loggedOut=<%= loggedOut %>";
			url += "&isHRM=<%= slUserDept.contains("HRM") ? "Yes" : "No" %>";

			document.location.href =  url;
		}
	</script>
</head>

<body>
<%
if(sMode != null)
{
	
	if(mUserLogs.size() > 0)
	{
%>
		<table class="mar_bot">
			<tr>
<%
			if(isAdmin)
			{
%>
				<td align="left">
					<input class="btn btn-effect-ripple btn-primary" type="button" id="expTimesheets" name="expTimesheets" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Export_to_File") %>" onClick="exportTimesheets()">
				</td>
<%
			}
%>
				<td><div id="empCnt"></div></td>
			</tr>
		</table>

		<div>
			<table id="freezeHeaders" class="table table-striped table-bordered table-vcenter">
				<tr>
					<th><%= resourceBundle.getProperty("DataManager.DisplayText.User_Name") %></th>
					<th><%= resourceBundle.getProperty("DataManager.DisplayText.Tasks") %></th>
					<th>&nbsp;</th>
<%
					String sDate = null;
					for(int i=0; i<alDates.size(); i++)
					{
						sDate = alDates.get(i);
%>
						<th style="border-right:solid 0px #ffffff;">&nbsp;</th>
						<th style="text-align:left;border-left:solid 0px #ffffff;"><%= sDate.substring(0, sDate.lastIndexOf("-")) %></th>
<%
					}
%>
				</tr>
<%
				long lMin = 0;
				Date inTime = null;
				Date outTime = null;
				Date deptIn = null;
				Date deptOut = null;
				String sCnt = null;
				String sOID = null;
				String sInTime = null;
				String sOutTime = null;
				String sDeptIn = null;
				String sDeptOut = null;
				String shiftCode = null;
				String blocked = null;
				List<String> lUsers = new ArrayList<String>();
				Map<String, MapList> mLogs = null;
				Map<String, String[]> mUsers = new HashMap<String, String[]>();
				Map<String, String> mLogData = null;
				MapList mlUserLogs = null;

				MapList mlUsers = null;
				if("".equals(sUserId) && "".equals(FName) && "".equals(LName) && "".equals(sDept))
				{
					mlUsers = RDMServicesUtils.getUserList();
				}
				else
				{
					mlUsers = RDMServicesUtils.getUsers(sUserId, FName, LName, sDept, true);
				}

				Map<String, String> mUser = null;
				for(int i=0; i<mlUsers.size(); i++)
				{
					mUser = mlUsers.get(i);
					sUserId = mUser.get(RDMServicesConstants.USER_ID);
					
					lUsers.add(sUserId);
					mUsers.put(sUserId, new String[] {mUser.get(RDMServicesConstants.LAST_NAME)+", "+mUser.get(RDMServicesConstants.FIRST_NAME), mUser.get(RDMServicesConstants.DEPARTMENT_NAME), mUser.get(RDMServicesConstants.BLOCKED)});
				}
				
				int iCnt = 0;
				Map<String, Integer> mEmpCnt = new HashMap<String, Integer>();
				Collections.sort(lUsers, String.CASE_INSENSITIVE_ORDER);

				String[] saDept = null;
				for(int i=0; i<lUsers.size(); i++)
				{
					sUserId = lUsers.get(i);
					mLogs = mUserLogs.get(sUserId);
					sCnt = mUsrTskCnt.get(sUserId);
					sCnt = (sCnt == null ? "0" : sCnt);
					
					iCnt = 1;
					sDept = mUsers.get(sUserId)[1];
					blocked = mUsers.get(sUserId)[2];
					sDept = ("".equals(sDept) ? "All" : sDept);
					
					if(mLogs == null)
					{
						continue;
					}					

					saDept = sDept.split("\\|");
					for(int l=0; l<saDept.length; l++)
					{
						sDept = saDept[l];
						if(mEmpCnt.containsKey(sDept))
						{
							iCnt = (mEmpCnt.get(sDept)).intValue();
							iCnt++;
						}					
						mEmpCnt.put(sDept, Integer.valueOf(iCnt));
					}
%>
					<tr>
						<th style="text-align:left" rowspan="2">
<%
						
						if("Y".equals(blocked))
						{
%>
							<font style="color:red;font-weight:bold"><%= mUsers.get(sUserId)[0] %><br>(<a style="color:red;text-decoration:underline" href="javascript:showDetails('<%= sUserId %>')"><%= sUserId %></a>)</font>
<%
						}
						else
						{
%>
							<%= mUsers.get(sUserId)[0] %><br>(<a style="text-decoration:underline" href="javascript:showDetails('<%= sUserId %>')"><%= sUserId %></a>)
<%
						}
%>
						</th>
						<th style="text-align:center" rowspan="2"><a style="text-decoration:underline" href="javascript:showOpenTasks('<%= sUserId %>')"><%= sCnt %></a></th>
						<th><font style="color:green"><%= resourceBundle.getProperty("DataManager.DisplayText.In_Time") %></font></th>
<%
					for(int j=0; j<alDates.size(); j++)
					{
						sDate = alDates.get(j);
						sOID = ""; sInTime = "";  sOutTime = ""; sDeptIn = ""; shiftCode = "";
						if(mLogs != null)
						{
							mlUserLogs = mLogs.get(sDate);
							if(mlUserLogs != null && mlUserLogs.size() > 0)
							{
								mLogData = mlUserLogs.get(mlUserLogs.size() - 1);
								sOID = mLogData.get(RDMServicesConstants.OID);
								sInTime = mLogData.get(RDMServicesConstants.LOG_IN);
								sOutTime = mLogData.get(RDMServicesConstants.LOG_OUT);
								shiftCode = mLogData.get(RDMServicesConstants.SHIFT_CODE);
								sDeptIn = mLogData.get(RDMServicesConstants.DEPT_IN);
							}
						}
%>
						<td class="input" rowspan="2" style="text-align:center">
							<b><%= shiftCode %></b>
						</td>
						<td class="input" style="text-align:center">
<%
						if(isAdmin)
						{
%>
							<a href="javascript:logInOut('<%= sUserId %>','<%= sOID %>','<%= sInTime %>','<%= sOutTime %>', '<%= shiftCode %>')">
<%
						}

						if("".equals(sInTime))
						{
%>
							<font style="color:black">X</font>
<%
						}
						else
						{
							lMin = 0;
							if(!"".equals(inTime))
							{
								deptIn = ("".equals(sDeptIn) ? ("".equals(sOutTime) ? new Date() : sdfTime.parse(sOutTime)) : sdfTime.parse(sDeptIn));
								inTime = sdfTime.parse(sInTime);
								lMin = (deptIn.getTime() - inTime.getTime()) / (60 * 1000);
							}
%>
							<font style="color:green;font-weight:bold"><%= sInTime.substring(sInTime.indexOf(" ")+1) %></font>
							<font style="color:<%= (lMin < 0 || lMin > 30 ? "red" : "green") %>;font-weight:bold">
								<%= ("".equals(sDeptIn) || lMin < 0 || lMin > 30 ? "<blink>" : "") %>(<%= ((lMin < 0) ? "---" : lMin) %>)<%= ("".equals(sDeptIn) || lMin < 0 || lMin > 30 ? "</blink>" : "") %>
							</font>
<%
						}
						
						if(isAdmin)
						{
%>
							</a>
<%
						}
%>
						</td>
<%
					}
%>
					</tr>
					<tr>
						<th><font style="color:blue"><%= resourceBundle.getProperty("DataManager.DisplayText.Out_Time") %></font></th>
<%
					for(int j=0; j<alDates.size(); j++)
					{
						sDate = alDates.get(j);
						sOID = ""; sInTime = ""; sOutTime = ""; sDeptOut = ""; shiftCode = "";
						if(mLogs != null)
						{
							mlUserLogs = mLogs.get(sDate);
							if(mlUserLogs != null && mlUserLogs.size() > 0)
							{
								mLogData = mlUserLogs.get(mlUserLogs.size() - 1);
								sOID = mLogData.get(RDMServicesConstants.OID);
								sInTime = mLogData.get(RDMServicesConstants.LOG_IN);
								sOutTime = mLogData.get(RDMServicesConstants.LOG_OUT);
								shiftCode = mLogData.get(RDMServicesConstants.SHIFT_CODE);
								sDeptOut = mLogData.get(RDMServicesConstants.DEPT_OUT);
							}
						}
%>
						<td class="input" style="text-align:center">
<%
						if(isAdmin)
						{
%>
							<a href="javascript:logInOut('<%= sUserId %>','<%= sOID %>','<%= sInTime %>','<%= sOutTime %>', '<%= shiftCode %>')">
<%
						}

						if("".equals(sOutTime))
						{
%>
							<font style="color:black">X</font>
<%
						}
						else
						{
							lMin = 0;
							if(!"".equals(sDeptOut) && !"".equals(sOutTime))
							{
								deptOut = sdfTime.parse(sDeptOut);
								outTime = sdfTime.parse(sOutTime);
								lMin = (outTime.getTime() - deptOut.getTime()) / (60 * 1000);
							}
								
							if(!"".equals(sInTime) && (sdf.parse(sOutTime.substring(0, sOutTime.indexOf(" "))).compareTo(sdf.parse(sInTime.substring(0, sInTime.indexOf(" ")))) > 0))
							{
%>
								<font style="color:DeepPink;font-weight:bold"><%= sOutTime.substring(sOutTime.indexOf(" ")+1) %></font>
								<font style="color:<%= (lMin < 0 || lMin > 30 ? "red" : "blue") %>;font-weight:bold">
									<%= (lMin < 0 || lMin > 30 ? "<blink>" : "") %>(<%= lMin %>)<%= (lMin > 30 ? "</blink>" : "") %>
								</font>
<%
							}
							else
							{
%>
								<font style="color:blue;font-weight:bold"><%= sOutTime.substring(sOutTime.indexOf(" ")+1) %></font>
								<font style="color:<%= (lMin < 0 || lMin > 30 ? "red" : "blue") %>;font-weight:bold">
									<%= (lMin < 0 || lMin > 30 ? "<blink>" : "") %>(<%= ((lMin < 0) ? "---" : lMin) %>)<%= (lMin > 30 ? "</blink>" : "") %>
								</font>
<%
							}
						}
						
						if(isAdmin)
						{
%>
							</a>
<%
						}
%>
						</td>
<%
					}
%>
					</tr>
<%
				}
%>
			</table>
		</div>
		
		<script type="text/javascript">
<%
			int idx = 1;
			String sEmpCnt = "";
			List<String> lDepartments = new ArrayList<String>(mEmpCnt.keySet());
			Collections.sort(lDepartments, String.CASE_INSENSITIVE_ORDER);
			String sDeptName = null;
			for(int j=0; j<lDepartments.size(); j++)
			{
				sDept = lDepartments.get(j);
				if(idx > 10)
				{
					sEmpCnt += "</tr><tr>";
					idx = 0;
				}
				else
				{
					idx++;
				}
				sEmpCnt += "<td><b><font style='font-size:14px'>"+sDept+"&nbsp;:&nbsp;</font><font style='font-size:14px;color:blue'>"+mEmpCnt.get(sDept).toString()+"&nbsp;</font></b></td>";				
			}
%>		
			document.getElementById('empCnt').innerHTML = "<table border='0' cellspacing='2'><tr><%= sEmpCnt %></tr></table>";
		
			var myST = new superTable("freezeHeaders", {
				cssSkin : "sGrey",
				headerRows : 1,
				fixedCols : 3
			});
		</script>
<%
	}
	else
	{
%>
		<table width="100%">
			<tr>
				<td class="input" style="text-align:center;background-color:#bbbbbb;font-size:12px;font-family:Arial,sans-serif"><%= resourceBundle.getProperty("DataManager.DisplayText.No_Users") %></td>
			</tr>
		</table>
<%
	}
}
else
{
%>
	<table width="100%">
		<tr>
			<td class="input" style="text-align:center;background-color:#bbbbbb;font-size:12px;font-family:Arial,sans-serif"><%= resourceBundle.getProperty("DataManager.DisplayText.Users_Search_Msg") %></td>
		</tr>
	</table>
<%
}
%>
</body>
</html>
