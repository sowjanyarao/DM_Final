<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.io.*" %>
<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>
<%@page import="org.apache.commons.fileupload.FileItem" %>
<%@page import="org.apache.commons.fileupload.FileItemFactory" %>
<%@page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<html>
<body>
	<form name="frm" method="post">
<%
	boolean bErr = false;
	long lSize = 0;
	String sField = "";
	String sFilePath = "";
	String sImageName = "";
	String sFolder = "";
	String sReplace = "";
	String sProcessPage = "";
	FileItem item = null;	
	boolean isMultipart = ServletFileUpload.isMultipartContent(request);
	if (isMultipart)
	{
		FileItemFactory factory = new DiskFileItemFactory();
		ServletFileUpload upload = new ServletFileUpload(factory);
	
		List<FileItem> fields = upload.parseRequest(request);
		Iterator<FileItem> itr = fields.iterator();
		while (itr.hasNext()) 
		{
			item = (FileItem) itr.next();
			if (item.isFormField())
			{
				sField = item.getFieldName();
				if("folder".equals(sField))
				{
					sFolder = item.getString();
				}
				else if("replace".equals(sField))
				{
					sReplace = item.getString();
				}
				else if("processPage".equals(sField))
				{
					sProcessPage = item.getString();
				}
%>
				<input type="hidden" id="<%= sField %>" name="<%= sField %>" value="<%= item.getString() %>">
<%
			}
			else
			{
				sImageName = item.getName();
				if(sImageName != null && !"".equals(sImageName))
				{
					lSize = item.getSize(); 
					if(lSize > 204800)
					{
						bErr = true;
					}
					else
					{
						File attachDir = new File(getServletContext().getRealPath("/Attachments")+"/"+sFolder); 
						if(!attachDir.exists())
						{
							attachDir.mkdir();
						}
						else
						{
							if("yes".equalsIgnoreCase(sReplace))
							{
								File[] files  = attachDir.listFiles();
								for(int i=0; i<files.length; i++)
								{
									files[i].delete();
								}
							}
						}
						
						File imageFile = new File(attachDir, sImageName); 
						if(imageFile.exists())
						{
							imageFile.delete();
						}
						imageFile.createNewFile();
						item.write(imageFile);
%>
						<input type="hidden" id="attachment" name="attachment" value="<%= sImageName %>">
<%
					}
				}
			}
		}
	}
%>
	</form>
	<script language="javascript">
<%
		if(bErr)
		{
%>
			alert("<%= resourceBundle.getProperty("DataManager.DisplayText.FileSizeError") %>");
			history.back(-1);
<%
		}
		else
		{
%>
			document.frm.action = "<%= sProcessPage %>";
			document.frm.submit();
			window.close();
<%
		}
%>
	</script>
</body>
</html>
