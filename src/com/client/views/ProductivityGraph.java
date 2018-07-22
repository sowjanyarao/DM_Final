package com.client.views;

import java.io.File;
import java.io.FileWriter;
import java.util.Map;

import com.client.db.DataQuery;
import com.client.util.MapList;
import com.client.util.RDMServicesConstants;
import com.client.util.RDMServicesUtils;
import com.client.util.StringList;

public class ProductivityGraph extends RDMServicesConstants
{
	public ProductivityGraph()
	{
	}
	
    public String loadProductivityGraph(String sUserId, String sFName, String sLName, 
    		String sDept, String sStartDt, String sEndDt, StringList slUsers) throws Exception
	{
		return getProductivityGraphCSV(sUserId, sFName, sLName, sDept, sStartDt, sEndDt, slUsers, false);
	}
	
	public String exportProductivityGraph(String sUserId, String sFName, String sLName, 
    		String sDept, String sStartDt, String sEndDt) throws Exception
	{
		return getProductivityGraphCSV(sUserId, sFName, sLName, sDept, sStartDt, sEndDt, null, true);
	}
    
    private String getProductivityGraphCSV(String sUserId, String sFName, String sLName, 
    		String sDept, String sStartDt, String sEndDt, StringList slUsers, boolean bExport) throws Exception
	{
		sStartDt = RDMServicesUtils.convertToSQLDate(sStartDt);
		sEndDt = RDMServicesUtils.convertToSQLDate(sEndDt);
		
		StringBuilder sbParamValues = new StringBuilder();
		if(bExport)
		{
			sbParamValues.append("Employee Code");
			sbParamValues.append(",");
			sbParamValues.append("Employee Name");
			sbParamValues.append(",");
			sbParamValues.append("No of Days");
			sbParamValues.append(",");
			sbParamValues.append("Total Quantity");
		}
		else
		{
			sbParamValues.append("count");
		}
		sbParamValues.append(",");
		sbParamValues.append("Productivity");
		sbParamValues.append("\n");
		
		String sTotalDays = null;
		String sTotalQty = null;
		String sUserName = null;
		String sProductivity = null;
		Map<String, String> mData = null;
		Map<String, String> mUsers = RDMServicesUtils.getUserNames();
		
		DataQuery query = new DataQuery();
		MapList mlData = query.getProductivity(sUserId, sFName, sLName, sDept, sStartDt, sEndDt);
		for(int i=0; i<mlData.size(); i++)
		{
			mData = mlData.get(i);
			sUserId = mData.get(USER_ID);
			sUserName = mUsers.get(sUserId);
			sProductivity = mData.get(PRODUCTIVITY);
			
			if(bExport)
			{
				sTotalDays = mData.get(T_DAYS);
				sTotalQty = mData.get(T_DEL_QTY);
				
				sbParamValues.append("=\"");
				sbParamValues.append(sUserId);
				sbParamValues.append("\",\"");
				sbParamValues.append(sUserName);
				sbParamValues.append("\",");
				sbParamValues.append((sTotalDays == null ? "0" : sTotalDays));
				sbParamValues.append(",");
				sbParamValues.append((sTotalQty == null ? "0" : sTotalQty));
			}
			else
			{
				slUsers.add(sUserName);
				sbParamValues.append(i);
			}
			
			sbParamValues.append(",");
			sbParamValues.append((sProductivity == null ? "0" : sProductivity));
			sbParamValues.append("\n");
		}
		
		String sPath = "";
		if(bExport)
		{
			sPath = RDMServicesUtils.getClassLoaderpath("../../export");
		}
		else
		{
			sPath = RDMServicesUtils.getClassLoaderpath("../../graphs/ControllerData");
		}
		
		File f = File.createTempFile("ProductivityGraphData", ".csv", new File(sPath));
		f.setReadable(true, false);
		f.setWritable(true, false);
		f.setExecutable(true, false);
		f.deleteOnExit();
		
		FileWriter fw = new FileWriter(f);
		fw.write(sbParamValues.toString());
		fw.flush();
		fw.close();
		
		return f.getName();
	}
}
