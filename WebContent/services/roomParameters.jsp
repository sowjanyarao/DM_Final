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
	String emptyPhase = (alPhases.get(0)[0]).toLowerCase();
	String startPhase = (alPhases.get(1)[0]).toLowerCase();

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

	String sParams = "";
	StringList slGraphs = u.getSavedGraphs();

	Random randomGenerator = new Random();
	int randomInt = randomGenerator.nextInt(1000);

	SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy", Locale.ENGLISH);
	Calendar cal = Calendar.getInstance();
	String endDate = sdf.format(cal.getTime());
	cal.add(Calendar.DAY_OF_YEAR, -1);
	String startDate = sdf.format(cal.getTime());

	String sDefProduct = "Default Product";

	String sDefParamType = client.getBatchDefType();
	DefParamValues defParamVals = new DefParamValues();
	StringList slDefTypes = defParamVals.getDefaultTypes(sCntrlType);

	String sScrollLeft = (String)session.getAttribute("scrollLeft");
	sScrollLeft = (sScrollLeft == null ? "" : sScrollLeft);
	String sScrollTop = (String)session.getAttribute("scrollTop");
	sScrollTop = (sScrollTop == null ? "" : sScrollTop);

	session.removeAttribute("scrollLeft");
	session.removeAttribute("scrollTop");

	NumberFormat decimalFormat = NumberFormat.getInstance(Locale.getDefault());
	decimalFormat.setMinimumFractionDigits(1);
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
	<title></title>

	<link type="text/css" href="../styles/superTables.css" rel="stylesheet" />
    <script type="text/javascript" src="../scripts/superTables.js"></script>
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
		if (!String.prototype.trim)
		{
			String.prototype.trim = function() {
				return this.replace(/^\s+|\s+$/g,'');
			}
		}
		
		if (!String.prototype.startsWith) 
		{
			String.prototype.startsWith = function(searchString, position) {
				position = position || 0;
				return this.indexOf(searchString, position) === position;
			};
		}

		function saveChanges()
		{
			document.getElementById("loading").style.display = "block";

			var bFlag = setBatchNo();
			if(bFlag == true)
			{
				var sStartEmpty = document.getElementById("start.phase.empty");
				var sStartCycle = document.getElementById("start.cycle");
				
				var sStartPhase = document.getElementById("StartPhase").value;
				var sCurrPhase = document.getElementById("CurrPhase").value;
				
				if(sStartEmpty != null && sStartEmpty != "undefined")
				{
					if(sStartPhase == "true" && sCurrPhase != "0" && sStartEmpty.value == "1")
					{
						resetPhase();
					}
				}
				else if(sStartCycle != null && sStartCycle != "undefined")
				{
					if(sCurrPhase != "0" && sStartCycle.value == "Off")
					{
						resetPhase();
					}
				}

				document.getElementById("scrollLeft").value = myST.sData.scrollLeft;
				document.getElementById("scrollTop").value = myST.sData.scrollTop;

				document.forms[0].submit();
			}
			else
			{
				document.getElementById("loading").style.display = "none";
			}
		}
		
		function resetPhase()
		{
<%
			ParamSettings paramSettings = mViewParams.get("BatchNo");
			if((paramSettings != null) && RDMServicesConstants.ACCESS_READ.equals(u.getUserAccess(paramSettings)))
			{
%>
				var r = confirm("<%= resourceBundle.getProperty("DataManager.DisplayText.Start_Update_Batch") %>")
				if (r == true)
				{
					document.getElementById("ResetPhase").value = "true";
				}
<%
			}
			else
			{
%>
				document.getElementById("ResetPhase").value = "true";
<%
			}
%>
		}

		function resetChanges()
		{
			document.location.href = document.location.href;
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

		function showAlarms()
		{
			var retval = window.open('showAlarms.jsp?controller=<%= sController %>', 'Alarms', 'left=250,top=250,resizable=no,scrollbars=no,status=no,toolbar=no,height=500,width=620');
		}

		function addComments()
		{
			var retval = window.open('addUserComments.jsp?controller=<%= sController %>', 'Comments', 'left=250,top=250,resizable=no,scrollbars=no,status=no,toolbar=no,height=375,width=525');
		}

		function setValue(pid, pg, obj)
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
				obj.style.background = '#FFFFFF';
				val = obj.value.trim();
				elm.value = val;

				if(document.getElementById(pid+"_OldVal").value != val)
				{
					selectDiv(pg);
					obj.style.background = '#00FF00';
				}
			}
		}

		function startPhase(pid)
		{
			var r = confirm("<%= resourceBundle.getProperty("DataManager.DisplayText.Start_Phase") %>")
			if (r == true)
			{
				var options = document.getElementsByTagName("SELECT");
				for(var i=0; i<options.length; i++)
				{
					if(options[i].id == pid)
					{
						options[i].selectedIndex = 0;
						options[i].value = "1";

						document.getElementById(pid).selectedIndex = 0;
						document.getElementById(pid).value = "1";
						
						document.getElementById("StartPhase").value = "true";
					}
				}

				saveChanges();
			}
		}

		function setOnOff(pid, obj)
		{
			var sel = obj.value;
			if(sel == "On" || sel == "1")
			{
				document.getElementById(pid).selectedIndex = 0;
				document.getElementById(pid).value = sel;
				
				if(pid.startsWith('start phase'))
				{
					document.getElementById("StartPhase").value = "true";
				}
			}
			else if(sel == "Off" || sel == "0")
			{
				document.getElementById(pid).selectedIndex = 1;
				document.getElementById(pid).value = sel;
				
				if(pid.startsWith('start phase'))
				{
					document.getElementById("StartPhase").value = "false";
				}
			}
		}

		function initOnOff()
		{
			var options = document.getElementsByTagName("SELECT");
			for(var i=0; i<options.length; i++)
			{
				var id = options[i].id;
				if(id != "controller")
				{
					setOnOff(id, options[i]);
				}
			}
		}

		function printView()
		{
			var retval = window.open('roomParametersPrint.jsp?controller=<%= sController %>', '', 'left=250,top=250,resizable=yes,scrollbars=yes,status=no,toolbar=no,height=600,width=800');
		}

		function showImage()
		{
			parent.frames["content"].location.href = "roomImageView.jsp?controller=<%=sController%>";
		}

		function setBatchNo()
		{
			if(document.getElementById("StartPhase").value == "true")
			{
				var batchNo = document.getElementById("BatchNo");
				if(batchNo != null && batchNo != "undefined")
				{
					var bNo = batchNo.value.trim();
					if(bNo == "")
					{
						alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Enter_Batch_No") %>");
						return false;
					}
				}
			}
			return true;
		}

		function resetParameters()
		{
			if(document.getElementById("defParamType").value.trim() != "")
			{
				var r = confirm("<%= resourceBundle.getProperty("DataManager.DisplayText.Reset_Parameters") %>")
				if (r == true)
				{
					document.getElementById("resetParams").value = "true";
					saveChanges();
				}
			}
		}

		function selectDiv(e)
		{
			document.getElementById(e).style.backgroundColor = '#00ff00';
		}

		function unselectDiv(e)
		{
			document.getElementById(e).style.backgroundColor = '#b3b7bb';
		}

		function showGraph()
		{
			var idx = "<%= randomInt %>";
			document.frm3.target = "POPUPW_"+idx;
			POPUPW = window.open('about:blank','POPUPW_'+idx,'menubar=no,toolbar=no,location=no,resizable=yes,scrollbars=yes,status=no,height=<%= winHeight * 0.85 %>px,width=<%= winWidth * 0.90 %>px');
			document.frm3.submit();
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

<body onLoad="javascript:initOnOff()">
	<form name="frm1" method="post" action="setParametersProcess.jsp" target="hiddenFrame">
		<input type="hidden" id="conroller" name="controller" value="<%= sController %>">
		<input type="hidden" id="resetParams" name="resetParams" value="false">
		<input type="hidden" id="cntrlType" name="cntrlType" value="<%= sCntrlType %>">
		<input type='hidden' id='BNo' name='BNo' value='<%= sBatchNo %>'>
		<input type='hidden' id='StartPhase' name='StartPhase' value='false'>
		<input type='hidden' id='ResetPhase' name='ResetPhase' value='false'>
		<input type='hidden' id='CurrPhase' name='CurrPhase' value='<%= sCurrPhaseSeq %>'>		
		<input type='hidden' id='scrollLeft' name='scrollLeft' value=''>
		<input type='hidden' id='scrollTop' name='scrollTop' value=''>
		<table border="0" cellpadding="0" cellspacing="0" width="95%">
			<tr>
				<td style="font-family:Arial; font-size:0.8em; font-weight:bold; border:#ffffff; text-align:left">
					<%= resourceBundle.getProperty("DataManager.DisplayText.Room") %>:<br>
					<select id="controller" name="controller" onChange="javascript:changeController(this)">
<%
					if(RDMServicesConstants.ROLE_ADMIN.equals(u.getRole()) || RDMServicesConstants.ROLE_MANAGER.equals(u.getRole()))
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
				<td style="font-family:Arial; font-size:9pt; font-weight:bold; border:#ffffff; text-align:left">
					<%= resourceBundle.getProperty("DataManager.DisplayText.Manual_Setting") %>:<br>
					<font style="weight:normal; color:<%= "On".equals(sManual) ? "#0000FF" : "#000000" %>"><%= sManual %></font>&nbsp;
				</td>
<%
				if(!slCoolingSteamParams.isEmpty())
				{
%>
					<td style="font-family:Arial; font-size:9pt; font-weight:bold; border:#ffffff; text-align:left">
						<%= resourceBundle.getProperty("DataManager.DisplayText.Cooling_Steam") %>:<br>
						<font style="weight:normal; color:<%= "On".equals(sCoolingSteam) ? "#00F7FF" : "#000000" %>"><%= sCoolingSteam %></font>&nbsp;
					</td>
<%
				}

				if(!slCompErrParams.isEmpty())
				{
%>
					<td style="font-family:Arial; font-size:9pt; font-weight:bold; border:#ffffff; text-align:left">
						<%= resourceBundle.getProperty("DataManager.DisplayText.Comp_Error") %>:<br>
						<font style="weight:normal; color:<%= "Off".equals(sCompErr) ? "#FFA500" : "#000000" %>"><%= sCompErr %></font>&nbsp;
					</td>
<%
				}

				paramSettings = mViewParams.get("BatchNo");
				if((paramSettings != null) && RDMServicesConstants.ACCESS_READ.equals(u.getUserAccess(paramSettings)))
				{
%>
					<td style="font-family:Arial; font-size:9pt; font-weight:bold; border:#ffffff; text-align:left">
						<%= resourceBundle.getProperty("DataManager.DisplayText.Batch_No") %>:<br>
<%
					sBatchNo = (sBatchNo.startsWith("auto_") ? "" : sBatchNo);
					if(emptyPhase.equals(sCurrPhaseSeq))
					{
%>
						<input type='text' id='BatchNo' name='BatchNo' value='<%= sBatchNo %>' size='15'>
<%
					}
					else
					{
%>
						<%= sBatchNo %>
<%
					}
%>
					</td>
<%
				}

				paramSettings = mViewParams.get("Product");
				if((paramSettings != null) && RDMServicesConstants.ACCESS_READ.equals(u.getUserAccess(paramSettings)))
				{
%>
					<td style="font-family:Arial; font-size:9pt; font-weight:bold; border:#ffffff; text-align:left">
						<%= resourceBundle.getProperty("DataManager.DisplayText.Product") %>:<br>
<%
					if(emptyPhase.equals(sCurrPhaseSeq))
					{
%>
						<select id="defParamType" name="defParamType" onChange="javascript:resetParameters()">
							<option value="" <%= ((sDefParamType == null || "".equals(sDefParamType)) ? "selected" : "") %>><%= resourceBundle.getProperty("DataManager.DisplayText.Please_Select") %></option>
							<option value="<%= sDefProduct %>" <%= (sDefProduct.equals(sDefParamType) ? "selected" : "") %>><%= sDefProduct %></option>
<%
						String sDefType = null;
						for(int i=0; i<slDefTypes.size(); i++)
						{
							sDefType = slDefTypes.get(i);
%>
							<option value="<%= sDefType %>" <%= (sDefType.equals(sDefParamType) ? "selected" : "") %>><%= sDefType %></option>
<%
						}
%>
						</select>
<%
					}
					else
					{
%>
						<%= sDefParamType %>
						<input type='hidden' id='defParamType' name='defParamType' value='<%= sDefParamType %>'>
<%
					}
%>
					</td>
<%
				}
%>
				<td style="font-family:Arial; font-size:0.8em; border:#ffffff; text-align:right">
					<input type="button" id="Alarms" name="Alarms" value="<%= resourceBundle.getProperty("DataManager.DisplayText.View_Alarms").replaceAll("\\s", "\n") %>" onClick="javascript:showAlarms()">&nbsp;
<%
					paramSettings = mViewParams.get("ViewImage");
					if((paramSettings != null) && RDMServicesConstants.ACCESS_READ.equals(u.getUserAccess(paramSettings)))
					{
%>
						<input type="button" id="Image" name="Image" value="<%= resourceBundle.getProperty("DataManager.DisplayText.View_Image").replaceAll("\\s", "\n") %>" onClick="javascript:showImage()">&nbsp;
<%
					}

					if(slGraphs.contains(sCntrlType+" Dashboard"))
					{
						Map<String, String> mGrpParams = u.getGraphParams(sCntrlType+" Dashboard");
						sParams = mGrpParams.get("PARAMS").replaceAll(",", "\\|");
%>
						<input type="button" id="Graph" name="Graph" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Show_Graph").replaceAll("\\s", "\n") %>" onClick="javascript:showGraph()">&nbsp;
<%
					}
					else
					{
%>
						<input type="button" id="Graph" name="Graph" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Show_Graph").replaceAll("\\s", "\n") %>">&nbsp;
<%
					}

					if(!RDMServicesConstants.ROLE_HELPER.equals(u.getRole()))
					{
%>
						<input type="button" id="Comments" name="Comments" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Add_Comments").replaceAll("\\s", "\n") %>" onClick="javascript:addComments()">&nbsp;
						<input type="button" id="Save" name="Save" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Save_Changes").replaceAll("\\s", "\n") %>" onClick="javascript:saveChanges()">&nbsp;
<%
					}
%>
					<input type="button" id="Refresh" name="Refresh" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Reload_Values").replaceAll("\\s", "\n") %>" onClick="javascript:resetChanges()">&nbsp;
					<input type="button" id="Print" name="Print" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Print") %>" onClick="javascript:printView()">
				</td>
				<td>
<%
					if(!RDMServicesConstants.ROLE_HELPER.equals(u.getRole()))
					{
%>
						<div id="loading" style="display:none"><image src="../images/loading_icon.gif"></div>
<%
					}
%>
				</td>
			</tr>
		</table>

		<div id="scrollDiv">
			<table id="freezeHeaders" border="1" cellpadding="2" cellspacing="0">
				<tr>
					<th style="border-right:0px"><%= resourceBundle.getProperty("DataManager.DisplayText.Parameter_Unit") %></th>
					<th style="border-left:0px">&nbsp;</th>
<%
					String sPhaseSeq = "";
					String stageName = "";
					String sSfx = "";
					String sSfx1 = "";
					String sPhaseLabel = "";
					String sParamGroup = "";
					String sStartPhase = "";
					String sAccess = "";
					ParamSettings groupParams = null;

					int phaseIdx = 1;
					for(int i=0; i<alPhases.size(); i++)
					{
						sPhaseSeq = alPhases.get(i)[0];
						stageName = alPhases.get(i)[1];
						sPhaseLabel = ((sPhaseSeq.equals(stageName) || "-".equals(stageName)) ? sPhaseSeq : (sPhaseSeq +"<br>"+ stageName));
						sStartPhase = "start phase " + ("0".equalsIgnoreCase(sPhaseSeq) ? stageName : sPhaseSeq);

						boolean bStartPhase = false;
						paramSettings = mViewParams.get("start");
						if(paramSettings != null)
						{
							groupParams = paramSettings.getGroupParams(sPhaseSeq);
							if(groupParams != null)
							{
								sAccess = u.getUserAccess(groupParams);
								if(RDMServicesConstants.ACCESS_WRITE.equals(sAccess))
								{
									bStartPhase = true;
								}
							}
						}

						if(sCurrPhase.equals(sPhaseSeq) || sCurrPhaseSeq.equals(sPhaseSeq))
						{
							if("0".equalsIgnoreCase(sPhaseSeq))
							{
								sSfx = stageName;
								sSfx1 = " phase" + " " + stageName;
							}
							else
							{
								phaseIdx = i;
								if(!sPhaseSeq.equals(stageName))
								{
									sSfx = stageName + " " + sPhaseSeq;
								}
								sSfx1 = " phase" + " " + sPhaseSeq;
							}
%>
							<th style="text-align:center; vertical-align:top; background-color:<%= bHasOpenAlarms ? "#ff0000" : "#00ff00" %>; color: #000000">
								<label id="currPhase">
<%
								if(bStartPhase)
								{
%>
									<a href="javascript:startPhase('<%= sStartPhase.toLowerCase() %>')"><%= sPhaseLabel.replaceAll(" ", "<br>") %></a>
<%
								}
								else
								{
%>
									<%= sPhaseLabel.replaceAll(" ", "<br>") %>
<%
								}
%>
								</label>
							</th>
<%
						}
						else
						{
%>
							<th style="text-align:center; vertical-align:top">
<%
							if(bStartPhase)
							{
%>
								<a href="javascript:startPhase('<%= sStartPhase.toLowerCase() %>')"><%= sPhaseLabel.replaceAll(" ", "<br>") %></a>
<%
							}
							else
							{
%>
								<%= sPhaseLabel.replaceAll(" ", "<br>") %>
<%
							}
%>
							</th>
<%
						}
					}

					if((((double)alPhases.size() / (double)phaseIdx) <= 2.0) && ("".equals(sScrollLeft) && "".equals(sScrollTop)))
					{
						sScrollLeft = "1000";
						sScrollTop = "0";
					}
%>
				</tr>
				<tr>
					<th style="text-align:left;border-right:0px"><%= resourceBundle.getProperty("DataManager.DisplayText.Start_Timestamp") %></th>
					<th style="border-left:0px">&nbsp;</th>
<%
					String sStarted = "";
					for(int i=0; i<alPhases.size(); i++)
					{
						sPhaseSeq = alPhases.get(i)[0];
						sStarted = mPhaseStartTime.get(sPhaseSeq);
						sStarted = (sStarted == null ? "&nbsp;" : sStarted);
%>
						<td style="text-align:center"><label><%= sStarted.replaceAll(" ", "<br>") %><label></td>
<%
					}
%>
				</tr>
<%
				boolean bShowSaveReset = false;
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
				String sSetParam = null;
				String bgColor = null;
				String sCurrentVal = null;
				String sCurrentAcc = null;
				String currBgColor = null;
				String[] saParamVal = null;
				Map<String, String> mParamMaxMinVal = new HashMap<String, String>();

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
								<th align="center" colspan="<%= alPhases.size() + 3 %>">
									<%= sHeader %>
								</th>
							</tr>
<%
							alDisplayOrder.remove(0);
							slHeaders.add(sHeader);
						}
					}

					sCurrentAcc = u.getUserAccess(paramSettings);
					if(sCurrentAcc == null || RDMServicesConstants.ACCESS_NONE.equals(sCurrentAcc))
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
%>
					<tr>
						<th style="text-align: left;border-right:0px">
							<div id="<%= sParamGroup %>_PG">
								<%= sParam %>
<%
								if(!"".equals(sUnit))
								{
%>
									&nbsp;<label class="unit">(<%= sUnit %>)</label>
<%
								}
%>
							</div>
						</th>
						<th style="border-left:0px">
							<img src="../images/info.png" height="18" width="18">
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

							currBgColor = "#FFFFFF";
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

							if(RDMServicesConstants.ACCESS_WRITE.equals(sCurrentAcc))
							{
								bShowSaveReset = true;
								if(bHasRange)
								{
									try
									{
										mParamMaxMinVal.put(sParam+"_MinVal", numberFormat.format(Double.parseDouble(sMinVal)));
										mParamMaxMinVal.put(sParam+"_MaxVal", numberFormat.format(Double.parseDouble(sMaxVal)));
									}
									catch(Exception e)
									{
										//do nothing
									}
								}
								sCurrentVal = new String(sValue);
							}
							else if(RDMServicesConstants.ACCESS_READ.equals(sCurrentAcc))
							{
								sCurrentVal = new String(sValue);
							}
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
								sMinVal = ""; sMaxVal = "";
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

								if(sCurrPhase.equals(sPhaseSeq) || sCurrPhaseSeq.equals(sPhaseSeq))
								{
									if(slManualParams.contains(sParamGroup) && ("On".equals(sValue) || "1".equals(sValue) || "1.0".equals(sValue)))
									{
										bgColor = "#0000FF";
									}
									else if(slCoolingSteamParams.contains(sParamGroup) && ("On".equals(sValue) || "1".equals(sValue) || "1.0".equals(sValue)))
									{
										bgColor = "#00F7FF";
									}
									else if(slCompErrParams.contains(sParam) && ("Off".equals(sValue) || "0".equals(sValue) || "0.0".equals(sValue)))
									{
										bgColor = "#FFA500";
									}
									else
									{
										bgColor = "#FFFF33";
									}
								}
								else
								{
									bgColor = "#FFFFFF";
								}
%>
								<td bgcolor="<%= bgColor %>">
<%
								bgColor = "#FFFFFF";
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

								if(RDMServicesConstants.ACCESS_WRITE.equals(sAccess))
								{
									bShowSaveReset = true;
									if(bHasRange)
									{
										try
										{
											mParamMaxMinVal.put(sParam+"_MinVal", numberFormat.format(Double.parseDouble(sMinVal)));
											mParamMaxMinVal.put(sParam+"_MaxVal", numberFormat.format(Double.parseDouble(sMaxVal)));
										}
										catch(Exception e)
										{
											//do nothing
										}
									}

									if("On".equals(sValue) || "Off".equals(sValue))
									{
%>
										<select id="<%= sParam %>" name="<%= sParam %>" onChange="javascript:setOnOff('<%= sParam %>', this);" onclick="javascript:selectDiv('<%= sParamGroup %>_PG');this.focus();this.select()" onBlur="javascript:unselectDiv('<%= sParamGroup %>_PG');setValue('<%= sParam %>', '<%= sParamGroup %>_PG', this)">
											<option value="On" <%= "On".equals(sValue) ? "selected" : "" %>><%= (sParam.contains("door") ? resourceBundle.getProperty("DataManager.DisplayText.Close") : resourceBundle.getProperty("DataManager.DisplayText.On")) %></option>
											<option value="Off" <%= "Off".equals(sValue) ? "selected" : "" %>><%= (sParam.contains("door") ? resourceBundle.getProperty("DataManager.DisplayText.Open") : resourceBundle.getProperty("DataManager.DisplayText.Off")) %></option>
										</select>
<%
									}
									else if(slOnOffValues.contains(sParam) || slOnOffValues.contains(sParamGroup))
									{
%>
										<select id="<%= sParam %>" name="<%= sParam %>" onChange="javascript:setOnOff('<%= sParam %>', this);" onclick="javascript:selectDiv('<%= sParamGroup %>_PG');this.focus();this.select()" onBlur="javascript:unselectDiv('<%= sParamGroup %>_PG');setValue('<%= sParam %>', '<%= sParamGroup %>_PG', this)">
											<option value="1" <%= ("1".equals(sValue) || "1.0".equals(sValue)) ? "selected" : "" %>><%= (sParam.contains("door") ? resourceBundle.getProperty("DataManager.DisplayText.Close") : resourceBundle.getProperty("DataManager.DisplayText.On")) %></option>
											<option value="0" <%= ("0".equals(sValue) || "0.0".equals(sValue)) ? "selected" : "" %>><%= (sParam.contains("door") ? resourceBundle.getProperty("DataManager.DisplayText.Open") : resourceBundle.getProperty("DataManager.DisplayText.Off")) %></option>
										</select>
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
										<input type="text" id="<%= sParam %>" name="<%= sParam %>" value="<%= sValue %>" style="background:<%= bgColor %>" size="8" onBlur="javascript:unselectDiv('<%= sParamGroup %>_PG');setValue('<%= sParam %>', '<%= sParamGroup %>_PG', this)" onclick="javascript:selectDiv('<%= sParamGroup %>_PG');this.focus();this.select()">
<%
									}
%>
									<input type="hidden" id="<%= sParam %>_OldVal" name="<%= sParam %>_OldVal" value="<%= sValue %>">
<%
								}
								else if(RDMServicesConstants.ACCESS_READ.equals(sAccess))
								{
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
%>
									<label><%= sValue %></label>
<%
								}
								else
								{
%>
									&nbsp;
<%
								}
%>
								</td>
<%
							}
							else if(sCurrPhase.equals(sPhaseSeq) || sCurrPhaseSeq.equals(sPhaseSeq))
							{
								bgColor = "#FFFF33";
								if(slManualParams.contains(sParamGroup) && ("On".equals(sCurrentVal) || "1".equals(sCurrentVal) || "1.0".equals(sCurrentVal)))
								{
									bgColor = "#0000FF";
								}
								else if(slCoolingSteamParams.contains(sParamGroup) && ("On".equals(sValue) || "1".equals(sValue) || "1.0".equals(sValue)))
								{
									bgColor = "#00F7FF";
								}
								else if(slCompErrParams.contains(sParamGroup) && ("Off".equals(sCurrentVal) || "0".equals(sCurrentVal) || "0.0".equals(sCurrentVal)))
								{
									bgColor = "#FFA500";
								}
%>
								<td bgcolor="<%= bgColor %>">
<%
								if(RDMServicesConstants.ACCESS_WRITE.equals(sCurrentAcc))
								{
									if("On".equals(sCurrentVal) || "Off".equals(sCurrentVal) || "Open".equals(sCurrentVal) || "Close".equals(sCurrentVal))
									{
%>
										<select id="<%= sParamGroup %>" name="<%= sParamGroup %>" onChange="javascript:setOnOff('<%= sParamGroup %>', this);" onclick="javascript:selectDiv('<%= sParamGroup %>_PG');this.focus();this.select()" onBlur="javascript:unselectDiv('<%= sParamGroup %>_PG');setValue('<%= sParamGroup %>', '<%= sParamGroup %>_PG', this)">
											<option value="On" <%= ("On".equals(sCurrentVal) || "Close".equals(sCurrentVal)) ? "selected" : "" %>><%= (sParamGroup.contains("door") ? resourceBundle.getProperty("DataManager.DisplayText.Close") : resourceBundle.getProperty("DataManager.DisplayText.On")) %></option>
											<option value="Off" <%= ("Off".equals(sCurrentVal) || "Open".equals(sCurrentVal)) ? "selected" : "" %>><%= (sParamGroup.contains("door") ? resourceBundle.getProperty("DataManager.DisplayText.Open") : resourceBundle.getProperty("DataManager.DisplayText.Off")) %></option>
										</select>
<%
									}
									else
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
%>
										<input type="text" id="<%= sParamGroup %>" name="<%= sParamGroup %>" value="<%= sCurrentVal %>" style="background:<%= currBgColor %>" size="8" onBlur="javascript:unselectDiv('<%= sParamGroup %>_PG');setValue('<%= sParamGroup %>', '<%= sParamGroup %>_PG', this)" onclick="javascript:selectDiv('<%= sParamGroup %>_PG');this.focus();this.select()">
<%
									}
%>
									<input type="hidden" id="<%= sParamGroup %>_OldVal" name="<%= sParamGroup %>_OldVal" value="<%= sCurrentVal %>">
<%
								}
								else if(RDMServicesConstants.ACCESS_READ.equals(sCurrentAcc))
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
%>
									<label><%= sCurrentVal %></label>
<%
								}
%>
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
	</form>

	<table border="0" cellpadding="0" cellspacing="0" width="95%">
		<td style="font-family:Arial; font-size:0.8em; font-weight:bold; border:#ffffff; text-align:center">
			<%= resourceBundle.getProperty("DataManager.DisplayText.Last_updated_on") %>:&nbsp;<font style="weight:normal; color:#FF0000"><%= sDate %></font>
		</td>
	</table>

	<form name="frm2">
<%
	String sKey = "";
	String sVal = "";
	Iterator<String> itr = mParamMaxMinVal.keySet().iterator();
	while(itr.hasNext())
	{
		sKey = itr.next();
		sVal = mParamMaxMinVal.get(sKey);
%>
		<input type="hidden" id="<%= sKey %>" name="<%= sKey %>" value="<%= sVal %>">
<%
	}
%>
	</form>

	<form name="frm3" method="post" action="showAttrDataGraph.jsp">
		<input type="hidden" id="saveAs" name="saveAs" value="">
		<input type="hidden" id="lstController" name="lstController" value="<%= sController %>">
		<input type="hidden" id="Parameters" name="Parameters" value="<%= sParams %>">
		<input type="hidden" id="start_date" name="start_date" value="<%= startDate %>">
		<input type="hidden" id="end_date" name="end_date" value="<%= endDate %>">
		<input type="hidden" id="yield" name="yield" value="">
		<input type="hidden" id="access" name="access" value="">
	</form>

	<script type="text/javascript">
		var myST = new superTable("freezeHeaders", {
			cssSkin : "sGrey",
			headerRows : 2,
			fixedCols : 2
		});
<%
		if(!"".equals(sScrollLeft) && !"".equals(sScrollTop))
		{
%>
			myST.sData.scrollLeft = "<%= sScrollLeft %>";
			myST.sData.scrollTop = "<%= sScrollTop %>";
<%
		}
%>
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
