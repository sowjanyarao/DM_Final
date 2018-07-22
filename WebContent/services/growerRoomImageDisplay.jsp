<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.text.*" %>
<%@page import="java.util.*" %>
<%@page import="com.client.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<%!
	Map<String, ParamSettings> mViewParams = null;
	Map<String, String[]> mParams = null;
	StringList slOnOffValues = null;
	String TEXT_OPEN = "Open";
	String TEXT_CLOSE = "Close";
	String TEXT_ON = "On";
	String TEXT_OFF = "Off";
	String sfxStage1 = "";
	String sfxStage2 = "";
	
	NumberFormat decimalFormat = NumberFormat.getInstance(Locale.getDefault());
%>

<%
	String sController = request.getParameter("controller");
	PLCServices client = new PLCServices(RDMSession, sController);

	mParams = client.getControllerData(true);

	String sCurrentPhase = (mParams.containsKey("current phase") ? mParams.get("current phase")[0] : "");
	String sPhase = new String(sCurrentPhase);

	String sCntrlType = client.getControllerType();
	String stageName = RDMServicesUtils.getStageName(sCntrlType, sPhase);
	StringList slControllers = RDMSession.getControllers(u);	

	TreeMap<String, Map<String, String>> mDisplayParams = null;
	mViewParams = RDMServicesUtils.getRoomImageParamaters(sCntrlType);
	slOnOffValues = RDMServicesUtils.getOnOffParams(sCntrlType);
	
	StringList slGraphs = u.getSavedGraphs();
	
	Random randomGenerator = new Random();
	int randomInt = randomGenerator.nextInt(1000);
	
	SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy", Locale.ENGLISH);
	Calendar cal = Calendar.getInstance();
	String endDate = sdf.format(cal.getTime());
	cal.add(Calendar.DAY_OF_YEAR, -1);
	String startDate = sdf.format(cal.getTime());
	
	String sStgSeq = new String(sCurrentPhase);
	if(sStgSeq.endsWith(".0"))
	{
		sStgSeq = sStgSeq.substring(0, sStgSeq.indexOf("."));
	}
	if("0".equalsIgnoreCase(sStgSeq))
	{
		sfxStage1 = " " + stageName;
		sfxStage2 = " " + "phase" + " " + stageName;
	}
	else
	{
		sfxStage1 = " " + stageName + " " + sStgSeq;
		sfxStage2 = " " + "phase" + " " + sStgSeq;
	}
	
	decimalFormat.setMinimumFractionDigits(1);
%>

<!DOCTYPE html>
<html>
	<head>
	<meta name="description" content="Datamanager"/>
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
    <!-- Modernizr (browser feature detection library) -->
    <script src="../js/vendor/modernizr-3.3.1.min.js"></script>
  
	<script src="../js/vendor/jquery-2.2.4.min.js"></script>
    <script src="../js/vendor/bootstrap.min.js"></script>
    <script src="../js/plugins.js"></script>
    <script src="../js/app.js"></script>
    <!-- Load and execute javascript code used only in this page -->
    <script src="../js/pages/readyDashboard.js"></script>
		<title></title>	
		<link type="text/css" href="../styles/dygraph.css" rel="stylesheet" />
		
		<script language="javascript">
		var prevId = "";
		
		if (!String.prototype.trim) 
		{
			String.prototype.trim = function() {
				return this.replace(/^\s+|\s+$/g,'');
			}
		}
		
		if ( typeof String.prototype.startsWith != 'function' ) {
			String.prototype.startsWith = function( str ) {
				return str.length > 0 && this.substring( 0, str.length ) === str;
			}
		};
		
		if ( typeof String.prototype.endsWith != 'function' ) {
			String.prototype.endsWith = function( str ) {
				return str.length > 0 && this.substring( this.length - str.length, this.length ) === str;
			}
		};

		function showMode(divId)
		{
			var idx1 = divId.indexOf("_");
			var str1 = divId.substring(0, idx1);
			
			if(prevId != "")
			{
				var idx2 = prevId.indexOf("_");
				var str2 = prevId.substring(0, idx2);
				
				if((str1 == str2) && prevId.endsWith("_Edit"))
				{
					return;
				}
			}

			if(prevId != "" && prevId != divId)
			{
				document.getElementById(prevId).style.display = "none";
			}
			if(divId != "")
			{
				document.getElementById(divId).style.display = "block";
			}			
			prevId = divId;
		}

		function hideMode(divId)
		{
			document.getElementById(divId).style.display = "none";
			prevId = "";
		}
		
		function changeController(obj)
		{
			var sCntrl = obj.value;
			if(sCntrl == "Bunker" || sCntrl == "Tunnel" || sCntrl == "Grower")
			{
				parent.location.href = "defaultParamsView.jsp?controller="+sCntrl;
			}
			else
			{
				parent.location.href = "roomImageView.jsp?controller="+sCntrl;
			}
		}
	
		function showAlarms()
		{
			var retval = window.open('showAlarms.jsp?controller=<%= sController %>', 'Alarms', 'left=250,top=250,resizable=no,scrollbars=no,status=no,toolbar=no,height=500,width=620');
		}
		
		function addComments()
		{
			var retval = window.open('addUserComments.jsp?controller=<%= sController %>', 'Comments', 'left=250,top=250,resizable=no,scrollbars=no,status=no,toolbar=no,height=375,width=525');
		}

		function showAllParams()
		{
			parent.document.location.href = "singleRoomView.jsp?controller=<%=sController%>";
		}
		
		function setValue(pid, obj) 
		{
			var val = obj.value.trim();
			if('<%= cDecimal %>' == '.')
			{
				val = val.replace(/,/g, "");
			}
			else if('<%= cDecimal %>' == ',')
			{
				val = val.replace(/\./g, "");
			}

			var elm = document.getElementById(pid);
			var minValue = document.getElementById(pid+"_MinVal");
			var maxValue = document.getElementById(pid+"_MaxVal");

			var err = false;
			if(minValue != null && minValue != "undefined")
			{
				var minVal = minValue.value.trim();
				if(minVal != "")
				{
					if('<%= cDecimal %>' == '.')
					{
						minVal = minVal.replace(/,/g, "");
					}
					else if('<%= cDecimal %>' == ',')
					{
						minVal = minVal.replace(/\./g, "");
					}
			
					if(parseFloat(val) < parseFloat(minVal))
					{
						err = true;
					}
				}
			}
			
			if(maxValue != null && maxValue != "undefined")
			{
				var maxVal = maxValue.value.trim();
				if(maxVal != "")
				{
					if('<%= cDecimal %>' == '.')
					{
						maxVal = maxVal.replace(/,/g, "");
					}
					else if('<%= cDecimal %>' == ',')
					{
						maxVal = maxVal.replace(/\./g, "");
					}
					
					if(parseFloat(val) > parseFloat(maxVal))
					{
						err = true;
					}
				}
			}
			
			if(err)
			{
				obj.style.background = '#FF0000';
				obj.value = document.getElementById(pid+"_OldVal").value;
				elm.value = document.getElementById(pid+"_OldVal").value;
				alert("The value entered should be between '"+minValue.value+" to '"+maxValue.value+"'");
			}
			else
			{
				if(document.getElementById(pid+"_OldVal").value != obj.value.trim())
				{
					obj.style.background = '#00FF00';
				}
				elm.value = obj.value.trim();
			}
		}
		
		function saveChanges()
		{
			document.forms[0].submit();
		}
		
		function showGraph()
		{
			idx = "<%= randomInt %>";
			document.grp.target = "POPUPW_"+idx;
			POPUPW = window.open('about:blank','POPUPW_'+idx,'menubar=no,toolbar=no,location=no,resizable=yes,scrollbars=yes,status=no,height=<%= winHeight * 0.85 %>px,width=<%= winWidth * 0.90 %>px');
			document.grp.submit();
		}
		
		function reloadValues()
		{
			document.location.href = document.location.href;
		}
		</script>
		
		<script type="text/javascript">
		//<![CDATA[
		window.onkeypress = enter;
		function enter(e)
		{
			if (e.keyCode == 13)
			{
				document.getElementById('controller').focus();
				setTimeout("saveChanges()", 1000);
			}
		}
		//]]>
	</script>
	</head>
	
	<body>
	    <!-- Main Container -->
            <div id="main-container">
             <!-- Page content -->
                <div id="page-content">
		<table border="0" cellspacing="2" cellpadding="2" width="90%">
			<tr>
				<td style="font-family:Arial; font-size:9pt; font-weight:bold; text-align:right">
					<%= resourceBundle.getProperty("DataManager.DisplayText.Select_Room") %>:&nbsp;
					<select id="controller" name="controller" onChange="javascript:changeController(this)" class="form-control">
<%
					if(RDMServicesConstants.ROLE_ADMIN.equals(u.getRole()))
					{
%>
						<optgroup label="<%= resourceBundle.getProperty("DataManager.DisplayText.Default_Values") %>">
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
						<optgroup label="<%= resourceBundle.getProperty("DataManager.DisplayText.Controllers") %>">
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
				
				<td style="font-family:Arial; font-size:9pt; font-weight:bold; text-align:right">
					<%= resourceBundle.getProperty("DataManager.DisplayText.Running_Phase") %>:&nbsp;<%= sPhase %>(<%= stageName %>)
				</td>	

				<td width="10%">&nbsp;</td>

				<td style="font-family:Arial; font-size:0.8em; text-align:right">
					<input type="button"  class="btn btn-effect-ripple btn-primary"id="alarms" name="alarms" value="<%= resourceBundle.getProperty("DataManager.DisplayText.View_Alarms") %>" onClick="javascript:showAlarms()">&nbsp;
					<input type="button" class="btn btn-effect-ripple btn-primary" id="singleRoom" name="singleRoom" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Single_Room") %>" onClick="javascript:showAllParams()">&nbsp;
<%
					String sParams = "";
					if(slGraphs.contains("Grower Dashboard"))
					{
						Map<String, String> mGraphParams = u.getGraphParams("Grower Dashboard");
						sParams = mGraphParams.get("PARAMS").replaceAll(",", "\\|");
%>
						<input type="button" class="btn btn-effect-ripple btn-primary" id="graph" name="graph" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Show_Graph") %>" onClick="javascript:showGraph()">
<%
					}
					/*else
					{
%>
						<input type="button" class="btn btn-effect-ripple btn-primary" id="graph" name="graph" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Show_Graph") %>">
<%
					}*/

					if(!RDMServicesConstants.ROLE_HELPER.equals(u.getRole()))
					{
%>
						<input type="button" class="btn btn-effect-ripple btn-primary" id="comments" name="comments" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Add_Comments") %>" onClick="javascript:addComments()">&nbsp;
<%
					}
%>
					<input type="button" class="btn btn-effect-ripple btn-primary" id="Refresh" name="Refresh" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Reload_Values") %>" onClick="javascript:reloadValues()">
				</td>
			</tr>
		</table>
		
		<form name="frm" method="post" action="setParametersProcess.jsp" target="hiddenFrame" class="form-horizontal form-bordered">
			<input type="hidden" id="controller" name="controller" value="<%= sController %>">
			<input type="hidden" id="cntrlType" name="cntrlType" value="<%= sCntrlType %>">
			<table width="525px" height="600px" cellspacing="0" cellpadding="0" border="0" align="left" background="../images/GrowerView.png" style="background-repeat:no-repeat">
				<tr>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('Time_View')" onClick="showMode('Time_Edit')" ondblClick="hideMode('Time_Edit')"></td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('Time_View')" onClick="showMode('Time_Edit')" ondblClick="hideMode('Time_Edit')">
<%
						mDisplayParams = client.getImageControllerData(mParams, "Time", sCurrentPhase);
%>
						<div id="Time_View" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, false) %>
						</div>
						<div id="Time_Edit" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, true) %>
						</div>
					</td>
				</tr>
				<tr>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('Comp.Temp.4_View')" onClick="showMode('Comp.Temp.4_Edit')" ondblClick="hideMode('Comp.Temp.4_Edit')"></td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('Comp.Temp.4_View')" onClick="showMode('Comp.Temp.4_Edit')" ondblClick="hideMode('Comp.Temp.4_Edit')">
<%
					mDisplayParams = client.getImageControllerData(mParams, "Comp.Temp.4", sCurrentPhase);
%>
						<div id="Comp.Temp.4_View" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, false) %>
						</div>
						<div id="Comp.Temp.4_Edit" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, true) %>
						</div>
					</td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('Outside.Params_View')" onClick="showMode('Outside.Params_Edit')" ondblClick="hideMode('Outside.Params_Edit')"></td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('Outside.Params_View')" onClick="showMode('Outside.Params_Edit')" ondblClick="hideMode('Outside.Params_Edit')">
<%
						mDisplayParams = client.getImageControllerData(mParams, "Outside.Params", sCurrentPhase);
%>
						<div id="Outside.Params_View" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, false) %>
						</div>
						<div id="Outside.Params_Edit" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, true) %>
						</div>
					</td>
				</tr>
				<tr>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('Set.Temp_View')" onClick="showMode('Set.Temp_Edit')" ondblClick="hideMode('Set.Temp_Edit')">
<%
						mDisplayParams = client.getImageControllerData(mParams, "Set.Temp", sCurrentPhase);
%>
						<div id="Set.Temp_View" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, false) %>
						</div>
						<div id="Set.Temp_Edit" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, true) %>
						</div>
					</td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('Comp.Temp.3_View')" onClick="showMode('Comp.Temp.3_Edit')" ondblClick="hideMode('Comp.Temp.3_Edit')"></td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('Comp.Temp.3_View')" onClick="showMode('Comp.Temp.3_Edit')" ondblClick="hideMode('Comp.Temp.3_Edit')">
<%
					mDisplayParams = client.getImageControllerData(mParams, "Comp.Temp.3", sCurrentPhase);
%>
						<div id="Comp.Temp.3_View" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, false) %>
						</div>
						<div id="Comp.Temp.3_Edit" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, true) %>
						</div>
					</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('Set.Params_View')" onClick="showMode('Set.Params_Edit')" ondblClick="hideMode('Set.Params_Edit')"></td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('Set.Params_View')" onClick="showMode('Set.Params_Edit')" ondblClick="hideMode('Set.Params_Edit')"></td>
				</tr>
				<tr>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('Set.Params_View')" onClick="showMode('Set.Params_Edit')" ondblClick="hideMode('Set.Params_Edit')"></td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('Set.Params_View')" onClick="showMode('Set.Params_Edit')" ondblClick="hideMode('Set.Params_Edit')">
<%
						mDisplayParams = client.getImageControllerData(mParams, "Set.Params", sCurrentPhase);
%>
						<div id="Set.Params_View" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, false) %>
						</div>
						<div id="Set.Params_Edit" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, true) %>
						</div>
					</td>
				</tr>
				<tr>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('Comp.Temp.1_View')" onClick="showMode('Comp.Temp.1_Edit')" ondblClick="hideMode('Comp.Temp.1_Edit')"></td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('Comp.Temp.1_View')" onClick="showMode('Comp.Temp.1_Edit')" ondblClick="hideMode('Comp.Temp.1_Edit')">
<%
						mDisplayParams = client.getImageControllerData(mParams, "Comp.Temp.1", sCurrentPhase);
%>
						<div id="Comp.Temp.1_View" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, false) %>
						</div>
						<div id="Comp.Temp.1_Edit" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, true) %>
						</div>
					</td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('Comp.Temp.2_View')" onClick="showMode('Comp.Temp.2_Edit')" ondblClick="hideMode('Comp.Temp.2_Edit')"></td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('Comp.Temp.2_View')" onClick="showMode('Comp.Temp.2_Edit')" ondblClick="hideMode('Comp.Temp.2_Edit')">
<%
						mDisplayParams = client.getImageControllerData(mParams, "Comp.Temp.2", sCurrentPhase);
%>
						<div id="Comp.Temp.2_View" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, false) %>
						</div>
						<div id="Comp.Temp.2_Edit" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, true) %>
						</div>
					</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
				</tr>
				<tr>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
				</tr>
				<tr>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
				</tr>
				<tr>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('Steam_View')" onClick="showMode('Steam_Edit')" ondblClick="hideMode('Steam_Edit')">
<%
						mDisplayParams = client.getImageControllerData(mParams, "Steam", sCurrentPhase);
%>
						<div id="Steam_View" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, false) %>
						</div>
						<div id="Steam_Edit" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, true) %>
						</div>
					</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('Watervalve_View')" onClick="showMode('Watervalve_Edit')" ondblClick="hideMode('Watervalve_Edit')">
<%
						mDisplayParams = client.getImageControllerData(mParams, "Watervalve", sCurrentPhase);
%>
						<div id="Watervalve_View" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, false) %>
						</div>
						<div id="Watervalve_Edit" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, true) %>
						</div>
					</td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('Humidify_View')" onClick="showMode('Humidify_Edit')" ondblClick="hideMode('Humidify_Edit')">
<%
						mDisplayParams = client.getImageControllerData(mParams, "Humidify", sCurrentPhase);
%>
						<div id="Humidify_View" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, false) %>
						</div>
						<div id="Humidify_Edit" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, true) %>
						</div>
					</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('Inlet.Airtemp_View')" onClick="showMode('Inlet.Airtemp_Edit')" ondblClick="hideMode('Inlet.Airtemp_Edit')">
<%
						mDisplayParams = client.getImageControllerData(mParams, "Inlet.Airtemp", sCurrentPhase);
%>
						<div id="Inlet.Airtemp_View" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, false) %>
						</div>
						<div id="Inlet.Airtemp_Edit" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, true) %>
						</div>
					</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('CHW.out_View')" onClick="showMode('CHW.out_Edit')" ondblClick="hideMode('CHW.out_Edit')">
<%
						mDisplayParams = client.getImageControllerData(mParams, "CHW.out", sCurrentPhase);
%>
						<div id="CHW.out_View" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, false) %>
						</div>
						<div id="CHW.out_Edit" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, true) %>
						</div>
					</td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('Room.Params_View')" onClick="showMode('Room.Params_Edit')" ondblClick="hideMode('Room.Params_Edit')">
<%
					mDisplayParams = client.getImageControllerData(mParams, "Room.Params", sCurrentPhase);
%>
						<div id="Room.Params_View" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, false) %>
						</div>
						<div id="Room.Params_Edit" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, true) %>
						</div>
					</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
				</tr>
				<tr>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('Fan_View')" onClick="showMode('Fan_Edit')" ondblClick="hideMode('Fan_Edit')"></td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('Fan_View')" onClick="showMode('Fan_Edit')" ondblClick="hideMode('Fan_Edit')">
<%
						mDisplayParams = client.getImageControllerData(mParams, "Fan", sCurrentPhase);
%>
						<div id="Fan_View" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, false) %>
						</div>
						<div id="Fan_Edit" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, true) %>
						</div>
					</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('Mix.Airtemp_View')" onClick="showMode('Mix.Airtemp_Edit')" ondblClick="hideMode('Mix.Airtemp_Edit')">
<%
						mDisplayParams = client.getImageControllerData(mParams, "Mix.Airtemp", sCurrentPhase);
%>
						<div id="Mix.Airtemp_View" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, false) %>
						</div>
						<div id="Mix.Airtemp_Edit" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, true) %>
						</div>
					</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
				</tr>
				<tr>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('Heating_View')" onClick="showMode('Heating_Edit')" ondblClick="hideMode('Heating_Edit')">
<%
						mDisplayParams = client.getImageControllerData(mParams, "Heating", sCurrentPhase);
%>
						<div id="Heating_View" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, false) %>
						</div>
						<div id="Heating_Edit" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, true) %>
						</div>
					</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('Cooling_View')" onClick="showMode('Cooling_Edit')" ondblClick="hideMode('Cooling_Edit')">
<%
					mDisplayParams = client.getImageControllerData(mParams, "Cooling", sCurrentPhase);
%>
						<div id="Cooling_View" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, false) %>
						</div>
						<div id="Cooling_Edit" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, true) %>
						</div>
					</td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('Airvalve_View')" onClick="showMode('Airvalve_Edit')" ondblClick="hideMode('Airvalve_Edit')">
<%
						mDisplayParams = client.getImageControllerData(mParams, "Airvalve", sCurrentPhase);
%>
						<div id="Airvalve_View" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, false) %>
						</div>
						<div id="Airvalve_Edit" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, true) %>
						</div>
					</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
				</tr>
				<tr>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('CHW.in_View')" onClick="showMode('CHW.in_Edit')" ondblClick="hideMode('CHW.in_Edit')">
<%
						mDisplayParams = client.getImageControllerData(mParams, "CHW.in", sCurrentPhase);
%>
						<div id="CHW.in_View" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, false) %>
						</div>
						<div id="CHW.in_Edit" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, true) %>
						</div>
					</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onMouseOver="javascript:this.style.cursor = 'pointer'; showMode('CHW.Flowmeter_View')" onClick="showMode('CHW.Flowmeter_Edit')" ondblClick="hideMode('CHW.Flowmeter_Edit')">
<%
						mDisplayParams = client.getImageControllerData(mParams, "CHW.Flowmeter", sCurrentPhase);
%>
						<div id="CHW.Flowmeter_View" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, false) %>
						</div>
						<div id="CHW.Flowmeter_Edit" style="display:none; z-index:5; position:absolute;">
							<%= getHTMLText(mDisplayParams, u, sCntrlType, true) %>
						</div>
					</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
				</tr>
				<tr>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
					<td width="50" height="50" onClick="showMode('')">&nbsp;</td>
				</tr>
			</table>
		</form>
		
		<form name="grp" method="grp" action="showAttrDataGraph.jsp">
			<input type="hidden" id="saveAs" name="saveAs" value="">
			<input type="hidden" id="lstController" name="lstController" value="<%= sController %>">
			<input type="hidden" id="Parameters" name="Parameters" value="<%= sParams %>">
			<input type="hidden" id="start_date" name="start_date" value="<%= startDate %>">
			<input type="hidden" id="end_date" name="end_date" value="<%= endDate %>">
			<input type="hidden" id="yield" name="yield" value="">
			<input type="hidden" id="access" name="access" value="">
		</form>
		</div>
		</div>
	</body>

</html>

<%!
	private String getHTMLText(TreeMap<String, Map<String, String>> mDisplayParams, User user, String sCntrlType, boolean bEdit)
	{
		StringBuilder sbHTMLText = new StringBuilder();
		try
		{
			boolean bOpen = false;
			String sParam = null;
			String sValue = null;
			String sUnit = null;
			String sMin = null;
			String sMax = null;
			String sAccess = null;
			String bgColor = null;
			Map<String, String> mParamVal = null;
			ParamSettings paramSettings = null;
			NumberFormat numberFormat = NumberFormat.getInstance(Locale.getDefault());
			
			sbHTMLText.append("<table border='1' cellpadding='1' cellspacing='0'>");
			Iterator<String> itr = mDisplayParams.keySet().iterator();
			while(itr.hasNext())
			{
				sParam = itr.next();
				paramSettings = mViewParams.get(sParam);
				if(paramSettings == null)
				{
					continue;
				}
				
				sAccess = user.getUserAccess(paramSettings);
				if(sAccess == null || RDMServicesConstants.ACCESS_NONE.equals(sAccess))
				{
					continue;
				}
				
				String sDisplay = new String(sParam);
				if(sParam.startsWith("max ") || sParam.startsWith("min ") || sParam.startsWith("set "))
				{
					if(sParam.endsWith(sfxStage1))
					{
						sDisplay = sParam.substring(0, sParam.indexOf(sfxStage1));
					}
					else if(sParam.endsWith(sfxStage2))
					{
						sDisplay = sParam.substring(0, sParam.indexOf(sfxStage2));
					}
					else
					{
						continue;
					}
				}
				
				mParamVal = mDisplayParams.get(sParam);
				sValue = mParamVal.get("value");
				sUnit = mParamVal.get("unit");
				sMin = mParamVal.get("min");
				sMax = mParamVal.get("max");
				
				sbHTMLText.append("<tr>");
				sbHTMLText.append("	<th height='25' nowrap style='text-align:left'>" + sDisplay);
				if(!"".equals(sUnit))
				{
					sbHTMLText.append("	&nbsp;<label class='unit'>(" + sUnit +")</label>");
				}
				sbHTMLText.append("	</th>");

				bgColor = "#FFFFFF";
				if(sMin != null && sMax != null)
				{
					if(Double.parseDouble(sValue) < Double.parseDouble(sMin) || 
						Double.parseDouble(sValue) > Double.parseDouble(sMax))
					{
						bgColor = "#FF0000";
					}
				}
				
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

				if(RDMServicesConstants.ACCESS_WRITE.equals(sAccess) && bEdit)
				{
					bOpen = sParam.contains("door.open");
					
					sbHTMLText.append("	<td class='text'>");
					if("On".equals(sValue) || "Off".equals(sValue))
					{
						sbHTMLText.append("	<select class='form-control' id='"+sParam+"' name='"+sParam+"'>");
						sbHTMLText.append("	<option value='On' "+("On".equals(sValue) ? "selected" : "")+">"+(bOpen ? TEXT_OPEN : TEXT_ON)+"</option>");
						sbHTMLText.append("	<option value='Off' "+("Off".equals(sValue) ? "selected" : "")+">"+(bOpen ? TEXT_CLOSE : TEXT_OFF)+"</option>");
						sbHTMLText.append("	</select>");
					}
					else if(slOnOffValues.contains(sParam))
					{
						sbHTMLText.append("	<select class='form-control' id='"+sParam+"' name='"+sParam+"'>");
						sbHTMLText.append("	<option value='1' "+("1".equals(sValue) ? "selected" : "")+">"+(bOpen ? TEXT_OPEN : TEXT_ON)+"</option>");
						sbHTMLText.append("	<option value='0' "+("0".equals(sValue) ? "selected" : "")+">"+(bOpen ? TEXT_CLOSE : TEXT_OFF)+"</option>");
						sbHTMLText.append("	</select>");
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

						sbHTMLText.append("	<input type='text' id='"+sParam+"' name='"+sParam+"' value='"+sValue+"' size='8' style='background:"+bgColor+"' onBlur='javascript:setValue(\""+sParam+"\", this)'>");
					}

					sbHTMLText.append("	<input type='hidden' id='"+sParam+"_OldVal' name='"+sParam+"_OldVal' value='"+sValue+"'>");
					if(sMin != null && sMax != null)
					{
						sbHTMLText.append("	<input type='hidden' id='"+sParam+"_MinVal' name='"+sParam+"_MinVal' value='"+numberFormat.format(Double.parseDouble(sMin))+"'>");
						sbHTMLText.append("	<input type='hidden' id='"+sParam+"_MaxVal' name='"+sParam+"_MaxVal' value='"+numberFormat.format(Double.parseDouble(sMax))+"'>");
					}
					sbHTMLText.append("	</td>");
				}
				else
				{
					if(slOnOffValues.contains(sParam))
					{
						if(bOpen)
						{
							if("1".equals(sValue) || "On".equals(sValue))
							{
								sValue = TEXT_OPEN;
							}
							else if("0".equals(sValue) || "Off".equals(sValue))
							{
								sValue = TEXT_CLOSE;
							}
						}
						else if("1".equals(sValue))
						{
							sValue = TEXT_ON;
						}
						else if("0".equals(sValue))
						{
							sValue = TEXT_OFF;
						}
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
					}
					sbHTMLText.append("	<td class='text'>");
					sbHTMLText.append("	<label style='display:inline-block; width:50px'>"+sValue+"</label>");
					sbHTMLText.append("	</td>");
				}
				sbHTMLText.append("	</tr>");
			}
			sbHTMLText.append("	</table>");
		}
		catch(Exception e)
		{
			//do nothing
		}
		return sbHTMLText.toString();
	}
%>