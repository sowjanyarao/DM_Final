<%@page import="java.util.*" %>
<%@page import="com.client.util.*" %>

<%
	Locale locale = request.getLocale();
	LabelResourceBundle resourceBundle = new LabelResourceBundle(locale);
%>

<html>
<head>
	<meta http-equiv="refresh" content="15;url=login.jsp">
</head>
<body>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>

<table align="center" valign="center">
	<tr>
		<td align="center">
			<font color="#800000" size="4"><%= resourceBundle.getProperty("DataManager.DisplayText.Logout_Message1") %></font><br>
			<%= resourceBundle.getProperty("DataManager.DisplayText.Logout_Message2") %>
		</td>
	</tr>	
</table>

</body>
</html>
