<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>
<%@page import="com.client.views.*" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<html>
<%
	String sController = request.getParameter("controller");
	String sText = request.getParameter("abbr");
	String sMessage = request.getParameter("message");
	String sComments = request.getParameter("comments");
	sComments = ((sComments == null) ? "" : sComments);
	String sGlobal = request.getParameter("global");
	sGlobal = ((sGlobal == null) ? "N" : sGlobal);
	String sUser = u.getUser();
	String sCommentId = request.getParameter("cmtId");
	String sMode = request.getParameter("mode");
	String sFrom = request.getParameter("from");
	sFrom = ((sFrom == null) ? "" : sFrom);
	String sAttachment = request.getParameter("attachment");
	
	String sDept = "";
	StringList slDept = new StringList();
	slDept.add(u.getDepartment());
	slDept.addAll(u.getSecondaryDepartments());
	if(slDept.size() > 1)
	{
		sDept = "";
	}
	else if(slDept.size() == 1)
	{
		sDept = slDept.get(0);
	}
	
	String[] saDept = request.getParameterValues("dept");
	if(saDept != null)
	{
		for(int i=0; i<saDept.length; i++)
		{
			sDept = ((sDept.length() == 0) ? saDept[i] : (sDept + "|" + saDept[i]));
		}
	}
		
	String sErr = "";
	Comments comments = new Comments();
	try
	{
		if("add".equals(sMode))
		{
			Map<String, String> mComment = new HashMap<String, String>();
			mComment.put(RDMServicesConstants.COMMENT_ID, sCommentId);
			mComment.put(RDMServicesConstants.ROOM_ID, sController);
			mComment.put(RDMServicesConstants.CATEGORY, sText);
			mComment.put(RDMServicesConstants.LOG_TEXT, sMessage);
			mComment.put(RDMServicesConstants.LOGGED_BY, sUser);
			mComment.put(RDMServicesConstants.REVIEW_COMMENTS, sComments);
			mComment.put(RDMServicesConstants.GLOBAL_ALERT, sGlobal);
			mComment.put(RDMServicesConstants.DEPARTMENT_NAME, sDept);
			mComment.put(RDMServicesConstants.ATTACHMENTS, sAttachment);

			comments.addUserComments(mComment);
		}
		else if("update".equals(sMode))
		{
			Map<String, String> mComment = new HashMap<String, String>();
			mComment.put(RDMServicesConstants.COMMENT_ID, sCommentId);
			mComment.put(RDMServicesConstants.LOGGED_BY, sUser);
			mComment.put(RDMServicesConstants.REVIEW_COMMENTS, sComments);
			mComment.put(RDMServicesConstants.ATTACHMENTS, sAttachment);
			mComment.put("REPLACE", request.getParameter("replace"));
			
			comments.updateAlert(mComment);
		}
		else if("close".equals(sMode))
		{
			
			comments.closeAlert(sUser, sCommentId);
		}
	}
	catch(Exception e)
	{
		sErr = e.getMessage();
		sErr = (sErr == null ? "null" : sErr.replaceAll("\"", "'").replaceAll("\r", " ").replaceAll("\n", " "));
	}
%>

	<script>
	
		var sMode = "<%= sMode %>";
		var sFrom = "<%= sFrom %>";
		var sErr = "<%= sErr %>";
		if(sErr != "")
		{
			alert("Error: "+sErr);
			history.back(-1);
		}
		else
		{
			if(sMode == "add" || sMode == "update")
			{
				if(sFrom == "homeView")
				{
					opener.location.href = opener.location.href;
				}
				else if(sFrom == "commentsView")
				{
					
					//opener.location.href = opener.location.href;
					opener.location.href = opener.location.href;
				}
				window.close();
			}
			else if(sMode == "close")
			{
				if(sFrom == "homeView")
				{
					//parent.frames['results'].document.location.href = parent.frames['results'].document.location.href;
					document.location.href = document.referrer;
					
				}
				else if(sFrom == "commentsView")
				{
					parent.frames['filter'].showComments();
					
				}
			}
		}
		
	</script>

</html>