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
	
	NumberFormat decimalFormat = NumberFormat.getInstance(Locale.getDefault());
	decimalFormat.setMinimumFractionDigits(1);
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
	<title></title>	
</head>

<body onLoad="javascript:window.print()">
	<table border="0" cellpadding="0" cellspacing="0" width="90%">
		<tr>
			<td style="font-family:Arial; font-size:0.8em; font-weight:bold; border:#ffffff; text-align:left">
				<%= sController %> <%= resourceBundle.getProperty("DataManager.DisplayText.Default_Values") %>&nbsp;(<%= sDefParamType %>)
			</td>
		</tr>
	</table>
	
		<table border="1" cellpadding="2" cellspacing="0">
			<tr>
				<td class="label"><%= resourceBundle.getProperty("DataManager.DisplayText.Parameter_Unit") %></td>
				<td class="label" width="5%">&nbsp;</td>
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
%>
					<td class="label"><%= sPhaseLabel.replaceAll(" ", "<br>") %></td>
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
			String sParamGroup = null;
			String sSetParam = null;
			String bgColor = null;
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

				sStage = paramSettings.getStage();

				sUnit = mCntrlParams.get(sParam);
				sUnit = ((sUnit == null) ? "" : sUnit);

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
				
				sDefVal = mParams.get(sParam);
				if(sDefVal == null)
				{
					sDefVal = "";
				}

				bgColor = "#000000";
				if(slManualParams.contains(sParam))
				{
					if("On".equals(sDefVal) || "1".equals(sDefVal))
					{
						bgColor = "#0000ff";
					}
				}
				
				if("".equals(sUnit))
				{
					sUnit = paramSettings.getParamUnit();
				}
%>
			<tr>
<%
				if(RDMServicesConstants.ACCESS_WRITE.equals(sAccess) || bParamGroup)
				{
%>
					<td class="label"><%= sParam %>
<%
						if(!"".equals(sUnit))
						{
%>
							&nbsp;<label class="unit">(<%= sUnit %>)</label>
<%
						}
%>
					</td>
<%
				}
				else
				{
					continue;
				}

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

					if(!bHasRange && RDMServicesConstants.ACCESS_WRITE.equals(sAccess))
					{
						if(slOnOffValues.contains(sParam) || slManualParams.contains(sParamGroup))
						{
							if(sParam.contains("door.open"))
							{
								if("1".equals(sDefVal) || "On".equals(sDefVal))
								{
									sDefVal = "Open";
								}
								else if("0".equals(sDefVal) || "Off".equals(sDefVal))
								{
									sDefVal = "Close";
								}
							}
							else if("1".equals(sDefVal))
							{
								sDefVal = "On";
							}
							else if("0".equals(sDefVal))
							{
								sDefVal = "Off";
							}
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
						}
%>
						<td class="text" bgcolor="<%= ((slManualParams.contains(sParam) && ("On".equals(sDefVal) || "1".equals(sDefVal))) ? "#0000FF" : "#FFFFFF") %>"><%= sDefVal %></td>
<%
					}
					else
					{
%>
						<td>&nbsp;</td>
<%
					}
				}
				else
				{
%>
					<td>&nbsp;</td>
<%
				}

				for(int k=0; k<alPhases.size(); k++)
				{
					sPhaseSeq = alPhases.get(k)[0];
					
					if(bParamGroup)
					{
						sDefVal = ""; sStage = "";
						groupParams = paramSettings.getGroupParams(sPhaseSeq);
						if(groupParams != null)
						{
							sStage = groupParams.getStage();
							sParam = groupParams.getParamName();
							sAccess = u.getUserAccess(groupParams);
							sDefVal = mParams.get(sParam);
							if(sDefVal == null)
							{
								sDefVal = "";
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
							sMinVal = mParams.get("min " + sSetParam);
						}

						if(mParams.containsKey("max " + sSetParam))
						{
							bHasRange = true;
							sMaxVal = mParams.get("max " + sSetParam);
						}

						bgColor = "#000000";
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
						
						if(RDMServicesConstants.ACCESS_WRITE.equals(sAccess))
						{
							if(slOnOffValues.contains(sParam) || slManualParams.contains(sParamGroup))
							{
								if(sParam.contains("door.open"))
								{
									if("1".equals(sDefVal) || "On".equals(sDefVal))
									{
										sDefVal = "Open";
									}
									else if("0".equals(sDefVal) || "Off".equals(sDefVal))
									{
										sDefVal = "Close";
									}
								}
								else if("1".equals(sDefVal))
								{
									sDefVal = "On";
								}
								else if("0".equals(sDefVal))
								{
									sDefVal = "Off";
								}
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
							}
%>
							<td class="text" nowrap><font color="<%= bgColor %>"><%= sDefVal %></font></td>
<%
						}
						else
						{
%>
							<td>&nbsp;</td>
<%
						}
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
</body>
</html>
