<%@page contentType="text/html;charset=UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>

<%@page import="java.io.*" %>
<%@page import="java.text.*" %>
<%@page import="java.util.*" %>
<%@page import="com.client.*" %>
<%@page import="com.client.util.*" %>
<%@page import="com.client.reports.*" %>
<%@page import="org.apache.commons.fileupload.FileItem" %>
<%@page import="org.apache.commons.fileupload.FileItemFactory" %>
<%@page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>

<jsp:useBean id="RDMSession" scope="session" class="com.client.ServicesSession" />
<%@include file="commonUtils.jsp" %>

<%
	boolean bErr = false;
	String sErr = "";	

	try
	{
		ReportDAO reportDAO = new ReportDAO();
		
		SimpleDateFormat input = new java.text.SimpleDateFormat("dd-MM-yyyy HH:mm", Locale.getDefault());
		SimpleDateFormat output = new java.text.SimpleDateFormat("dd-MMM-yyyy HH:mm", Locale.getDefault());
		SimpleDateFormat sdf = new java.text.SimpleDateFormat("ddMMyyyyHHmmss", Locale.getDefault());
		String sDate = output.format(Calendar.getInstance().getTime());
		String sAttachmentFolder = sdf.format(Calendar.getInstance().getTime());

		boolean isMultipart = ServletFileUpload.isMultipartContent(request);
		if (!isMultipart)
		{
			String sReport = request.getParameter("report");
			String sAction = request.getParameter("action");
			String sReportRecords = request.getParameter("recordFile");
			
			if("addMultiRecords".equals(sAction))
			{
				reportDAO.insertRecords(u.getUser(), sReport, sReportRecords);
			}
		}
		else
		{
			String sAttrName = "";
			String sAttrValue = "";
			String sValue = "";
			String sDateCol = "";
			String sReport = "";
			String sAction = "";
			String[] saDateCol = null;
			FileItem item = null;
			Map<String, String> mRecord = new HashMap<String, String>();
			Map<String, String[]> mDateCols = new HashMap<String, String[]>();

			FileItemFactory factory = new DiskFileItemFactory();
			ServletFileUpload upload = new ServletFileUpload(factory);

			List<FileItem> fields = upload.parseRequest(request);
			Iterator<FileItem> itr = fields.iterator();
			while (itr.hasNext()) 
			{
				item = (FileItem) itr.next();
				if (item.isFormField())
				{
					sAttrName = item.getFieldName();
			
					if("report".equals(sAttrName))
					{
						sReport = item.getString();
					}
					else if("action".equals(sAttrName))
					{
						sAction = item.getString();
					}
					else if("AttachDir".equals(sAttrName))
					{
						if(!"".equals(item.getString()))
						{
							sAttachmentFolder = item.getString();
						}
					}
					else
					{
						sAttrValue = item.getString();
						if(sAttrName.startsWith("Column"))
						{
							if(sAttrName.endsWith("_dt") || sAttrName.endsWith("_hr") || sAttrName.endsWith("_min"))
							{
								sDateCol = sAttrName.substring(0, sAttrName.indexOf("_"));						
								saDateCol = (mDateCols.containsKey(sDateCol) ? mDateCols.get(sDateCol) : new String[3]);
								
								if(sAttrName.endsWith("_dt"))
								{
									saDateCol[0] = sAttrValue;
								}
								else if(sAttrName.endsWith("_hr"))
								{
									saDateCol[1] = sAttrValue;
								}
								else if(sAttrName.endsWith("_min"))
								{
									saDateCol[2] = sAttrValue;
								}
								
								mDateCols.put(sDateCol, saDateCol);
							}
							else
							{
								if(sAttrName.endsWith("_Manual"))
								{
									sAttrName = sAttrName.substring(0, sAttrName.indexOf("_"));
								}
								else if(sAttrValue.equals("SystemDateTime"))
								{
									sAttrValue = sDate;
								}
								
								if(mRecord.containsKey(sAttrName))
								{
									sValue = mRecord.get(sAttrName);
									if("".equals(sValue))
									{
										mRecord.put(sAttrName, sAttrValue);
									}
								}
								else
								{
									mRecord.put(sAttrName, sAttrValue);
								}
							}
						}
					}
				}
				else
				{
					sAttrName = item.getFieldName();
					sAttrValue = item.getName();
					String sAttachments = sAttachmentFolder+"/"+sAttrValue;
					
					if(sAttrValue != null && !"".equals(sAttrValue))
					{
						File attachDir = new File(getServletContext().getRealPath("/Attachments/"+sAttachmentFolder)); 
						if(!attachDir.exists())
						{
							attachDir.mkdir();
						}
						else
						{
							String[] saFiles = attachDir.list();
							for(int z=0; z<saFiles.length; z++)
							{
								sAttachments = sAttachments + "|" + sAttachmentFolder+"/"+saFiles[z];
							}
						}
						
						File attachment = new File(attachDir, sAttrValue);
						if(attachment.exists())
						{
							attachment.delete();
						}
						attachment.createNewFile();
						item.write(attachment);
						
						mRecord.put(sAttrName, sAttachments);
					}
				}
			}

			Iterator<String> itrDateCols = mDateCols.keySet().iterator();
			while(itrDateCols.hasNext())
			{
				sAttrName = itrDateCols.next();

				saDateCol = mDateCols.get(sAttrName);
				if(!"".equals(saDateCol[0]))
				{
					sAttrValue = output.format(input.parse(saDateCol[0]+" "+saDateCol[1]+":"+saDateCol[2]));				
					mRecord.put(sAttrName, sAttrValue);
				}
			}
			
			if("addRecord".equals(sAction))
			{
				reportDAO.insertRecord(u.getUser(), sReport, mRecord);
			}
			else
			{
				reportDAO.updateRecord(u.getUser(), sReport, mRecord);
			}
		}
	}
	catch(Exception e)
	{
		e.printStackTrace(System.out);
		bErr = true;
		sErr = e.getMessage();
	}
%>
	<html>
	<head>
		<link type="text/css" href="../styles/dygraph.css" rel="stylesheet" />
	</head>
	<body>
		<table width="80%">
<%
		if(bErr)
		{
%>
			<tr>
				<th class="label">Data record(s) upload failed with following errors</th>
			</tr>
			<tr>
				<td class="text"><%= sErr %></td>
			</tr>
<%
		}
		else
		{
%>
			<tr>
				<th class="label">Data record(s) updated successfully</th>
			</tr>
<%
		}
%>
		</table>
	</body>
</html>