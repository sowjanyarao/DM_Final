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
				<div class="block">
                       <div class="block-title">
							<h2><%= resourceBundle.getProperty("DataManager.DisplayText.Add_Comments") %></h2>
						</div>
    <form name="frm" method="post" action="processAttachments.jsp" enctype="multipart/form-data" class="form-horizontal form-bordered">
        <input type="hidden" id="mode" name="mode" value="add"/>
		<input type="hidden" id="from" name="from" value="<%= sFrom %>"/>		
        <input type="hidden" id="message" name="message" value=""/>
		<input type="hidden" id="cmtId" name="cmtId" value="<%= sCommentId %>"/>
		<input type="hidden" id="folder" name="folder" value="<%= sCommentId %>"/>
		<input type="hidden" id="replace" name="replace" value="no"/>
		<input type="hidden" id="processPage" name="processPage" value="manageCommentsProcess.jsp"/>
		
	     
<%
        if("".equals(sController))
        {
%>

<div class="form-group">
                                <label class="col-md-3 control-label" for="example-select"><%= resourceBundle.getProperty("DataManager.DisplayText.Room") %></label>
                                <div class="col-md-6">
                                    <select id="controller" name="controller" class="form-control" size="1">
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
                                 
                                </div>
                            </div>
<%
        }
        else
        {
%>
            <input type="hidden" id="controller" name="controller" value="<%= sController %>"/>
<%
        }
%>


<div class="form-group">
                                <label class="col-md-3 control-label"><%= resourceBundle.getProperty("DataManager.DisplayText.Add_Alert") %></label>
                                <div class="col-md-9">
                                    <label class="checkbox-inline" for="example-inline-checkbox1">
                                                    <input type="checkbox" id="global" name="global" value="N" onclick="javascript:setGlobal()">Yes
                                                </label>
                                </div>
                            </div>
                            
        
        <div class="form-group">
                                <label class="col-md-3 control-label" for="example-select"><%= resourceBundle.getProperty("DataManager.DisplayText.Text_Short_Desc") %></label>
                                <div class="col-md-6">
                                    <select id="abbr" name="abbr" class="form-control" size="1">
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
                                </div>
                            </div>
      
      
    <div class="form-group">
                                <label class="col-md-3 control-label" for="dept"><%= resourceBundle.getProperty("DataManager.DisplayText.Departments") %></label>
                                <div class="col-md-6">
                                    <select id="dept" name="dept" class="form-control" size="5" multiple="">
                                                   
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
                                </div>
                            </div>   
      
      <div class="form-group">
                                <label class="col-md-3 control-label" for="comments"><%= resourceBundle.getProperty("DataManager.DisplayText.Comments") %></label>
                                <div class="col-md-9">
                                    <textarea id="comments" name="comments" rows="7" class="form-control" placeholder="Description.."></textarea>
                                </div>
                            </div>
  
 <div class="form-group">
                                <label class="col-md-3 control-label" for="example-file-input"><%= resourceBundle.getProperty("DataManager.DisplayText.Attachments") %>
                                </label>
                                <div class="col-md-9">
                                    <input type="file" id="attachment" name="attachment">
                                </div>
                            </div>     
      
<div class="form-group form-actions">
                                <div class="col-md-9 col-md-offset-3">
                                <input type="button" name="Save" class="btn btn-effect-ripple btn-primary" style="overflow: hidden; position: relative;" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Save") %>" onclick="submitForm()"/>
                    <input type="button" name="Cancel" class="btn btn-effect-ripple btn-danger" style="overflow: hidden; position: relative;" value="<%= resourceBundle.getProperty("DataManager.DisplayText.Cancel") %>" onclick="javascript:top.window.close()"/>
                    
                                </div>
                            </div>
                            

       
        
    </form>
  </div>
  </div>

</body>
</html>
