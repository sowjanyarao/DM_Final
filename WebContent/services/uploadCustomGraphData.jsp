<%@page import="com.client.views.*" %>

<%@include file="commonUtils.jsp" %>

<%
try
{
	AttrDataGraph graph = new AttrDataGraph();
	String sGraphFile = graph.loadCustomGraph(request);
%>
	<script language="javascript">
		window.open('showCustomGraph.jsp?GraphFile=<%= sGraphFile %>','','menubar=no,toolbar=no,location=no,resizable=yes,scrollbars=yes,status=no,height=<%= winHeight * 0.85 %>px,width=<%= winWidth * 0.90 %>px');
		
		parent.frames['custom'].location.href = parent.frames['custom'].location.href;
	</script>
<%
}
catch(Exception e)
{
%>
	<script language="javascript">
		alert("Error : <%= e.getMessage() %>");
	</script>
<%
}
%>