package com.client;

import java.net.ConnectException;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;
import java.util.TreeMap;

import com.client.db.DataQuery;
import com.client.util.MapList;
import com.client.util.ParamSettings;
import com.client.util.RDMServicesConstants;
import com.client.util.RDMServicesUtils;
import com.client.util.StringList;
import com.client.util.User;
import com.resourcedm.www.rdmplanttdb._2009._03._13.*;

public class PLCServices extends RDMServicesConstants
{
	private String sController = null;
	private ServicesSession session = null;
	private String sCntrlType = null;
	private StringList slManualParams = null;
	private StringList slCoolingSteamParams = null;
	private StringList slCompErrorParams = null;
	private NumberFormat numberFormat = NumberFormat.getInstance(Locale.getDefault());
	
	public PLCServices(ServicesSession session, String sController) throws Exception
	{
		this.sController = sController;
		this.session = session;
		sCntrlType = RDMServicesUtils.getControllerType(sController);
		slManualParams = RDMServicesUtils.getManualParams(sCntrlType);
		slCoolingSteamParams = RDMServicesUtils.getCoolingSteamParams(sCntrlType);
		slCompErrorParams = RDMServicesUtils.getCompErrorParams(sCntrlType);
	}
	
	private Map<String, String[]> getControllerData() throws Exception
	{
		Map<String, String[]> mParams = new HashMap<String, String[]>();

		RDMPlantTDBServicesSoapStub stub = session.getStub(this.sController);
		if(stub != null)
		{
			GetSlave getSlave = new GetSlave();
			GetSlaveResponse getSlaveResp = stub.getSlave(getSlave);
			SlaveDetail slaveDetail = getSlaveResp.getGetSlaveResult();
		
			String sName = "";
			String sUnit = "";
			String[] saParamVal = null;
			
			ArrayOfItems items = slaveDetail.getItems(); 
			Item[] item = items.getItem();
			for(int i=0; i<item.length; i++)
			{
				saParamVal = new String[2];
				saParamVal[0] = item[i].getValue().trim();
				
				sUnit = item[i].getUnits().trim();
				saParamVal[1] = ("None".equalsIgnoreCase(sUnit) ? "" : sUnit);
				
				if(!saParamVal[0].isEmpty() && "hrs:min".equals(sUnit))
				{
					try
					{
						double d = Double.valueOf(saParamVal[0]);
						int hh = (int)(d / 60);
						int mm = (int)(d % 60);

						saParamVal[0] = ((hh < 10 ? "0" : "") + hh)  + ":" + ((mm < 10 ? "0" : "") + mm);
					}
					catch(Exception e)
					{
						//do nothing
					}
				}
				
				sName = item[i].getName().trim();
				if(!"".equals(sName)  && !Character.isDigit(sName.charAt(0)) && !sName.contains("."))
				{
					mParams.put(sName, saParamVal);
				}
			}
			
			java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd-MMM-yyyy HH:mm", Locale.getDefault());
			String sDate = sdf.format(Calendar.getInstance().getTime());
			
			mParams.put("Last Refresh", new String[] {sDate, ""});
			mParams.put("BatchNo", new String[] {RDMServicesUtils.getBatchNo(sController), ""});
			mParams.put("Product", new String[] {RDMServicesUtils.getProductType(sController), ""});
		}
		return mParams;
	}
	
	public ArrayList<String[]> getControllerStages() throws Exception
	{
		return RDMServicesUtils.getControllerStages(sCntrlType);
	}
	
	public Map<String, String[]> getControllerData(boolean isRealTime) throws Exception
	{
		Map<String, String[]> mParams = new HashMap<String, String[]>();
		DataQuery query = new DataQuery();
		
		if(isRealTime)
		{
			//Sravani commented for removing active stub calculation
			//mParams = getControllerData();
			if(mParams.isEmpty() || (mParams.size() == 0))
			{
				mParams = query.getControllerParameters(sController);
			}
		}
		else
		{
			mParams = query.getControllerParameters(sController);
			if(mParams.isEmpty() || (mParams.size() == 0))
			{
				mParams = getControllerData();
			}
		}
		
		if(!mParams.isEmpty() && (mParams.size() > 0))
		{
			if(!RDMServicesUtils.isGeneralController(sController))
			{
				getSetParamValues(mParams);

				String manual = (isParamsSetOn(slManualParams, mParams) ? "On" : "Off");
				mParams.put("manual.sl", new String[] {manual, ""});
				
				String coolingSteam = (isParamsSetOn(slCoolingSteamParams, mParams) ? "On" : "Off");
				mParams.put("cooling.steam", new String[] {coolingSteam, ""});
				
				String compError = (isCompError(mParams) ? "Off" : "On");
				mParams.put("comp.error", new String[] {compError, ""});
			}
		}
		return mParams;
	}
	
    public Map<String, Map<String, String>> getRoomViewParams(User u, boolean isRealTime) throws Exception
	{
		ParamSettings paramS = null;
		String sName = "";
		String sCurrPhase = "";		
		String[] saParamVal = null;
		Map<String, String> mParamInfo = null;
		Map<String, String> mEmpty = new HashMap<String, String>();
		Map<String, Map<String, String>> mRoomViewParams = new HashMap<String, Map<String, String>>();
		
		Map<String, String[]> mParams = getControllerData(isRealTime);
		if(mParams.isEmpty() || (mParams.size() == 0))
		{
			return mRoomViewParams;
		}

		String sSfx = "";
		String sSfx1 = "";
		String stageParam = null;
		String sParamStage = null;
		String sDisplayName = null;
		String minParam = null;
		String maxParam = null;
		
		StringList slStages = new StringList();
		slStages.add("");
		slStages.add("NA");
		slStages.add("Current.Phase");

		if(mParams.containsKey("current phase"))
		{
			sCurrPhase = (mParams.get("current phase")[0]).trim();
			sCurrPhase = ((sCurrPhase.endsWith(".0")) ? sCurrPhase.substring(0, sCurrPhase.indexOf(".")) : sCurrPhase);
			sCurrPhase = sCurrPhase.replace('.', ' ');
			
			slStages.add(sCurrPhase);
		}
		
		String[] saStage = RDMServicesUtils.getControllerStage(sCntrlType, sCurrPhase);
		sCurrPhase = saStage[0];
		String stageName = saStage[1];
		
		if("0".equals(sCurrPhase))
		{
			sSfx = stageName;
			sSfx1 = "phase" + " " + stageName;
		}
		else
		{
			if(!sCurrPhase.equals(stageName))
			{
				sSfx = stageName + " " + sCurrPhase;
			}
			sSfx1 = "phase" + " " + sCurrPhase;
		}
		
		Map<String, ParamSettings> mRoomParams = RDMServicesUtils.getRoomsOverViewParamaters(sCntrlType);
		Iterator<String> itr = mRoomParams.keySet().iterator();
		while(itr.hasNext())
		{
			sName = itr.next();
			paramS = mRoomParams.get(sName);
			sParamStage = paramS.getStage();
			sDisplayName = (sCurrPhase.equals(sParamStage) ? paramS.getParamGroup() : sName);
			
			if(mParams.containsKey(sName + " " + sSfx))
			{
				stageParam = sName + " " + sSfx;
			}
			else if(mParams.containsKey(sName + " " + sSfx1))
			{
				stageParam = sName + " " + sSfx1;
			}
			else
			{
				stageParam = sName;
			}
			
			saParamVal = mParams.get(stageParam);
			if(slStages.contains(sParamStage) && (saParamVal != null))
			{
				minParam = ""; maxParam = "";
				if(stageParam.startsWith("set "))
				{
					minParam = stageParam.replaceAll("set ", "min ");
					if(mParams.containsKey(minParam))
					{
						minParam = mParams.get(minParam)[0];
					}
					else
					{
						minParam = "";
					}
					
					maxParam = stageParam.replaceAll("set ", "max ");
					if(mParams.containsKey(maxParam))
					{
						maxParam = mParams.get(maxParam)[0];
					}
					else
					{
						maxParam = "";
					}
				}
				
				mParamInfo = new HashMap<String, String>();
				mParamInfo.put(PARAM_VALUE, saParamVal[0]);
				mParamInfo.put(PARAM_UNIT, saParamVal[1]);
				mParamInfo.put(PARAM_NAME, stageParam);
				mParamInfo.put(MIN_PARAM_VALUE, minParam);
				mParamInfo.put(MAX_PARAM_VALUE, maxParam);
				mParamInfo.put(USER_ACCESS, u.getUserAccess(paramS));
				
				mRoomViewParams.put(sDisplayName, mParamInfo);
			}
			else if(!mRoomViewParams.containsKey(paramS.getParamGroup()))
			{
				mRoomViewParams.put(paramS.getParamGroup(), mEmpty);
			}
		}
		
		mParamInfo = new HashMap<String, String>();
		mParamInfo.put(PARAM_VALUE, mParams.get("Last Refresh")[0]);
		mRoomViewParams.put("Last Refresh", mParamInfo);
		
		mParamInfo = new HashMap<String, String>();
		mParamInfo.put(PARAM_VALUE, mParams.get("manual.sl")[0]);
		mRoomViewParams.put("manual.sl", mParamInfo);
		
		mParamInfo = new HashMap<String, String>();
		mParamInfo.put(PARAM_VALUE, mParams.get("cooling.steam")[0]);
		mRoomViewParams.put("cooling.steam", mParamInfo);
		
		mParamInfo = new HashMap<String, String>();
		mParamInfo.put(PARAM_VALUE, mParams.get("comp.error")[0]);
		mRoomViewParams.put("comp.error", mParamInfo);
		
		return mRoomViewParams;
	}
	
	public TreeMap<String, Map<String, String>> getImageControllerData(Map<String, String[]> mParams, String sParamKey, String sSelPhase) throws Exception
	{
		TreeMap<String, Map<String, String>> mImageParams = new TreeMap<String, Map<String, String>>();
		
		StringList slStages = new StringList();
		if("All".equals(sSelPhase))
		{
			String sPhaseSeq = ""; 
			
			ArrayList<String[]> alControllerStages = RDMServicesUtils.getControllerStages(sCntrlType);
			for(int i=0; i<alControllerStages.size(); i++)
			{
				sPhaseSeq = alControllerStages.get(i)[0];
				if("0".equals(sPhaseSeq))
				{
					slStages.add(alControllerStages.get(i)[1]);
					slStages.add("phase" + " " + alControllerStages.get(i)[1]);
				}
				else
				{
					if(!alControllerStages.get(i)[1].equals(sPhaseSeq))
					{
						slStages.add(alControllerStages.get(i)[1] + " " + sPhaseSeq);
					}
					slStages.add("phase" + " " + sPhaseSeq);
				}
			}
		}
		else
		{
			String[] saStage = RDMServicesUtils.getControllerStage(sCntrlType, sSelPhase);
			sSelPhase = saStage[0];
			String sPhaseName = saStage[1];
			
			if("0".equals(sSelPhase))
			{
				slStages.add(sPhaseName);
				slStages.add("phase" + " " + sPhaseName);
			}
			else
			{
				if(!sPhaseName.equals(sSelPhase))
				{
					slStages.add(sPhaseName + " " + sSelPhase);
				}
				slStages.add("phase" + " " + sSelPhase);
			}
		}
		
		String sName = null;
		String[] saParamVal = null;
		StringList slParams = RDMServicesUtils.getImageDisplayParams(sParamKey, sCntrlType);
		
		for(int i=0, sz=slParams.size(); i<sz; i++)
		{
			sName = slParams.get(i);
			if(sName.startsWith("set ") || sName.startsWith("max ") || sName.startsWith("min ") 
				|| "duration".equals(sName) || "time".equals(sName))
			{
				for(int j=0; j<slStages.size(); j++)
				{
					slParams.add(sName + " " + slStages.get(j));
				}
			}
		}
		
		String sSetParam = null;
		Map<String, String> mTmp = null;
		for(int i=0; i<slParams.size(); i++)
		{
			sName = slParams.get(i);
			
			if(mParams.containsKey(sName))
			{
				saParamVal = mParams.get(sName);
				
				mTmp = new HashMap<String, String>();
				mTmp.put("value", saParamVal[0]);
				mTmp.put("unit", saParamVal[1]);
				
				if(sName.startsWith("set "))
				{
					sSetParam = sName.substring(4, sName.length());
					
					if(mParams.containsKey("min " + sSetParam))
					{
						mTmp.put("min", mParams.get("min " + sSetParam)[0]);
					}
					
					if(mParams.containsKey("max " + sSetParam))
					{
						mTmp.put("max", mParams.get("max " + sSetParam)[0]);
					}
				}
				
				mImageParams.put(sName, mTmp);
			}
		}
		
		return mImageParams;
	}
	
	public String setParameters(User u, Map<String, String[]> mParams) throws Throwable
	{
		DataQuery query = new DataQuery();
		if(!query.checkAllowedRooms())
		{
			throw new Exception("Max number of Licensed Rooms has exceeded. Please contact the admin at L-Pit for licenses to create more Rooms.");
		}

		if(!session.checkConnectionIsAlive(sController))
		{
			throw new ConnectException("Controller "+sController+" connection not available, please check with the Administrator.");
		}

		String sParam = null;
		String sValue = null;
		String sOldValue = null;
		String[] saParamVal = null;
		StringBuilder sbParams = new StringBuilder();
		Setting param = null;
		ArrayOfSettings params = new ArrayOfSettings();
		
		final Map<String, String[]> mResetParams = new HashMap<String, String[]>();
		StringList slResetParams = RDMServicesUtils.getResetParams(sCntrlType);
		
		Iterator<String> itr = mParams.keySet().iterator();
		while(itr.hasNext())
		{
			sParam = itr.next();
			saParamVal = mParams.get(sParam);
			if("On".equals(saParamVal[1]))
			{
				sValue = "1";
			}
			else if("Off".equals(saParamVal[1]))
			{
				sValue = "0";
			}
			else
			{
				sValue = saParamVal[1];
			}
			
			if(!"".equals(sValue))
			{
				try
				{
					//if(sNewValue.length() > 4)
					//{
						if(!("On".equals(sValue) || "Off".equals(sValue) || sValue.contains(":")))
						{
							sValue = numberFormat.parse(sValue).toString();
						}
					//}
				}
				catch(Exception e)
				{
					//do nothing
				}
				
				param = new Setting();
				param.setName(sParam);
				param.setValue(sValue);
				params.addSetting(param);
				
				if(slResetParams.contains(sParam) && "1".equals(sValue))
				{
					mResetParams.put(sParam, new String[] {"1", "0"});
				}
			}
		}
		
		SetSlave setSlave = new SetSlave();
		setSlave.setSettings(params);
		
		SetSlaveResponse setSlaveResp = session.getStub(sController).setSlave(setSlave, getCredentials());
		boolean setSlaveRes = setSlaveResp.getSetSlaveResult();
		
		StringList slParams = new StringList();
		itr = mParams.keySet().iterator();
		while(itr.hasNext())
		{
			sParam = itr.next();
			
			sValue = mParams.get(sParam)[1];
			if(sValue.endsWith(".0"))
			{
				sValue = sValue.substring(0, sValue.indexOf('.'));
			}
			
			sOldValue = mParams.get(sParam)[0];
			if(sOldValue.endsWith(".0"))
			{
				sOldValue = sOldValue.substring(0, sOldValue.indexOf('.'));
			}
			
			if("".equals(sValue) || sValue.equals(sOldValue))
			{
				sbParams.append("\\n - ");
				sbParams.append(sParam);
				slParams.add(sParam);
			}
		}
		
		if(setSlaveRes)
		{
			for(int i=0; i<slParams.size(); i++)
			{
				sParam = slParams.get(i);
				mParams.remove(sParam);
			}
			
			if(u != null)
			{
				query.saveLogHistory(u.getUser(), this.sController, mParams);
			}
			else
			{
				query.saveLogHistory("System", this.sController, mParams);
			}
		}

		if(!mResetParams.isEmpty())
		{
			new java.util.Timer().schedule( 
				new java.util.TimerTask() 
				{
		            public void run() 
		            {
		            	try 
		            	{
							resetParameters(mResetParams);
						}
		            	catch (Throwable e) 
						{
							// do nothing
						}
		            }
		        }, 
		        15000
			);
		}

		return sbParams.toString();
	}
	
	private void resetParameters(Map<String, String[]> mResetParams) throws Throwable
	{
		setParameters(null, mResetParams);
	}
	
	public boolean hasOpenAlarms() throws Exception 
	{
		DataQuery query = new DataQuery();
		return query.hasOpenAlarms(sController);
	}
	
	public MapList getAlarmList() throws Exception 
	{
		DataQuery query = new DataQuery();
		return query.getOpenAlarms(sController);
	}
	
	public MapList getAlarmList(int cnt, boolean bUpdate) throws Exception 
	{
		if(!session.checkConnectionIsAlive(sController))
		{
			throw new ConnectException("Controller "+sController+" connection not available, please check with the Administrator");
		}
		
		DataQuery query = null;
		ArrayList<String> alOpenAlarms = null;
		Map<String, String> mClosedAlarms = null;
		MapList mlAlarms = new MapList();

		if(bUpdate)
		{
			query = new DataQuery();
			alOpenAlarms = new ArrayList<String>();
			mClosedAlarms = new HashMap<String, String>();
			
			Map<String, String> mAlarm = null;
			MapList mlOpenAlarms = query.getOpenAlarms(sController);
			for(int i=0, iSz=mlOpenAlarms.size(); i<iSz; i++)
			{
				mAlarm = mlOpenAlarms.get(i);
				alOpenAlarms.add(mAlarm.get(SERIAL_ID));
			}
		}
		
		SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss");
		TimeZone tz = TimeZone.getDefault();
		sdf.setTimeZone(tz);
		
		Calendar cal = Calendar.getInstance(tz);
		cal.add(Calendar.DAY_OF_MONTH, 1);
		
		GetAlarmList getAlarmList = new GetAlarmList();
		getAlarmList.setStartTime(cal);
		getAlarmList.setNumber(cnt);
		
		GetAlarmListResponse getAlarmListResp = session.getStub(sController).getAlarmList(getAlarmList);
		ArrayOfAlarm arrAlarm = getAlarmListResp.getGetAlarmListResult();
		Alarm[] alarms = arrAlarm.getAlarm();
		String serialNo = "";
		String acceptedBy = "";
		String accepted = "";
		String cleared = "";
		String occured = "";
		int idx = 0;
		
		if(alarms == null)
		{
			return mlAlarms;
		}
		
		Alarm alarm = null;
		Map<String, String> mAlarm = null;
		for(int i=0; i<alarms.length; i++)
		{
			alarm = alarms[i];
			serialNo = alarm.getSerial();
			
			cal = alarm.getOccurred();
			cal.add(Calendar.HOUR_OF_DAY, -1);
			occured = sdf.format(cal.getTime());
			
			if(alarm.getCleared() != null)
			{
				cal = alarm.getCleared();
				cal.add(Calendar.HOUR_OF_DAY, -1);
				cleared = sdf.format(cal.getTime());

				if(bUpdate && alOpenAlarms.contains(serialNo))
				{
					mClosedAlarms.put(serialNo, cleared);
				}
			}
			else
			{
				cleared = "";
			}
			
			if(alarm.getAccepted() != null)
			{
				cal = alarm.getAccepted();
				cal.add(Calendar.HOUR_OF_DAY, -1);
				accepted = sdf.format(cal.getTime());
			}
			else
			{
				accepted = "";
			}
			
			mAlarm = new HashMap<String, String>();
			mAlarm.put(ACCEPTED_ON, accepted);
			mAlarm.put(ACCEPTED_BY, acceptedBy);
			mAlarm.put(CLEARED_ON, cleared);
			mAlarm.put(OCCURED_ON, occured);
			mAlarm.put(SERIAL_ID, serialNo);
			mAlarm.put(ALARM_TEXT, alarm.getText());
			
			if("".equals(cleared) && (idx <= mAlarm.size()))
			{
				mlAlarms.insertAt(idx, mAlarm);
				idx++;
			}
			else
			{
				mlAlarms.add(mAlarm);
			}
		}
		
		if(bUpdate)
		{
			query.closeOpenAlarms("SYSTEM", sController, mClosedAlarms);
		}
		
		return mlAlarms;
	}
	
	public boolean saveLogData(String sStartDate, String sEndDate) throws Exception 
	{
		if(!session.checkConnectionIsAlive(sController))
		{
			throw new ConnectException("Controller "+sController+" connection not available, please check with the Administrator");
		}
		
		DataQuery query = new DataQuery();
		
		ArrayList<Date[]> datesBetween = RDMServicesUtils.getDateRangesBetween(sStartDate, sEndDate);
		for(int i=0; i<datesBetween.size(); i++)
		{
			GetLogDataInline getLogDataInline = new GetLogDataInline();
			getLogDataInline.setResponseType(ResponseType.Csv);
			getLogDataInline.setStep(300);
			
			Calendar start = Calendar.getInstance();
			start.setTime(datesBetween.get(i)[0]);
			getLogDataInline.setStart(start);
			
			Calendar end = Calendar.getInstance();
			end.setTime(datesBetween.get(i)[1]);
			getLogDataInline.setEnd(end);
			
			GetLogDataInlineResponse getLogDataResp = session.getStub(sController).getLogDataInline(getLogDataInline);
			LogData logData = getLogDataResp.getGetLogDataInlineResult();
			String sLogData = logData.getLogData();
			
			String[] saLogData = sLogData.split("\n");
			query.saveParameters(sController, saLogData);
		}
		
		return true;
	}
	
	public ArrayList<String[]> getSysLog(Date toTime) throws Throwable 
	{
		if(!session.checkConnectionIsAlive(sController))
		{
			throw new ConnectException("Controller "+sController+" connection not available, please check with the Administrator");
		}
		
		ArrayList<String[]> alEvent = new ArrayList<String[]>();
		
		GetSyslog getSysLog = new GetSyslog();
		if(toTime != null)
		{
			getSysLog.setNumber(100);
		}
		else
		{
			getSysLog.setNumber(1000);
		}
		
		GetSyslogResponse getSyslogResp = session.getStub(sController).getSyslog(getSysLog, getCredentials());
		ArrayOfEvent arrOfEvent = getSyslogResp.getGetSyslogResult();
		Event[] arrEvent = arrOfEvent.getEvent();
		
		SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss");
		TimeZone tz = TimeZone.getDefault();
		sdf.setTimeZone(tz);
		Calendar cal = Calendar.getInstance(tz);
		
		String[] saLog = null;
		Event event = null;
		
		if(arrEvent == null)
		{
			return alEvent;
		}
		
		for(int i=0; i<arrEvent.length; i++)
		{
			event = arrEvent[i];
			cal = event.getTime();
			cal.add(Calendar.HOUR_OF_DAY, -1);
			
			saLog = new String[2];
			saLog[0] = sdf.format(cal.getTime());
			saLog[1] = event.getText();
			alEvent.add(saLog);
		}
		
		return alEvent;
	}
	
	private UserCredentialsE getCredentials() throws Throwable
	{
		Map<String, String> mAcctCredentails = RDMServicesUtils.getAccountCredentials();
		String sCntrlUID = mAcctCredentails.get(CNTRL_UID);
		String sCntrlPwd = mAcctCredentails.get(CNTRL_PWD);
		
		UserCredentials userCredentials = new UserCredentials();
		userCredentials.setUserName(sCntrlUID);
		userCredentials.setPassword(sCntrlPwd);
		
		UserCredentialsE userCredentialsE = new UserCredentialsE();
		userCredentialsE.setUserCredentials(userCredentials);
		
		return userCredentialsE;
	}
	
	private boolean isParamsSetOn(StringList slParams, Map<String, String[]> mParams) throws Exception
	{
		String sSfx = null;
		String sSfx1 = null;
		String sParam = null;
		String[] saParam = null;
		
		if(mParams.containsKey("current phase"))
		{
			String sCurrPhase = (mParams.get("current phase")[0]).trim();
			sCurrPhase = ((sCurrPhase.endsWith(".0")) ? sCurrPhase.substring(0, sCurrPhase.indexOf(".")) : sCurrPhase);
			sCurrPhase = sCurrPhase.replace('.', ' ');

			String[] saStage = RDMServicesUtils.getControllerStage(sCntrlType, sCurrPhase);
			sCurrPhase = saStage[0];
			String stageName = saStage[1];
			
			if("0".equals(sCurrPhase))
			{
				sSfx = " " + stageName;
				sSfx1 = " " + "phase" + " " + stageName;
			}
			else
			{
				if(!sCurrPhase.equals(stageName))
				{
					sSfx = " " + stageName + " " + sCurrPhase;
				}
				sSfx1 = " " + "phase" + " " + sCurrPhase;
			}
		}
		
		for(int i=0; i<slParams.size(); i++)
		{
			saParam = null;
			sParam = slParams.get(i);
			
			if(mParams.containsKey(sParam + sSfx))
			{
				saParam = mParams.get(sParam + sSfx);
			}
			else if(mParams.containsKey(sParam + sSfx1))
			{
				saParam = mParams.get(sParam + sSfx1);
			}
			else
			{
				saParam = mParams.get(sParam);
			}
			
			if(saParam != null)
			{
				if(!("On".equals(saParam[0]) || "Off".equals(saParam[0])))
				{
					saParam[0] = numberFormat.parse(saParam[0]).toString();
				}

				if("On".equals(saParam[0]) || "1".equals(saParam[0]))
				{
					return true;
				}
			}
		}
		return false;
	}
	
	private boolean isCompError(Map<String, String[]> mParams) throws ParseException
	{
		String[] saError = null;
		
		for(int i=0; i<slCompErrorParams.size(); i++)
		{
			saError = mParams.get(slCompErrorParams.get(i));
			if(saError != null)
			{
				if(!("On".equals(saError[0]) || "Off".equals(saError[0])))
				{
					saError[0] = numberFormat.parse(saError[0]).toString();
				}

				if("Off".equals(saError[0]) || "0".equals(saError[0]))
				{
					return true;
				}
			}
		}
		return false;
	}

	private void getSetParamValues(Map<String, String[]> mParams) throws Exception
	{
		String sSfx  = null;
		String sSfx1 = null;
		
		if(mParams.containsKey("current phase"))
		{
			String sCurrPhase = (mParams.get("current phase")[0]).trim();
			sCurrPhase = ((sCurrPhase.endsWith(".0")) ? sCurrPhase.substring(0, sCurrPhase.indexOf(".")) : sCurrPhase);
			sCurrPhase = sCurrPhase.replace('.', ' ');

			String[] saStage = RDMServicesUtils.getControllerStage(sCntrlType, sCurrPhase);
			sCurrPhase = saStage[0];
			String stageName = saStage[1];
			
			if("0".equals(sCurrPhase))
			{
				sSfx = " " + stageName;
				sSfx1 = " " + "phase" + " " + stageName;
			}
			else
			{
				if(!sCurrPhase.equals(stageName))
				{
					sSfx = " " + stageName + " " + sCurrPhase;
				}
				sSfx1 = " " + "phase" + " " + sCurrPhase;
			}
		}

		String sParam = null;
		String[] saParamVal = null;
		Iterator<String> itr = SET_PARAMS.keySet().iterator();
		while(itr.hasNext())
		{
			saParamVal = null;
			sParam = itr.next();
			
			if(mParams.containsKey(sParam + sSfx))
			{
				saParamVal = mParams.get(sParam + sSfx);
			}
			else if(mParams.containsKey(sParam + sSfx1))
			{
				saParamVal = mParams.get(sParam + sSfx1);
			}
			
			if(saParamVal != null)
			{
				mParams.put(sParam, saParamVal);
			}
		}
	}
	
	public Map<String, String> getPhaseStartTime(Map<String, String[]> mCntrlData) throws Exception
	{
		double dTime = 0d;
		String sParam = "";
		String sValue = "";
		Map<String, String> mPhaseStartTime = new HashMap<String, String>();
		
		double dPhaseSeq = 0.0;
		double dCurrPhase = 0.0;
		Calendar cal = Calendar.getInstance(); 
		SimpleDateFormat sdf = new SimpleDateFormat("dd-MMM-yyyy HH:mm", Locale.getDefault());
		
		if(mCntrlData.containsKey("current phase"))
		{
			dCurrPhase = Double.parseDouble(mCntrlData.get("current phase")[0]);
		}
		
		if(mCntrlData.containsKey("Last Refresh"))
		{
			Date date = sdf.parse(mCntrlData.get("Last Refresh")[0]); 
			cal.setTime(date);
		}
		
		int iMin = cal.get(Calendar.MINUTE);
		iMin = iMin - ((iMin / 6) * 6);
		cal.add(Calendar.SECOND, -(cal.get(Calendar.SECOND)));
		cal.add(Calendar.MINUTE, -(iMin));
		
		ArrayList<String[]> alCntrlStgs = getControllerStages();
		for(int i=alCntrlStgs.size()-1; i>=0; i--)
		{
			dPhaseSeq = Double.parseDouble((alCntrlStgs.get(i)[0]).replaceAll("\\s", "."));
			if(dPhaseSeq <= dCurrPhase)
			{
				sValue = "";
				sParam = "time " + alCntrlStgs.get(i)[1] + " " + alCntrlStgs.get(i)[0];
				if(mCntrlData.containsKey(sParam))
				{
					sValue = mCntrlData.get(sParam)[0];
				}
				else
				{
					sParam = "time phase " + alCntrlStgs.get(i)[0];
					if(mCntrlData.containsKey(sParam))
					{
						sValue = mCntrlData.get(sParam)[0];
					}
				}
				
				if(sValue == null || "".equals(sValue) || "0".equals(sValue) || "0.0".equals(sValue))
				{
					sParam = "duration " + alCntrlStgs.get(i)[1] + " " + alCntrlStgs.get(i)[0];
					if(mCntrlData.containsKey(sParam))
					{
						sValue = mCntrlData.get(sParam)[0];
					}
					else
					{
						sParam = "duration phase " + alCntrlStgs.get(i)[0];
						if(mCntrlData.containsKey(sParam))
						{
							sValue = mCntrlData.get(sParam)[0];
						}
					}
				}
				
				if(sValue != null && !"".equals(sValue) && !("0".equals(sValue) || "0.0".equals(sValue)))
				{
					try
					{
						dTime = Double.parseDouble(sValue);
						cal.add(Calendar.HOUR, getHours(dTime));
						cal.add(Calendar.MINUTE, getMinutes(dTime));
						mPhaseStartTime.put(alCntrlStgs.get(i)[0], sdf.format(cal.getTime()));
					}
					catch(NumberFormatException e)
					{
						//do nothing
					}
				}
			}
		}
		
		return mPhaseStartTime;
	}
	
	public static int getPhaseRunningDay(String sController) throws Exception
	{
		int iNoDays = 0;
		
		DataQuery query = new DataQuery();
		Map<String, String[]> mCntrlData = query.getControllerParameters(sController);
		
		if(mCntrlData.containsKey("current phase"))
		{
			String sValue = "";
			
			Calendar cal = Calendar.getInstance(); 
			SimpleDateFormat sdf = new SimpleDateFormat("dd-MMM-yyyy HH:mm", Locale.getDefault());
			
			String cntrlType = RDMServicesUtils.getControllerType(sController);

			String sPhaseSeq = mCntrlData.get("current phase")[0];
			sPhaseSeq = ((sPhaseSeq.endsWith(".0")) ? sPhaseSeq.substring(0, sPhaseSeq.indexOf(".")) : sPhaseSeq);
			sPhaseSeq = sPhaseSeq.replace('.', ' ');
			
			String sPhase = RDMServicesUtils.getStageName(cntrlType, sPhaseSeq);
			
			if(mCntrlData.containsKey("Last Refresh"))
			{
				Date date = sdf.parse(mCntrlData.get("Last Refresh")[0]); 
				cal.setTime(date);
			}
			
			int iMin = cal.get(Calendar.MINUTE);
			iMin = iMin - ((iMin / 6) * 6);
			cal.add(Calendar.SECOND, -(cal.get(Calendar.SECOND)));
			cal.add(Calendar.MINUTE, -(iMin));
			
			String sParam = "time " + sPhase + " " + sPhaseSeq;
			if(mCntrlData.containsKey(sParam))
			{
				sValue = mCntrlData.get(sParam)[0];
			}
			else
			{
				sParam = "time phase " + sPhaseSeq;
				if(mCntrlData.containsKey(sParam))
				{
					sValue = mCntrlData.get(sParam)[0];
				}
			}
			
			if(sValue == null || "".equals(sValue) || "0".equals(sValue) || "0.0".equals(sValue))
			{
				sParam = "duration " + sPhase + " " + sPhaseSeq;
				if(mCntrlData.containsKey(sParam))
				{
					sValue = mCntrlData.get(sParam)[0];
				}
				else
				{
					sParam = "duration phase " + sPhaseSeq;
					if(mCntrlData.containsKey(sParam))
					{
						sValue = mCntrlData.get(sParam)[0];
					}
				}
			}
			
			if(sValue != null && !"".equals(sValue) && !("0".equals(sValue) || "0.0".equals(sValue)))
			{
				try
				{
					double dTime = Double.parseDouble(sValue);
					iNoDays = (int)Math.ceil(Math.abs(dTime) / 24);
				}
				catch(NumberFormatException e)
				{
					//do nothing
				}
			}
		}
		
		return iNoDays;
	}
	
	private int getHours(double d)
	{
	    double dAbs = Math.abs(d);
	    int i = (int) dAbs;
	    return -i;
	}
	
	private int getMinutes(double d)
	{
		DecimalFormat oneDigit = new DecimalFormat("#,##0.0");
		double dAbs = Math.abs(d);
		String sAbs = oneDigit.format(d - (int)dAbs);
		sAbs = sAbs.replaceAll(",", ".");
		int i = (int)(Double.parseDouble(sAbs) * 60.0);
		return -i;
	}
	
	public String getBatchNo() throws Exception
	{
		DataQuery qry = new DataQuery();
		return qry.getBatchNo(this.sController, false);
	}
	
	public String getBatchDefType() throws Exception
	{
		DataQuery qry = new DataQuery();
		return qry.getBatchDefType(this.sController, null);
	}
	
	public String getControllerType()
	{
		return sCntrlType;
	}
	
	public void addBatchNo(String sBNo, String sDefType) throws Exception
	{
		DataQuery qry = new DataQuery();
		qry.addBatchNo(this.sController, sBNo, sDefType);
	}
    
    public void updateBatchNo(String sBNo, String sDefType) throws Exception
	{
    	DataQuery qry = new DataQuery();
    	qry.updateBatchNo(this.sController, sBNo, sDefType);
	}
    
    public void updateDefaultProduct(String sBNo, String sDefType) throws Exception
	{
    	DataQuery qry = new DataQuery();
    	qry.updateDefaultProduct(this.sController, sBNo, sDefType);
	}
    
}
