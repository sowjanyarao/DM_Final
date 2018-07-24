<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.db.*" %>
<%@page import="com.client.util.*" %>
<%@page import="com.client.reports.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
	<title></title>
	<link type="text/css" href="../styles/dygraph.css" rel="stylesheet" />
	<link type="text/css" href="../styles/calendar.css" rel="stylesheet" />
	<link type="text/css" href="../styles/bootstrap.min.css" rel="stylesheet" />
	<link type="text/css" href="../styles/select2.min.css" rel="stylesheet" />
	
	<script language="javaScript" type="text/javascript" src="../scripts/jquery.min.js"></script>
	<script language="javaScript" type="text/javascript" src="../scripts/select2.full.js"></script>
	<script language="javaScript" type="text/javascript" src="../scripts/bootstrap.min.js"></script>
	
	<style type="text/css">		
		th.txtLabel
		{
			border: solid 1px #ffffff;
			text-align: center;
			background-color: #888888;
			color: #ffffff;
			font-size:14px;
			font-family:Arial,sans-serif;
			font-weight:bold;
		}
		td.txtLabel
		{
			border: solid 1px #ffffff;
			text-align: left;
			background-color: #888888;
			color: #ffffff;
			font-size:12px;
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
			document.frm.submit();
		}
		
		function getWeights(sColumn, scaleIP, port)
		{
			frames['hidden'].document.location.href = "readWeighingScale.jsp?scaleIP="+scaleIP+"&port="+port+"&attrName="+sColumn;
			
			document.getElementById(sColumn+'_weights').style.display = "none";
			document.getElementById(sColumn+'_loading').style.display = "block";
		}
		
		function toggleDateTime(column)
		{
			var col_dt = document.getElementById(column.name+'_dt');
			var col_hr = document.getElementById(column.name+'_hr');
			var col_min = document.getElementById(column.name+'_min');
			
			if(column.checked)
			{
				col_dt.value = "";
				col_hr.selectedIndex = 0;
				col_min.selectedIndex = 0;
				
				col_dt.disabled = true;
				col_hr.disabled = true;
				col_min.disabled = true;
			}
			else
			{
				col_dt.disabled = false;				
				col_hr.disabled = false;				
				col_min.disabled = false;
			}
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
	String sAction = request.getParameter("action");
	String sColumn = "";
	String sName = "";
	String sFormula = "";
	String sUser = "";
	String[] sRanges = null;
	
	ReportDAO reportDAO = new ReportDAO();
	Map<String, String> mReportColumns = reportDAO.getReportColumnHeaders(sReport);
	Map<String, String> mReportFormulae = reportDAO.getReportColumnFormulae(sReport);
	Map<String, String[]> mReportRanges = reportDAO.getReportColumnRanges(sReport);
	StringList slReadOnlyCols = reportDAO.getReadOnlyColumns(sReport);
	StringList slColumns = reportDAO.getReportColumns(sReport);

	Map<String, String> mUsers = RDMServicesUtils.getUserNames(false);
	List<String> lKeys = new ArrayList<String>(mUsers.keySet());
	Collections.sort(lKeys, String.CASE_INSENSITIVE_ORDER);
	
	Map <String, String> mDepartments = RDMServicesUtils.getDepartments();
	List<String> lDepartments = new ArrayList<String>(mDepartments.keySet());
	Collections.sort(lDepartments, String.CASE_INSENSITIVE_ORDER);
	
	String[] HOUR = new String[] {"00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", 
									"12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"};
	String[] MIN = new String[] {"00", "05", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"};
%>

<body>
	<form name="frm" method="post" action="addReportRecords.jsp" enctype="multipart/form-data">
		<input type="hidden" id="report" name="report" value="<%= sReport %>">
		<input type="hidden" id="action" name="action" value="<%= sAction %>">
		<table class="table table-responsive table-hover table table-striped table-bordered table-vcenter">
			<tr>
				<th><%= resourceBundle.getProperty("DataManager.DisplayText.Name") %></th>
				<th><%= resourceBundle.getProperty("DataManager.DisplayText.Value") %></th>
			</tr>
<%
		for(int i=1; i<slColumns.size(); i++)
		{
			sColumn = slColumns.get(i);
			sName = mReportColumns.get(sColumn);
			sFormula = mReportFormulae.get(sColumn);
			sRanges = mReportRanges.get(sColumn);

			if(sName.equals(RDMServicesConstants.LOGGEDBY) || sName.equals(RDMServicesConstants.MODIFIEDBY) 
				|| sName.equals(RDMServicesConstants.MODIFIEDON) || sName.equals(RDMServicesConstants.IS_UPDATED))
			{
				continue;
			}
%>
			<tr><td>&nbsp;<%= sName %></td>
<%
			if(sName.equals(RDMServicesConstants.REMARKS))
			{
%>
				<td class="input">
					<textarea id="<%= sColumn %>" name="<%= sColumn %>" cols="30" rows="3"></textarea>
				</td>
<%
			}
			else
			{
				if(sFormula != null && !"".equals(sFormula))
				{
%>
					<td class="input">
						<font><%= ReportDAO.convertFormulaExpr(sReport, sFormula) %></font>
					</td>
<%
				}
				else if(sRanges != null)
				{
					if(sRanges[0].equals("#DATETIME"))
					{
						if(slReadOnlyCols.contains(sColumn))
						{
%>
							<td class="input">
								<input type="checkbox" id="<%= sColumn %>" name="<%= sColumn %>" value="SystemDateTime">System Date & Time
							</td>
<%
						}
						else
						{
%>
							<td id="<%= sColumn %>_pos" class="input">
								<input type="checkbox" id="<%= sColumn %>" name="<%= sColumn %>" value="SystemDateTime" onChange="javascript:toggleDateTime(this, '<%= sColumn %>')">System Date & Time<br>
								<input type="text" id="<%= sColumn %>_dt" name="<%= sColumn %>_dt" class="form-control input-datepicker" data-date-format="dd-mm-yyyy" placeholder="dd-mm-yyyy">
								&nbsp;HH:&nbsp;
								<select id="<%= sColumn %>_hr" name="<%= sColumn %>_hr">
<%					
								for(int x=0; x<HOUR.length; x++)
								{
%>
									<option value="<%= HOUR[x] %>"><%= HOUR[x] %></option>
<%
								}
%>
								</select>
								&nbsp;MM:&nbsp;
								<select id="<%= sColumn %>_min" name="<%= sColumn %>_min">
<%
								for(int x=0; x<MIN.length; x++)
								{
%>
									<option value="<%= MIN[x] %>"><%= MIN[x] %></option>
<%
								}
%>
								</select>
							</td>
<%
						}
					}
					else if(sRanges[0].equals("#LOGGEDUSER"))
					{
%>
						<td class="input">
							<%= mUsers.get(u.getUser()) %>
							<input type="hidden" id="<%= sColumn %>" name="<%= sColumn %>" value="<%= u.getUser() %>">
						</td>
<%
					}
					else if(sRanges[0].equals("#READWEIGHT"))
					{
						String[] saScale = sRanges[1].split(":"); 
%>
						<td class="input">
							<input type="text" id="<%= sColumn %>" name="<%= sColumn %>" value="" size="12" readonly>

							<div id="<%= sColumn %>_weights">
								<a href="javascript:getWeights('<%= sColumn %>', '<%= saScale[0] %>', '<%= saScale[1] %>')"><img src="../images/readWeights.jpg" border="0"></a>
							</div>
							<div id="<%= sColumn %>_loading" style="display:none">
								<img src="../images/loading_icon.gif" border="0">
							</div>
						</td>
<%
					}
					else if(sRanges[0].equals("#SYSTEMUSERS"))
					{
%>
						<td class="input">
							<select id="<%= sColumn %>" name="<%= sColumn %>" style="width:250px" class="js-example-basic-multiple" onChange="javascript:toggleRanges('<%= sColumn %>_Manual', 'text')">
								<option value=""><%= resourceBundle.getProperty("DataManager.DisplayText.Please_Select") %></option>
<%
							for(int x=0; x<lKeys.size(); x++)
							{
								sUser = lKeys.get(x);
%>								
								<option value="<%= sUser %>"><%= mUsers.get(sUser) %> (<%= sUser %>)</option>
<%
							}
%>
							</select>

							<input type="text" id="<%= sColumn %>_Manual" name="<%= sColumn %>_Manual" value="" onKeyPress="javascript:toggleRanges('<%= sColumn %>', 'select')">
						</td>
<%
					}
					else if(sRanges[0].equals("#DEPARTMENTS"))
					{
%>
						<td class="input">
							<select id="<%= sColumn %>" name="<%= sColumn %>">
								<option value=""><%= resourceBundle.getProperty("DataManager.DisplayText.Please_Select") %></option>
<%							
							String sDept = "";
							for(int x=0; x<lDepartments.size(); x++)
							{
								sDept = lDepartments.get(x);
%>
								<option value="<%= sDept %>"><%= sDept %></option>
<%
							}
%>
							</select>
						</td>
<%
					}
					else if(sRanges[0].equals("#AUTONAME"))
					{
						SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyyMMdd-HHmm", Locale.getDefault());
						String sAutoname = sdf.format(Calendar.getInstance().getTime());
		
						if(sRanges.length > 1 && !"".equals(sRanges[1]))
						{
							sAutoname = sRanges[1] + "-" + sAutoname;
						}
%>
						<td class="input">
							<%= sAutoname %>
							<input type="hidden" id="<%= sColumn %>" name="<%= sColumn %>" value="<%= sAutoname %>">
						</td>
<%
					}
					else if(sRanges[0].equals("#FILEUPLOAD"))
					{
%>
						<td class="input">
							<input type="file" id="<%= sColumn %>" name="<%= sColumn %>">
						</td>
<%
					}
					else
					{
%>
						<td class="input">
							<select id="<%= sColumn %>" name="<%= sColumn %>" onChange="javascript:toggleRanges('<%= sColumn %>_Manual', 'text')">
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
								<input type="text" id="<%= sColumn %>_Manual" name="<%= sColumn %>_Manual" value="" onKeyPress="javascript:toggleRanges('<%= sColumn %>', 'select')">
<%
							}
%>
						</td>
<%
					}
				}
				else
				{
%>
					<td class="input"><input type="text" id="<%= sColumn %>" name="<%= sColumn %>" value=""></td>
<%
				}
			}
%>
			</tr>
<%
		}
%>
			<tr>
				<td colspan="2" align="center">
					<input type="button" class="btn btn-primary" name="btn" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Submit") %>" onClick="javascript:submitAction()">
				</td>
			</tr>
		</table>
	</form>
	
	
	<iframe name="hidden" src="" frameBorder="0" width="0px" height="0px">
</body>
</html>