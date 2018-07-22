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
import com.client.views.BatchPhaseLoad;

public class ExportBatchPhaseLoad extends HttpServlet
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
			
			String sMonth = request.getParameter("Month");
			String sYear = request.getParameter("Year");
			String sCntrlType = request.getParameter("CntrlType");
			String sProductType = request.getParameter("ProductType");
			String sYield = request.getParameter("Yield");
			boolean bYield = (!"Yes".equals(sYield) ? false : true);
			
			BatchPhaseLoad phaseLoad = new BatchPhaseLoad();
			String filename = phaseLoad.exportBatchPhaseGraph(sMonth, sYear, sCntrlType, sProductType, bYield);
			
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
