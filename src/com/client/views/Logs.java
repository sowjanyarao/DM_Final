package com.client.views;

import com.client.db.DataQuery;
import com.client.util.MapList;

public class Logs 
{
	public Logs()
	{
		
	}
	
	public MapList getLogHistory(String sRoom, String sStage, String BNo, String sFromDate, String sToDate, 
		String sParams, String showSysLogs, int limit) throws Exception
	{
		DataQuery query = new DataQuery();
		return query.getLogHistory(sRoom, sStage, BNo, sFromDate, sToDate, sParams, showSysLogs, limit);
	}
}
