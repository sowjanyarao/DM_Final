package com.client.views;

import java.io.DataInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileWriter;

import javax.servlet.http.HttpServletRequest;

import com.client.db.DataQuery;
import com.client.util.RDMServicesConstants;
import com.client.util.RDMServicesUtils;
import com.client.util.StringList;

public class AttrDataGraph extends RDMServicesConstants
{
	public AttrDataGraph()
	{
	}
	
	public String loadAttrDataGraph(String sController, String[] saParams, String sStartDt, String sEndDt, boolean bYield) throws Exception
	{
		return getAttrDataGraphCSV(sController, saParams, sStartDt, sEndDt, bYield, false);
	}
	
	public String exportAttrDataGraph(String sController, String[] saParams, String sStartDt, String sEndDt, boolean bYield) throws Exception
	{
		return getAttrDataGraphCSV(sController, saParams, sStartDt, sEndDt, bYield, true);
	}
	
	private String getAttrDataGraphCSV(String sController, String[] saParams, String sStartDt, String sEndDt, boolean bYield, boolean bExport) throws Exception
	{
		DataQuery query = new DataQuery();
		
		sStartDt = RDMServicesUtils.convertToSQLDate(sStartDt);
		sEndDt = RDMServicesUtils.convertToSQLDate(sEndDt);
		
		String sCSVParams = query.getControllerParameters(sController, saParams, sStartDt, sEndDt, bYield, bExport);
		
		String sPath = "";
		if(bExport)
		{
			try{
				sPath = RDMServicesUtils.getClassLoaderpath("../../export");		
			}catch(Exception e) {
				sPath = RDMServicesUtils.getClassLoaderpath("");		
			}
		}
		else
		{
			try{
				sPath = RDMServicesUtils.getClassLoaderpath("../../graphs/ControllerData");		
			}catch(Exception e) {
				sPath = RDMServicesUtils.getClassLoaderpath("");		
			}
		}
		
		File f = File.createTempFile(sController.replaceAll("\\s",""), ".csv", new File(sPath));
		f.setReadable(true, false);
		f.setWritable(true, false);
		f.setExecutable(true, false);
		f.deleteOnExit();
		
		FileWriter fw = new FileWriter(f);
		fw.write(sCSVParams);
		fw.flush();
		fw.close();
		
		return f.getName();
	}

	public String loadCustomGraph(HttpServletRequest request) throws Exception
	{
		String sGraphFile = "";
		
		String contentType = request.getContentType();
		if (contentType != null && contentType.indexOf("multipart/form-data") >= 0)
		{
			DataInputStream in = new DataInputStream(request.getInputStream());
			int formDataLength = request.getContentLength();
			byte dataBytes[] = new byte[formDataLength];
	
			int byteRead = 0;
			int totalBytesRead = 0;
			while (totalBytesRead < formDataLength)
			{
				byteRead = in.read(dataBytes, totalBytesRead, formDataLength);
				totalBytesRead += byteRead;
			}
	
			String file = new String(dataBytes);
	
			sGraphFile = file.substring(file.indexOf("filename=\"") + 10);
			sGraphFile = sGraphFile.substring(0, sGraphFile.indexOf("\n"));
			sGraphFile = sGraphFile.substring(sGraphFile.lastIndexOf("\\") + 1, sGraphFile.indexOf("\""));
			
			int lastIndex = contentType.lastIndexOf("=");
			String boundary = contentType.substring(lastIndex + 1, contentType.length());
			
			int pos = file.indexOf("filename=\"");
			pos = file.indexOf("\n", pos) + 1;
			pos = file.indexOf("\n", pos) + 1;
			pos = file.indexOf("\n", pos) + 1;
			
			int boundaryLocation = file.indexOf(boundary, pos) - 4;
			int startPos = ((file.substring(0, pos)).getBytes()).length;
			int endPos = ((file.substring(0, boundaryLocation)).getBytes()).length;
			
			String sPath = RDMServicesUtils.getClassLoaderpath("../../graphs/CustomData");
	
			File f = new File(sPath, sGraphFile);
			FileOutputStream fileOut = new FileOutputStream(f);
			fileOut.write(dataBytes, startPos, (endPos - startPos));
			fileOut.flush();
			fileOut.close();
		}
		
		return sGraphFile;
	}
    
    public StringList getCustomGraphs() throws Exception
    {
    	StringList slFiles = new StringList();
    	
		String sPath = RDMServicesUtils.getClassLoaderpath("../../graphs/CustomData");
    	File dir = new File(sPath);
    	
    	File[] file = dir.listFiles();
    	for(int i=0; i<file.length; i++)
    	{
    		slFiles.add(file[i].getName());
    	}
    	
    	return slFiles;
    }
    
    public void deleteCustomGraph(String sFile) throws Exception
    {
    	String sPath = RDMServicesUtils.getClassLoaderpath("../../graphs/CustomData");
    	File file = new File(sPath, sFile);
    	
    	if(file.exists())
    	{
    		file.delete();
    	}
    }
}
