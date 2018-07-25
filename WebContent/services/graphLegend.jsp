<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

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
		width: <%= winWidth * 0.25 %>px; 
		height: <%= winHeight * 0.85 %>px;
		overflow: hidden; 
		font-size: 0.85em;
	}
	</style>
</head>

<body>
	<div id="scrollDiv">
		<table id="freezeHeaders" class="table-striped table-bordered table-centre">			
			<tr>
				<th style="text-align: center; height:25px">
					<%= resourceBundle.getProperty("DataManager.DisplayText.Parameter") %>
				</th>
				<th style="width:100px; text-align: center; height:25px">
					<%= resourceBundle.getProperty("DataManager.DisplayText.Scale") %>
				</th>
			</tr>
<%
			String sCntrlType = request.getParameter("type");
			if(sCntrlType != null && !"".equals(sCntrlType))
			{			
				Map <String, ParamSettings> mParams = RDMServicesUtils.getGraphViewParamaters(sCntrlType);
				List<String> lParams = new ArrayList<String>(mParams.keySet());
				Collections.sort(lParams, String.CASE_INSENSITIVE_ORDER);

				int iScale;
				String sParam;
				ParamSettings paramS = null;
				for(int i=0; i<lParams.size(); i++)
				{
					sParam = lParams.get(i);							
					paramS = mParams.get(sParam);
					iScale = paramS.getScaleOnGraph();
					if(iScale > 1)
					{
%>							
						<tr>
							<td><%= sParam %></td>
							<td>1 : <%= iScale %></td>
						</tr>
<%							
					}
				}
			}
%>
			<tr>
				<td><%= resourceBundle.getProperty("DataManager.DisplayText.Yield") %></td>
				<td>1 : <%= RDMServicesUtils.getGraphYieldScale() %></td>
			</tr>
		</table>
	</div>

	<script type="text/javascript">
		var myST = new superTable("freezeHeaders", {
			cssSkin : "sGrey",
			headerRows : 2,
			fixedCols : 0
		});
	</script>

</body>
</html>
