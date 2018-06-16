<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>

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

<%
String flag = request.getParameter("flag");

Locale locale = request.getLocale();
LabelResourceBundle resourceBundle = new LabelResourceBundle(locale);
%>

<table align="center" valign="center">
	<tr>
		<td>
<%
			if("nouser".equals(flag))
			{
%>
				<font color="#800000" size="4"><%= resourceBundle.getProperty("DataManager.DisplayText.User_Invalid") %></font>
<%
			}
			else if("nomail".equals(flag))
			{
%>
				<font color="#800000" size="4"><%= resourceBundle.getProperty("DataManager.DisplayText.Email_Id_Empty") %></font>
<%
			}
			else
			{
%>
				<font color="#800000" size="4"><%= resourceBundle.getProperty("DataManager.DisplayText.Password_Req_Processed") %></font>
<%
			}
%>
		</td>
	</tr>	
</table>

</body>
</html>
