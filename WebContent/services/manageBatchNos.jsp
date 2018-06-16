<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>
<%@page import="com.client.views.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<!DOCTYPE html>
<html class="no-js" lang="en">

<head>
    <meta charset="utf-8">

    <title>Inventaa</title>

    <meta name="description" content="Inventaa">
    <meta name="author" content="pixelcave">
    <meta name="robots" content="noindex, nofollow">
    <meta name="viewport" content="width=device-width,initial-scale=1.0,user-scalable=0">

    <!-- Icons -->
    <!-- The following icons can be replaced with your own, they are used by desktop and mobile browsers -->
    <link rel="shortcut icon" href="../img/fav-icon.jpg">
    <!-- END Icons -->

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

    <!-- Modernizr (browser feature detection library) -->
    <script src="../js/vendor/modernizr-3.3.1.min.js"></script>
    
    <script language="javascript">
		function Map() {
			this.keys = new Array();
			this.data = new Object();

			this.put = function (key, value) {
				if (this.data[key] == null) {
					this.keys.push(key);
				}
				this.data[key] = value;
			};

			this.get = function (key) {
				return this.data[key];
			};

			this.each = function (fn) {
				if (typeof fn != 'function') {
					return;
				}
				var len = this.keys.length;
				for (var i = 0; i < len; i++) {
					var k = this.keys[i];
					fn(k, this.data[k], i);
				}
			};

			this.entrys = function () {
				var len = this.keys.length;
				var entrys = new Array(len);
				for (var i = 0; i < len; i++) {
					entrys[i] = {
						key: this.keys[i],
						value: this.data[i]
					};
				}
				return entrys;
			};
		}
	
		function validate()
		{
			if(document.getElementById('Month').value != "" && document.getElementById('Year').value == "")
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Please_Enter_Year") %>");
				return false;
			}
			
			return true;
		}
		
		function showBatchNos()
		{
			if(validate())
			{
				document.frm.target = "results";
				document.frm.submit();
			}
		}
		
		function exportBatchNos() 
		{		
			if(validate())
			{
				var url = "../ExportBatchNos";
				url += "?Month="+document.getElementById('Month').value;
				url += "&Year="+document.getElementById('Year').value;
				url += "&CntrlType="+document.getElementById('CntrlType').value;
				url += "&defParamType="+document.getElementById('defParamType').value;

				document.location.href =  url;
			}
		}
		
		var map = new Map();
<%
		String sDefProduct = "Default Product";
		DefParamValues defParamVals = new DefParamValues();
		
		String sCntrl = null;
		StringList slDefTypes = null;
		String[] saCntrlTypes = new String[]{RDMServicesConstants.TYPE_BUNKER,RDMServicesConstants.TYPE_GROWER,RDMServicesConstants.TYPE_TUNNEL};

		for(int i=0; i<saCntrlTypes.length; i++)
		{
			sCntrl = saCntrlTypes[i];
			slDefTypes = defParamVals.getDefaultTypes(sCntrl);
%>
			var saDefTypes = new Array();
			saDefTypes[0] = "<%= sDefProduct %>";
<%
			for(int j=0; j<slDefTypes.size(); j++)
			{
%>	
				saDefTypes[<%= j + 1 %>] = "<%= slDefTypes.get(j) %>";
<%		
			}
%>
			map.put("<%= sCntrl %>", saDefTypes);
<%
		}
%>
		function setDefTypes(cntrl)
		{
			var sel = cntrl.value;
			var products = document.getElementById('defParamType');
			if(products.options != null)
			{
				while(products.options.length > 0)
				{
					products.remove(0);
				}
			}
			
			var opt = document.createElement('option');
			opt.value = "";
			opt.text = "<%= resourceBundle.getProperty("DataManager.DisplayText.Please_choose_one") %>";
			products.options.add(opt);

			var saDefTypes = map.get(sel);
			for(i=0; i<saDefTypes.length; i++)
			{
				var opt = document.createElement('option');
				opt.value = saDefTypes[i];
				opt.text = saDefTypes[i];
				products.options.add(opt);
			}
		}
		
		function refreshBatchNos()
		{
			//parent.parent.frames['displaycontent'].location.href = "manageBatchNosView.jsp";
			parent.location.href = "manageBatchNosView.jsp";
		}
	</script>
    
    
</head>

<body>
    <div id="page-wrapper" class="page-loading">
        <div class="preloader">
            <div class="inner">
                <!-- Animation spinner for all modern browsers -->
                <div class="preloader-spinner themed-background hidden-lt-ie10"></div>

                <!-- Text for IE9 -->
                <h3 class="text-primary visible-lt-ie10"><strong>Loading..</strong></h3>
            </div>
        </div>
        <!-- END Preloader -->

		<div id="page-container"
			class="header-fixed-top sidebar-visible-lg-full">

			<jsp:include page="header.jsp" />
			<!-- Alternative Sidebar -->
			<jsp:include page="header-sidebar.jsp">
				<jsp:param name="u" value="${u}" />
			</jsp:include>
			<!-- Main Sidebar -->
			<jsp:include page="sidebar.jsp" />

			<!-- Main Container -->
			<div id="main-container">
				<!-- Page content -->
				<div id="page-content">
					<form name="frm" method="post" action="manageBatchNoResults.jsp">
						<div class="row">
							<div class="col-xs-3">
								<!-- Input States Block -->
								<div class="block">
									<!-- Input States Title -->
									<div class="block-title">

										<h2><%=resourceBundle.getProperty("DataManager.DisplayText.Select_Month")%></h2>
									</div>
									<div class="form-group">
										<div class="form-group">
											<select id="Month" name="Month" class="form-control" size="1">
												<option value=""><%=resourceBundle.getProperty("DataManager.DisplayText.Please_Select")%></option>
												<option value="Jan"><%=resourceBundle.getProperty("DataManager.DisplayText.January")%></option>
												<option value="Feb"><%=resourceBundle.getProperty("DataManager.DisplayText.February")%></option>
												<option value="Mar"><%=resourceBundle.getProperty("DataManager.DisplayText.March")%></option>
												<option value="Apr"><%=resourceBundle.getProperty("DataManager.DisplayText.April")%></option>
												<option value="May"><%=resourceBundle.getProperty("DataManager.DisplayText.May")%></option>
												<option value="Jun"><%=resourceBundle.getProperty("DataManager.DisplayText.June")%></option>
												<option value="Jul"><%=resourceBundle.getProperty("DataManager.DisplayText.July")%></option>
												<option value="Aug"><%=resourceBundle.getProperty("DataManager.DisplayText.August")%></option>
												<option value="Sep"><%=resourceBundle.getProperty("DataManager.DisplayText.September")%></option>
												<option value="Oct"><%=resourceBundle.getProperty("DataManager.DisplayText.October")%></option>
												<option value="Nov"><%=resourceBundle.getProperty("DataManager.DisplayText.November")%></option>
												<option value="Dec"><%=resourceBundle.getProperty("DataManager.DisplayText.December")%></option>
											</select>
										</div>
									</div>
								</div>

							</div>
							<div class="col-xs-3">
								<!-- Input States Block -->
								<div class="block">
									<!-- Input States Title -->
									<div class="block-title">
										<h2><%=resourceBundle.getProperty("DataManager.DisplayText.Enter_Year")%></h2>
									</div>
									<!-- END Input States Title -->
									<!-- Input States Content -->
									<div class="form-group">
										<input type="text" id="Year" name="Year" class="form-control"
											value="" size="5">
									</div>
									<!-- END Input States Content -->
								</div>
							</div>
							<div class="col-xs-3">
								<!-- Input States Block -->
								<div class="block">
									<!-- Input States Title -->
									<div class="block-title">
										<h2><%=resourceBundle.getProperty("DataManager.DisplayText.Room_Type")%></h2>
									</div>
									<div class="form-group">
										<select id="CntrlType" name="CntrlType" class="form-control"
											size="1" onChange="javascript:setDefTypes(this)">
											<option value=""><%=resourceBundle.getProperty("DataManager.DisplayText.Please_choose_one")%></option>
											<option value="<%=RDMServicesConstants.TYPE_GROWER%>"><%=resourceBundle.getProperty("DataManager.DisplayText.Grower")%></option>
											<option value="<%=RDMServicesConstants.TYPE_BUNKER%>"><%=resourceBundle.getProperty("DataManager.DisplayText.Bunker")%></option>
											<option value="<%=RDMServicesConstants.TYPE_TUNNEL%>"><%=resourceBundle.getProperty("DataManager.DisplayText.Tunnel")%></option>
										</select>
									</div>
								</div>
							</div>
							<div class="col-xs-3">
								<!-- Input States Block -->
								<div class="block">
									<!-- Input States Title -->
									<div class="block-title">

										<h2><%=resourceBundle.getProperty("DataManager.DisplayText.Product")%></h2>
									</div>
									<div class="form-group">
										<select id="defParamType" name="defParamType"
											class="form-control" size="1">
											<option value=""><%=resourceBundle.getProperty("DataManager.DisplayText.Please_choose_one")%></option>
										</select>
									</div>
								</div>
							</div>

							<div class="col-xs-4 text-right">
								<input type="button" name="search" id="search"
									onclick="showBatchNos()"
									value="<%=resourceBundle.getProperty("DataManager.DisplayText.Show_Batch_Nos")%>">

								<input type="button" name="refresh" id="refresh"
									onclick="refreshBatchNos()"
									value="<%=resourceBundle.getProperty("DataManager.DisplayText.Refresh")%>">

								<input type="button" name="expBatchNos" id="expBatchNos"
									onclick="exportBatchNos()"
									value="<%=resourceBundle.getProperty("DataManager.DisplayText.Export_to_File")%>">
							</div>

						</div>
					</form>
					<!-- Datatables Block -->
					<!-- Datatables is initialized in ../js/pages/uiTables.js -->
					
					
					<div class="block full">
					<iframe name="results" src="manageBatchNoResults.jsp" align="middle" frameBorder="0" width="100%" height="<%= winHeight * 0.7 %>px">
					</iframe>
					</div>

					
				</div>
				<!-- END Page Content -->
			</div>
			<!-- END Main Container -->
		</div>
		<!-- END Page Container -->
	</div>
    <!-- END Page Wrapper -->

    <!-- jQuery, Bootstrap, jQuery plugins and Custom JS code -->
    <script src="../js/vendor/jquery-2.2.4.min.js"></script>
    <script src="../js/vendor/bootstrap.min.js"></script>
    <script src="../js/plugins.js"></script>
    <script src="../js/app.js"></script>

    <!-- Load and execute javascript code used only in this page -->
    <script src="../js/pages/uiTables.js"></script>
    <script>
        $(function() {
            UiTables.init();
        });

    </script>
</body>

</html>
