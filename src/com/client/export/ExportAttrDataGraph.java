package com.client.export;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.client.util.RDMServicesUtils;
import com.client.views.AttrDataGraph;

public class ExportAttrDataGraph extends HttpServlet
{
	private static final long serialVersionUID = 1L;

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
	{
		doPost(request, response);
	}
	
	@SuppressWarnings("unchecked")
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
	{
		FileInputStream fileInputStream = null;
		PrintWriter out = null;
		
		try
		{
			out = response.getWriter();
			
			HttpSession session = request.getSession();
			Map<String, String> mGraphArgs = (Map <String, String>)session.getAttribute("GraphArgs");
			
			String sController = mGraphArgs.get("Controller");
			String sStartDt = mGraphArgs.get("StartDt");
			String sEndDt = mGraphArgs.get("EndDt");
			String sParams = mGraphArgs.get("Parameters");
			String sYield = mGraphArgs.get("Yield");
			String[] saParams = sParams.split("\\|");
			boolean bYield = "Yes".equals(sYield);
			
			AttrDataGraph graph = new AttrDataGraph();
			String filename = graph.exportAttrDataGraph(sController, saParams, sStartDt, sEndDt, bYield);
			
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
