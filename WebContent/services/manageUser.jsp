<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<%
	String sMode = request.getParameter("mode");
	String sUserId = request.getParameter("userId");
	String sFirstName = "";
	String sLastName = "";
	String sDOB = "";
	String sGender = "";
	String sAddress = "";
	String sEmail = "";
	String sDOJ = "";
	String sContactNo = "";
	String sLocale = "en";
	String sTraining = "";
	
	Map<String, String> mUserInfo = new HashMap<String, String>();
	if(sUserId != null && !"".equals(sUserId))
	{
		mUserInfo = RDMServicesUtils.getUser(sUserId);
		sFirstName = mUserInfo.get(RDMServicesConstants.FIRST_NAME);
		sLastName = mUserInfo.get(RDMServicesConstants.LAST_NAME);
		sDOB = mUserInfo.get(RDMServicesConstants.DATE_OF_BIRTH);
		sGender = mUserInfo.get(RDMServicesConstants.GENDER);
		sAddress = mUserInfo.get(RDMServicesConstants.ADDRESS);
		sAddress = (sAddress == null ? "" : sAddress);
		sEmail = mUserInfo.get(RDMServicesConstants.EMAIL);	
		sDOJ = mUserInfo.get(RDMServicesConstants.DATE_OF_JOIN);
		sContactNo = mUserInfo.get(RDMServicesConstants.CONTACT_NO);
		sContactNo = (sContactNo == null ? "" : sContactNo);
		sLocale = mUserInfo.get(RDMServicesConstants.LOCALE);
		if(sLocale == null || "".equals(sLocale))
		{
			sLocale = "en";
		}
		sTraining = mUserInfo.get(RDMServicesConstants.TRAINING);
	}
	
	boolean bAdd = "add".equals(sMode);
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
	<title></title>

	<!-- Stylesheets -->
    <!-- Bootstrap is included in its original form, unaltered -->
    <link rel="stylesheet" href="../css/bootstrap.min.css">

    <!-- Related styles of various icon packs and plugins -->
    <link rel="stylesheet" href="../css/plugins.css">

    <!-- The main stylesheet of this template. All Bootstrap overwrites are defined in here -->
    <link rel="stylesheet" href="../css/main.css">

    <!-- Include a specific file here from css/themes/ folder to alter the default theme of the template -->

    <!-- The themes stylesheet of this template (for using specific theme color in individual elements - must included last) -->
    <link rel="stylesheet" href="../css/themes.css">
    <!-- END Stylesheets -->

    <!-- Modernizr (browser feature detection library) -->
    <script src="../js/vendor/modernizr-3.3.1.min.js"></script>
    
	<script language="javascript">
		if (!String.prototype.trim) 
		{
			String.prototype.trim = function() {
				return this.replace(/^\s+|\s+$/g,'');
			}
		}
	
		function submitForm()
		{
			if(!checkUserId())
			{
				return false;
			}
<%
			if(bAdd)
			{
%>
				if(!checkPassword())
				{
					return false;
				}
<%
			}
%>
			if(!checkUserName())
			{
				return false;
			}
			
			if(!checkGender())
			{
				return false;
			}
			
			if(!checkAddress())
			{
				return false;
			}

			if(!checkDate('dateOfBirth'))
			{
				return false;
			}

			if(!checkDate('dateOfJoin'))
			{
				return false;
			}

			var role = document.getElementById("role");
			if(role.value == "")
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Choose_User_Role") %>");
				userId.focus();
				return false;
			}

			var dept = document.getElementById("dept");
			if(dept.value == "")
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Choose_User_Dept") %>");
				userId.focus();
				return false;
			}

			if(!checkEmail())
			{
				return false;
			}
			
			if(document.frm.training.checked)
			{
				document.frm.training.value = "Y";
			}
			else
			{
				document.frm.training.value = "N";
			}
			
			document.frm.submit();
		}

		function checkUserId() 
		{
			var userId = document.getElementById("userId");
			userId.value = userId.value.trim();
			
			if(userId.value.length < 6)
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.User_ID_Length_Mismatch") %>");
				userId.focus();
				return false;
			}
			
			var nameRegex = /^[A-Za-z0-9_]{6,10}$/;
			var validUserId = userId.value.match(nameRegex);
			if(validUserId == null)
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.User_ID_Invalid") %>");
				userId.focus();
				return false;
			}
			return true;
		}
		
		function checkPassword()
		{
			var password = document.getElementById("password");
			password.value = password.value.trim();
			
			if(password.value.length < 8)
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Password_length_Mismatch") %>");
				password.focus();
				return false;
			}
			
			var nameRegex = /^[A-Za-z0-9_@#$]{8,15}$/;
			var validUserId = password.value.match(nameRegex);
			if(validUserId == null)
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Password_Invalid") %>");
				password.focus();
				return false;
			}
			return true;
		}
		
		function checkUserName() 
		{
			var nameRegex = /^[A-Za-z0-9]+$/;
			
			var firstName = document.getElementById("firstName");
			firstName.value = firstName.value.trim();
			if(firstName.value == "")
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.First_Name_Empty") %>");
				firstName.focus();
				return false;
			}
			
			var validFirstName = firstName.value.match(nameRegex);
			if(validFirstName == null)
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.First_Name_Invalid") %>");
				firstName.focus();
				return false;
			}		
			
			var lastName = document.getElementById("lastName");
			lastName.value = lastName.value.trim();
			if(lastName.value == "")
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Last_Name_Empty") %>");
				lastName.focus();
				return false;
			}
			
			var validLastName = lastName.value.match(nameRegex);
			if(validLastName == null)
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Last_Name_Invalid") %>");
				lastName.focus();
				return false;
			}
			return true;
		}

		function checkEmail() 
		{
			var email = document.getElementById("email");
			email.value = email.value.trim();
			
			if(email.value != "")
			{
				var filter = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
				if (!filter.test(email.value)) 
				{
					alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Email_Addr_Invalid") %>");
					email.focus;
					return false;
				}
			}
			else
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Email_Addr_Empty") %>");
				email.focus;
				return false;
			}
			return true;
		}
			
		function checkGender()
		{
			var checked = false;
			
			var gender = document.getElementsByName("gender");
			for(var i=0; i<gender.length; i++)
			{
				var e = gender[i];
				if(e.checked)
				{
					checked = true;
				}
			}
			
			if(!checked)
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Gender_Empty") %>");
				age.focus();
				return false;
			}

			return true;
		}
		
		function checkAddress()
		{
			var address = document.getElementById("address");
			address.value = address.value.trim();

			if(address.value == "")
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Address_Empty") %>");
				address.focus();
				return false;
			}
			return true;
		}
		
		function checkDate(dt)
		{
			var date1;
			var fg = false;
			var today = new Date();
			
			if(document.getElementById(dt).value != "")
			{
				var startDt = document.getElementById(dt).value;
				var dt1  = parseInt(startDt.substring(0,2),10); 
				var mon1 = parseInt(startDt.substring(3,5),10);
				var yr1  = parseInt(startDt.substring(6,10),10); 
				mon1 = mon1 - 1;
				date1 = new Date(yr1, mon1, dt1);

				if(date1 > today)
				{
					alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Select_Date_Invalid") %>");
					return false;
				}
			}

			return true;
		}
		
		function setDate(dt, fld)
		{
			if(dt != "")
			{
				var today = new Date(dt);

				var dd = today.getDate();
				if(dd < 10)
				{
					dd = '0' + dd;
				}
				
				var mm = today.getMonth() + 1;
				if(mm < 10)
				{
					mm = '0' + mm;
				}
				
				var yy = today.getFullYear();

				document.getElementById(fld).value = dd + "-" + mm + "-" + yy;
			}
		}
	</script>
</head>

<body onLoad="javascript:setDate('<%= sDOB %>', 'dateOfBirth');setDate('<%= sDOJ %>', 'dateOfJoin')">
	<form name="frm" method="post" action="manageUserProcess.jsp" enctype="multipart/form-data"  class="form-horizontal">
		<input type="hidden" id="mode" name="mode" value="<%= sMode %>">
		
		<table border="0" cellpadding="1" cellspacing="1" width="100%">
			<tr>
				<td class="label" width="30%"><b><%= resourceBundle.getProperty("DataManager.DisplayText.User_ID") %></b></td>
<%
				if(bAdd)
				{
%>
					<td class="input" width="70%">
						<input type="text" id="userId" name="userId" value="" maxlength="10">
					</td>
<%
				}
				else
				{
%>
					<td class="input" width="30%">
						<input type="text" id="userId" name="userId" value="<%= mUserInfo.get(RDMServicesConstants.USER_ID) %>" maxlength="10">
						<input type="hidden" id="hid_userId" name="hid_userId" value="<%= sUserId %>">
					</td>
					<td rowspan="5" class="input" width="40%">
						<img src="../UserImages/<%= sUserId %>.jpg" height="150" width="150" align="right">
					</td>
<%
				}
%>
			</tr>
<%
			if(bAdd)
			{
%>			
				<tr>
					<td class="label"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Password") %></b></td>
					<td class="input">
						<input type="password" id="password" name="password" maxlength="15" value="">
					</td>
				</tr>
<%
			}
%>
			<tr>
				<td class="label"><b><%= resourceBundle.getProperty("DataManager.DisplayText.First_Name") %></b></td>
				<td class="input" colspan="<%= !bAdd ? 2 : 0 %>">
					<input type="text" id="firstName" name="firstName" size="15" value="<%= sFirstName %>">
				</td>
			</tr>
			<tr>
				<td class="label"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Last_Name") %></b></td>
				<td class="input" colspan="<%= !bAdd ? 2 : 0 %>">
					<input type="text" id="lastName" name="lastName" size="15" value="<%= sLastName %>">
				</td>
			</tr>
			<tr>
				<td class="label" id="a"><b><%= resourceBundle.getProperty("DataManager.DisplayText.DateOfBirth") %><b></td>
				<td class="input" colspan="<%= !bAdd ? 2 : 0 %>">
					<input type="text" size="10" id="dateOfBirth" name="dateOfBirth" readonly>
					<a href="#" onClick="setYears(1960, 2010);showCalender('a', 'dateOfBirth');"><img src="../images/calender.png"></a>
					<a href="#" onClick="javascript:document.getElementById('dateOfBirth').value=''"><img src="../images/clear.png"></a>
				</td>
			</tr>
			<tr>
				<td class="label"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Gender") %></b></td>
				<td class="input" colspan="<%= !bAdd ? 2 : 0 %>">
					<input type="radio" id="gender" name="gender" value="M" <%= "M".equals(sGender) ? "checked" : "" %>><%= resourceBundle.getProperty("DataManager.DisplayText.Male") %>
					<input type="radio" id="gender" name="gender" value="F" <%= "F".equals(sGender) ? "checked" : "" %>><%= resourceBundle.getProperty("DataManager.DisplayText.Female") %>
				</td>
			</tr>
			<tr>
				<td class="label" id="b"><b><%= resourceBundle.getProperty("DataManager.DisplayText.DateOfJoin") %><b></td>
				<td class="input" colspan="<%= !bAdd ? 2 : 0 %>">
					<input type="text" size="10" id="dateOfJoin" name="dateOfJoin" readonly>
					<a href="#" onClick="setYears(2000, 2025);showCalender('b', 'dateOfJoin');"><img src="../images/calender.png"></a>
					<a href="#" onClick="javascript:document.getElementById('dateOfJoin').value=''"><img src="../images/clear.png"></a>
				</td>
			</tr>
			<tr>
				<td class="label"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Address") %></b></td>
				<td class="input" colspan="<%= !bAdd ? 2 : 0 %>">
					<textarea id="address" name="address"><%= sAddress %></textarea>
				</td>
			</tr>
			<tr>
				<td class="label"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Contact_No") %></b></td>
				<td class="input" colspan="<%= !bAdd ? 2 : 0 %>">
					<input type="text" id="contactNo" name="contactNo" size="15" value="<%= sContactNo %>">
				</td>
			</tr>
			<tr>
				<td class="label"><b><%= resourceBundle.getProperty("DataManager.DisplayText.User_Role") %></b></td>
				<td class="input" colspan="<%= !bAdd ? 2 : 0 %>">
<%
					String sRole = mUserInfo.get(RDMServicesConstants.ROLE_NAME);
%>
					<select id="role" name="role">
						<option value=""><%= resourceBundle.getProperty("DataManager.DisplayText.Please_choose_one") %></option>
						<option value="<%= RDMServicesConstants.ROLE_ADMIN %>" <%= RDMServicesConstants.ROLE_ADMIN.equals(sRole) ? "selected" : "" %>><%= resourceBundle.getProperty("DataManager.DisplayText.Administrator") %></option>
						<option value="<%= RDMServicesConstants.ROLE_MANAGER %>" <%= RDMServicesConstants.ROLE_MANAGER.equals(sRole) ? "selected" : "" %>><%= resourceBundle.getProperty("DataManager.DisplayText.Manager") %></option>
						<option value="<%= RDMServicesConstants.ROLE_SUPERVISOR %>" <%= RDMServicesConstants.ROLE_SUPERVISOR.equals(sRole) ? "selected" : "" %>><%= resourceBundle.getProperty("DataManager.DisplayText.Supervisor") %></option>
						<option value="<%= RDMServicesConstants.ROLE_HELPER %>" <%= RDMServicesConstants.ROLE_HELPER.equals(sRole) ? "selected" : "" %>><%= resourceBundle.getProperty("DataManager.DisplayText.Helper") %></option>
						<option value="<%= RDMServicesConstants.ROLE_TIMEKEEPER %>" <%= RDMServicesConstants.ROLE_TIMEKEEPER.equals(sRole) ? "selected" : "" %>><%= resourceBundle.getProperty("DataManager.DisplayText.TimeKeeper") %></option>
					</select>
				</td>
			</tr>
			<tr>
				<td class="label"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Department") %></b></td>
				<td class="input" colspan="<%= !bAdd ? 2 : 0 %>">
<%
					String sUserDept = null;
					StringList slUserDepts = null;
					if(!bAdd)
					{
						sUserDept = mUserInfo.get(RDMServicesConstants.DEPARTMENT_NAME);
						slUserDepts = StringList.split(mUserInfo.get(RDMServicesConstants.SEC_DEPARTMENT), "\\|");
						slUserDepts.sort();
					}

					Map <String, String> mDepartments = RDMServicesUtils.getDepartments();
					List<String> lDepartments = new ArrayList<String>(mDepartments.keySet());
						
					String[] saDepts = new String[lDepartments.size()];
					saDepts = lDepartments.toArray(saDepts);
						
					StringList slDepts = new StringList();
					slDepts.addAll(saDepts);
					slDepts.sort();
%>
					<select id="dept" name="dept">
						<option value=""><%= resourceBundle.getProperty("DataManager.DisplayText.Please_choose_one") %></option>
<%
						String sDeptName = null;
						for(int j=0; j<slDepts.size(); j++)
						{
							sDeptName = slDepts.get(j);
%>
							<option  value="<%= sDeptName %>" <%= (!bAdd && sDeptName.equals(sUserDept)) ? "selected" : "" %>><%= sDeptName %></option>
<%
						}
%>
					</select>
				</td>
			</tr>
			<tr>
				<td class="label"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Sec_Department") %></b></td>
				<td class="input" colspan="<%= !bAdd ? 2 : 0 %>">
					<select id="secDept" name="secDept" multiple size="5">
<%
						for(int j=0; j<slDepts.size(); j++)
						{
							sDeptName = slDepts.get(j);
%>
							<option  value="<%= sDeptName %>" <%= (!bAdd && slUserDepts.contains(sDeptName)) ? "selected" : "" %>><%= sDeptName %></option>
<%
						}
%>
					</select>
				</td>
			</tr>
			<tr>
				<td class="label"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Email") %></b></td>
				<td class="input" colspan="<%= !bAdd ? 2 : 0 %>">
					<input type="text" id="email" name="email" value="<%= sEmail %>">
				</td>
			</tr>
			<tr>
				<td class="label"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Preferred_Language") %></b></td>
				<td class="input" colspan="<%= !bAdd ? 2 : 0 %>">
					<select id="locale" name="locale">
						<option value="" <%= "".equals(sLocale) ? "selected" : "" %>><%= resourceBundle.getProperty("DataManager.DisplayText.Please_choose_one") %></option>
						<option value="nl" <%= "nl".equals(sLocale) ? "selected" : "" %>>Dutch</option>
						<option value="en" <%= "en".equals(sLocale) ? "selected" : "" %>>English</option>
						<option value="fr" <%= "fr".equals(sLocale) ? "selected" : "" %>>French</option>
						<option value="de" <%= "de".equals(sLocale) ? "selected" : "" %>>German</option>
						<option value="it" <%= "it".equals(sLocale) ? "selected" : "" %>>Italian</option>
						<option value="es" <%= "es".equals(sLocale) ? "selected" : "" %>>Spanish</option>
					</select>
				</td>
			</tr>
			<tr>
				<td class="label"><b>Needs Training</b></td>
				<td class="input" colspan="<%= !bAdd ? 2 : 0 %>">
					<input type="checkbox" id="training" name="training" value="Y" <%= ("Y".equals(sTraining) ? "checked" : "") %>>
				</td>
			</tr>
			<tr>
				<td class="label"><b><%= resourceBundle.getProperty("DataManager.DisplayText.UploadImage") %></b></td>
				<td class="input" colspan="<%= !bAdd ? 2 : 0 %>">
					<input type="file" id="image" name="image" accept="image/*">
				</td>
			</tr>
			<tr>
				<td colspan="<%= !bAdd ? 3 : 2 %>">
					&nbsp;
				</td>
			</tr>
			<tr>
				<td colspan="<%= !bAdd ? 3 : 2 %>" align="right">
					<input type="button" name="Save" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Save") %>" onClick="submitForm()">&nbsp;&nbsp;&nbsp;
					<input type="button" name="Close" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Close") %>" onClick="javascript:top.window.close()">
				</td>
			</tr>
		</table>
	</form>
	
	<table id="calenderTable">
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
	</table>
</body>
</html>
