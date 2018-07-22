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
	
	String sCntrlType = RDMServicesUtils.getControllerType(sName);
	if(sType.equals(sCntrlType))
	{
		return;
	}
		
	Map <String, ParamSettings> mParams = RDMServicesUtils.getGraphViewParamaters(sCntrlType);
	List<String> lParams = new ArrayList<String>(mParams.keySet());
	Collections.sort(lParams, String.CASE_INSENSITIVE_ORDER);
%>

<html>
<script language="javascript">
	var lstParams = parent.parent.frames['select'].document.getElementById('lstParams');
	parent.parent.frames['select'].document.getElementById('cntrlType').value = "<%= sCntrlType %>";
	alert(lstParams.options);
	if(lstParams.options != null)
	{
		while(lstParams.options.length > 0)
		{
			lstParams.remove(0);
		}
	}
<%
	String sAccess = "";
	String sParam = "";
	ParamSettings paramS = null;
	for(int i=0; i<lParams.size(); i++)
	{
		sParam = lParams.get(i);
		
		paramS = mParams.get(sParam);
		sAccess = u.getUserAccess(paramS);
		if(sAccess == null || RDMServicesConstants.ACCESS_NONE.equals(sAccess))
		{
			continue;
		}
%>
		var opt = parent.parent.frames['select'].document.createElement('option');
		opt.value = "<%= sParam %>";
		opt.text = "<%= sParam %>";
		lstParams.options.add(opt);
		
<%
	}
%>
	//parent.frames['legend'].location.href = "graphLegend.jsp?type=<%= sCntrlType %>";
</script>
</html>