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
<%
	String sAction = "";
	String sUserId = "";
	String sSecDept = "";
	String sHidUserId = "";	
	String sErr = "";
	
	Map<String, String> mKeys = new HashMap<String, String>();
	mKeys.put("userId", RDMServicesConstants.USER_ID);
	mKeys.put("password", RDMServicesConstants.PASSWORD);
	mKeys.put("firstName", RDMServicesConstants.FIRST_NAME);
	mKeys.put("lastName", RDMServicesConstants.LAST_NAME);
	mKeys.put("email", RDMServicesConstants.EMAIL);
	mKeys.put("dateOfBirth", RDMServicesConstants.DATE_OF_BIRTH);
	mKeys.put("gender", RDMServicesConstants.GENDER);
	mKeys.put("address", RDMServicesConstants.ADDRESS);
	mKeys.put("role", RDMServicesConstants.ROLE_NAME);
	mKeys.put("dept", RDMServicesConstants.DEPARTMENT_NAME);
	mKeys.put("secDept", RDMServicesConstants.SEC_DEPARTMENT);
	mKeys.put("dateOfJoin", RDMServicesConstants.DATE_OF_JOIN);
	mKeys.put("contactNo", RDMServicesConstants.CONTACT_NO);
	mKeys.put("locale", RDMServicesConstants.LOCALE);
	mKeys.put("training", RDMServicesConstants.TRAINING);
	
	Map<String, String> mUserInfo = new HashMap<String, String>();
	try
	{
		String sField = "";
		String sFilePath = "";
		String sImageName = "";
		String sImagePath = getServletContext().getRealPath("/UserImages");
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
					if("hid_userId".equals(sField))
					{
						sHidUserId = item.getString();
					}
					if(mKeys.containsKey(sField))
					{
						if("secDept".equals(sField))
						{
							sSecDept = mUserInfo.get(mKeys.get(sField));
							sSecDept = ((sSecDept == null) ? item.getString() : (sSecDept + "|" + item.getString()));
							
							mUserInfo.put(mKeys.get(sField), sSecDept);
						}
						else
						{
							mUserInfo.put(mKeys.get(sField), item.getString());
							if("userId".equals(sField))
							{
								sUserId = item.getString();
							}
						}
					}
					else if("mode".equals(sField))
					{
						sAction = item.getString();
					}
				}
				else
				{
					sImageName = item.getName(); 
					if(sImageName != null && !"".equals(sImageName))
					{
						File imageFile = new File(sImagePath, (sUserId + ".jpg")); 
						if(imageFile.exists())
						{
							imageFile.delete();
						}
						imageFile.createNewFile();
						item.write(imageFile);
					}
				}
			}
			
			if("edit".equals(sAction) && !sUserId.equals(sHidUserId))
			{
				File imageFile1 = new File(sImagePath, sUserId + ".jpg"); 
				File imageFile2 = new File(sImagePath, sHidUserId + ".jpg");
				if(imageFile1.exists() && imageFile2.exists())
				{
					boolean bDeleted = imageFile2.delete();
				}
				else if(!imageFile1.exists() && imageFile2.exists())
				{
					boolean bRenamed = imageFile2.renameTo(imageFile1);
				}
			}
		}
		else
		{
			sAction = request.getParameter("mode");
			sUserId = request.getParameter("userId");
		}
		
		if(!mUserInfo.containsKey(RDMServicesConstants.TRAINING))
		{
			mUserInfo.put(RDMServicesConstants.TRAINING, "N");
		}
		
		if("add".equals(sAction))
		{
			RDMServicesUtils.addUser(mUserInfo);
		}
		else if("edit".equals(sAction))
		{
			RDMServicesUtils.updateUser(sHidUserId, mUserInfo);
		}
		else if("delete".equals(sAction))
		{
			RDMServicesUtils.deleteUser(sUserId);
		}
		else if("chgPwd".equals(sAction))
		{
			String sPassword = request.getParameter("password");
			u.changePassword(sPassword);
		}
		else if("block".equals(sAction))
		{
			RDMServicesUtils.blockUser(sUserId);
		}
		else if("unblock".equals(sAction))
		{
			RDMServicesUtils.unblockUser(sUserId);
		}
		else if("setHomePage".equals(sAction))
		{
			String sHomePage = request.getParameter("shortLink");
			u.setHomePage(sHomePage);
		}
	}
	catch(Exception e)
	{
		sErr = e.getMessage();
		sErr = (sErr == null ? "null" : sErr.replaceAll("\"", "'").replaceAll("\r", " ").replaceAll("\n", " "));
	}
%>

	<script>
		var sErr = "<%= sErr %>";
		var mode = "<%= sAction %>";
		if(sErr != "")
		{
			alert("Error: "+sErr);
			history.back(-1);
		}
		else
		{	
			if(mode == "add")
			{
				top.opener.parent.frames['filter'].searchUsers();
				top.window.close();
			}
			else if(mode == "edit")
			{
				document.location.href = "manageUser.jsp?userId=<%= sUserId %>&mode="+mode;
				top.opener.parent.frames['filter'].searchUsers();
			}
			else if(mode == "chgPwd")
			{
				alert("<%= resourceBundle.getProperty("DataManager.DisplayText.Password_Modified") %>");
				top.document.location.href =  "../LogoutServlet";
				alert(top.document.location.href);
			}
			else if(mode == "setHomePage")
			{
				document.location.href =  "short-links.jsp";
			}
			else
			{
				parent.frames['filter'].searchUsers();
			}
		}
		
	</script>
</html>
