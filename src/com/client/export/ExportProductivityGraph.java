package com.client.export;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.client.util.RDMServicesUtils;
import com.client.views.ProductivityGraph;

public class ExportProductivityGraph extends HttpServlet
{
	private static final long serialVersionUID = 1L;

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
	{
		doPost(request, response);
	}
	
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
	{
		FileInputStream fileInputStream = null;
		PrintWriter out = null;
		
		try
		{
			out = response.getWriter();
			
			String sUserId = request.getParameter("userId");
			String sFName = request.getParameter("FName");
			String sLName = request.getParameter("LName");
			String sDept = request.getParameter("dept");
			String sStartDt = request.getParameter("start_date");
			String sEndDt = request.getParameter("end_date");
			
			ProductivityGraph graph = new ProductivityGraph();
			String filename = graph.exportProductivityGraph(sUserId, sFName, sLName, sDept, sStartDt, sEndDt);
			
			String filepath = RDMServicesUtils.getClassLoaderpath("../../export");
			
			File file = new File(filepath , filename);
			fileInputStream = new FileInputStream(file);
			
			response.setHeader("Content-Type", "application/octet-stream");
			response.setHeader("Content-Disposition","attachment; filename=\"" + filename + "\""); 
	  
			int i; 
			while ((i = fileInputStream.read()) != -1)
			{
				out.write(i); 
			}
		}
		catch(Exception e)
		{
			e.printStackTrace(System.out);
		}
		finally
		{
			if(fileInputStream != null)
			{
				fileInputStream.close();
			}
			if(out != null)
			{
				out.close();
			}
		}
	}
}
