package com.client.export;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.client.util.RDMServicesUtils;

public class ViewAttachments extends HttpServlet
{
	private static final long serialVersionUID = 1L;

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
	{
		doPost(request, response);
	}
	
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
	{
		int iSz = 0;
		String sFolder = request.getParameter("folder");
		String sFile = request.getParameter("imageName");
		String filepath = RDMServicesUtils.getClassLoaderpath("../../Attachments")+"/"+sFolder;
		
		if(sFile == null || "".equals(sFile))
		{
			File folder = new File(filepath);
			if(folder.exists())
			{
				File[] files = folder.listFiles();
				iSz = files.length;
				
				if(iSz == 1)
				{
					sFile = files[0].getName();
				}
			}
		}
		else
		{
			iSz = 1;
		}
		
		if(iSz == 1)
		{
			writeFile(filepath, sFile, response);
		}
		else if(iSz > 1)
		{
			writeZipFile(filepath, response);
		}
	}
	
	private void writeFile(String filepath, String sFile, HttpServletResponse response) throws ServletException, IOException 
	{
		try
		{
			File file = new File(filepath, sFile);
			FileInputStream fis = new FileInputStream(file);
			
			BufferedInputStream bis = new BufferedInputStream(fis);
			ByteArrayOutputStream out = new ByteArrayOutputStream();
			byte[] buf = new byte[1024];
			
			int bytesRead;
			while ((bytesRead = bis.read(buf)) != -1)
			{
				out.write(buf, 0, bytesRead);
			}
			
			bis.close();
			fis.close();
			out.close();
			
			ServletOutputStream sos = response.getOutputStream();
			response.setHeader("Content-Type", "application/octet-stream");
			response.setHeader("Content-Disposition","attachment; filename=\"" + file.getName() + "\"");
			sos.write(out.toByteArray());
			sos.flush();
			sos.close();
		}
		catch(Exception e)
		{
			e.printStackTrace(System.out);
		}
	}
	
	private void writeZipFile(String filepath, HttpServletResponse response) throws ServletException, IOException 
	{
		try
		{
			byte[] buf = new byte[1024];
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			ZipOutputStream out = new ZipOutputStream(baos);
	
			File file = null;
			FileInputStream fis = null;
			BufferedInputStream bis = null;
			String entryname = null;
			
			File folder = new File(filepath);
			File[] files = folder.listFiles();
			for(int i=0; i<files.length; i++)
			{
				file = files[i];
				entryname = file.getName();
				out.putNextEntry(new ZipEntry(entryname));
				
				fis = new FileInputStream(file);
				bis = new BufferedInputStream(fis);
		
				int bytesRead;
				while ((bytesRead = bis.read(buf)) != -1)
				{
					out.write(buf, 0, bytesRead);
				}
	
				out.closeEntry();
				bis.close();
				fis.close();
			}
			
			out.flush();
			baos.flush();
			out.close();
			baos.close();
	
			ServletOutputStream sos = response.getOutputStream();
			response.setHeader("Content-Type", "application/octet-stream");
			response.setHeader("Content-Disposition", "attachment; filename=\""+folder.getName()+".zip\"");
			sos.write(baos.toByteArray());
			sos.flush();
			sos.close();
		}
		catch(Exception e)
		{
			e.printStackTrace(System.out);
		}
	}
} 

