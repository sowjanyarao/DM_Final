<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>
<%@page import="com.client.db.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>
<%
	String sName = request.getParameter("name");
	String sType = request.getParameter("type");
	
	Map<String, String> mParams = u.getGraphParams(sName);
	String roomId = mParams.get("RM_ID");
	String params = mParams.get("PARAMS");
	String[] saParams = params.split(",");
	
	Map <String, ParamSettings> mGraphParams = null;
	List<String> lParams = null;
	String sCntrlType = RDMServicesUtils.getControllerType(roomId);
	if(!sType.equals(sCntrlType))
	{
		mGraphParams = RDMServicesUtils.getGraphViewParamaters(sCntrlType);
		lParams = new ArrayList<String>(mGraphParams.keySet());
		Collections.sort(lParams, String.CASE_INSENSITIVE_ORDER);
	}
%>
<html>
<script language="javascript">
	var rooms = parent.frames['select'].document.getElementById('lstController');
	for(i=0; i<rooms.length; i++)
	{
		if(rooms[i].value == "<%= roomId %>")
		{
			rooms[i].selected = true;
		}
		else
		{
			rooms[i].selected = false;
		}
	}
	
	var params = parent.frames['select'].document.getElementById('lstParams');
	parent.frames['select'].document.getElementById('cntrlType').value = "<%= sCntrlType %>";
<%
	if(!sType.equals(sCntrlType))
	{
%>
		if(params.options != null)
		{
			while(params.options.length > 0)
			{
				params.remove(0);
			}
		}
<%
		String sAccess = "";
		String sParam = "";
		ParamSettings paramS = null;
		for(int i=0; i<lParams.size(); i++)
		{
			sParam = lParams.get(i);
			
			paramS = mGraphParams.get(sParam);
			sAccess = u.getUserAccess(paramS);
			if(sAccess == null || RDMServicesConstants.ACCESS_NONE.equals(sAccess))
			{
				continue;
			}
%>
			var opt = parent.frames['select'].document.createElement('option');
			opt.value = "<%= sParam %>";
			opt.text = "<%= sParam %>";
			params.options.add(opt);
<%
		}
	}
%>	
	var selParams = new Array();
<%
	for(int i=0; i<saParams.length; i++)
	{
%>	
		selParams[<%= i %>] = "<%= saParams[i] %>";
<%		
	}
%>	
	for(y=0; y<params.length; y++)
	{
		params[y].selected = false;
	}

	for(x=0; x<selParams.length; x++)
	{
		for(y=0; y<params.length; y++)
		{
			if(params[y].value == selParams[x])
			{
				params[y].selected = true;
			}
		}
	}
	
	parent.frames['legend'].location.href = "graphLegend.jsp?type=<%= sCntrlType %>";
</script>
</html>