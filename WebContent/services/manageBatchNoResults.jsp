<%@page contentType="text/html;charset=UTF-8"%>
<%
	request.setCharacterEncoding("UTF-8");
%>
<%@page import="java.util.*"%>
<%@page import="com.client.*"%>
<%@page import="com.client.util.*"%>

<jsp:useBean id="RDMSession" scope="session"
	class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp"%>

<!DOCTYPE html>
<html class="no-js" lang="en">
<head>
<meta charset="utf-8">
<title>Inventaa</title>
<meta name="description" content="Inventaa">
<meta name="author" content="pixelcave">
<meta name="robots" content="noindex, nofollow">
<meta name="viewport"
	content="width=device-width,initial-scale=1.0,user-scalable=0">

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
		
	function updateBNo(roomId, mode)
	{
		var batchNo = document.getElementById(roomId+'_BNO'); 
		batchNo.value = batchNo.value.trim();
		if(batchNo.value == "")
		{
			alert("<%=resourceBundle.getProperty("DataManager.DisplayText.Enter_Batch_No")%>");
			batchNo.focus();
		} else {
			parent.parent.frames['hiddenFrame'].document.location.href = "manageBNoProcess.jsp?roomId="
					+ roomId + "&BNo=" + batchNo.value + "&mode=" + mode;
		}
	}
</script>
</head>

<body>

	<form name="frm">

		<%
			boolean isInactive = false;
			boolean bActions = true;
			String roomId = null;
			String cntrlType = null;
			String batchNo = null;
			String startDt = null;
			String endDt = null;
			String sHeader = null;
			StringList slHeaders = new StringList();
			StringList slInactiveControllers = RDMSession.getInactiveControllers();
			Map<String, String> mBatchNo = null;
			MapList mlBatchNos = null;
			String sMonth = request.getParameter("Month");
			sMonth = (sMonth == null ? "" : sMonth);
			String sYear = request.getParameter("Year");
			sYear = (sYear == null ? "" : sYear);
			String sCntrlType = request.getParameter("CntrlType");
			sCntrlType = (sCntrlType == null ? "" : sCntrlType);
			String sDefParamType = request.getParameter("defParamType");
			sDefParamType = (sDefParamType == null ? "" : sDefParamType);
			if (!"".equals(sMonth) && !"".equals(sYear)) {
				bActions = false;
				mlBatchNos = RDMServicesUtils.getBatchNos(sMonth, sYear, sCntrlType, sDefParamType);
			} else {
				mlBatchNos = RDMServicesUtils.getBatchNos(sCntrlType, sDefParamType);
			}
			for (int i = 0; i < mlBatchNos.size(); i++) {
			
				mBatchNo = mlBatchNos.get(i);
				roomId = mBatchNo.get(RDMServicesConstants.ROOM_ID);
				if (RDMServicesUtils.isGeneralController(roomId)) {
					continue;
				}
				batchNo = mBatchNo.get(RDMServicesConstants.BATCH_NO);
				batchNo = (batchNo.startsWith("auto_") ? "" : batchNo);
				startDt = mBatchNo.get(RDMServicesConstants.START_DT);
				endDt = mBatchNo.get(RDMServicesConstants.END_DT);
				cntrlType = mBatchNo.get(RDMServicesConstants.CNTRL_TYPE);
				sHeader = cntrlType;
				if (!slHeaders.contains(sHeader)) {
					slHeaders.add(sHeader);
					if (i != 0) {
		%>
							</tbody>
						</table>
					</div>

		<%
			}
		%>
		<div>
					<h4 class="panel-title">
						
							<%=resourceBundle.getProperty("DataManager.DisplayText." + sHeader)%>
						
					</h4>
				</div>
				<div>
						<table id="example-datatable"
							class="table table-striped table-bordered table-vcenter  ">
							<thead>
								<tr>
									<th class="label" width="20%"><%=resourceBundle.getProperty("DataManager.DisplayText.Room_Name")%></th>
									<th class="label" width="20%"><%=resourceBundle.getProperty("DataManager.DisplayText.Product")%></th>
									<th class="label" width="15%"><%=resourceBundle.getProperty("DataManager.DisplayText.Batch_No")%></th>
									<th class="label" width="17%"><%=resourceBundle.getProperty("DataManager.DisplayText.From_Date")%></th>
									<th class="label" width="17%"><%=resourceBundle.getProperty("DataManager.DisplayText.To_Date")%></th>
									<th class="label" width="15%"><%=resourceBundle.getProperty("DataManager.DisplayText.Actions")%></th>

								</tr>
							</thead>
							<tbody>
								<%
									}
								%>
								<tr>

									<td><%=roomId%></td>
									<td><%=mBatchNo.get(RDMServicesConstants.DEF_VAL_TYPE)%></td>
									<td>
										<%
											if (bActions) {
										%> <input type="text" id="<%=roomId%>_BNO"
										name="<%=roomId%>_BNO" class="form-control"
										value="<%=batchNo%>" maxlength="10"> <%
											} else {
										%> <%=batchNo%> <%
										}
										%>
									</td>
									<td><%=startDt%></td>
									<td><%=endDt%></td>
									<td class="text-center">
										<%
											if (bActions) {
													if ("".equals(batchNo)) {
														if (slInactiveControllers.contains(roomId)) {
										%> <a href="javascript:updateBNo('<%=roomId%>', 'add')"><img
											border="0" src="../images/unblocked.png" height="20"
											alt="<%=resourceBundle.getProperty("DataManager.DisplayText.Add")%>"></a>
										<%
											}
													} else {
										%> <a href="javascript:updateBNo('<%=roomId%>', 'edit')"
										data-toggle="tooltip" title="Edit User"
										class="btn btn-effect-ripple btn-xs btn-success"><i
											class="fa fa-pencil"></i></a> <%
 	if (slInactiveControllers.contains(roomId)) {
 %> <a href="javascript:updateBNo('<%=roomId%>', 'close')"
										data-toggle="tooltip" title="Delete User"
										class="btn btn-effect-ripple btn-xs btn-danger"><i
											class="fa fa-times"></i></a> <%
 	}
 			}
 		} else {
 %> &nbsp; <%
 	}
 %>
									</td>
								</tr>
								<% if(i==(mlBatchNos.size()-1)){
	
		%>
							</tbody>
						</table>
					</div>
				

		<% } 
			}
		%>

	</form>

</body>
</html>