<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>
<%@page import="com.client.views.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<html>
<%
	String sController = request.getParameter("controller");	
	boolean bResetParams = "true".equals(request.getParameter("resetParams"));
	String sCntrlType = request.getParameter("cntrlType");
	String sDefParamType = request.getParameter("defParamType");		
	String sScrollLeft = request.getParameter("scrollLeft");
	String sScrollTop = request.getParameter("scrollTop");
	session.setAttribute("scrollLeft", sScrollLeft);
	session.setAttribute("scrollTop", sScrollTop);

	Map<String, String[]> mParams = new HashMap<String, String[]>();
	String sParam = "";
	String sValue = "";
	String sNewValue = "";
	String sOldValue = "";
	String[] saParamVal = null;
	Map<String, String> mDefValues = new HashMap<String, String>();
	if(bResetParams)
	{	
		DefParamValues defParamVals = new DefParamValues();
		mDefValues = defParamVals.getDefaultParamValues(sCntrlType, sDefParamType);
	}

	StringBuilder sbResetParams = new StringBuilder();
	StringList slResetParams = RDMServicesUtils.getResetParams(sCntrlType);

	Enumeration eParams = request.getParameterNames();
	while(eParams.hasMoreElements())
	{
		sParam = (String)eParams.nextElement();
		if(sParam.endsWith("_OldVal") || sParam.endsWith("_MinVal") || sParam.endsWith("_MaxVal") || "controller".equalsIgnoreCase(sParam)
			|| "BatchNo".equalsIgnoreCase(sParam) || "BNo".equalsIgnoreCase(sParam) || "resetParams".equalsIgnoreCase(sParam) 
				|| "ResetPhase".equalsIgnoreCase(sParam) || "CurrPhase".equalsIgnoreCase(sParam) || "cntrlType".equalsIgnoreCase(sParam) 
					|| "defParamType".equalsIgnoreCase(sParam) || "StartPhase".equalsIgnoreCase(sParam) 
						|| "scrollLeft".equalsIgnoreCase(sParam) || "scrollTop".equalsIgnoreCase(sParam))
		{
			continue;
		}

		if(bResetParams && mDefValues.containsKey(sParam) && !(sParam.contains("start phase") || sParam.equals("start cycle")))
		{
			sNewValue = mDefValues.get(sParam);
		}
		else
		{
			sNewValue = request.getParameter(sParam);
		}

		if(sNewValue != null && !"".equals(sNewValue.trim()))
		{
			if(sNewValue.endsWith(".0"))
			{
				sNewValue = sNewValue.substring(0, sNewValue.indexOf('.'));
			}

			sOldValue = request.getParameter(sParam+"_OldVal");
			if(sOldValue != null && sOldValue.endsWith(".0"))
			{
				sOldValue = sOldValue.substring(0, sOldValue.indexOf('.'));
			}

			if(!sNewValue.equals(sOldValue))
			{
				saParamVal = new String[2];
				saParamVal[0] = sOldValue;
				saParamVal[1] = sNewValue;

				mParams.put(sParam, saParamVal);

				if(slResetParams.contains(sParam) && ("1".equals(saParamVal[1]) || "On".equals(saParamVal[1])))
				{
					if(sbResetParams.length() > 0)
					{
						sbResetParams.append(", ");
					}
					sbResetParams.append(sParam);
				}
			}
		}
	}

	String sErr = "";
	String sRet = "";
	try
	{
		String batchNo = request.getParameter("BatchNo");
		batchNo = (batchNo == null ? "" : batchNo);
		String BNo = request.getParameter("BNo");
		String sResetPhase = request.getParameter("ResetPhase");
			
		PLCServices client = new PLCServices(RDMSession, sController);		
		if(!RDMServicesUtils.isGeneralController(sController))
		{
			ArrayList<String[]> alPhases = RDMServicesUtils.getControllerStages(sCntrlType);
			if("".equals(batchNo) && bResetParams)
			{
				if("".equals(BNo) || !BNo.startsWith("auto_"))
				{
					BNo = "auto_" + sController + "_" + new SimpleDateFormat("yyyyMMddHHmmss").format(Calendar.getInstance().getTime());
					client.addBatchNo(BNo, sDefParamType);
				}
				else
				{
					client.updateDefaultProduct(BNo, sDefParamType);
				}			
			}
			else if(!"".equals(batchNo))
			{
				if(!batchNo.equals(BNo))
				{
					if("".equals(BNo) || !BNo.startsWith("auto_"))
					{
						client.addBatchNo(batchNo, sDefParamType);
					}
					else
					{
						client.updateBatchNo(batchNo, sDefParamType);
					}
				}
				else
				{
					client.updateDefaultProduct(batchNo, sDefParamType);
				}
			}
		}

		if(!mParams.isEmpty())
		{
			sRet = client.setParameters(u, mParams);
		}
		
		if(!RDMServicesUtils.isGeneralController(sController))
		{
			if("true".equals(sResetPhase))
			{
				BNo = "auto_" + sController + "_" + new SimpleDateFormat("yyyyMMddHHmmss").format(Calendar.getInstance().getTime());
				client.addBatchNo(BNo, "");
			}
		}
	}
	catch(Exception e)
	{
		e.printStackTrace(System.out);
		sErr = e.getMessage();
		sErr = sErr.replaceAll("\n", "\\n");
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
			var sRet = "<%= sRet %>";
			if(sRet != "")
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Parameters_Modified_Except") %>" + sRet);
			}
			else
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Parameters_Modified") %>");
			}
<%
			if(sbResetParams.length() > 1)
			{
%>
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Parameters_Auto_Reset") %>\n\t<%= sbResetParams.toString() %>");
<%
			}
%>
		}

		if(parent.frames['param'] != null)
		{
			parent.frames['param'].document.location.href = parent.frames['param'].document.location.href;
		}
		else
		{
			parent.frames['content'].document.location.href = parent.frames['content'].document.location.href;
		}
	</script>

</html>