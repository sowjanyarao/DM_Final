<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.text.*" %>
<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>
<%@page import="com.client.db.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
	<title></title>

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

    <!-- Modernizr (browser feature detection library) -->
    <script src="../js/vendor/modernizr-3.3.1.min.js"></script>
    
     <!-- jQuery, Bootstrap, jQuery plugins and Custom JS code -->
    <script src="../js/vendor/jquery-2.2.4.min.js"></script>
    <script src="../js/vendor/bootstrap.min.js"></script>
    <script src="../js/plugins.js"></script>
    <script src="../js/app.js"></script>

    <!-- Load and execute javascript code used only in this page -->
    <script src="../js/pages/uiTables.js"></script>
    <script>
        $(function() {
            UiTables.init();
        });

    </script>
    <script>
        $('.collapse').collapse()
    </script>
	<style>
	#scrollDiv 
	{	
		margin: 2px 2px; 
		width: <%= winWidth * 0.95 %>px; 
		height: <%= winHeight * 0.80 %>px; 
		overflow: hidden; 
		font-size: 0.85em;
	}
	</style>
	
	<script language="javascript">
		function saveChanges()
		{
			document.forms[0].submit();
		}
		
		function resetChanges()
		{
			document.location.href = document.location.href;
		}
		
		function showAlarms()
		{
			var retval = window.open('showAlarms.jsp?controller=General', 'Alarms', 'left=250,top=250,resizable=no,scrollbars=no,status=no,toolbar=no,height=500,width=800');
		}
		
		function addComments()
		{
			var retval = window.open('addUserComments.jsp?controller=General', 'Comments', 'left=250,top=250,resizable=no,scrollbars=no,status=no,toolbar=no,height=375,width=525');
		}
		
		function setValue(pid, obj) 
		{
			var val = obj.value;
			var elm = document.getElementById(pid);
			elm.value = val;
		}
		
		function setOnOff(pid, obj)
		{
			var sel = obj.value;
			if(sel == "On" || sel == "1")
			{
				document.getElementById(pid).selectedIndex = 0;
				document.getElementById(pid).value = sel;
			}
			else if(sel == "Off" || sel == "0")
			{
				document.getElementById(pid).selectedIndex = 1;
				document.getElementById(pid).value = sel;
			}
		}
		
		function initOnOff()
		{
			var options = document.getElementsByTagName("SELECT"); 
			for(var i=0; i<options.length; i++) 
			{
				var id = options[i].id;
				setOnOff(id, options[i]);
			}
		}
		
		function changeController(obj)
		{
			var sCntrl = obj.value;
			if(sCntrl == "Bunker" || sCntrl == "Tunnel" || sCntrl == "Grower")
			{
				document.location.href = "defaultParamsView.jsp?controller="+sCntrl;
			}
			else
			{
				parent.document.location.href = "singleRoomView.jsp?controller="+sCntrl;
			}
		}
	</script>
</head>

<%

	boolean bShowSaveReset = false;
	String[] saParamVal = null;
	String sParam = null;
	String sValue = null;
	String sUnit = null;
	String sAccess = null;
	ParamSettings mParam = null;
	
	String sController = request.getParameter("controller");
	
	PLCServices client = new PLCServices(RDMSession, sController);
	String sCntrlType = client.getControllerType();
	
	Map<String, ParamSettings> mParamSettings = RDMServicesUtils.getGeneralViewParams(sCntrlType);
	ArrayList<String> displayOrder = RDMServicesUtils.getDisplayOrder(sCntrlType);

	Map<String, String[]> mParamData = client.getControllerData(true);
	
	boolean isAdmin = RDMServicesConstants.ROLE_ADMIN.equals(u.getRole());
	StringList slControllers = RDMSession.getControllers(u);
 
	String sDate = (mParamData.containsKey("Last Refresh") ? mParamData.get("Last Refresh")[0] : "");
	
	NumberFormat decimalFormat = NumberFormat.getInstance(Locale.getDefault());
	decimalFormat.setMinimumFractionDigits(1);
	
	StringList slOnOffValues = RDMServicesUtils.getOnOffParams(sCntrlType);
%>

<body onLoad="javascript:initOnOff()">
 <!-- Main Container -->
            <div id="main-container">
             <!-- Page content -->
                <div id="page-content" style="background-color:#FFFFFF">
                
                <div class="form-group">
                <div class="container pad_bot">
                
	<table border="0" cellpadding="0" cellspacing="0" width="95%">
		<tr>
			<td style="font-family:Arial; font-size:0.8em; font-weight:bold; border:#ffffff; text-align:left">
				<%= resourceBundle.getProperty("DataManager.DisplayText.Select_Room") %>:&nbsp;
				<select id="controller" name="controller" onChange="javascript:changeController(this)" >
<%
				if(RDMServicesConstants.ROLE_ADMIN.equals(u.getRole()))
				{
%>
					<optgroup label="Default Values">
<%
					boolean bViewGrwDB = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_GROWER);
					if(bViewGrwDB && (RDMSession.getControllers(RDMServicesConstants.TYPE_GROWER).size() > 0))
					{
%>
						<option value="<%= RDMServicesConstants.TYPE_GROWER %>"><%= resourceBundle.getProperty("DataManager.DisplayText.Grower") %></option>
<%
					}
					boolean bViewBnkDB = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_BUNKER);
					if(bViewBnkDB && (RDMSession.getControllers(RDMServicesConstants.TYPE_BUNKER).size() > 0))
					{
%>
						<option value="<%= RDMServicesConstants.TYPE_BUNKER %>"><%= resourceBundle.getProperty("DataManager.DisplayText.Bunker") %></option>
<%
					}
					boolean bViewTnlDB = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_TUNNEL);
					if(bViewTnlDB && (RDMSession.getControllers(RDMServicesConstants.TYPE_TUNNEL).size() > 0))
					{
%>
						<option value="<%= RDMServicesConstants.TYPE_TUNNEL %>"><%= resourceBundle.getProperty("DataManager.DisplayText.Tunnel") %></option>
<%
					}
%>
					<optgroup label="Controllers">
<%
				}

				String sCntrlName = "";
				String sSelected = "";
				for(int i=0; i<slControllers.size(); i++)
				{
					sCntrlName = slControllers.get(i);
					sSelected = (sCntrlName.equals(sController) ? "selected" : "");
%>
					<option value="<%= sCntrlName %>" <%= sSelected %>><%= sCntrlName %></option>
<%
				}
%>
				</select>
			</td>
			<td style="font-family:Arial; font-size:0.8em; font-weight:bold; border:#ffffff; text-align:right">
				<%= resourceBundle.getProperty("DataManager.DisplayText.Last_updated_on") %>:&nbsp;
				<font style="weight:normal; color:#FF0000"><%= sDate %></font>
			</td>
			<td style="font-family:Arial; font-size:0.8em; font-weight:bold; border:#ffffff; text-align:right">
				<input type="button" id="Refresh" name="Refresh" class="btn btn-effect-ripple btn-primary" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Reload_Values") %>" onclick="javascript:resetChanges()">&nbsp;				
				<input type="button" id="Alarms" name="Alarms" class="btn btn-effect-ripple btn-primary" value="<%= resourceBundle.getProperty("DataManager.DisplayText.View_Alarms") %>" onclick="javascript:showAlarms()">&nbsp;
<%
				if(!RDMServicesConstants.ROLE_HELPER.equals(u.getRole()))
				{
%>
					<input type="button" id="Comments" name="Comments" class="btn btn-effect-ripple btn-primary" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Add_Comments") %>" onClick="javascript:addComments()">&nbsp;
					<input type="button" id="Save" name="Save" class="btn btn-effect-ripple btn-primary" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Save_Changes") %>" onClick="javascript:saveChanges()">
<%
				}
%>
			</td>
		</tr>
	</table>
	</div>

	<form name="frm" method="post" action="setParametersProcess.jsp" target="hiddenFrame" class="form-horizontal form-bordered">
		<input type="hidden" id="controller" name="controller" value="<%= sController %>">
		<div class="container">
			<table id="freezeHeaders" class="table table-striped table-bordered table-vcenter  ">
				<tr>
					<th style="text-align: center; height:25px">
						<%= resourceBundle.getProperty("DataManager.DisplayText.Parameter_Unit") %>
					</th>
					<th style="text-align: center; height:25px">
						<%= resourceBundle.getProperty("DataManager.DisplayText.Value") %>
					</th>
				</tr>
<%
			for(int m=0; m<displayOrder.size(); m++)
			{
				sParam = displayOrder.get(m);
				
				saParamVal = mParamData.get(sParam);
				if(saParamVal != null)
				{
					sValue = saParamVal[0];
					sUnit = saParamVal[1];
				}
				else
				{
					sValue = "";
					sUnit = "";
				}
				
				mParam = mParamSettings.get(sParam);
				sAccess = u.getUserAccess(mParam);
				if(sAccess == null || RDMServicesConstants.ACCESS_NONE.equals(sAccess))
				{
					continue;
				}
%>
				<tr>
					<th style="text-align: left"><%= sParam %>
<%
					if(!"".equals(sUnit))
					{
%>
						&nbsp;<label class="unit">(<%= sUnit %>)</label>
<%
					}
%>
					</th>
<%
					try
					{
						if(!("On".equals(sValue) || "Off".equals(sValue) || sValue.contains(":")))
						{
							sValue = numberFormat.format(Double.parseDouble(sValue));
						}
					}
					catch(Exception e)
					{
						//do nothing
					}
					if(RDMServicesConstants.ACCESS_WRITE.equals(sAccess))
					{
						bShowSaveReset = true;
						if("On".equals(sValue) || "Off".equals(sValue))
						{
%>
							<td>
								<select id="<%= sParam %>" name="<%= sParam %>" onChange="javascript:setOnOff('<%= sParam %>', this);" class="form-control">
									<option value="On" <%= ("On".equals(sValue) ? "selected" : "") %>><%= resourceBundle.getProperty("DataManager.DisplayText.On") %></option>
									<option value="Off" <%= ("Off".equals(sValue) ? "selected" : "") %>><%= resourceBundle.getProperty("DataManager.DisplayText.Off") %></option>
								</select>
							</td>
<%
						}
						else if(slOnOffValues.contains(sParam))
						{
%>
							<td>
								<select id="<%= sParam %>" name="<%= sParam %>" onChange="javascript:setOnOff('<%= sParam %>', this);" class="form-control">
									<option value="1" <%= (("1".equals(sValue) || "1.0".equals(sValue)) ? "selected" : "") %>><%= resourceBundle.getProperty("DataManager.DisplayText.On") %></option>
									<option value="0" <%= (("0".equals(sValue) || "0.0".equals(sValue)) ? "selected" : "") %>><%= resourceBundle.getProperty("DataManager.DisplayText.Off") %></option>
								</select>
							</td>
<%
						}
						else
						{
							if(java.util.regex.Pattern.matches("[0-9,.-]+", sValue))
							{
								try
								{
									sValue = decimalFormat.format(decimalFormat.parse(sValue));
								}
								catch(Exception e)
								{
									//do nothing
								}
							}
%>
							<td>
								<input type="text" id="<%= sParam %>" name="<%= sParam %>" value="<%= sValue %>" size="8" onBlur="javascript:setValue('<%= sParam %>', this);">
							</td>
<%
						}
%>
						<input type="hidden" id="<%= sParam %>_OldVal" name="<%= sParam %>_OldVal" value="<%= sValue %>">
<%
					}
					else
					{
						if(java.util.regex.Pattern.matches("[0-9,.-]+", sValue))
						{
							try
							{
								sValue = decimalFormat.format(decimalFormat.parse(sValue));
							}
							catch(Exception e)
							{
								//do nothing
							}
						}
						if(slOnOffValues.contains(sParam))
						{
							if("1".equals(sValue) || "1.0".equals(sValue))
							{
								sValue = "On";
							}
							else if("0".equals(sValue) || "0.0".equals(sValue))
							{
								sValue = "Off";
							}
						}
%>
						<td>
							<%= sValue %>
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
	</form>
	</div>
	</div>
	</div>
	<script type="text/javascript">		
		var myST = new superTable("freezeHeaders", {
			cssSkin : "sGrey",
			headerRows : 1,
			fixedCols : 1
		});
	</script>
<%
if(!bShowSaveReset)
{
%>
	<script language="javascript">
		document.getElementById('Save').style.visibility = 'hidden';
	</script>
<%
}
%>
</body>
</html>
