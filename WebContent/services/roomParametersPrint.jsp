<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>
<%@page import="com.client.views.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<%
	String sController = request.getParameter("controller");
	String sRole = u.getRole();
	
	PLCServices client = new PLCServices(RDMSession, sController);
	String sCntrlType = client.getControllerType();

	StringList slControllers = RDMSession.getControllers(u);	
	ArrayList<String[]> alPhases = client.getControllerStages();
	
	Map<String, ParamSettings> mViewParams = RDMServicesUtils.getSingleRoomViewParamaters(sCntrlType);
	ArrayList<String> alParams = RDMServicesUtils.getDisplayOrder(sCntrlType);

	Map<String, String[]> mParams = client.getControllerData(true);
	String sManual = (mParams.containsKey("manual.sl") ? mParams.get("manual.sl")[0] : "");
	String sCoolingSteam = (mParams.containsKey("cooling.steam") ? mParams.get("cooling.steam")[0] : "");
	String sCompErr = (mParams.containsKey("comp.error") ? mParams.get("comp.error")[0] : "");
	String sCurrPhase = (mParams.containsKey("current phase") ? mParams.get("current phase")[0] : "").trim();
	String sCurrPhaseSeq = (sCurrPhase.endsWith(".0") ? sCurrPhase.substring(0, sCurrPhase.indexOf(".")) : sCurrPhase);
	sCurrPhase = sCurrPhase.replace('.', ' ');

	Map<String, String> mPhaseStartTime = client.getPhaseStartTime(mParams);

	String sHeader = null;
	StringList slHeaders = new StringList();
	Map<String, String> mParamHeaders = RDMServicesUtils.displayHeaders(sCntrlType);

	Map<Integer, String> mDisplayHeaders = RDMServicesUtils.getHeaders(sCntrlType);
	ArrayList<Integer> alDisplayOrder = new ArrayList<Integer>();
	alDisplayOrder.addAll(mDisplayHeaders.keySet());
	Collections.sort(alDisplayOrder);

	String sDate = (mParams.containsKey("Last Refresh") ? mParams.get("Last Refresh")[0] : "");
	String sBatchNo = client.getBatchNo();
	
	boolean bHasOpenAlarms = client.hasOpenAlarms();
	
	StringList slManualParams = RDMServicesUtils.getManualParams(sCntrlType);
	StringList slCoolingSteamParams = RDMServicesUtils.getCoolingSteamParams(sCntrlType);
	StringList slCompErrParams = RDMServicesUtils.getCompErrorParams(sCntrlType);
	
	StringList slOnOffValues = RDMServicesUtils.getOnOffParams(sCntrlType);
	slOnOffValues.addAll(slManualParams);
	slOnOffValues.addAll(slCoolingSteamParams);
	slOnOffValues.addAll(slCompErrParams);
	
	String sDefProduct = "Default Product";
	
	String sDefParamType = client.getBatchDefType();
	sDefParamType = ((sDefParamType == null || "".equals(sDefParamType)) ? sDefProduct : sDefParamType);
	
	NumberFormat decimalFormat = NumberFormat.getInstance(Locale.getDefault());
	decimalFormat.setMinimumFractionDigits(1);
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
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
</head>

<body onLoad="javascript:window.print()">
<div id="main-container">

				<div id="page-content">
				<div class="block">
	<table border="0" cellpadding="0" cellspacing="0" width="90%">
		<tr>
			<td style="font-family:Arial; font-size:0.8em; font-weight:bold; border:#ffffff; text-align:left">
				<%= sController %>
			</td>
			<td style="font-family:Arial; font-size:0.8em; font-weight:bold; border:#ffffff; text-align:right">
				<%= resourceBundle.getProperty("DataManager.DisplayText.Manual_Setting") %>:&nbsp;<font style="weight:normal; color:<%= "On".equals(sManual) ? "#0000FF" : "#000000" %>"><%= sManual %></font>&nbsp;
			</td>
<%
			if(!slCoolingSteamParams.isEmpty())
			{
%>
				<td style="font-family:Arial; font-size:9pt; font-weight:bold; border:#ffffff; text-align:right">
					<%= resourceBundle.getProperty("DataManager.DisplayText.Cooling_Steam") %>:&nbsp;<font style="weight:normal; color:<%= "On".equals(sCoolingSteam) ? "#00F7FF" : "#000000" %>"><%= sCoolingSteam %></font>&nbsp;
				</td>
<%
			}

			if(!slCompErrParams.isEmpty())
			{
%>
				<td style="font-family:Arial; font-size:0.8em; font-weight:bold; border:#ffffff; text-align:right">
					<%= resourceBundle.getProperty("DataManager.DisplayText.Comp_Error") %>:&nbsp;<font style="weight:normal; color:<%= "Off".equals(sCompErr) ? "#FFA500" : "#000000" %>"><%= sCompErr %></font>
				</td>
<%
			}
			
			ParamSettings paramSettings = mViewParams.get("BatchNo");
			if((paramSettings != null) && RDMServicesConstants.ACCESS_READ.equals(u.getUserAccess(paramSettings)))
			{
%>
				<td style="font-family:Arial; font-size:0.8em; font-weight:bold; border:#ffffff; text-align:right">
					<%= resourceBundle.getProperty("DataManager.DisplayText.Batch_No") %>:&nbsp;<%= sBatchNo %>
				</td>
<%
			}
			
			paramSettings = mViewParams.get("Product");
			if((paramSettings != null) && RDMServicesConstants.ACCESS_READ.equals(u.getUserAccess(paramSettings)))
			{
%>
				<td style="font-family:Arial; font-size:0.8em; font-weight:bold; border:#ffffff; text-align:right">
					<%= resourceBundle.getProperty("DataManager.DisplayText.Product") %>:&nbsp;<%= sDefParamType %>
				</td>
<%
			}
%>
			<td style="font-family:Arial; font-size:0.8em; font-weight:bold; border:#ffffff; text-align:right">
				<%= resourceBundle.getProperty("DataManager.DisplayText.Last_updated_on") %>:&nbsp;<font style="weight:normal; color:#FF0000"><%= sDate %></font>
			</td>			
		</tr>
	</table>
	
	<table border="1" cellpadding="2" cellspacing="0">
		<tr>
			<th  style="text-align:left"><%= resourceBundle.getProperty("DataManager.DisplayText.Parameter_Unit") %></th>
<%
			String sPhaseSeq = "";
			String stageName = "";
			String sSfx = "";
			String sSfx1 = "";
			String sPhaseLabel = "";
				
			for(int i=0; i<alPhases.size(); i++)
			{
				sPhaseSeq = alPhases.get(i)[0];
				stageName = alPhases.get(i)[1];
				
				sPhaseLabel = ((sPhaseSeq.equals(stageName) || "-".equals(stageName)) ? sPhaseSeq : (sPhaseSeq +"<br>"+ stageName));

				if(sCurrPhase.equals(sPhaseSeq) || sCurrPhaseSeq.equals(sPhaseSeq))
				{
					if("0".equalsIgnoreCase(sPhaseSeq))
					{
						sSfx = stageName;
						sSfx1 =  " phase" + " " + stageName;
					}
					else
					{
						if(!sPhaseSeq.equals(stageName))
						{
							sSfx = stageName + " " + sPhaseSeq;
						}
						sSfx1 = " phase" + " " + sPhaseSeq;
					}
%>				
						<th  style="color:#000000; background-color: <%= bHasOpenAlarms ? "#ff0000" : "#00ff00" %>">
							<%= sPhaseLabel.replaceAll(" ", "<br>") %>
						</th>
<%
				}
				else
				{
%>
					<th ><%= sPhaseLabel.replaceAll(" ", "<br>") %></th>
<%
				}
			}
%>
		</tr>
		
		<tr>
			<th  style="text-align:left"><%= resourceBundle.getProperty("DataManager.DisplayText.Start_Timestamp") %></th>
<%
			String sStarted = "";
			for(int i=0; i<alPhases.size(); i++)
			{
				sPhaseSeq = alPhases.get(i)[0];
				sStarted = mPhaseStartTime.get(sPhaseSeq);
				sStarted = (sStarted == null ? "&nbsp;" : sStarted);
%>
				<td class="text"><%= sStarted.replaceAll(" ", "<br>") %></td>
<%
			}
%>
		</tr>
<%
		boolean bParamGroup = false;
		boolean bHasRange = false;
		boolean bDispOrd = false;
		int iDispOrd = 0;
		String sMinVal = null;
		String sMaxVal = null;
		String sParam = null;
		String sValue = null;
		String sUnit = null;
		String sStage = null;
		String sAccess = null;
		String sParamGroup = null;
		String sSetParam = null;
		String bgColor = null;
		String tdColor = null;
		String sCurrentVal = null;
		String sCurrentAcc = null;
		String currBgColor = null;
		String[] saParamVal = null;
		ParamSettings groupParams = null;

		for(int i=0; i<alParams.size(); i++)
		{
			sParam = (String)alParams.get(i);
			paramSettings = mViewParams.get(sParam);
			if(paramSettings == null)
			{
				continue;
			}

			bDispOrd = false;
			iDispOrd = paramSettings.getDisplayOrder();
			for(int n=alDisplayOrder.size()-1; n>=0; n--)
			{
				if(iDispOrd >= alDisplayOrder.get(n))
				{
					iDispOrd = alDisplayOrder.get(n);
					//alDisplayOrder.remove(n);
					bDispOrd = true;
					break;
				}
			}

			if(bDispOrd)
			{
				sHeader = mDisplayHeaders.get(iDispOrd);
				if(!slHeaders.contains(sHeader))
				{
%>
					<tr>
						<th align="center" colspan="<%= alPhases.size() + 2 %>" style="color:#000000">
							<%= sHeader %>
						</th>
					</tr>
<%
					alDisplayOrder.remove(0);
					slHeaders.add(sHeader);
				}
			}

			sAccess = u.getUserAccess(paramSettings);
			if(sAccess == null || RDMServicesConstants.ACCESS_NONE.equals(sAccess))
			{
				continue;
			}

			sStage = paramSettings.getStage();
			bParamGroup = paramSettings.hasGroupParams();
			sParamGroup = new String(sParam);
			
			sValue = ""; sUnit = "";
			saParamVal = mParams.get(sParam);
			if(saParamVal != null)
			{
				sValue = saParamVal[0];
				sUnit = saParamVal[1];
			}
			else
			{
				if(!bParamGroup)
				{
					continue;
				}
			}
			
			if("".equals(sUnit))
			{
				sUnit = paramSettings.getParamUnit();
			}

			bgColor = "#000000";
			if(slManualParams.contains(sParam))
			{
				if("On".equals(sValue) || "1".equals(sValue) || "1.0".equals(sValue))
				{
					bgColor = "#0000ff";
				}
			}
%>
			<tr>
				<th  style="text-align:left"><%= sParam %>
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
				sCurrentVal = "";
				if("NA".equals(sStage))
				{
					bHasRange = false;
					sMinVal = ""; sMaxVal = "";
					sSetParam = (sParam.startsWith("set ") ? sParam.substring(4, sParam.length()) : sParam);
					if(mParams.containsKey("min " + sSetParam + " " + sSfx))
					{
						bHasRange = true;
						sMinVal = mParams.get("min " + sSetParam + " " + sSfx)[0];
					}
					else if(mParams.containsKey("min " + sSetParam + " " + sSfx1))
					{
						bHasRange = true;
						sMinVal = mParams.get("min " + sSetParam + " " + sSfx1)[0];
					}

					if(mParams.containsKey("max " + sSetParam + " " + sSfx))
					{
						bHasRange = true;
						sMaxVal = mParams.get("max " + sSetParam + " " + sSfx)[0];
					}
					else if(mParams.containsKey("max " + sSetParam + " " + sSfx1))
					{
						bHasRange = true;
						sMaxVal = mParams.get("max " + sSetParam + " " + sSfx1)[0];
					}

					currBgColor = "#000000";
					if(bHasRange && sValue != null && !"".equals(sValue))
					{
						try
						{
							if(Double.parseDouble(sValue) < Double.parseDouble(sMinVal) ||
								Double.parseDouble(sValue) > Double.parseDouble(sMaxVal))
							{
								currBgColor = "#FF0000";
							}
						}
						catch(Exception e)
						{
							//do nothing
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
					
					if("On".equals(sValue) || "Off".equals(sValue) || slOnOffValues.contains(sParam) || slOnOffValues.contains(sParamGroup))
					{
						if(sParam.contains("door"))
						{
							if("1".equals(sValue) || "1.0".equals(sValue) || "On".equals(sValue))
							{
								sValue = "Close";
							}
							else if("0".equals(sValue) || "0.0".equals(sValue) || "Off".equals(sValue))
							{
								sValue = "Open";
							}
						}
						else if("1".equals(sValue) || "1.0".equals(sValue))
						{
							sValue = "On";
						}
						else if("0".equals(sValue) || "0.0".equals(sValue))
						{
							sValue = "Off";
						}
					}

					sCurrentVal = new String(sValue);
				}

				for(int k=0; k<alPhases.size(); k++)
				{
					sPhaseSeq = alPhases.get(k)[0];
					
					if(bParamGroup)
					{
						sValue = ""; sUnit = ""; sStage = "";
						groupParams = paramSettings.getGroupParams(sPhaseSeq);
						if(groupParams != null)
						{
							sStage = groupParams.getStage();
							sParam = groupParams.getParamName();
							sAccess = u.getUserAccess(groupParams);
							saParamVal = mParams.get(sParam);
							if(saParamVal != null)
							{
								sValue = saParamVal[0];
								sUnit = saParamVal[1];
							}
						}
					}

					if(sPhaseSeq.equals(sStage))
					{
						bHasRange = false;
						sMinVal = "0.0"; sMaxVal = "0.0";
						sSetParam = ((sParam.startsWith("set ")) ? sParam.substring(4, sParam.length()) : "");
						if(mParams.containsKey("min " + sSetParam))
						{
							bHasRange = true;
							sMinVal = mParams.get("min " + sSetParam)[0];
						}

						if(mParams.containsKey("max " + sSetParam))
						{
							bHasRange = true;
							sMaxVal = mParams.get("max " + sSetParam)[0];
						}

						bgColor = "#000000";
						if(bHasRange && sValue != null && !"".equals(sValue))
						{
							try
							{
								if(Double.parseDouble(sValue) < Double.parseDouble(sMinVal) || 
									Double.parseDouble(sValue) > Double.parseDouble(sMaxVal))
								{
									bgColor = "#FF0000";
								}
							}
							catch(Exception e)
							{
								//do nothing
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
						
						if("On".equals(sValue) || "Off".equals(sValue) || slOnOffValues.contains(sParam) || slOnOffValues.contains(sParamGroup))
						{
							if(sParam.contains("door"))
							{
								if("1".equals(sValue) || "1.0".equals(sValue) || "On".equals(sValue))
								{
									sValue = "Close";
								}
								else if("0".equals(sValue) || "0.0".equals(sValue) || "Off".equals(sValue))
								{
									sValue = "Open";
								}
							}
							else if("1".equals(sValue) || "1.0".equals(sValue))
							{
								sValue = "On";
							}
							else if("0".equals(sValue) || "0.0".equals(sValue))
							{
								sValue = "Off";
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
						
						tdColor = "#FFFFFF";
						if(sCurrPhase.equals(sPhaseSeq) || sCurrPhaseSeq.equals(sPhaseSeq))
						{
							if(slManualParams.contains(sParam) && ("On".equals(sValue) || "1".equals(sValue) || "1.0".equals(sValue)))
							{
								tdColor = "#0000FF";
							}							
							else if(slCoolingSteamParams.contains(sParam) && ("On".equals(sValue) || "1".equals(sValue) || "1.0".equals(sValue)))
							{
								tdColor = "#00F7FF";
							}
							else if(slCompErrParams.contains(sParam) && ("Off".equals(sValue) || "0".equals(sValue) || "0.0".equals(sValue)))
							{
								tdColor = "#FFA500";
							}
							else
							{
								tdColor = "#FFFF33";
							}
						}
%>
						<td class="text" style="background-color:<%= tdColor %>">
							<font color="<%= bgColor %>"><%= sValue %></font>
						</td>
<%
					}
					else if(sCurrPhase.equals(sPhaseSeq) || sCurrPhaseSeq.equals(sPhaseSeq))
					{
						if(java.util.regex.Pattern.matches("[0-9,.-]+", sCurrentVal))
						{
							try
							{
								sCurrentVal = decimalFormat.format(decimalFormat.parse(sCurrentVal));
							}
							catch(Exception e)
							{
								//do nothing
							}
						}
						
						tdColor = "#FFFF33";
						if(slManualParams.contains(sParam) && ("On".equals(sCurrentVal) || "1".equals(sCurrentVal) || "1.0".equals(sCurrentVal)))
						{
							tdColor = "#0000FF";
						}							
						else if(slCoolingSteamParams.contains(sParam) && ("On".equals(sCurrentVal) || "1".equals(sCurrentVal) || "1.0".equals(sCurrentVal)))
						{
							tdColor = "#00F7FF";
						}
						else if(slCompErrParams.contains(sParam) && ("Off".equals(sCurrentVal) || "0".equals(sCurrentVal) || "0.0".equals(sCurrentVal)))
						{
							tdColor = "#FFA500";
						}
%>
						<td class="text" style="background-color:<%= tdColor %>">
							<font color="<%= currBgColor %>"><%= sCurrentVal %></font>
						</td>
<%
					}
					else
					{
%>
						<td bgcolor="#FFFFFF">&nbsp;</td>
<%
					}
				}
%>						
			</tr>
<%
		}
%>
	</table>
	</div>
	</div>
	</div>
</body>
</html>
