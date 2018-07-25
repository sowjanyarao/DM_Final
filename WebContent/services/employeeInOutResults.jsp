<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>

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

	<script language="javascript">
		function logInOut(userId, OID)
		{
			var retval = window.open('employeeInOut.jsp?userId='+userId+'&OID='+OID, '', 'left=250,top=250,resizable=no,scrollbars=no,status=no,toolbar=no,height=400,width=420');
		}
	</script>
</head>

<body>
	<form name="frm">
		<table border="0" cellpadding="1" align="center" cellspacing="1" width="<%= winWidth * 0.7 %>">
			<tr>
				<th class="label" width="10%"><%= resourceBundle.getProperty("DataManager.DisplayText.User_ID") %></th>
				<th class="label" width="20%"><%= resourceBundle.getProperty("DataManager.DisplayText.User_Name") %></th>
				<th class="label" width="10%"><%= resourceBundle.getProperty("DataManager.DisplayText.Role") %></th>
				<th class="label" width="10%"><%= resourceBundle.getProperty("DataManager.DisplayText.Department") %></th>
				<th class="label" width="15%"><%= resourceBundle.getProperty("DataManager.DisplayText.In_Time") %></th>
				<th class="label" width="15%"><%= resourceBundle.getProperty("DataManager.DisplayText.Out_Time") %></th>
				<th class="label" width="15%"><%= resourceBundle.getProperty("DataManager.DisplayText.Shift") %></th>
			</tr>
<%
			String sUserId = request.getParameter("userId");
			String sFName = request.getParameter("FName");
			String sLName = request.getParameter("LName");

			if(!(sUserId == null || sFName == null || sLName == null))
			{
				MapList mlUsers = RDMServicesUtils.getUsers(sUserId, sFName, sLName, "", false);
				Map<String, Map<String, String>> mUsers = new HashMap<String, Map<String, String>>();
				Map<String, String> mInfo= null;
				int iSz = mlUsers.size();				
				for(int i=0; i<iSz; i++)
				{
					mInfo = mlUsers.get(i);
					sUserId = mInfo.get(RDMServicesConstants.USER_ID);
					mUsers.put(sUserId, mInfo);
				}

				if(iSz > 0)
				{
					boolean fg = false;
					boolean bLog = false;
					int diff = 0;
					Calendar logCal = Calendar.getInstance();
					Date sDate = null;
					String sOID = null;
					String role = null;
					String dept = null;
					String sInTime = null;
					String sOutTime = null;
					String shiftCode = null;
					String[] saLogs = null;
					List<String> lUsers = null;
					Map<String, String[]> mLog = null;

					SimpleDateFormat sdf = new SimpleDateFormat("dd-MMM-yyyy", Locale.ENGLISH);
					SimpleDateFormat input = new SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.ENGLISH);
					SimpleDateFormat output = new SimpleDateFormat("dd-MMM HH:mm", Locale.ENGLISH);
					
					String sCurrDate = sdf.format(new java.util.Date());
					Calendar currCal = Calendar.getInstance();
					currCal.setTime(new java.util.Date());
					currCal.add(Calendar.DAY_OF_YEAR, -1);
					int currDay = currCal.get(Calendar.DAY_OF_YEAR);

					Map<Date, Map<String, String[]>> mUserLog = RDMServicesUtils.getUserLogs();
					Iterator<Date> itr = mUserLog.keySet().iterator();
					while(itr.hasNext())
					{
						sDate = itr.next();
						if(sCurrDate.equals(sdf.format(sDate)))
						{
							fg = true;
						}
					}
					
					if(!fg)
					{
						mUserLog.put(new java.util.Date(), new HashMap<String, String[]>());
					}
					
					List<Date> lDates = new ArrayList<Date>(mUserLog.keySet());
					Collections.sort(lDates);
					for(int i=0; i<lDates.size(); i++)
					{
						sDate = lDates.get(i);
						mLog = mUserLog.get(sDate);
						
						fg = true;
						bLog = true;
						if(sCurrDate.equals(sdf.format(sDate)))
						{
							lUsers = new ArrayList<String>(mUsers.keySet());
						}
						else
						{
							logCal.setTime(sDate);
							diff = currDay - logCal.get(Calendar.DAY_OF_YEAR);
							if(diff != 0)
							{
								bLog = false;
							}
							lUsers = new ArrayList<String>(mLog.keySet());
						}
						Collections.sort(lUsers, String.CASE_INSENSITIVE_ORDER);
						for(int j=0; j<lUsers.size(); j++)
						{
							sUserId = lUsers.get(j);
							if(!mUsers.containsKey(sUserId))
							{
								continue;
							}
							
							mInfo = mUsers.get(sUserId);
							role = mInfo.get(RDMServicesConstants.ROLE_NAME);
							dept = mInfo.get(RDMServicesConstants.DEPARTMENT_NAME);
							dept = (dept == null ? "" : dept);
						
							saLogs = mLog.get(sUserId);
							sOID = ""; sInTime = ""; sOutTime = ""; shiftCode = "";
							if(saLogs != null)
							{
								sOID = saLogs[0];
								sInTime = (!"".equals(saLogs[1]) ? output.format(input.parse(saLogs[1])) : "");
								sOutTime = (!"".equals(saLogs[2]) ? output.format(input.parse(saLogs[2])) : "");
								shiftCode = saLogs[3];

								if(bLog && !"".equals(sInTime) && !"".equals(sOutTime))
								{
									sOID = "";
									sInTime = "";
									sOutTime = "";
									shiftCode = "";
								}
							}
							
							if(fg)
							{
%>
								<tr>
									<td class="input" colspan="7" style="text-align:center"><b><%= sdf.format(sDate) %></b></td>
								</tr>
<%
							}
%>
							<tr>
								<td class="input">
<%
								if(bLog)
								{
%>
									<a href="javascript:logInOut('<%= sUserId %>', '<%= sOID %>')"><%= sUserId %></a>
<%
								}
								else
								{
%>
									<%= sUserId %>
<%
								}
%>
								</td>
								<td class="input"><%= mInfo.get(RDMServicesConstants.LAST_NAME) %>,&nbsp;<%= mInfo.get(RDMServicesConstants.FIRST_NAME) %></td>
								<td class="input"><%= role %></td>
								<td class="input"><%= dept %></td>
								<td class="input"><%= sInTime.replaceAll(" ", "&nbsp;&nbsp;<b>") %></b></td>
								<td class="input"><%= sOutTime.replaceAll(" ", "&nbsp;&nbsp;<b>") %></b></td>								
								<td class="input">&nbsp;
<%
								if(!"".equals(shiftCode.trim()))
								{
%>
									<%= resourceBundle.getProperty("DataManager.DisplayText."+shiftCode+"_Shift") %>
<%
								}
%>
								</td>
							</tr>
<%
							fg = false;
						}
					}
				}
				else
				{
%>
					<tr>
						<td class="input" colspan="7" style="text-align:center"><%= resourceBundle.getProperty("DataManager.DisplayText.No_Users") %></td>
					</tr>
<%
				}
			}
			else
			{
%>
				<tr>
					<td class="input" colspan="7" style="text-align:center"><%= resourceBundle.getProperty("DataManager.DisplayText.Users_Search_Msg") %></td>
				</tr>
<%
			}
%>
		</table>
	</form>
</body>
</html>
