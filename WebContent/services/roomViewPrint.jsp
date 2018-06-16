<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<%
	String sController = null;
	String sName = null;
	String sValue = null;
	String sUnit = null;
	String sCurrentPhase = null;	
	String bgColor = null;
	String sAlarm = null;
	String sManual = null;
	String sLastRefresh = null;
	String[] saParams = null;

	Map<String, String> mParamInfo = null;
	Map<String, Map<String, String>> mParams = null;
	Map<String, Map<String, Map<String, String>>> mAllParams = new HashMap<String, Map<String, Map<String, String>>>();
	Map<String, String> mAllAlarms = new HashMap<String, String>();
	
	String sRealTime = request.getParameter("realTime");
	boolean bRealTime = ("true".equalsIgnoreCase(sRealTime));	
	String sSelRange = request.getParameter("selRange");
	int iSelRange = Integer.parseInt(sSelRange);
	
	String sCntrlType = request.getParameter("cntrlType");
	
	PLCServices client = null;
	StringList slControllers = RDMSession.getControllers(iSelRange, 10, sCntrlType);
	StringList slCntrlSel = RDMSession.getControllersSelection(sCntrlType, 10);
	ArrayList<String> alParams = new ArrayList<String>(RDMServicesUtils.getDisplayOrder(sCntrlType));
	
	boolean fg = true;
	for(int i=(slControllers.size()-1); i>=0; i--)
	{
		try
		{
			sController = slControllers.get(i);
			client = new PLCServices(RDMSession, sController);

			mParams = client.getRoomViewParams(u, bRealTime);
			mAllParams.put(sController, mParams);

			sAlarm = (client.hasOpenAlarms() ? "Yes" : "No");
			mAllAlarms.put(sController, sAlarm);
			
			if(fg)
			{
				sLastRefresh = (mParams.containsKey("Last Refresh") ? mParams.get("Last Refresh").get(RDMServicesConstants.PARAM_VALUE) : "");
				alParams.retainAll(mParams.keySet());
				fg = false;
			}
		}
		catch(Exception e)
		{
			slControllers.remove(sController);
		}
	}
	
	int iSz = slControllers.size();

	String sHeader = null;
	StringList slHeaders = new StringList();
	Map<String, String> mParamHeaders = RDMServicesUtils.displayHeaders(sCntrlType);

	Map<Integer, String> mDisplayHeaders = RDMServicesUtils.getHeaders(sCntrlType);
	ArrayList<Integer> alDisplayOrder = new ArrayList<Integer>();
	alDisplayOrder.addAll(mDisplayHeaders.keySet());
	Collections.sort(alDisplayOrder);
	
	Map<String, ParamSettings> mViewParams = RDMServicesUtils.getRoomsOverViewParamaters(sCntrlType);
	
	NumberFormat decimalFormat = NumberFormat.getInstance(Locale.getDefault());
	decimalFormat.setMinimumFractionDigits(1);
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
	<style type="text/css">
	.unit
	{
		color: #FF0000;
		font-weight: bold;
		font-family: sans serif;
		font-size: 8pt;
	}
	
	.label
	{
		text-align: left;
		background-color: #ffffff;
		font-size:12px;
		font-family:Arial,sans-serif;
	}

	.text
	{
		text-align: left;
		background-color: #ffffff;
		font-size:12px;
		font-family:Arial,sans-serif;
	}
	</style>
</head>

<body onLoad="javascript:window.print()">
	<table border="0" cellpadding="0" cellspacing="0" width="95%">
		<tr>
			<td style="font-family:Arial; font-size:0.8em; font-weight:bold; border:#ffffff; text-align:left">
				<%= resourceBundle.getProperty("DataManager.DisplayText.Rooms") %>:&nbsp;<%= slCntrlSel.get(iSelRange) %>
			</td>
			<td style="font-family:Arial; font-size:0.8em; font-weight:bold; border:#ffffff; text-align:right">
				<%= resourceBundle.getProperty("DataManager.DisplayText.Last_updated_on") %>:&nbsp;<font style="weight:normal; color:#FF0000"><%= sLastRefresh %></font>
			</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
	</table>

	<table border="1px" cellpadding="1" cellspacing="0">
		<tr>
			<th class="label"><%= resourceBundle.getProperty("DataManager.DisplayText.Rooms") %></th>
<%
			for(int i=0; i<iSz; i++)
			{
				sController = slControllers.get(i);
%>						
				<th class="label"><%= sController %></th>
<%
			}
%>
		</tr>
		<tr>
			<th class="label" style="text-align:left"><%= resourceBundle.getProperty("DataManager.DisplayText.Open_Alarms") %></th>
<%
			for(int i=0; i<iSz; i++)
			{
				sController = slControllers.get(i);
				sAlarm = mAllAlarms.get(sController);

				if("Yes".equals(sAlarm))
				{
%>
					<td class="text" style="color:#ff0000"><b><%= sAlarm %></b></td>
<%
				}
				else
				{
%>
					<td class="text" style="color:#000000"><%= sAlarm %></td>
<%
				}
			}
%>
		</tr>
		<tr>
			<th class="label" style="text-align:left"><%= resourceBundle.getProperty("DataManager.DisplayText.Manual_Setting") %></th>
<%
			for(int i=0; i<iSz; i++)
			{
				sController = slControllers.get(i);
				mParams = mAllParams.get(sController);
				sManual = (mParams.containsKey("manual.sl") ? mParams.get("manual.sl").get(RDMServicesConstants.PARAM_VALUE) : "");
				bgColor = ("On".equals(sManual) ? "#0000ff" : "#000000");

				if("On".equals(sManual))
				{
%>
					<td class="text" style="color:#0000ff"><b><%= sManual %></b></td>
<%
				}
				else
				{
%>
					<td class="text" style="color:#000000"><%= sManual %></td>
<%
				}
			}
%>
		</tr>
<%
		if(mViewParams.containsKey("current phase"))
		{
%>
			<tr>
				<th class="label" style="text-align:left">current phase</th>
<%
				for(int i=0; i<iSz; i++)
				{
					sController = slControllers.get(i);
					mParams = mAllParams.get(sController);
					sValue = mParams.get("current phase").get(RDMServicesConstants.PARAM_VALUE);
					if(sValue.endsWith(".0"))
					{
						sValue = sValue.substring(0, sValue.indexOf("."));
					}
					sName = RDMServicesUtils.getStageName(sCntrlType, sValue);
					if(!("".equals(sName) || "-".equals(sName)))
					{
						sValue = sName.replaceAll(" ", "<br>") + "&nbsp;("+ sValue + ")";
					}
%>
					<td class="text" align="left"><%= sValue %></td>
<%
				}
%>
			</tr>
<%
		}
		
		boolean bHasRange = false;
		boolean bDispOrd = false;
		int iDispOrd = 0;
		String sMinVal = "";
		String sMaxVal = "";
		String sUserAccess = "";
		String sParamName = "";
		StringList slOnOffValues = RDMServicesUtils.getOnOffParams(sCntrlType);
		ParamSettings paramSettings = null;

		for(int i=0, iCnt=alParams.size(); i<iCnt; i++)
		{
			sName = alParams.get(i);
			if("current phase".equals(sName))
			{
				continue;
			}

			iDispOrd = -1;
			paramSettings = mViewParams.get(sName);
			if(paramSettings != null)
			{
				iDispOrd = paramSettings.getDisplayOrder();
			}

			bDispOrd = false;
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
						<th align="center" colspan="12">
							<%= sHeader %>
						</th>
					</tr>
<%
					alDisplayOrder.remove(0);
					slHeaders.add(sHeader);
				}
			}
%>
			<tr>
<%
				for(int j=0; j<iSz; j++)
				{
					sController = slControllers.get(j);
					mParams = mAllParams.get(sController);
					mParamInfo = mParams.get(sName);
					
					sValue = "&nbsp;";
					sUserAccess = "";
					if(mParamInfo != null && !mParamInfo.isEmpty())
					{
						sUnit = mParamInfo.get(RDMServicesConstants.PARAM_UNIT);
						if(j == 0)
						{
%>
							<th class="label" style="text-align:left"><%= sName %>
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
						}
						
						sValue = mParamInfo.get(RDMServicesConstants.PARAM_VALUE);
						sValue = (sValue == null ? "&nbsp;" : sValue);
						
						sMinVal = mParamInfo.get(RDMServicesConstants.MIN_PARAM_VALUE);
						sMaxVal = mParamInfo.get(RDMServicesConstants.MAX_PARAM_VALUE);
						
						bgColor = "#000000";
						bHasRange = (!"".equals(sMinVal) && !"".equals(sMaxVal));
						if(bHasRange && !"".equals(sValue))
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
						
						sUserAccess = mParamInfo.get(RDMServicesConstants.USER_ACCESS);
					}
					else
					{
						if(j == 0)
						{
%>
							<th class="label" style="text-align:left"><%= sName %></th>
<%
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
%>
					<td class="text" align="left" style="color:<%= bgColor %>">
<%
					if(!("".equals(sUserAccess) || RDMServicesConstants.ACCESS_NONE.equals(sUserAccess)))
					{
						if(slOnOffValues.contains(mParamInfo.get(RDMServicesConstants.PARAM_NAME)))
						{
							if(mParamInfo.get(RDMServicesConstants.PARAM_NAME).contains("door.open"))
							{
								if("1".equals(sValue) || "On".equals(sValue))
								{
									sValue = "Open";
								}
								else if("0".equals(sValue) || "Off".equals(sValue))
								{
									sValue = "Close";
								}
							}
							else if("1".equals(sValue))
							{
								sValue = "On";
							}
							else if("0".equals(sValue))
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
%>				
			</tr>
<%
		}
%>
	</table>
</body>
</html>