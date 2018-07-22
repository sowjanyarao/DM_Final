<%@page import="java.util.*" %>
<%@page import="com.client.util.*" %>

<%
	Locale locale = request.getLocale();
	LabelResourceBundle resourceBundle = new LabelResourceBundle(locale);
%>

<html>
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
		<td>
			<font color="#800000" size="4"><%= resourceBundle.getProperty("DataManager.DisplayText.Invalid_License") %></font>
		</td>
	</tr>	
</table>

</body>
</html>
