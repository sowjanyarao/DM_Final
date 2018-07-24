<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>
<%@page import="com.client.reports.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
	<meta charset="utf-8"/>

    <title>Inventaa</title>

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
    <script src="../js/vendor/modernizr-3.3.1.min.js"></script>
  
	<script language="javaScript" type="text/javascript" src="../scripts/calendar.js"></script>
	<script src="../js/vendor/jquery-2.2.4.min.js"></script>
    <script src="../js/vendor/bootstrap.min.js"></script>
    <script src="../js/plugins.js"></script>
    <script src="../js/app.js"></script>
    <!-- Load and execute javascript code used only in this page -->
    <script src="../js/pages/readyDashboard.js"></script>
    <script>
        $(function() {
            ReadyDashboard.init();
        });

    </script>
	
	<style type="text/css">		
		th.txtLabel
		{
			border: solid 1px #ffffff;
			text-align: left;
			background-color: #888888;
			color: #ffffff;
			font-size:14px;
			font-family:Arial,sans-serif;
			font-weight:bold;
		}
	</style>

	<script type="text/javascript">
		//<![CDATA[
		$(document).ready(function(){
			$(".js-example-basic-multiple").select2();
		});
		//]]>
	</script>
	
	<script language="javascript">	
		function submitAction()
		{
			if(document.getElementById('Column1_From').value == "")
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Select_From_date") %>");
				return false;
			}
			else if(document.getElementById('Column1_To').value == "")
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Select_To_date") %>");
				return false;
			}
			else
			{
				var startDt = document.getElementById("Column1_From").value;
				var dt1  = parseInt(startDt.substring(0,2),10); 
				var mon1 = parseInt(startDt.substring(3,5),10);
				var yr1  = parseInt(startDt.substring(6,10),10); 
				mon1 = mon1 - 1;
				var date1 = new Date(yr1, mon1, dt1);
				
				var endDt = document.getElementById("Column1_To").value;
				var dt2  = parseInt(endDt.substring(0,2),10); 
				var mon2 = parseInt(endDt.substring(3,5),10); 
				var yr2  = parseInt(endDt.substring(6,10),10); 
				mon2 = mon2 - 1;
				var date2 = new Date(yr2, mon2, dt2); 
				
				if (date1 > date2)
				{
					alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Start_date_Invalid") %>");
					return false;
				}
			}
			
			var actions = parent.frames['filter'].document.getElementsByName('selAction');
			for(i=0; i<actions.length; i++)
			{
				if(actions[i].checked == true)
				{
					document.getElementById("action").value = actions[i].value;
				}
			}
			
			if(document.getElementById("action").value == "updateRecord")
			{
				document.frm.action = "updateRecord.jsp";
			}
			else if(document.getElementById("action").value == "getRecords")
			{
				document.frm.action = "../ExportReport";
			}
			else
			{
				document.frm.action = "viewRecord.jsp";
			}

			document.frm.submit();
		}
		
		function toggleRanges(column, type)
		{
			if(type == "text")
			{
				document.getElementById(column).value = "";
			}
			else if(type == "select")
			{
				document.getElementById(column).selectedIndex = 0;
			}
		}
	</script>
</head>

<%
	String sReport = request.getParameter("report");
	String sTemplate = request.getParameter("template");
	String sAction = request.getParameter("action");
	
	ReportDAO reportDAO = new ReportDAO();
	Map<String, String> mReportColumns = reportDAO.getReportColumnHeaders(sReport);
	Map<String, String[]> mReportRanges = reportDAO.getReportColumnRanges(sReport);
	StringList slColumns = reportDAO.getReportSearchColumns(sReport);
	
	Map<String, String> mUsers = RDMServicesUtils.getUserNames(false);
	List<String> lKeys = new ArrayList<String>(mUsers.keySet());
	Collections.sort(lKeys, String.CASE_INSENSITIVE_ORDER);
	
	Map <String, String> mDepartments = RDMServicesUtils.getDepartments();
	List<String> lDepartments = new ArrayList<String>(mDepartments.keySet());
	Collections.sort(lDepartments, String.CASE_INSENSITIVE_ORDER);
	
	session.removeAttribute("RecordTimestamps");
%>

<body>
	<form name="frm" method="post" target="content">
		<input type="hidden" id="report" name="report" value="<%= sReport %>"/>
		<input type="hidden" id="template" name="template" value="<%= sTemplate %>"/>		
		<input type="hidden" id="action" name="action" value="<%= sAction %>"/>
		<input type="hidden" id="mode" name="mode" value="search"/>
		<div id="page-container" class="header-fixed-top sidebar-visible-lg-full">
            <!-- Main Container -->
            <div id="main-container">
              
                <div id="page-content">
                    <div class="block">
                        <!-- General Elements Title -->
                        <div class="block-title">

                            <h2><%= resourceBundle.getProperty("DataManager.DisplayText.Search_Records") %></h2>
                        </div>
                        <!-- END General Elements Title -->
		
		<table align="center" border="0" cellpadding="2" cellspacing="2" >
<%
		if(!slColumns.contains("Column1"))
		{
			slColumns.add(0, "Column1");
		}
		
		String sColumn = "";
		String sUser = "";
		String[] sRanges = null;
		for(int i=0; i<slColumns.size(); i++)
		{
			sColumn = slColumns.get(i);
			sRanges = mReportRanges.get(sColumn);
			
			if("Column1".equals(sColumn))
			{
				sRanges = new String[] {"#DATETIME"};
			}
			
			if(i == 0)
			{
%>
				
<%
			}
%>
			<tr>
				<td id="<%= sColumn %>_pos" class="input"><b><%= "Column1".equals(sColumn) ? "Logged On" : mReportColumns.get(sColumn) %></b></td>
				<td class="text" style="border: solid 1px #ffffff">
<%
				if(sRanges != null)
				{
					if(sRanges[0].equals("#DATETIME"))
					{
%>
						From:&nbsp;<input type="text" size="10" id="<%= sColumn %>_From" name="<%= sColumn %>_From" value="" readonly/>
						<a href="#" onclick="setYears(2000, 2025);showCalender('<%= sColumn %>_pos', '<%= sColumn %>_From');"><img src="../images/calender.png"></a>
						<a href="#" onclick="javascript:document.getElementById('<%= sColumn %>_From').value=''"><img src="../images/clear.png"></a>
						<br>
						To:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" size="10" id="<%= sColumn %>_To" name="<%= sColumn %>_To" value="" readonly>
						<a href="#" onclick="setYears(2000, 2025);showCalender('<%= sColumn %>_pos', '<%= sColumn %>_To');"><img src="../images/calender.png"></a>
						<a href="#" onclick="javascript:document.getElementById('<%= sColumn %>_To').value=''"><img src="../images/clear.png"></a>
<%
					}
					else if(sRanges[0].equals("#LOGGEDUSER") || sRanges[0].equals("#SYSTEMUSERS"))
					{
						if(sRanges[0].equals("#SYSTEMUSERS"))
						{
%>
							<select id="<%= sColumn %>" name="<%= sColumn %>" onchange="javascript:toggleRanges('<%= sColumn %>_Manual', 'text')" style="width:250px" class="js-example-basic-multiple">
								<option value=""><%= resourceBundle.getProperty("DataManager.DisplayText.Please_Select") %></option>
<%
						}
						else
						{
%>
							<select id="<%= sColumn %>" name="<%= sColumn %>" style="width:250px" class="js-example-basic-multiple">
								<option value=""><%= resourceBundle.getProperty("DataManager.DisplayText.Please_Select") %></option>
<%
						}

						for(int x=0; x<lKeys.size(); x++)
						{
							sUser = lKeys.get(x);
%>								
							<option value="<%= sUser %>"><%= mUsers.get(sUser) %> (<%= sUser %>)</option>
<%
						}
%>
						</select>
<%
						if(sRanges[0].equals("#SYSTEMUSERS"))
						{
%>
							<br><input type="text" id="<%= sColumn %>_Manual" name="<%= sColumn %>_Manual" value="" onkeypress="javascript:toggleRanges('<%= sColumn %>', 'select')"/>
<%
						}
					}
					else if(sRanges[0].equals("#DEPARTMENTS"))
					{
%>
						<select id="<%= sColumn %>" name="<%= sColumn %>">
							<option value=""><%= resourceBundle.getProperty("DataManager.DisplayText.Please_Select") %></option>
<%
						String sDept = "";
						for(int x=0; x<lDepartments.size(); x++)
						{
							sDept = lDepartments.get(x);
%>
							<option  value="<%= sDept %>"><%= sDept %></option>
<%
						}
%>
						</select>
<%
					}
					else if(sRanges[0].equals("#AUTONAME"))
					{
%>
						<input type="text" id="<%= sColumn %>" name="<%= sColumn %>" value=""/>
<%
					}
					else
					{
%>
						<select id="<%= sColumn %>" name="<%= sColumn %>" onchange="javascript:toggleRanges('<%= sColumn %>_Manual', 'text')">
							<option value=""><%= resourceBundle.getProperty("DataManager.DisplayText.Please_Select") %></option>
<%
						boolean bManual = false;
						for(int k=0; k<sRanges.length; k++)
						{
							if("#Manual".equalsIgnoreCase(sRanges[k]))
							{
								bManual = true;
							}
							else
							{
%>								
								<option value="<%= sRanges[k] %>"><%= sRanges[k] %></option>
<%
							}
						}
%>
						</select>
<%
						if(bManual)
						{
%>
							<input type="text" id="<%= sColumn %>_Manual" name="<%= sColumn %>_Manual" value="" onkeypress="javascript:toggleRanges('<%= sColumn %>', 'select')" />
<%
						}
					}
				}
				else
				{
%>
					<input type="text" id="<%= sColumn %>" name="<%= sColumn %>" value=""/>
<%
				}
%>
				</td>
			</tr>
<%
		}
%>
			<tr>
				<td colspan="2" class="input"><b>You can specify '=' (equals), '!' (not equals), '>' (greater than), </b></td>
			</tr>
			<tr>
				<td colspan="2" class="input"><b>'<' (lesser than), '~' (in between e.g., 2~5) in the search criteria.</b></td>
			</tr>

			<tr>
				<td class="pad_bot" colspan="2" align="left">
					<input type="button" class="btn btn-primary" name="btn" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Search") %>" onclick="javascript:submitAction()"/>
				</td>
			</tr>
		</table>
			<!-- END General Elements Content -->
                    </div>
                </div>

                <!-- END Page Content -->
            </div>
            <!-- END Main Container -->
        </div>
      
	</form>
	<table id="calenderTable">
		<tbody id="calenderTableHead">
			<tr>
				<td colspan="4" align="center">
					<select class="form-control" onchange="showCalenderBody(createCalender(document.getElementById('selectYear').value, this.selectedIndex, false));" id="selectMonth">
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
					<select class="form-control" onchange="showCalenderBody(createCalender(this.value, document.getElementById('selectMonth').selectedIndex, false));" id="selectYear">
					</select>
				</td>
				<td align="center">
					<a href="#" onclick="closeCalender();"><font color="#003333" size="2">X</font></a>
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
