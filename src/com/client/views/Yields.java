package com.client.views;

import com.client.db.DataQuery;
import com.client.util.MapList;

public class Yields 
{
	public Yields()
	{
		
	}

	public MapList getYields(String sController, String sFromDate, String sToDate, String sCond, String sYield, String sBNo, boolean bGrpByDate) throws Exception
	{
		DataQuery query = new DataQuery();
		return query.getYields(sController, sFromDate, sToDate, sCond, sYield, sBNo, bGrpByDate);
	}
	
	public boolean updateYield(String sController, String sEstYield, String sYield, String sDate, String sLoggedBy, String sComments) throws Exception
	{
		DataQuery query = new DataQuery();
		return query.updateYield(sController, sEstYield, sYield, sDate, sLoggedBy, sComments);
	}
	
	public boolean deleteYield(String sUserId, String sController, String sDate) throws Exception
	{
		DataQuery query = new DataQuery();
		return query.deleteYield(sUserId, sController, sDate);
	}
	
	public void updateDailyYield() throws Exception
	{
		DataQuery query = new DataQuery();
		query.updateDailyYield();
	}
	
	public double[] getPackedOverages(String sDate) throws Exception
	{
		DataQuery query = new DataQuery();
		return query.getPackedOverages(sDate);
	}
}
