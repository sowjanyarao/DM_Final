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
			<div class="col-xs-6">
				<!-- Input States Block -->
				<div class="block">
					<!-- Input States Title -->
					<div class="block-title">
						<h2><%=resourceBundle.getProperty("DataManager.DisplayText.Upload_custom_graph")%></h2>
					</div>
					<!-- END Input States Title -->
					<!-- Input States Content -->

					<div class="form-group">
						<label class="col-md-3 control-label" for="F1"><%=resourceBundle.getProperty("DataManager.DisplayText.Choose_file")%></label>
						<input type="file" name="F1">
					</div>
					<!-- END Input States Content -->
					<INPUT TYPE="submit" VALUE="<%=resourceBundle.getProperty("DataManager.DisplayText.Load_Graph")%>">
				</div>
			</div>

		</FORM>

		<FORM id="g2" name="g2" METHOD="POST" target="hidden">
		
					<div class="col-xs-6">
				<!-- Input States Block -->
				<div class="block">
					<!-- Input States Title -->
					<div class="block-title">
					<h2><%= resourceBundle.getProperty("DataManager.DisplayText.Choose_custom_graph") %></h2>
					</div>
					<!-- END Input States Title -->

			

			<%
			AttrDataGraph graph = new AttrDataGraph();
			StringList slGraphs = graph.getCustomGraphs();
			for(int i=0; i<slGraphs.size(); i++)
			{
%>
			<div>
			<input type="radio" name="GraphFile" id="GraphFile" value="<%= slGraphs.get(i) %>"> <%= slGraphs.get(i) %>
			</div>
				<%
			}
%>
			<input type="button" name="ShowGraph" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Load_Graph") %>" onClick="loadGraph()"></td>
			<input type="button" name="DeleteGraph" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Delete_Graph") %>" onClick="deleteGraph()"></td>
			
		</FORM>
		<table>
</BODY>
</HTML>