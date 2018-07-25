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
	<title></title>

	<link type="text/css" href="../styles/dygraph.css" rel="stylesheet" />
	<link type="text/css" href="../styles/calendar.css" rel="stylesheet" />
	<script language="javaScript" type="text/javascript" src="../scripts/calendar.js"></script>
	<script language="javascript">
		function saveTimesheet()
		{
			if(document.getElementById('shift').value == "")
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Select_Shift_Code") %>");				
			}
			else
			{
				document.frm.mode.value = "save";
				document.frm.submit();
			}
		}
		
		function deleteTimesheet()
		{
			var r = confirm("<%= resourceBundle.getProperty("DataManager.DisplayText.Delete_Timesheet") %>")
			if (r == true)
			{
				document.frm.mode.value = "delete";
				document.frm.submit();
			}
		}
	</script>
</head>

<%	
	String sUserId = request.getParameter("userId");
	String sOID = request.getParameter("OID");
	String sInTime = request.getParameter("inTime");
	String sOutTime = request.getParameter("outTime");
	String shiftCode = request.getParameter("shift");

	SimpleDateFormat sdfin = new SimpleDateFormat("yyyy-MM-dd", Locale.ENGLISH);
	SimpleDateFormat sdfout = new SimpleDateFormat("dd-MM-yyyy", Locale.ENGLISH);
	
	String sInDt = "";
	String sInHH = "";
	String sInMM = ""; 
	String sOutDt = "";
	String sOutHH = "";
	String sOutMM = "";

	if(!"".equals(sInTime))
	{
		int idx = sInTime.indexOf(' ');
		sInDt = sInTime.substring(0, idx);
		sInDt = sdfout.format(sdfin.parse(sInDt));
		sInTime = sInTime.substring(idx + 1);
		
		String[] saTime = sInTime.split(":");
		sInHH = saTime[0];
		sInMM = saTime[1];
	}
	
	if(!"".equals(sOutTime))
	{
		int idx = sOutTime.indexOf(' ');
		sOutDt = sOutTime.substring(0, idx);
		sOutDt = sdfout.format(sdfin.parse(sOutDt));
		sOutTime = sOutTime.substring(idx + 1);

		String[] saTime = sOutTime.split(":");
		sOutHH = saTime[0];
		sOutMM = saTime[1];
	}
	
	Map<String, String> mUsers = RDMServicesUtils.getUserNames();
%>

<body>
	<form name="frm" method="post" action="updateTimesheetsProcess.jsp">
		<input type="hidden" id="userId" name="userId" value="<%= sUserId %>">
		<input type="hidden" id="OID" name="OID" value="<%= sOID %>">
		<input type="hidden" id="mode" name="mode" value="">
		
		<table class="mar_bot">
		<tr>
				<th colspan="5"><%= resourceBundle.getProperty("DataManager.DisplayText.Update_Timesheet") %></th>
			</tr>
			
		</table>
		<table class="table table-striped table-bordered table-vcenter">
			
			<tr>
				<td ><%= resourceBundle.getProperty("DataManager.DisplayText.User_Name") %></td>
				<td class="input" colspan="4"><%= mUsers.get(sUserId) %>&nbsp;(<%= sUserId %>)</td>
			</tr>
			<tr>
				<td ><%= resourceBundle.getProperty("DataManager.DisplayText.Shift") %></td>
				<td class="input" colspan="4">
					<select id="shift" name="shift">
						<option value=""><%= resourceBundle.getProperty("DataManager.DisplayText.Please_Select") %></option>
						<option value="G" <%= "G".equals(shiftCode) ? "selected" : "" %>><%= resourceBundle.getProperty("DataManager.DisplayText.G_Shift") %></option>
						<option value="A" <%= "A".equals(shiftCode) ? "selected" : "" %>><%= resourceBundle.getProperty("DataManager.DisplayText.A_Shift") %></option>
						<option value="B" <%= "B".equals(shiftCode) ? "selected" : "" %>><%= resourceBundle.getProperty("DataManager.DisplayText.B_Shift") %></option>
						<option value="C" <%= "C".equals(shiftCode) ? "selected" : "" %>><%= resourceBundle.getProperty("DataManager.DisplayText.C_Shift") %></option>
					</select>
				</td>
			</tr>
			<tr>
				<td  rowspan="2"><%= resourceBundle.getProperty("DataManager.DisplayText.Log_In") %></td>
				<td  colspan="4" id="a">
					<input type="text" size="10" id="log_in" name="log_in" value="<%= sInDt %>" readonly>
					<a href="#" onClick="setYears(2000, 2025);showCalender('b', 'log_in');"><img src="../images/calender.png"></a>
					<a href="#" onClick="javascript:document.getElementById('log_in').value=''"><img src="../images/clear.png"></a>
				</td>
			</tr>
			<tr>
				<td >HH</td>
				<td>
					<input type="text" id="in_hr" name="in_hr" size="1" value="<%= sInHH %>">
				<td >MM</td>
				<td>
					<input type="text" id="in_min" name="in_min" size="1" value="<%= sInMM %>">
				</td>
			</tr>
			<tr>
				<td  rowspan="2"><%= resourceBundle.getProperty("DataManager.DisplayText.Log_Out") %></td>
				<td  colspan="4" id="b">
					<input type="text" size="10" id="log_out" name="log_out" value="<%= sOutDt %>" readonly>
					<a href="#" onClick="setYears(2000, 2025);showCalender('b', 'log_out');"><img src="../images/calender.png"></a>
					<a href="#" onClick="javascript:document.getElementById('log_out').value=''"><img src="../images/clear.png"></a>
				</td>
			</tr>
			<tr>
				<td >HH</td>
				<td>
					<input type="text" id="out_hr" name="out_hr" size="1" value="<%= sOutHH %>">
				</td>
				<td >MM</td>
				<td>
					<input type="text" id="out_min" name="out_min" size="1" value="<%= sOutMM %>">
				</td>
			</tr>
			<tr>
				<td colspan="5">&nbsp;</td>
			</tr>
			<tr>
				<td align="left">
					<input type="button" class="btn btn-effect-ripple btn-primary" name="save" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Save") %>" onClick="saveTimesheet()">
				</td>
				<td colspan="3">&nbsp;</td>
				<td align="right">
					<input type="button" class="btn btn-effect-ripple btn-primary" name="delete" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Delete") %>" <%= "".equals(sOID) ? "disabled" : "" %> onClick="deleteTimesheet()">
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
