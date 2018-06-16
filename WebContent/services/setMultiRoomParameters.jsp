<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<html>
<%
	String sSelCntrl = request.getParameter("selControllers");
	int iSelCntrl = (sSelCntrl == null || "".equals(sSelCntrl)) ? 0 : Integer.parseInt(sSelCntrl);

	StringBuilder sbResetParams = new StringBuilder();
	String sCntrlType = request.getParameter("cntrlType");
	StringList slControllers = RDMSession.getControllers(iSelCntrl, 10, sCntrlType);	
	StringList slResetParams = RDMServicesUtils.getResetParams(sCntrlType);
	
	Map<String, String[]> mParams = new HashMap<String, String[]>();
	String sParam = "";
	String sValue = "";

	Enumeration eParams = request.getParameterNames();
	while(eParams.hasMoreElements())
	{
		sParam = (String)eParams.nextElement();		
		if("selControllers".equalsIgnoreCase(sParam) || "cntrlType".equalsIgnoreCase(sParam) || slControllers.contains(sParam))
		{
			continue;
		}		
		sValue = request.getParameter(sParam);
		
		if(!"".equals(sValue.trim()))
		{
			mParams.put(sParam, new String[] {"", sValue});

			if(slResetParams.contains(sParam) && ("1".equals(sValue) || "On".equals(sValue)))
			{
				if(sbResetParams.length() > 0)
				{
					sbResetParams.append(", ");
				}
				sbResetParams.append(sParam);
			}
		}
	}

	StringBuilder sbErr = new StringBuilder();
	PLCServices client = null;
	String sController = null;
	String sSelected = null;
	for(int i=0; i<slControllers.size(); i++)
	{
		try
		{
			sController = slControllers.get(i);
			sSelected = request.getParameter(sController);
			
			if("Yes".equals(sSelected) && !mParams.isEmpty())
			{
				client = new PLCServices(RDMSession, sController);				
				client.setParameters(u, mParams);
			}
		}
		catch(Exception e)
		{
			sbErr.append(e.getMessage());
			sbErr.append("\\n");
		}
	}
%>
	<script>
		var sErr = "<%= sbErr.toString() %>";
		if(sErr != "")
		{
			alert("Error: "+sErr);
		}
		else
		{
<%
			if(sbResetParams.length() > 1)
			{
%>
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Parameters_Auto_Reset") %>\n\t<%= sbResetParams.toString() %>");
<%
			}
%>
		}
		parent.frames['content'].document.location.href = parent.frames['content'].document.location.href;
	</script>

</html>