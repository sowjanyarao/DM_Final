<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.text.*" %>
<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>
<%@page import="com.client.views.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<%
String sGraphName = request.getParameter("saveAs");
String sRoom = request.getParameter("lstController");
String[] saParams = request.getParameterValues("lstParams");

if(saParams == null)
{
	String sParameters = request.getParameter("Parameters");
	saParams = sParameters.split("\\|");
}
String sStartDt = request.getParameter("start_date");
String sEndDt = request.getParameter("end_date");
String sYield = request.getParameter("yield");
String sAccess = request.getParameter("access");
boolean isPublic = "Public".equals(sAccess);
String showWeekGraph = request.getParameter("showWeekGraph");
showWeekGraph = ((showWeekGraph == null || "".equals(showWeekGraph)) ? "true" : showWeekGraph);

boolean bSaved = false;
if(sGraphName != null && !"".equals(sGraphName))
{
	bSaved = u.saveGraphParams(sGraphName, sRoom, saParams, isPublic);
}

boolean bYield = "Yes".equals(sYield);

AttrDataGraph graph = new AttrDataGraph();
String sGraphCSV = graph.loadAttrDataGraph(sRoom, saParams, sStartDt, sEndDt, bYield);

String sParams = "";
for(int i=0; i<saParams.length; i++)
{
	if(i > 0)
	{
		sParams += "|";
	}
	sParams += saParams[i];
}

Map<String, String> mGraphArgs = new HashMap<String, String>();
mGraphArgs.put("Controller", sRoom);
mGraphArgs.put("StartDt", sStartDt);
mGraphArgs.put("EndDt", sEndDt);
mGraphArgs.put("Parameters", sParams);
mGraphArgs.put("Yield", sYield);
session.setAttribute("GraphArgs", mGraphArgs);

String sPrevRoom = "";
String sNextRoom = "";	
StringList slControllers = RDMSession.getControllers(u);
int iSz = slControllers.size();
if(!RDMServicesUtils.isGeneralController(sRoom) && slControllers.contains(sRoom) && (iSz > 1))
{
	int idx = slControllers.indexOf(sRoom);
	
	if((idx == 0) && (iSz > (idx + 1)))
	{
		sNextRoom = slControllers.get(idx + 1);
		if(RDMServicesUtils.isGeneralController(sNextRoom))
		{
			sNextRoom = "";
		}
	}
	else if(iSz == (idx + 1))
	{
		sPrevRoom = slControllers.get(idx - 1);
		if(RDMServicesUtils.isGeneralController(sPrevRoom))
		{
			sPrevRoom = "";
		}
	}
	else
	{
		sPrevRoom = slControllers.get(idx - 1);
		if(RDMServicesUtils.isGeneralController(sPrevRoom))
		{
			sPrevRoom = "";
		}
		
		sNextRoom = slControllers.get(idx + 1);
		if(RDMServicesUtils.isGeneralController(sNextRoom))
		{
			sNextRoom = "";
		}
	}
}

String sTitle = new String(sRoom);
if(!"".equals(sPrevRoom))
{
	sTitle = "<a href='javascript:showGraph(\""+sPrevRoom+"\")'>"+sPrevRoom+"</a>&nbsp;&nbsp;<<&nbsp;&nbsp;"+sTitle;
}

if(!"".equals(sNextRoom))
{
	sTitle = sTitle+"&nbsp;&nbsp;>>&nbsp;&nbsp;<a href='javascript:showGraph(\""+sNextRoom+"\")'>"+sNextRoom+"</a>";
}

Random randomGenerator = new Random();
int randomInt = randomGenerator.nextInt(1000);

SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy", Locale.ENGLISH);
Calendar cal = Calendar.getInstance();
Date stDate = null;
if("true".equals(showWeekGraph))
{
	stDate = sdf.parse(sStartDt);
	cal.setTime(stDate);
	cal.add(Calendar.WEEK_OF_YEAR, -1);
	cal.add(Calendar.DAY_OF_YEAR, 1);
}
else
{
	stDate = sdf.parse(sEndDt);
	cal.setTime(stDate);
	cal.add(Calendar.DAY_OF_YEAR, -1);
}	
stDate = cal.getTime();			
String sWkStartDt = sdf.format(stDate);
%>

<html>
	<head>
		<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE6; IE=EmulateIE7; IE=EmulateIE8; IE=EmulateIE9">
		<title></title>
		<link type="text/css" href="../styles/dygraph.css" rel="stylesheet" />
		<script type="text/javascript" src="../scripts/excanvas.js"></script>
		<script type="text/javascript" src="../scripts/dygraph-combined.js"></script>
		<script type="text/javascript" src="../scripts/dygraph-extra.js"></script>
		<script language="javascript">
			function showGraph(room)
			{
				document.getElementById('lstController').value = room;
				document.getElementById('start_date').value = "<%= sStartDt %>";
				document.getElementById('showWeekGraph').value = "<%= showWeekGraph %>";

				var idx = "<%= randomInt %>";
				document.frm.target = "POPUPW_"+idx;
				POPUPW = window.open('about:blank','POPUPW_'+idx,'menubar=no,toolbar=no,location=no,resizable=yes,scrollbars=yes,status=no,height=<%= winHeight * 0.85 %>px,width=<%= winWidth * 0.90 %>px');			
				document.frm.submit();
			}
			
			function showWeeklyGraph()
			{
				document.getElementById('lstController').value = "<%= sRoom %>";
				document.getElementById('start_date').value = "<%= sWkStartDt %>";

				var idx = "<%= randomInt %>";
				document.frm.target = "POPUPW_"+idx;
				POPUPW = window.open('about:blank','POPUPW_'+idx,'menubar=no,toolbar=no,location=no,resizable=yes,scrollbars=yes,status=no,height=<%= winHeight * 0.85 %>px,width=<%= winWidth * 0.90 %>px');			
				document.frm.submit();
			}
		</script>
	</head>

	<body>
		<table>
			<tr>
				<td style="font-family:Arial; font-size:0.8em; font-weight:bold; color:#0000FF">
					<a href="javascript:showWeeklyGraph()">
<%
					if("true".equals(showWeekGraph))
					{
%>
						<%= resourceBundle.getProperty("DataManager.DisplayText.Weekly_Graph") %></a>
<%
					}
					else
					{
%>
						<%= resourceBundle.getProperty("DataManager.DisplayText.Day_Graph") %></a>
<%
					}
%>
				</td>
				<td style="font-family:Arial; font-size:0.8em; font-weight:bold; color:#0000FF">
					<%= sTitle %>
				</td>
				<td style="font-family:Arial; font-size:0.8em; font-weight:bold; color:#0000FF">
					<a href="../ExportAttrDataGraph" target="exportGraph"><%= resourceBundle.getProperty("DataManager.DisplayText.Export_Graph_Data") %></a><br>
					<a href="printAttrDataGraph.jsp?room=<%= sRoom %>" target="exportGraph"><%= resourceBundle.getProperty("DataManager.DisplayText.Print_Graph") %></a>
				</td>
			</tr>
			<tr>
				<td valign="top" colspan="2">
					<div id="graphdiv" style="width:<%= winWidth * 0.75 %>px; height:<%= winHeight * 0.85 %>px;"></div>
				</td>
				<td valign="top">
					<table>
						<tr>
							<br><td class="label"><%= resourceBundle.getProperty("DataManager.DisplayText.Parameter_Values") %></td>
						</tr>
						<tr>
							<td>
								<div id="status" style="width:150px; font-size:0.8em; padding-top:5px;"></div>
							</td>
						</tr>						
						<tr>
							<td class="label"><%= resourceBundle.getProperty("DataManager.DisplayText.Select_Parameters") %></td>
						</tr>
						<tr>
							<td valign="top">		
								<table>
<%
								if(bYield)
								{
%>
									<tr>
										<td>
											<input type="checkbox" id="0" onClick="change(this)" checked>
											<label style="font-family:Arial,sans-serif; font-size:12px;" for="0"><%= resourceBundle.getProperty("DataManager.DisplayText.Yield") %>&nbsp;</label>
										</td>
									</tr>
<%
								}

								int idx = 0;
								for(int i=0; i<saParams.length; i++)
								{
									idx = (bYield ? (i+1) : i);
%>
									<tr>
										<td>
											<input type="checkbox" id="<%= idx %>" onClick="change(this)" checked>
											<label style="font-family:Arial,sans-serif; font-size:12px;" for="<%= idx %>"><%= saParams[i] %>&nbsp;</label>
										</td>
									</tr>
<%
								}
%>
								</table>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
		<form name="frm" method="post" action="showAttrDataGraph.jsp">
			<input type="hidden" id="showWeekGraph" name="showWeekGraph" value="<%= ("true".equals(showWeekGraph) ? "false" : "true") %>">
			<input type="hidden" id="saveAs" name="saveAs" value="">
			<input type="hidden" id="lstController" name="lstController" value="">
			<input type="hidden" id="Parameters" name="Parameters" value="<%= sParams %>">
			<input type="hidden" id="start_date" name="start_date" value="">
			<input type="hidden" id="end_date" name="end_date" value="<%= sEndDt %>">
			<input type="hidden" id="yield" name="yield" value="<%= sYield %>">
		</form>
		
		<script type="text/javascript">			
			var g = new Dygraph(document.getElementById("graphdiv"),
				'../graphs/ControllerData/<%= sGraphCSV %>',				
				{
					labelsDiv: document.getElementById('status'),					
					labelsSeparateLines: true,
					labelsKMB: true,
					legend: 'always',
					colors: ["Blue",
							"Brown",
							"DeepPink",
							"DarkGreen",
							"Magenta",
							"Red",
							"Orange",
							"Violet",
							"Crimson",
							"Purple"],
					width: 640,
					height: 480,
					title: '',
					xlabel: '<%= resourceBundle.getProperty("DataManager.DisplayText.Date_Time") %>',
					ylabel: '<%= resourceBundle.getProperty("DataManager.DisplayText.Values") %>',
					axisLineColor: 'black'
				}
			);
			
			function change(el)
			{				
				g.setVisibility(el.id, el.checked);
			}
		</script>
<%
	if(bSaved)
	{
%>	
		<script type="text/javascript">
			var lstGraphs = top.opener.document.getElementById("lstGraphs");
			var opt = top.opener.document.createElement('option');
			opt.value = "<%= sGraphName %>";
			opt.text = "<%= sGraphName %>";
			lstGraphs.options.add(opt);
		</script>
<%
	}
%>	
	</body>
	<iframe src="blank.jsp" name="exportGraph" width="0" height="0" frameborder="0" scrolling="no"></iframe>
</html>