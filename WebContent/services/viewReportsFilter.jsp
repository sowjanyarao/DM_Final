<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>
<%@page import="com.client.reports.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<!DOCTYPE html>
<!--[if IE 9]>         <html class="no-js lt-ie10" lang="en"> <![endif]-->
<!--[if gt IE 9]><!-->
<html class="no-js" lang="en">
<!--<![endif]-->

<head>
    <meta charset="utf-8">

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
    <script language="javascript">	
		function submitAction()
		{
			var selAction = "";
			var actions = document.getElementsByName('selAction');
			for(i=0; i<actions.length; i++)
			{
				if(actions[i].checked == true)
				{
					selAction = actions[i].value;
				}
			}			
			
			if(document.getElementById('report').value == "")
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Select_Report") %>");
				return false;
			}
			
			if(selAction == "")
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Invalid_Action") %>");
				return false;
			}
			else
			{
				if(selAction == "addRecord")
				{
					document.frm.target = "content";
					document.frm.submit();
				}
				else if(selAction == "addMultiRecords")
				{
					addMultiRecords();
				}
				else if(selAction == "downloadTemplate")
				{
					downloadTemplate();
				}
			}
		}
		
		function search()
		{		
			var selAction = "";
			var actions = document.getElementsByName('selAction');
			for(i=0; i<actions.length; i++)
			{
				if(actions[i].checked == true)
				{
					selAction = actions[i].value;
				}
			}
			
			if(document.getElementById('report').value != "" && (selAction == "getRecords" || selAction == "viewRecord" || selAction == "updateRecord"))
			{						
				var report = document.getElementById('report').value;
				var reportTemplate = report.split("|");
				
				if(selAction == "getRecords")
				{
					var access = document.getElementById(reportTemplate[0]+"_Download").value;
					if(access == "false")
					{
						resetSearch();
						alert("<%= resourceBundle.getProperty("DataManager.DisplayText.No_Download_Record_Access") %>");
						return;
					}
				}
				else if(selAction == "updateRecord")
				{					
					var access = document.getElementById(reportTemplate[0]+"_Update").value;
					if(access == "false")
					{
						resetSearch();
						alert("<%= resourceBundle.getProperty("DataManager.DisplayText.No_Update_Record_Access") %>");
						return;
					}					
				}
			
				parent.frames['search'].document.location.href = "viewReportSearchCriteria.jsp?report="+reportTemplate[0]+"&template="+reportTemplate[1]+"&action="+selAction;			
			}
		}
		
		function resetSearch()
		{			
			parent.frames['search'].document.location.href = "blank.jsp";
		}
		
		function downloadTemplate(report, template) 
		{
			var report = document.getElementById('report').value;
			var reportTemplate = report.split("|");
			
			var url = "../ExportReport";
			url += "?report="+reportTemplate[0];
			url += "&template="+reportTemplate[1];

			document.location.href =  url;
		}
		
		function addMultiRecords()
		{			
			var records = document.getElementById("records");
			if(records.value == "")
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Select_Upload_Records") %>");
				records.focus();
				return;
			}
			
			document.frm.target = "content";
			document.frm.submit();
		}
	</script>
</head>
<%
	Map<String, String> mReport = null;
	String sReport = "";
	String sTemplate = "";
	String sDescription = "";
	String sRole = u.getRole();	
	String sReadAccess = null;
	String sReadDept = null;
	String sModifyAccess = null;
	String sModifyDept = null;
	
	StringList slDept = new StringList();
	slDept.add(u.getDepartment());
	slDept.addAll(u.getSecondaryDepartments());
	
	Map<String, String> mDownloadAccess = new HashMap<String, String>();
	Map<String, String> mUpdateAccess = new HashMap<String, String>();

	ReportDAO reportDAO = new ReportDAO();
	MapList mlReports = reportDAO.getReports(u.getUser());
%>
<body>
<form name="frm" method="post" target="content" action="addPreReportRecords.jsp" enctype="multipart/form-data">
    <div id="page-wrapper" class="page-loading">
        <div class="preloader">
            <div class="inner">
                <!-- Animation spinner for all modern browsers -->
                <div class="preloader-spinner themed-background hidden-lt-ie10"></div>

                <!-- Text for IE9 -->
                <h3 class="text-primary visible-lt-ie10"><strong>Loading..</strong></h3>
            </div>
        </div>
        <div id="page-container" class="header-fixed-top sidebar-visible-lg-full">
           

            <!-- Main Container -->
            <div id="main-container">
              
                <div id="page-content">
                    <div class="block">
                        <!-- General Elements Title -->
                        <div class="block-title">

                            <h2>Reports</h2>
                        </div>
                        <!-- END General Elements Title -->

							<table align="center" border="0" cellpadding="1" cellspacing="1"
								width="100%">
								<tr>
									<td class="input"><%= resourceBundle.getProperty("DataManager.DisplayText.Report") %></td>
									<td><select id="report" name="report" style="width: 250px"
										onChange="javascript:search()">
											<option value=""><%= resourceBundle.getProperty("DataManager.DisplayText.Please_Select") %></option>
											<%
						for(int i=0; i<mlReports.size(); i++)
						{
							mReport = mlReports.get(i);
							sReport = mReport.get(RDMServicesConstants.REPORT);
							sTemplate = mReport.get(RDMServicesConstants.TEMPLATE);
							
							sReadAccess = mReport.get(RDMServicesConstants.READ_ACCESS);
							sReadDept = mReport.get(RDMServicesConstants.READ_DEPT);
							sModifyAccess = mReport.get(RDMServicesConstants.MODIFY_ACCESS);
							sModifyDept = mReport.get(RDMServicesConstants.MODIFY_DEPT);
							
							mDownloadAccess.put(sReport, (((sReadAccess.contains(sRole) && (slDept.isEmpty() || slDept.contains(StringList.split(sReadDept, "\\|")))) || RDMServicesConstants.ROLE_ADMIN.equals(sRole)) ? "true" : "false"));
							mUpdateAccess.put(sReport, (((sModifyAccess.contains(sRole) && (slDept.isEmpty() || slDept.contains(StringList.split(sModifyDept, "\\|")))) || RDMServicesConstants.ROLE_ADMIN.equals(sRole)) ? "true" : "false"));
%>
											<option value="<%= sReport %>|<%= sTemplate %>"><%= sReport %></option>
											<%
						}
%>
									</select></td>
								</tr>
								<tr>
									<td class="input" width="40%"><%= resourceBundle.getProperty("DataManager.DisplayText.Action") %></td>
									<td class="text" width="60%">
										<%
				if(!RDMServicesConstants.ROLE_ADMIN.equals(sRole))
				{
%> <input type="radio" id="selAction" name="selAction" value="addRecord"
										onClick="javascript:resetSearch()"><%= resourceBundle.getProperty("DataManager.DisplayText.Add_Record") %><br>
										<%
					if(RDMServicesConstants.ROLE_MANAGER.equals(sRole) || RDMServicesConstants.ROLE_SUPERVISOR.equals(sRole))
					{
%> <input type="radio" id="selAction" name="selAction"
										value="addMultiRecords" onClick="javascript:resetSearch()"><%= resourceBundle.getProperty("DataManager.DisplayText.Add_Multi_Records") %><br>
										<%
					}
				}
%> <input type="radio" id="selAction" name="selAction"
										value="viewRecord" onClick="javascript:search()"><%= resourceBundle.getProperty("DataManager.DisplayText.View_Record") %><br>

										<input type="radio" id="selAction" name="selAction"
										value="updateRecord" onClick="javascript:search()"><%= resourceBundle.getProperty("DataManager.DisplayText.Update_Record") %><br>

										<input type="radio" id="selAction" name="selAction"
										value="getRecords" onClick="javascript:search()"><%= resourceBundle.getProperty("DataManager.DisplayText.Download_Records") %>
										<%
				if(!RDMServicesConstants.ROLE_HELPER.equals(sRole))
				{
%> <br> <input type="radio" id="selAction" name="selAction"
										value="downloadTemplate" onClick="javascript:resetSearch()"><%= resourceBundle.getProperty("DataManager.DisplayText.Download_Template") %>
										<%
				}
%>
									</td>
								</tr>
								<%
			if(RDMServicesConstants.ROLE_MANAGER.equals(sRole) || RDMServicesConstants.ROLE_SUPERVISOR.equals(sRole))
			{
%>
								<tr>
									<td class="label" colspan="2"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Add_Multi_Records") %></b></td>
								</tr>
								<tr>
									<td class="input"><%= resourceBundle.getProperty("DataManager.DisplayText.Upload_Records") %></td>
									<td><input type="file" id="records" name="records"
										accept="application/vnd.ms-excel"></td>
								</tr>
								<tr>
									<td colspan="2" class="input"><b>Date Format:</b>
										dd-MMM-yyyy hh:mm a<br> e.g., 14-Oct-2008 10:30 AM</td>
								</tr>
								<%
			}
%>
								<tr>
									<td align="left" colspan="2"><input type="button"
										name="btn" class="btn btn-primary"
										value="<%= resourceBundle.getProperty("DataManager.DisplayText.Submit") %>"
										onClick="javascript:submitAction()"></td>
								</tr>
							</table>
							<%
		Iterator<String> itr = mDownloadAccess.keySet().iterator();
		while(itr.hasNext())
		{
			sReport = itr.next();
			sReadAccess = mDownloadAccess.get(sReport);
%>
							<input type="hidden" id="<%= sReport %>_Download"
								name="<%= sReport %>_Download" value="<%= sReadAccess %>">
							<%
		}
		
		itr = mUpdateAccess.keySet().iterator();
		while(itr.hasNext())
		{
			sReport = itr.next();
			sModifyAccess = mUpdateAccess.get(sReport);
%>
							<input type="hidden" id="<%= sReport %>_Update"
								name="<%= sReport %>_Update" value="<%= sModifyAccess %>">
							<%
		}
%>
							<!-- END General Elements Content -->
                    </div>
                </div>

                <!-- END Page Content -->
            </div>
            <!-- END Main Container -->
        </div>
        <!-- END Page Container -->
    </div>
    <!-- END Page Wrapper -->
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
    <!-- jQuery, Bootstrap, jQuery plugins and Custom JS code -->
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
    
</body>

</html>
