<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>
<%@page import="com.client.views.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<%
	String sMode = request.getParameter("mode");
	String sController = request.getParameter("controller");
	String sDate = request.getParameter("date");
	
	sController = (sController == null ? "" : sController);
	sDate = (sDate == null ? "" : sDate);
	
	Yields yields = new Yields();
	Map<String, String> mYield = new HashMap<String, String>();
	if("edit".equals(sMode))
	{
		SimpleDateFormat sdfIn = new SimpleDateFormat("MM/dd/yyyy", Locale.ENGLISH);
		SimpleDateFormat sdOut = new SimpleDateFormat("dd-MM-yyyy", Locale.ENGLISH);
		sDate = sdOut.format(sdfIn.parse(sDate));

		MapList mlYields = yields.getYields(sController, sDate, sDate, "", "", "", true);
		if(!mlYields.isEmpty())
		{
			mYield = mlYields.get(0);
		}
	}

	DecimalFormat df2 = new DecimalFormat("#.###");
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
	<title></title>

	<meta name="description" content="Datamanager"/>
    <meta name="author" content="Inventaa"/>
    <meta name="robots" content="noindex, nofollow"/>
    <meta name="viewport" content="width=device-width,initial-scale=1.0,user-scalable=0"/>

    <!-- Icons -->
    <!-- The following icons can be replaced with your own, they are used by desktop and mobile browsers -->
    <link rel="shortcut icon" href="../img/fav-icon.jpg"/>
    <!-- END Icons -->

    <!-- Stylesheets -->
    <!-- Bootstrap is included in its original form, unaltered -->
    <link rel="stylesheet" href="../css/bootstrap.min.css"/>

    <!-- Related styles of various icon packs and plugins -->
    <link rel="stylesheet" href="../css/plugins.css"/>

    <!-- The main stylesheet of this template. All Bootstrap overwrites are defined in here -->
    <link rel="stylesheet" href="../css/main.css"/>

    <!-- Include a specific file here from ../css/themes/ folder to alter the default theme of the template -->

    <!-- The themes stylesheet of this template (for using specific theme color in individual elements - must included last) -->
    <link rel="stylesheet" href="../css/themes.css"/>
    <!-- END Stylesheets -->
    <link type="text/css" href="../styles/calendar.css" rel="stylesheet" />
    
    <!-- Modernizr (browser feature detection library) -->
    <script src="../js/vendor/modernizr-3.3.1.min.js"/>
  
	<script language="javaScript" type="text/javascript" src="../scripts/calendar.js"></script>
	<script src="../js/vendor/jquery-2.2.4.min.js"></script>
    <script src="../js/vendor/bootstrap.min.js"></script>
    <script src="../js/plugins.js"></script>
    <script src="../js/app.js"></script>
    <!-- Load and execute javascript code used only in this page -->
    <script src="../js/pages/readyDashboard.js"></script>
	<script language="javascript">
		if (!String.prototype.trim) 
		{
			String.prototype.trim = function() {
				return this.replace(/^\s+|\s+$/g,'');
			}
		}
		
		function setDate()
		{
			var today = new Date();
			
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

			document.getElementById('date').value = dd + "-" + mm + "-" + yy;
		}
		
		function submitForm()
		{
			var controller = document.getElementById("controller").value;
			if(controller == "")
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Choose_Room") %>");
				return false;
			}
			
			var estYield = document.getElementById("EstYield").value;
			if(estYield == "")
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Enter_Yield") %>");
				return false;
			}
			else if(isNaN(estYield))
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Yield_NAN") %>");
				return false;
			}

			var comments = document.getElementById("comments").value;
			if(comments == "")
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Enter_Comments") %>");
				return false;
			}
		
			document.frm.submit();
		}
	</script>
</head>

<body <%= ("add".equals(sMode) ? "onLoad='setDate()'" : "") %>>
	<form name="frm" method="post" action="manageYieldsProcess.jsp">
		<input type="hidden" id="mode" name="mode" value="add">
		<div class="table table-responsive table-hover">
		
        <table id="datatable" class="table table-striped table-bordered table-vcenter">
<%
		if("add".equals(sMode))
		{
%>
			<tr>
				<td width="25%" ><b><%= resourceBundle.getProperty("DataManager.DisplayText.Room") %></b></td>
				<td width="75%" >
					<select id="controller" name="controller">
						<option value=""><%= resourceBundle.getProperty("DataManager.DisplayText.Please_choose_one") %></option>
<%
					StringList slControllers = RDMSession.getControllers();
					slControllers.addAll(RDMSession.getInactiveControllers());
					slControllers.sort();
					for(int i=0; i<slControllers.size(); i++)
					{
%>
						<option value="<%= slControllers.get(i) %>"><%= slControllers.get(i) %></option>
<%
					}
%>
					</select>
				</td>
			</tr>
			
			<tr>
				<td  width="25%" id="a"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Date") %></b></td>
				<td  width="75%">
					<input type="text" size="10" id="date" name="date" readonly>
					<a href="#" onClick="setYears(2000, 2025);showCalender('a', 'date');"><img src="../images/calender.png"></a>
					<a href="#" onClick="javascript:document.getElementById('date').value=''"><img src="../images/clear.png"></a>
				</td>
			</tr>
<%
		}
		else
		{
%>
			<tr>
				<td  width="25%"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Room") %></b></td>
				<td  width="75%"><%= sController %></td>
				<input type="hidden" id="controller" name="controller" value="<%= sController %>">
			</tr>
			<tr>
				<td  width="25%" id="a"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Date") %></b></td>
				<td  width="75%"><%= sDate %></td>
				<input type="hidden" id="date" name="date" value="<%= sDate %>">
			</tr>
<%
		}
			String sEstYield = mYield.get(RDMServicesConstants.EST_YIELD);
			sEstYield = (sEstYield == null ? "" : sEstYield);
%>		
			<tr>
				<td  width="25%"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Est_Yield") %></b></td>
				<td  width="75%">
					<input type="text" id="EstYield" name="EstYield" value="<%= sEstYield %>">
				</td>
			</tr>
<%
		if("edit".equals(sMode))
		{
%>
			<tr>
				<td  width="25%"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Yield") %></b></td>
				<td  width="75%">
<%
				String sActYield = mYield.get(RDMServicesConstants.DAILY_YIELD);
				sActYield = (sActYield == null ? "" : sActYield);
				if(!"".equals(sActYield))
				{
					sActYield = df2.format(Double.parseDouble(sActYield));
				}

				if(RDMServicesConstants.ROLE_ADMIN.equals(u.getRole()))
				{
%>
					<input type="text" id="ActYield" name="ActYield" value="<%= sActYield %>">
<%
				}
				else
				{
%>
					<%= sActYield %>
					<input type="hidden" id="ActYield" name="ActYield" value="<%= sActYield %>">
<%
				}
%>
				</td>
			</tr>
<%
		}
%>
			<tr>
				<td  width="25%"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Comments") %></b></td>
				<td  width="75%">
					<textarea id="comments" name="comments" rows="5" cols="25"></textarea>
				</td>
			</tr>
			<tr>
				<td colspan="2">
					&nbsp;
				</td>
			</tr>
			<tr>
				<td colspan="2" align="right">
					<input type="button" class="btn btn-primary" name="Save" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Save") %>" onClick="submitForm()">&nbsp;&nbsp;&nbsp;
					<input type="button" class="btn btn-primary" name="Cancel" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Cancel") %>" onClick="javascript:top.window.close()">
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
	</div>
</body>
</html>
