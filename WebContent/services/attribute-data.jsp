<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<html>

	<div style="width:100%;" >
	<div style="float:left;width:100%;overflow: hidden; position:relative;" >
			
			<frameset rows="99%,1%" frameborder="0">
		<frameset cols="30%,30%,40%" frameborder="0">
			<frame name="select" src="attrDataGraphSelection.jsp" />
			<frame name="legend" src="graphLegend.jsp" />
			<frame name="custom" src="viewCustomGraph.jsp" />
		</frameset>
		<frame name="hidden" src="blank.jsp" />
	</frameset>
	</div>
	</div>
</html>