<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>
<%@page language="java" %>
<%@page import="com.client.util.*" %>
<%@page import="com.client.views.*" %>
<%@include file="commonUtils.jsp" %>
<HTML>
<HEAD>
	<link type="text/css" href="../styles/dygraph.css" rel="stylesheet" />
	<link type="text/css" href="../styles/superTables.css" rel="stylesheet" />
	
	<script language="javascript">
	function loadGraph()
	{
		var sGraphFile = "";
		var elm = document.getElementsByName('GraphFile');
		for(i=0; i<elm.length; i++)
		{
			if(elm[i].checked == true)
			{
				sGraphFile = elm[i].value;
			}
		}

		if(sGraphFile == "")
		{
			alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Choose_Load_Graph") %>");
			return;
		}

		window.open('showCustomGraph.jsp?GraphFile='+sGraphFile,'','menubar=no,toolbar=no,location=no,resizable=yes,scrollbars=yes,status=no,height=<%= winHeight * 0.85 %>px,width=<%= winWidth * 0.90 %>px');
	}
	
	function deleteGraph()
	{
		var sGraphFile = "";
		var elm = document.getElementsByName('GraphFile');
		for(i=0; i<elm.length; i++)
		{
			if(elm[i].checked == true)
			{
				sGraphFile = elm[i].value;
			}
		}

		if(sGraphFile == "")
		{
			alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Choose_Delete_Graph") %>");
			return;
		}

		document.g2.action = "deleteCustomGraph.jsp";
		document.g2.submit();
	}
	</script>
	
</HEAD>  
<BODY>
	<table border="0" width="80%">
		<FORM id="g1" name="g1" ENCTYPE="multipart/form-data" ACTION="uploadCustomGraphData.jsp" METHOD="POST" target="hidden">
            <tr>
				<th colspan="2" class="label" style="text-align: center; height:25px">
					<%= resourceBundle.getProperty("DataManager.DisplayText.Upload_custom_graph") %>
				</th>
			</tr>
			<tr>
				<td class="label" width="30%"><%= resourceBundle.getProperty("DataManager.DisplayText.Choose_file") %></td>
				<td width="70%"><INPUT TYPE="file" NAME="F1"></td>
			</tr>
			<tr>
				<td colspan="2" align="right"><INPUT TYPE="submit" VALUE="<%= resourceBundle.getProperty("DataManager.DisplayText.Load_Graph") %>"></td>
			</tr>
		</FORM>
		<tr>
			<td COLSPAN="2">&nbsp;</td>
		</tr>
		<tr>
			<td COLSPAN="2">&nbsp;</td>
		</tr>
		<FORM id="g2" name="g2" METHOD="POST" target="hidden">
		    <tr>
				<th colspan="2" class="label" style="text-align: center; height:25px">
					<%= resourceBundle.getProperty("DataManager.DisplayText.Choose_custom_graph") %>
				</th>
			</tr>

<%
			AttrDataGraph graph = new AttrDataGraph();
			StringList slGraphs = graph.getCustomGraphs();
			for(int i=0; i<slGraphs.size(); i++)
			{
%>
				<tr>
					<td colspan="2">
						<input type="radio" name="GraphFile" id="GraphFile" value="<%= slGraphs.get(i) %>">
						<%= slGraphs.get(i) %>
					</td>
				<tr>
<%
			}
%>
			<tr>
				<td align="left">
					<input type="button" name="ShowGraph" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Load_Graph") %>" onClick="loadGraph()">
				</td>
				<td align="right">
					<input type="button" name="DeleteGraph" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Delete_Graph") %>" onClick="deleteGraph()">
				</td>
			</tr>
		</FORM>
	<table>
</BODY>
</HTML>