package com.client.views;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

import com.client.db.DataQuery;
import com.client.util.MapList;
import com.client.util.RDMServicesConstants;
import com.client.util.StringList;

public class Alarms extends RDMServicesConstants
{
	public Alarms()
	{
		
	}
	
	public MapList getAlarmLogHistory(String sRoom, String sStage, String BNo, String sParams, 
		String sFromDate, String sToDate, String showOpenAlarms, int limit) throws Exception
	{
		DataQuery query = new DataQuery();
		return query.getAlarmLogHistory(sRoom, sStage, BNo, sParams, sFromDate, sToDate, showOpenAlarms, limit);
	}
	
	public StringList getAlarmFilters() throws Exception
	{
		DataQuery query = new DataQuery();
		return query.getAlarmFilters();
	}

	public void clearOpenAlarms(String sUser, String sClearAll, Map<String, String> mInfo) throws Exception
	{
		Map<String, Map<String, String>> mCloseAlarm = new HashMap<String, Map<String, String>>();
		DataQuery query = new DataQuery();
		
		SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss", Locale.getDefault());
		String sClosedOn = sdf.format(Calendar.getInstance().getTime());
		
		String sRoomId = mInfo.get("RoomId");
		String sSerialId = mInfo.get("SerialId");
		String sStage = mInfo.get("Stage");
		String sBatchNo = mInfo.get("Batch");
		String sTypes = mInfo.get("Types");
		String sFromDt = mInfo.get("FromDate");
		String sToDt = mInfo.get("ToDate");	
		
		if("Yes".equals(sClearAll))
		{
			Map<String, String> mAlarm = null;
			Map<String, String> mOpenAlarm = null;
			
			MapList mlOpenAlarms = query.getAlarmLogHistory(sRoomId, sStage, sBatchNo, sTypes, sFromDt, sToDt, "Yes", 0);				
			for(int i=0; i<mlOpenAlarms.size(); i++)
			{
				mOpenAlarm = mlOpenAlarms.get(i);
				sRoomId = mOpenAlarm.get(ROOM_ID);
				
				if(mCloseAlarm.containsKey(sRoomId))
				{
					mAlarm = mCloseAlarm.get(sRoomId);
				}
				else
				{
					mAlarm = new HashMap<String, String>();
				}
				
				mAlarm.put(mOpenAlarm.get(SERIAL_ID), sClosedOn);
				mCloseAlarm.put(sRoomId, mAlarm);
			}
		}
		else
		{
			Map<String, String> mAlarm = new HashMap<String, String>();
			mAlarm.put(sSerialId, sClosedOn);
			mCloseAlarm.put(sRoomId, mAlarm);
		}
		
		query.closeOpenAlarms(sUser, mCloseAlarm);
	}
	
	public void muteOpenAlarm(String sUser, String sRoomId, String sSerialId) throws Exception
	{
		SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss", Locale.getDefault());
		String sMutedOn = sdf.format(Calendar.getInstance().getTime());
		
		DataQuery query = new DataQuery();
		query.muteOpenAlarm(sUser, sRoomId, sSerialId, sMutedOn);
	}
}
