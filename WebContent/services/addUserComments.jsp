<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<%
    String sController = request.getParameter("controller");
    sController = (sController == null ? "" : sController);
	String sFrom = request.getParameter("from");
	sFrom = ((sFrom == null) ? "" : sFrom);
	
	StringList slDept = new StringList();
	slDept.add(u.getDepartment());
	slDept.addAll(u.getSecondaryDepartments());
	
	MapList mlTasks = RDMServicesUtils.getCommentTasks(slDept);
	
	Map <String, String> mDepartments = RDMServicesUtils.getDepartments();
	List<String> lDepartments = new ArrayList<String>(mDepartments.keySet());
	Collections.sort(lDepartments, String.CASE_INSENSITIVE_ORDER);
	
	SimpleDateFormat sdf = new SimpleDateFormat("MMddyyyyHHmmss");
	Calendar cal = Calendar.getInstance();
	String sCommentId = sdf.format(cal.getTime());
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta name="description" content="Datamanager"/>
     <meta name="description" content="Datamanager"/>
    <meta name="author" content="Inventaa"/>
    <meta name="robots" content="noindex, nofollow"/>
    <meta name="viewport" content="width=device-width,initial-scale=1.0,user-scalable=0"/>

   <!-- Icons -->
    <!-- The following icons can be replaced with your own, they are used by desktop and mobile browsers -->
    <link rel="shortcut icon" href="../img/fav-icon.jpg"/>
    <!-- END Icons -->

    <!-- Stylesheets -->
    <!-- Bootstrap is included in its original form, unaltered -->
    <link rel="stylesheet" href="../css/bootstrap.min.css"/>

    <!-- Related styles of various icon packs and plugins -->
    <link rel="stylesheet" href="../css/plugins.css"/>

    <!-- The main stylesheet of this template. All Bootstrap overwrites are defined in here -->
    <link rel="stylesheet" href="../css/main.css"/>

    <!-- Include a specific file here from ../css/themes/ folder to alter the default theme of the template -->

    <!-- The themes stylesheet of this template (for using specific theme color in individual elements - must included last) -->
    <link rel="stylesheet" href="../css/themes.css"/>
    <!-- END Stylesheets -->
    <!-- Modernizr (browser feature detection library) -->
    <script src="../js/vendor/modernizr-3.3.1.min.js"></script>
  
	<script src="../js/vendor/jquery-2.2.4.min.js"></script>
    <script src="../js/vendor/bootstrap.min.js"></script>
    <script src="../js/plugins.js"></script>
    <script src="../js/app.js"></script>
    <!-- Load and execute javascript code used only in this page -->
    <script src="../js/pages/readyDashboard.js"></script>
    <script language="javascript">
        if (!String.prototype.trim) 
        {
            String.prototype.trim = function() {
                return this.replace(/^\s+|\s+$/g,'');
            }
        }
        
        function submitForm()
        {
            var controller = document.getElementById("controller");
            if(controller.value == "")
            {
                alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Choose_Room") %>");
                controller.focus();
                return false;
            }
            
            var abbr = document.getElementById("abbr");
            if(abbr.value == "")
            {
                alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Select_Text_Short_Desc") %>");
                abbr.focus();
                return false;
            }
            
            document.frm.submit();
        }
        
        function setGlobal()
        {
            if(document.frm.global.checked)
            {
                document.frm.global.value = "Y";
            }
            else
            {
                document.frm.global.value = "N";
            }           
        }
    </script>
</head>

<body>

			
			<!-- Main Container -->
			<div id="main-container">

				<div id="page-content">
    <form name="frm" method="post" action="processAttachments.jsp" enctype="multipart/form-data" class="form-horizontal form-bordered">
        <input type="hidden" id="mode" name="mode" value="add"/>
		<input type="hidden" id="from" name="from" value="<%= sFrom %>"/>		
        <input type="hidden" id="message" name="message" value=""/>
		<input type="hidden" id="cmtId" name="cmtId" value="<%= sCommentId %>"/>
		<input type="hidden" id="folder" name="folder" value="<%= sCommentId %>"/>
		<input type="hidden" id="replace" name="replace" value="no"/>
		<input type="hidden" id="processPage" name="processPage" value="manageCommentsProcess.jsp"/>
       <div class="table table-responsive table-hover">
		
        <table id="datatable" class="table table-striped table-bordered table-vcenter">
            <tr>
                <td colspan="2" align="center"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Add_Comments") %></b></td>
            </tr>
<%
        if("".equals(sController))
        {
%>
            <tr>
                <td  width="30%"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Room") %></b></td>
                <td  width="70%">
                    <select id="controller" name="controller" class="form-control">
                        <option value=""><%= resourceBundle.getProperty("DataManager.DisplayText.Please_choose_one") %></option>
<%
                    StringList slControllers = RDMSession.getControllers();
					slControllers.addAll(RDMSession.getInactiveControllers());
					slControllers.sort();
                    for(int i=0; i<slControllers.size(); i++)
                    {
%>
                        <option value="<%= slControllers.get(i) %>"><%= slControllers.get(i) %></option>
<%
                    }
%>
                    </select>
                </td>
            </tr>
<%
        }
        else
        {
%>
            <input type="hidden" id="controller" name="controller" value="<%= sController %>"/>
<%
        }
%>
            <tr>
                <td  width="30%"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Add_Alert") %></b></td>
                <td  width="70%">
                    <input type="checkbox" id="global" name="global" value="N" onclick="javascript:setGlobal()">Yes
                </td>
            </tr>
            
            <tr>
                <td  width="30%"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Text_Short_Desc") %></b></td>
                <td  width="70%">
                    <select id="abbr" name="abbr" class="form-control">
                        <option value=""><%= resourceBundle.getProperty("DataManager.DisplayText.Please_choose_one") %></option>
<%
                    Map<String, String> mTask = null;
					String sTaskId = "";
					String sTaskName = "";
					for(int i=0; i<mlTasks.size(); i++)
					{
						mTask = mlTasks.get(i);
						sTaskId = mTask.get(RDMServicesConstants.TASK_ID);
						sTaskName = mTask.get(RDMServicesConstants.TASK_NAME);
%>
                        <option value="<%= sTaskId %>"><%= sTaskId %> (<%= sTaskName %>)</option>
<%
                    }
%>
                    </select>
                </td>
            </tr>
			<tr>
				<td  width="30%"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Departments") %></b></td>
				<td  width="70%">
					<select id="dept" name="dept" multiple size="5"  class="form-control">
<%
						String sDeptName = null;
						for(int j=0; j<slDept.size(); j++)
						{
							sDeptName = slDept.get(j);
%>
							<option value="<%= sDeptName %>" selected><%= sDeptName %></option>
<%
						}
						
						for(int j=0; j<lDepartments.size(); j++)
						{
							sDeptName = lDepartments.get(j);
							if(slDept.contains(sDeptName))
							{
								continue;
							}
%>
							<option value="<%= sDeptName %>"><%= sDeptName %></option>
<%
						}
%>
					</select>
				</td>
			</tr>
            <tr>
                <td  width="30%"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Comments") %></b></td>
                <td  width="70%">
                    <textarea id="comments" name="comments" rows="5" cols="35" class="form-control"></textarea>
                </td>
            </tr>
			<tr>
				<td  width="30%"><b><%= resourceBundle.getProperty("DataManager.DisplayText.Attachments") %></b></td>
				<td  width="70%">
					<input type="file" id="attachment" name="attachment" class="form-control"/>
				</td>
			</tr>
            <tr>
                <td colspan="2"></td>
            </tr>
            <tr>
                <td colspan="2" align="right">
                    <input type="button" name="Save" class="btn btn-primary" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Save") %>" onclick="submitForm()"/>&nbsp;&nbsp;&nbsp;
                    <input type="button" name="Cancel" class="btn btn-primary" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Cancel") %>" onclick="javascript:top.window.close()"/>
                </td>
            </tr>
        </table>
        </div>
    </form>
  </div>

</body>
</html>
