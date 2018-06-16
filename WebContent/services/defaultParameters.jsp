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
	String sDefParamType = request.getParameter("defParamType");
	sDefParamType = ((sDefParamType == null || "".equals(sDefParamType)) ? "Default Product" : sDefParamType);
	StringList slControllers = RDMSession.getControllers(u);	
	ArrayList<String[]> alPhases = RDMServicesUtils.getControllerStages(sController);
	
	Map<String, ParamSettings> mViewParams = RDMServicesUtils.getSingleRoomViewParamaters(sController);
	ArrayList<String> alParams = RDMServicesUtils.getDisplayOrder(sController);

	DefParamValues defParamVals = new DefParamValues();
	Map<String, String> mParams = defParamVals.getDefaultParamValues(sController, sDefParamType);
	Map<String, String> mCntrlParams = RDMSession.getControllerParameters(sController);

	String sHeader = null;
	StringList slHeaders = new StringList();
	Map<String, String> mParamHeaders = RDMServicesUtils.displayHeaders(sController);
	
	Map<Integer, String> mDisplayHeaders = RDMServicesUtils.getHeaders(sController);
	ArrayList<Integer> alDisplayOrder = new ArrayList<Integer>();
	alDisplayOrder.addAll(mDisplayHeaders.keySet());
	Collections.sort(alDisplayOrder);
	
	StringList slOnOffValues = RDMServicesUtils.getOnOffParams(sController);
	StringList slManualParams = RDMServicesUtils.getManualParams(sController);
	
	String sDefaultProduct = "Default Product";
	
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

		function saveChanges()
		{
			document.getElementById("mode").value = "save";
			document.forms[0].submit();
		}
		
		function copyValues()
		{
			var copyTo = document.getElementById("defParamType").value;
			var copyFrom = document.getElementById("copyFrom").value;
			if(copyFrom == "")
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Select_Copy_From") %>");
				return false;
			}
			
			document.getElementById("mode").value = "copy";
			parent.frames['hiddenFrame'].document.location.href = "setDefaultParameters.jsp?mode=copy&toDefType="+copyTo+"&fromDefType="+copyFrom+"&controller=<%= sController %>";
		}
		
		function changeController(obj)
		{
			var sCntrl = obj.value;
			if(sCntrl == "General")
			{
				parent.document.location.href = "generalParamsView.jsp?controller="+sCntrl;
			}
			else if(sCntrl == "Bunker" || sCntrl == "Tunnel" || sCntrl == "Grower")
			{
				document.location.href = "defaultParamsView.jsp?controller="+sCntrl;
			}
			else
			{
				parent.document.location.href = "singleRoomView.jsp?controller="+sCntrl;
			}
		}
		
		function changeDefaultValues(obj)
		{
			var sDefType = obj.value;
			document.location.href = "defaultParamsView.jsp?controller=<%= sController %>&defParamType="+sDefType;
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
				if(id != "controller")
				{
					setOnOff(id, options[i]);
				}
			}
		}

		function printView()
		{		
			var retval = window.open('defaultParametersPrint.jsp?controller=<%= sController %>&defParamType=<%= sDefParamType %>', '', 'left=250,top=250,resizable=yes,scrollbars=yes,status=no,toolbar=no,height=600,width=800');
		}
		function selectDiv(e)
		{
			document.getElementById(e).style.backgroundColor = '#00ff00';
		}
		
		function unselectDiv(e)
		{
			document.getElementById(e).style.backgroundColor = '#b3b7bb';
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
	<table border="0" cellpadding="0" cellspacing="0" width="95%">
		<tr>
			<td style="font-family:Arial; font-size:0.8em; font-weight:bold; border:#ffffff; text-align:left">
				<%= resourceBundle.getProperty("DataManager.DisplayText.Select_Room") %>:&nbsp;
				<select id="controller" name="controller" onChange="javascript:changeController(this)">
<%
				if(RDMServicesConstants.ROLE_ADMIN.equals(u.getRole()) || RDMServicesConstants.ROLE_MANAGER.equals(u.getRole()))
				{
%>
					<optgroup label="Default Values">
<%
					boolean bViewGrwDB = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_GROWER);
					if(bViewGrwDB && (RDMSession.getControllers(RDMServicesConstants.TYPE_GROWER).size() > 0))
					{
%>
						<option value="<%= RDMServicesConstants.TYPE_GROWER %>" <%= (sController.equals(RDMServicesConstants.TYPE_GROWER) ? "selected" : "") %>><%= resourceBundle.getProperty("DataManager.DisplayText.Grower") %></option>
<%
					}
					boolean bViewBnkDB = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_BUNKER);
					if(bViewBnkDB && (RDMSession.getControllers(RDMServicesConstants.TYPE_BUNKER).size() > 0))
					{
%>
						<option value="<%= RDMServicesConstants.TYPE_BUNKER %>" <%= (sController.equals(RDMServicesConstants.TYPE_BUNKER) ? "selected" : "") %>><%= resourceBundle.getProperty("DataManager.DisplayText.Bunker") %></option>
<%
					}
					boolean bViewTnlDB = u.hasViewAccess(RDMServicesConstants.ROOMS_VIEW_DASHBOARD_TUNNEL);
					if(bViewTnlDB && (RDMSession.getControllers(RDMServicesConstants.TYPE_TUNNEL).size() > 0))
					{
%>
						<option value="<%= RDMServicesConstants.TYPE_TUNNEL %>" <%= (sController.equals(RDMServicesConstants.TYPE_TUNNEL) ? "selected" : "") %>><%= resourceBundle.getProperty("DataManager.DisplayText.Tunnel") %></option>
<%
					}
%>
					<optgroup label="Controllers">
<%
				}

				String sCntrlName = "";
				for(int i=0; i<slControllers.size(); i++)
				{
					sCntrlName = slControllers.get(i);
%>
					<option value="<%= sCntrlName %>"><%= sCntrlName %></option>
<%
				}
%>
				</select>
				&nbsp;&nbsp;
				<%= resourceBundle.getProperty("DataManager.DisplayText.Product") %>:&nbsp;
				<select id="defParamType" name="defParamType" onChange="javascript:changeDefaultValues(this)">
					<option value="<%= sDefaultProduct %>" <%= (sDefParamType.equals(sDefaultProduct) ? "selected" : "") %>><%= resourceBundle.getProperty("DataManager.DisplayText.Default_Product") %></option>
<%
				String sDefType = null;
				StringList slDefTypes = defParamVals.getDefaultTypes(sController);
				for(int i=0; i<slDefTypes.size(); i++)
				{
					sDefType = slDefTypes.get(i);
%>
					<option value="<%= sDefType %>" <%= (sDefParamType.equals(sDefType) ? "selected" : "") %>><%= sDefType %></option>
<%
				}
%>
				</select>
				&nbsp;&nbsp;
				<%= resourceBundle.getProperty("DataManager.DisplayText.Copy_From") %>:&nbsp;
				<select id="copyFrom" name="copyFrom">
					<option value="" <%= sDefParamType.equals(sDefaultProduct) ? "selected" : "" %>><%= resourceBundle.getProperty("DataManager.DisplayText.Please_Select") %></option>
<%
				if(!sDefParamType.equals(sDefaultProduct))
				{
%>
					<option value="<%= sDefaultProduct %>" selected><%= resourceBundle.getProperty("DataManager.DisplayText.Default_Product") %></option>
<%
				}
				for(int i=0; i<slDefTypes.size(); i++)
				{
					sDefType = slDefTypes.get(i);
					if(!sDefParamType.equals(sDefType))
					{
%>
						<option value="<%= sDefType %>" <%= (sDefParamType.equals(sDefType) ? "selected" : "") %>><%= sDefType %></option>
<%
					}
				}
%>
				</select>
			</td>

			<td style="font-family:Arial; font-size:0.8em; font-weight:bold; color:#0000FF; text-align:right">
				<input type="button" id="copy" name="copy" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Copy_Values") %>" onClick="javascript:copyValues()">
				<input type="button" id="Save" name="Save" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Save_Changes") %>" onClick="javascript:saveChanges()">
				<input type="button" id="Print" name="Print" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Print") %>" onClick="javascript:printView()">
			</td>
		</tr>
	</table>
	
	<form name="frm1" method="post" action="setDefaultParameters.jsp" target="hiddenFrame">
	<input type="hidden" id="controller" name="controller" value="<%= sController %>">
	<input type="hidden" id="defParamType" name="defParamType" value="<%= sDefParamType %>">
	<input type="hidden" id="mode" name="mode" value="">
	<div id="scrollDiv">
		<table id="freezeHeaders" border="1" cellpadding="2" cellspacing="0">
			<tr>
				<th style="border-right:0px"><%= resourceBundle.getProperty("DataManager.DisplayText.Parameter_Unit") %></th>
				<th style="border-left:0px">&nbsp;</th>
				<th>&nbsp;</th>
<%
				String sPhaseSeq = "";
				String stageName = "";
				String sSfx = "";
				String sSfx1 = "";
				String sPhaseLabel = "";
				String sParamGroup = "";
				
				for(int i=0; i<alPhases.size(); i++)
				{
					sPhaseSeq = alPhases.get(i)[0];
					stageName = alPhases.get(i)[1];
					
					sPhaseLabel = ((sPhaseSeq.equals(stageName) || "-".equals(stageName)) ? sPhaseSeq : (sPhaseSeq +"<br>"+ stageName));
%>
					<th style="text-align: center">
						<%= sPhaseLabel.replaceAll(" ", "<br>") %>
					</th>
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
			String sDefVal = null;
			String sUnit = null;
			String sStage = null;
			String sAccess = null;
			String sSetParam = null;
			String bgColor = null;
			Map<String, String> mParamMaxMinVal = new HashMap<String, String>();
			ParamSettings paramSettings = null;
			ParamSettings groupParams = null;

			for(int i=0; i<alParams.size(); i++)
			{
				sParam = (String)alParams.get(i);
				paramSettings = mViewParams.get(sParam);
				if(paramSettings == null)
				{
					continue;
				}
				
				sAccess = u.getUserAccess(paramSettings);
				bParamGroup = paramSettings.hasGroupParams();
				if(sAccess == null || RDMServicesConstants.ACCESS_NONE.equals(sAccess) || (!(RDMServicesConstants.ACCESS_WRITE.equals(sAccess) || bParamGroup)))
				{
					continue;
				}
				
				sParamGroup = new String(sParam);
				if("time".equals(sParamGroup))
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

				sStage = paramSettings.getStage();

				sUnit = mCntrlParams.get(sParam);
				sUnit = ((sUnit == null) ? "" : sUnit);
				
				sDefVal = mParams.get(sParam);
				sDefVal = ((sDefVal == null) ? "" : sDefVal);
				
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
				if("NA".equals(sStage))
				{
					bHasRange = false;
					if(mParams.containsKey(sParam + " empty") || mParams.containsKey(sParam + " phase empty"))
					{
						bHasRange = true;
					}

					if(mParams.containsKey(sParam + " empty") || mParams.containsKey(sParam + " phase empty"))
					{
						bHasRange = true;
					}
					
					try
					{
						if(!("On".equals(sDefVal) || "Off".equals(sDefVal) || sDefVal.contains(":")))
						{
							sDefVal = numberFormat.format(Double.parseDouble(sDefVal));
						}
					}
					catch(Exception e)
					{
						//do nothing
					}
%>
					<td bgcolor="<%= ((slManualParams.contains(sParam) && ("On".equals(sDefVal) || "1".equals(sDefVal))) ? "#0000FF" : "#FFFFFF") %>">
<%
					if(!bHasRange && RDMServicesConstants.ACCESS_WRITE.equals(sAccess))
					{
						if("On".equals(sDefVal) || "Off".equals(sDefVal))
						{
%>
							<select id="<%= sParam %>" name="<%= sParam %>" onChange="javascript:setOnOff('<%= sParam %>', this);">
								<option value="" <%= "".equals(sDefVal) ? "selected" : "" %>></option>
								<option value="On" <%= "On".equals(sDefVal) ? "selected" : "" %>><%= (sParam.contains("door.open") ? resourceBundle.getProperty("DataManager.DisplayText.Open") : resourceBundle.getProperty("DataManager.DisplayText.On")) %></option>
								<option value="Off" <%= "Off".equals(sDefVal) ? "selected" : "" %>><%= (sParam.contains("door.open") ? resourceBundle.getProperty("DataManager.DisplayText.Close") : resourceBundle.getProperty("DataManager.DisplayText.Off")) %></option>
							</select>
<%
						}
						else if(slOnOffValues.contains(sParam) || slManualParams.contains(sParamGroup))
						{
%>
							<select id="<%= sParam %>" name="<%= sParam %>" onChange="javascript:setOnOff('<%= sParam %>', this);">
								<option value="" <%= "".equals(sDefVal) ? "selected" : "" %>></option>
								<option value="1" <%= "1".equals(sDefVal) ? "selected" : "" %>><%= (sParam.contains("door.open") ? resourceBundle.getProperty("DataManager.DisplayText.Open") : resourceBundle.getProperty("DataManager.DisplayText.On")) %></option>
								<option value="0" <%= "0".equals(sDefVal) ? "selected" : "" %>><%= (sParam.contains("door.open") ? resourceBundle.getProperty("DataManager.DisplayText.Close") : resourceBundle.getProperty("DataManager.DisplayText.Off")) %></option>
							</select>
<%
						}
						else
						{
							if(java.util.regex.Pattern.matches("[0-9,.-]+", sDefVal))
							{
								try
								{
									sDefVal = decimalFormat.format(decimalFormat.parse(sDefVal));
								}
								catch(Exception e)
								{
									//do nothing
								}
							}
%>
							<input type="text" id="<%= sParam %>" name="<%= sParam %>" value="<%= sDefVal %>" style="background:<%= bgColor %>" size="8" onBlur="javascript:unselectDiv('<%= sParam %>_PG');setValue('<%= sParam %>', '<%= sParam %>_PG', this)" onclick="javascript:selectDiv('<%= sParam %>_PG');this.focus();this.select()">
<%
						}
%>
						<input type="hidden" id="<%= sParam %>_OldVal" name="<%= sParam %>_OldVal" value="<%= sDefVal %>">
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

				for(int k=0; k<alPhases.size(); k++)
				{
					sPhaseSeq = alPhases.get(k)[0];
					
					if(bParamGroup)
					{
						sStage = "";
						groupParams = paramSettings.getGroupParams(sPhaseSeq);
						if(groupParams != null)
						{
							sStage = groupParams.getStage();
							sParam = groupParams.getParamName();
							sAccess = u.getUserAccess(groupParams);
							sDefVal = mParams.get(sParam);
							sDefVal = ((sDefVal == null) ? "" : sDefVal);
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
							sMinVal = mParams.get("min " + sSetParam);
						}

						if(mParams.containsKey("max " + sSetParam))
						{
							bHasRange = true;
							sMaxVal = mParams.get("max " + sSetParam);
						}
						
						bgColor = "#ffffff";
						if(bHasRange && sDefVal != null && !"".equals(sDefVal))
						{
							try
							{
								if(Double.parseDouble(sDefVal) < Double.parseDouble(sMinVal) || 
									Double.parseDouble(sDefVal) > Double.parseDouble(sMaxVal))
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
							if(!("On".equals(sDefVal) || "Off".equals(sDefVal) || sDefVal.contains(":")))
							{
								sDefVal = numberFormat.format(Double.parseDouble(sDefVal));
							}
						}
						catch(Exception e)
						{
							//do nothing
						}
%>
						<td>
<%
						if(RDMServicesConstants.ACCESS_WRITE.equals(sAccess))
						{
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

							if("On".equals(sDefVal) || "Off".equals(sDefVal))
							{
%>
								<select id="<%= sParam %>" name="<%= sParam %>" onChange="javascript:setOnOff('<%= sParam %>', this);">
									<option value="" <%= "".equals(sDefVal) ? "selected" : "" %>></option>
									<option value="On" <%= "On".equals(sDefVal) ? "selected" : "" %>><%= (sParam.contains("door.open") ? resourceBundle.getProperty("DataManager.DisplayText.Open") : resourceBundle.getProperty("DataManager.DisplayText.On")) %></option>
									<option value="Off" <%= "Off".equals(sDefVal) ? "selected" : "" %>><%= (sParam.contains("door.open") ? resourceBundle.getProperty("DataManager.DisplayText.Close") : resourceBundle.getProperty("DataManager.DisplayText.Off")) %></option>
								</select>
<%
							}
							else if(slOnOffValues.contains(sParam) || slManualParams.contains(sParamGroup))
							{
%>
								<select id="<%= sParam %>" name="<%= sParam %>" onChange="javascript:setOnOff('<%= sParam %>', this);">
									<option value="" <%= "".equals(sDefVal) ? "selected" : "" %>></option>
									<option value="1" <%= "1".equals(sDefVal) ? "selected" : "" %>><%= resourceBundle.getProperty("DataManager.DisplayText.On") %></option>
									<option value="0" <%= "0".equals(sDefVal) ? "selected" : "" %>><%= (sParam.contains("door.open") ? resourceBundle.getProperty("DataManager.DisplayText.Close") : resourceBundle.getProperty("DataManager.DisplayText.Off")) %></option>
								</select>
<%
							}
							else
							{
								if(java.util.regex.Pattern.matches("[0-9,.-]+", sDefVal))
								{
									try
									{
										sDefVal = decimalFormat.format(decimalFormat.parse(sDefVal));
									}
									catch(Exception e)
									{
										//do nothing
									}
								}
%>
								<input type="text" id="<%= sParam %>" name="<%= sParam %>" value="<%= sDefVal %>" style="background:<%= bgColor %>" size="5" onBlur="javascript:unselectDiv('<%= sParamGroup %>_PG');setValue('<%= sParam %>', '<%= sParamGroup %>_PG', this)" onclick="javascript:selectDiv('<%= sParamGroup %>_PG');this.focus();this.select()">
<%
							}
%>
							<input type="hidden" id="<%= sParam %>_OldVal" name="<%= sParam %>_OldVal" value="<%= sDefVal %>">
<%
						}
%>
						</td>
<%
					}
					else
					{
%>
						<td>&nbsp;</td>
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

	<script type="text/javascript">
		var myST = new superTable("freezeHeaders", {
			cssSkin : "sGrey",
			headerRows : 1,
			fixedCols : 2
		});
	</script>
</body>
</html>
