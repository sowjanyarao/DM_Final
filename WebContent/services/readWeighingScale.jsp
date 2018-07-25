<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>
<%@page import="com.client.db.*" %>
<%@page import="com.client.weights.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<%
double dWeight = 0.0d;
boolean bErr = false;
String sErr = "";

String sScaleId = request.getParameter("scaleId");
String sScaleIP = request.getParameter("scaleIP");
String sPort = request.getParameter("port");
int iPort = Integer.parseInt(sPort);
String sAttrName = request.getParameter("attrName");

try
{
	if(sScaleId != null)
	{
		session.setAttribute("SelectedScale", sScaleId);
	}
	CheckWeight chkWeight = new CheckWeight();
	dWeight = chkWeight.readWeight(sScaleIP, iPort);
}
catch(Exception e)
{
	bErr = true;
	sErr = e.getMessage();
}
%>
<html>
	<script language="javascript">
<%
		if(bErr)
		{
%>
			alert("<%= sErr %>");
<%
		}
		else
		{
			if(dWeight > 0.0)
			{
%>
				try
				{
					parent.frames['content'].document.getElementById('save').disabled = false;
				}
				catch(e1)
				{}
<%
			}
%>
			try
			{
				var AttrName = parent.frames['content'].document.getElementById('<%= sAttrName %>');
				AttrName.value = "<%= dWeight %>";
			}
			catch(e2)
			{
				var AttrName = parent.document.getElementById('<%= sAttrName %>');
				AttrName.value = "<%= dWeight %>";
			}
<%
		}
%>
		try
		{
			parent.frames['content'].document.getElementById('<%= sAttrName %>_weights').style.display = "block";
			parent.frames['content'].document.getElementById('<%= sAttrName %>_loading').style.display = "none";
		}
		catch(e3)
		{
			parent.document.getElementById('<%= sAttrName %>_weights').style.display = "block";
			parent.document.getElementById('<%= sAttrName %>_loading').style.display = "none";
		}
	</script>
</html>