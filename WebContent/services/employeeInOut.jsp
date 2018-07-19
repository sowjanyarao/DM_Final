<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<%
	String sUserId = request.getParameter("userId");
	String sOID = request.getParameter("OID");
	String sFirstName = "";
	String sLastName = "";
	String sRole = "";
	String sDept = "";
	String sSecDept = "";
	String sAddress = "";
	String sContactNo = "";
	String sEmail = "";
	String sInTime = "";
	String sOutTime = "";
	String shiftCode = "";
	
	Map<String, String> mUserInfo = RDMServicesUtils.getUser(sUserId);
	sFirstName = mUserInfo.get(RDMServicesConstants.FIRST_NAME);
	sLastName = mUserInfo.get(RDMServicesConstants.LAST_NAME);
	sRole = mUserInfo.get(RDMServicesConstants.ROLE_NAME);
	sDept = mUserInfo.get(RDMServicesConstants.DEPARTMENT_NAME);
	sEmail = mUserInfo.get(RDMServicesConstants.EMAIL);	
	sAddress = mUserInfo.get(RDMServicesConstants.ADDRESS);
	sAddress = (sAddress == null ? "" : sAddress);
	sContactNo = mUserInfo.get(RDMServicesConstants.CONTACT_NO);
	sContactNo = (sContactNo == null ? "" : sContactNo);
	sSecDept = mUserInfo.get(RDMServicesConstants.SEC_DEPARTMENT);
	
	SimpleDateFormat input = new SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.ENGLISH);
	SimpleDateFormat output = new SimpleDateFormat("dd-MMM HH:mm", Locale.ENGLISH);	

	if(sOID != null && !"".equals(sOID))
	{		
		Map<String, String> mLogTime = RDMServicesUtils.getLogTime(sOID);
		sInTime = mLogTime.get(RDMServicesConstants.LOG_IN);
		sInTime = (!"".equals(sInTime) ? output.format(input.parse(sInTime)) : "");
		sOutTime = mLogTime.get(RDMServicesConstants.LOG_OUT);
		sOutTime = (!"".equals(sOutTime) ? output.format(input.parse(sOutTime)) : "");
		shiftCode = mLogTime.get(RDMServicesConstants.SHIFT_CODE);
	}
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
	<title></title>

	<link type="text/css" href="../styles/dygraph.css" rel="stylesheet" />
	
	<script language="javascript">
		var flag = true;

		function logTime(v)
		{
			if(flag)
			{
				flag = false;
				
				var url = "employeeInOutLogTime.jsp?userId=<%= sUserId %>&OID=<%= sOID %>&type="+v;

				var shift = document.getElementById('shift');
				if(shift != null && shift != undefined)
				{
					url = url + "&shift="+shift.value;
				}
				
				document.location.href = url;
			}
		}
	</script>
</head>

<body>
	<form name="frm">
		<table id="datatable" class="table table-striped table-bordered table-vcenter">
			<tr>
				<td class="label" width="30%"><b><%= resourceBundle.getProperty("DataManager.DisplayText.User_ID") %></b></td>
				<td class="input" width="30%">
					<%= sUserId %>
				</td>
				<td rowspan="5" class="input" width="40%">
					<img src="../UserImages/<%= sUserId %>.jpg" height="150" width="150" align="right">
				</td>
			</tr>
			<tr>
				<td class="label"><b><%= resourceBundle.getProperty("DataManager.DisplayText.First_Name") %></b></td>
				<td class="input">
					<%= sFirstName %>
				</td>
			</tr>
			<tr>
				<td class="label"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Last_Name") %></b></td>
				<td class="input">
					<%= sLastName %>
				</td>
			</tr>
			<tr>
				<td class="label"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Contact_No") %></b></td>
				<td class="input">
					<%= sContactNo %>
				</td>
			</tr>
			<tr>
				<td class="label"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Email") %></b></td>
				<td class="input">
					<%= sEmail %>
				</td>
			</tr>
			<tr>
				<td class="label"><b><%= resourceBundle.getProperty("DataManager.DisplayText.User_Role") %></b></td>
				<td class="input">
					<%= sRole %>
				</td>
			</tr>
			<tr>
				<td class="label"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Department") %></b></td>
				<td class="input">
					<%= sDept.replaceAll("\\|", "<br>") %>
				</td>
			</tr>
			<tr>
				<td class="label"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Sec_Department") %></b></td>
				<td class="input">
					<%= sSecDept.replaceAll("\\|", "<br>") %>
				</td>
			</tr>
			<tr>
				<td class="label"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Address") %></b></td>
				<td class="input">
					<%= sAddress %>
				</td>
			</tr>
<%
			if(RDMServicesConstants.ROLE_TIMEKEEPER.equals(u.getRole()))
			{
%>
				<tr>
					<td colspan="3">&nbsp;</td>
				</tr>
				<tr>
					<td class="label"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Shift") %></b></td>
<%
					if("".equals(shiftCode.trim()))
					{
						Calendar cal = Calendar.getInstance();
						int hr = cal.get(Calendar.HOUR_OF_DAY);
						
						String s = "";
						if(hr >= 4 && hr < 8)
						{
							shiftCode = "A";
						}
						else if(hr >= 8 && hr < 12)
						{
							shiftCode = "G";
						}
						else if(hr >= 12 && hr < 20)
						{
							shiftCode = "B";
						}
						else if(hr >= 20 || hr < 4)
						{
							shiftCode = "C";
						}
						else
						{
							shiftCode = "D";
						}
%>				
						<td class="input">
							<select id="shift" name="shift">
								<option value="G" <%= "G".equals(shiftCode) ? "selected" : "" %>><%= resourceBundle.getProperty("DataManager.DisplayText.G_Shift") %></option>
								<option value="A" <%= "A".equals(shiftCode) ? "selected" : "" %>><%= resourceBundle.getProperty("DataManager.DisplayText.A_Shift") %></option>
								<option value="B" <%= "B".equals(shiftCode) ? "selected" : "" %>><%= resourceBundle.getProperty("DataManager.DisplayText.B_Shift") %></option>
								<option value="C" <%= "C".equals(shiftCode) ? "selected" : "" %>><%= resourceBundle.getProperty("DataManager.DisplayText.C_Shift") %></option>
								<option value="D" <%= "D".equals(shiftCode) ? "selected" : "" %>><%= resourceBundle.getProperty("DataManager.DisplayText.D_Shift") %></option>
							</select>
						</td>
						<td>&nbsp;</td>
<%
					}
					else
					{
%>
						<td class="input" colspan="2">
							<%= resourceBundle.getProperty("DataManager.DisplayText."+shiftCode+"_Shift") %>
						</td>
<%
					}
%>
				</tr>
				<tr>
					<td class="label"><b><%= resourceBundle.getProperty("DataManager.DisplayText.In_Time") %></b></td>
					<td class="input" colspan="<%= "".equals(sInTime) ? "1" : "2" %>">
						<%= sInTime %>
					</td>
<%
					if("".equals(sInTime))
					{
%>
						<td align="left">
							<input type="button" name="InTime" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Log_In") %>" onClick="logTime('in')">
						</td>
<%
					}
%>
				</tr>
				<tr>
					<td class="label"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Out_Time") %></b></td>
					<td class="input" colspan="<%= "".equals(sOutTime) ? "1" : "2" %>">
						<%= sOutTime %>
					</td>
<%
					int iCnt = User.getUserTaskCnt(sUserId);
					if("".equals(sOutTime) && (iCnt == 0))
					{
%>				
						<td align="left">
							<input type="button" name="OutTime" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Log_Out") %>" onClick="logTime('out')">
						</td>
<%
					}
%>
				</tr>
<%
				if(iCnt != 0)
				{
%>
					<tr>
						<td colspan="3" class="input">
							<i><%= resourceBundle.getProperty("DataManager.DisplayText.Open_Tasks") %></i>
						</td>
					</tr>
<%
				}

			}
			else
			{
%>
				<td colspan="3" align="right">
					<input type="button" class="btn btn-effect-ripple btn-primary" name="close" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Close") %>" onClick="javascript:top.window.close()">
				</td>
<%
			}
%>
		</table>
	</form>
</body>
</html>
