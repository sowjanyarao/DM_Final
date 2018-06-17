<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>
<%@page import="com.client.db.*" %>
<%@page import="com.client.views.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<html>
<%
	String sAction = request.getParameter("mode");
	String sController = request.getParameter("controller");
	String sDefParamType = request.getParameter("defParamType");
	String sToDefType = request.getParameter("toDefType");
	String sFromDefType = request.getParameter("fromDefType");
	Map<String, String> mParams = new HashMap<String, String>();

	if("save".equals(sAction))
	{
		String sParam = "";
		String sValue = "";
		String sNewValue = "";
		String sOldValue = "";
		String[] saParamVal = null;
		
		Enumeration eParams = request.getParameterNames();
		while(eParams.hasMoreElements())
		{
			sParam = (String)eParams.nextElement();		
			if(sParam.endsWith("_OldVal") || "controller".equalsIgnoreCase(sParam) || "mode".equalsIgnoreCase(sParam) 
				|| "defParamType".equalsIgnoreCase(sParam) || "copyFrom".equalsIgnoreCase(sParam))
			{
				continue;
			}

			sNewValue = request.getParameter(sParam);
			if(sNewValue.endsWith(".0"))
			{
				sNewValue = sNewValue.substring(0, sNewValue.indexOf('.'));
			}
			
			if(sNewValue != null)
			{
				sOldValue = request.getParameter(sParam+"_OldVal");			
				if(sOldValue.endsWith(".0"))
				{
					sOldValue = sOldValue.substring(0, sOldValue.indexOf('.'));
				}
			
				if(!sNewValue.equals(sOldValue))
				{				
					try
					{
						if(!("On".equals(sNewValue) || "Off".equals(sNewValue) || sNewValue.contains(":")))
						{
							sNewValue = numberFormat.parse(sNewValue).toString();
						}
					}
					catch(Exception e)
					{
						//do nothing
					}
				
					mParams.put(sParam, sNewValue);
				}
			}
		}
	}

	String sErr = "";
	try
	{
		DefParamValues defParamVals = new DefParamValues();
		if("save".equals(sAction) && !mParams.isEmpty())
		{
			defParamVals.updateDefaultParamValues(sController, sDefParamType, mParams);
		}
		else if("copy".equals(sAction))
		{
			defParamVals.copyDefaultValues(sController, sToDefType, sFromDefType);
		}
	}
	catch(Exception e)
	{
		sErr = e.getMessage();
		sErr = sErr.replaceAll("\r", "\\n").replaceAll("\n", "\\n");
	}
%>

	<script>
		var sErr = "<%= sErr %>";
		if(sErr != "")
		{
			alert("Error: "+sErr);
		}
		else
		{
			alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Default_values_Modified") %>");
		}
		
		parent.frames['content'].document.location.href = parent.frames['content'].document.location.href;
	</script>

</html>