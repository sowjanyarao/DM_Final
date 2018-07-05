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
	
	Map<String, String[]> mParams = null;
	Map<String, Map<String, String[]>> mCntrlParams = new HashMap<String, Map<String, String[]>>();
	String sParam = "";
	String sValue = "";
	String sOldValue = "";
	String sController = null;
	String[] saParamName = null;
	
	Enumeration eParams = request.getParameterNames();
	while(eParams.hasMoreElements())
	{
		sParam = (String)eParams.nextElement();		
		if("selControllers".equalsIgnoreCase(sParam) || "cntrlType".equalsIgnoreCase(sParam) 
			|| slControllers.contains(sParam) || sParam.endsWith("_OldVal"))
		{
			continue;
		}

		sValue = request.getParameter(sParam);
		sOldValue = request.getParameter(sParam+"_OldVal");
		
		if(!sValue.equals(sOldValue))
		{
			saParamName = sParam.split("_");
			sController = saParamName[0];
			sParam = saParamName[1];
			
			if(mCntrlParams.containsKey(sController))
			{
				mParams = mCntrlParams.get(sController);
			}
			else
			{
				mParams = new HashMap<String, String[]>();
			}
			mParams.put(sParam, new String[] {sOldValue, sValue});

			mCntrlParams.put(sController, mParams);
			
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
	String sSelected = null;
	for(int i=0; i<slControllers.size(); i++)
	{
		/* try
		{
 */			sController = slControllers.get(i);
			sSelected = request.getParameter(sController);			
			mParams = mCntrlParams.get(sController);
			if("Yes".equals(sSelected) && mParams != null && !mParams.isEmpty())
			{
				client = new PLCServices(RDMSession, sController);				
				client.setParameters(u, mParams);
			}
		//}
		/* catch(Throwable e)
		{
			sbErr.append(e.getMessage());
			sbErr.append("\\n");
		} */
	}
%>
	<script>
		var sErr = "<%= sbErr.toString() %>";
		if(sErr != "")
		{
			alert("Error123: "+sErr);
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
			else
			{
%>
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Parameters_Modified") %>");
<%
			}
%>
		}
		
		parent.frames['content'].document.location.href = parent.frames['content'].document.location.href + "&realTime=true";
	</script>

</html>