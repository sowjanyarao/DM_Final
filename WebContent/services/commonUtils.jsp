<!DOCTYPE html>
<html class="no-js" lang="en">

<%@page import="java.util.*" %>
<%@page import="java.text.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>

<%
	com.client.util.User u = (com.client.util.User)session.getAttribute("currentSessionUser");
	if(u == null || !u.isLoggedIn())
	{
%>	
		<script>
			top.window.document.location.href = "/login.jsp";
		</script>
<%
		return;
	}

	Locale locale = u.getLocale();
	LabelResourceBundle resourceBundle = new LabelResourceBundle(locale);
	
	String sVerifyLicenseExpiry = (String)session.getAttribute("VerifyLicenseExpiry");
	if(sVerifyLicenseExpiry == null || "".equals(sVerifyLicenseExpiry))
	{
		String sExpiryDate = "";//VerifyLicense.verifyLicenseExpiry();
		if(!"".equals(sExpiryDate))
		{
			String sWarning = resourceBundle.getProperty("DataManager.DisplayText.LicenseExpiryAlert");
			sWarning = String.format(sWarning, sExpiryDate);
%>	
			<script>
				alert("<%= sWarning %>");
			</script>
<%
		}
		session.setAttribute("VerifyLicenseExpiry", "TRUE");
	}

	String winW = request.getParameter("winW");
	String winH = request.getParameter("winH");
	if(winW != null && winH != null && !"".equals(winW) && !"".equals(winH))
	{	
		session.setAttribute("windowWidth", winW);
		session.setAttribute("windowHeight", winH);
	}
	
	int winWidth = Integer.parseInt((String)session.getAttribute("windowWidth"));
	int winHeight = Integer.parseInt((String)session.getAttribute("windowHeight"));
	
	NumberFormat numberFormat = NumberFormat.getInstance(Locale.getDefault());
	
	DecimalFormatSymbols dfSymbol = new DecimalFormatSymbols(Locale.getDefault());
	char cDecimal = dfSymbol.getDecimalSeparator();
%>

	<!-- Stylesheets -->
    <!-- Bootstrap is included in its original form, unaltered -->
    <link rel="stylesheet" href="../css/bootstrap.min.css">

    <!-- Related styles of various icon packs and plugins -->
    <link rel="stylesheet" href="../css/plugins.css">

    <!-- The main stylesheet of this template. All Bootstrap overwrites are defined in here -->
    <link rel="stylesheet" href="../css/main.css">

    <!-- Include a specific file here from css/themes/ folder to alter the default theme of the template -->

    <!-- The themes stylesheet of this template (for using specific theme color in individual elements - must included last) -->
    <link rel="stylesheet" href="../css/themes.css">
    <!-- END Stylesheets -->