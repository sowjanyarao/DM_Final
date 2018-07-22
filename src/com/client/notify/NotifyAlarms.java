package com.client.notify;

import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;

import com.client.db.DataQuery;
import com.client.rules.RuleEngine;
import com.client.util.LabelResourceBundle;
import com.client.util.MapList;
import com.client.util.RDMServicesConstants;
import com.client.util.RDMServicesUtils;
import com.client.util.StringList;

import com.twilio.sdk.TwilioRestClient;
import com.twilio.sdk.resource.factory.CallFactory;
import com.twilio.sdk.resource.factory.MessageFactory;
import com.twilio.sdk.resource.instance.Call;
import com.twilio.sdk.resource.instance.Message;

public class NotifyAlarms extends RDMServicesConstants
{
	private static SimpleDateFormat format = new SimpleDateFormat("yyyy/MM/dd HH:mm", Locale.getDefault());
    private static Map<String, MapList> NOTIFY_ALARMS = null;
    private static LabelResourceBundle resourceBundle = new LabelResourceBundle(Locale.getDefault());
    
    public NotifyAlarms()
	{
    	
	}
    
    public StringList listAlarms(String sController) throws Exception
	{
		StringList slAlarms = new StringList();
    	
    	DataQuery query = new DataQuery();
		ArrayList<String[]> alAlarms = query.getNotificationAlarms();
		
		RuleEngine engine = new RuleEngine();
		MapList mlRules = engine.getUserRules();
		
		Map<String, String> mRule = null;
		for(int i=0; i<mlRules.size(); i++)
		{
			mRule = mlRules.get(i);
			alAlarms.add(new String[] {mRule.get(RULE_DESCRIPTION), mRule.get(CNTRL_TYPE)});
		}
		
		String[] saAlarm = null;
		Map<String, Map<String, String>> mAlarms = getNotificationAlarms();
		
		for(int i=0, iSz=alAlarms.size(); i<iSz; i++)
		{
			saAlarm = alAlarms.get(i);
			if(sController.equals(saAlarm[1]) && !mAlarms.containsKey(saAlarm[1] + "." + saAlarm[0]))
			{
				slAlarms.add(saAlarm[0]);
			}
		}
		
		return slAlarms;
	}
    
    public Map<String, MapList> listNotificationAlarms() throws Exception
	{
    	if(NOTIFY_ALARMS == null)
    	{
			DataQuery query = new DataQuery();
			NOTIFY_ALARMS = query.listNotificationAlarms();
		}
    	return NOTIFY_ALARMS;
	}
    
    public Map<String, Map<String, String>> listNotificationAlarms(String sController) throws Exception
	{
    	listNotificationAlarms();
    	
		Map<String, String> mAlarm = null;
		Map<String, Map<String, String>> mAlarms = new HashMap<String, Map<String, String>>();
		
		MapList mlAlarms = NOTIFY_ALARMS.get(sController);
		if(mlAlarms != null)
		{
			for(int i=0, iSz=mlAlarms.size(); i<iSz; i++)
			{
				mAlarm = mlAlarms.get(i);
				mAlarms.put(mAlarm.get(ALARM), mAlarm);
			}
		}
    	return mAlarms;
	}
    
    private Map<String, Map<String, String>> getNotificationAlarms() throws Exception
	{
    	listNotificationAlarms();
    	
    	String sController = null;
    	MapList mlAlarms = null;
		Map<String, String> mAlarm = null;
		Map<String, Map<String, String>> mAlarms = new HashMap<String, Map<String, String>>();
		
		Iterator<String> itr = NOTIFY_ALARMS.keySet().iterator();
		while(itr.hasNext())
		{
			sController = itr.next();
			mlAlarms = NOTIFY_ALARMS.get(sController);
			for(int i=0, iSz=mlAlarms.size(); i<iSz; i++)
			{
				mAlarm = mlAlarms.get(i);
				mAlarms.put((sController + "." + mAlarm.get(ALARM)), mAlarm);
			}
		}
    	return mAlarms;
	}
    
    public void addNotificationAlarm(String sAlarm, String sCntrlType, String sNotifyBy, String sNotifyFirst, int firstDuration, 
    	String sNotifySecond, int secondDuration, String sNotifyThird, int thirdDuration, int notifyDuration) throws Exception
	{
		DataQuery query = new DataQuery();
		query.addNotificationAlarm(sAlarm, sCntrlType, sNotifyBy, sNotifyFirst, firstDuration, 
				sNotifySecond, secondDuration, sNotifyThird, thirdDuration, notifyDuration);
		NOTIFY_ALARMS = query.listNotificationAlarms();
	}
    
    public void updateNotificationAlarm(String sAlarm, String sCntrlType, String sNotifyBy, String sNotifyFirst, int firstDuration, 
        String sNotifySecond, int secondDuration, String sNotifyThird, int thirdDuration, int notifyDuration) throws Exception
	{
		DataQuery query = new DataQuery();
		query.updateNotificationAlarm(sAlarm, sCntrlType, sNotifyBy, sNotifyFirst, firstDuration, 
				sNotifySecond, secondDuration, sNotifyThird, thirdDuration, notifyDuration);
		NOTIFY_ALARMS = query.listNotificationAlarms();
	}
    
    public void deleteNotificationAlarm(String sAlarm, String sCntrlType) throws Exception
	{
		DataQuery query = new DataQuery();
		query.deleteNotificationAlarm(sAlarm, sCntrlType);
		NOTIFY_ALARMS = query.listNotificationAlarms();
	}
    
	public void notifyUsers(Date timeStamp) throws Exception
    {
    	HashSet<String> hsCallUsers = new HashSet<String>();
		Map<String, MapList> mSMSUsers = new HashMap<String, MapList>();
		MapList mlAlarms = null;
		
		Map<String, Map<String, String>> mNotificationAlarms = getNotificationAlarms();
		
		DataQuery query = new DataQuery();
		MapList mlNotifyAlarms = query.getNotifyAlarms();
		
		int level1;
		int level2;
		int level3;
		int firstNotify;
		int secondNotify;
		int thirdNotify;
		int notifyDuration;
		long timeDiff;
		String sAlarm = null;
		String sCntrlAlarm = null;
		String sNotifyBy = null;
		String sNotifyUser = null;
		String sLastNotified = null;
		Map<String, String> mAlarm = null;
		Map<String, String> mNotify = null;
		MapList mlUpdateAlarms = new MapList();
		
		Map<String, String> mAcctCredentials = RDMServicesUtils.getAccountCredentials();
		String ACCOUNT_SID = mAcctCredentials.get(ACCT_SID);
		String AUTH_TOKEN = mAcctCredentials.get(AUTH_CODE);
		String REG_NUM = mAcctCredentials.get(REG_NUMBER);

		TwilioRestClient client = new TwilioRestClient(ACCOUNT_SID, AUTH_TOKEN);
		
		for(int i=0; i<mlNotifyAlarms.size(); i++)
		{
			mAlarm = mlNotifyAlarms.get(i);
			sAlarm = mAlarm.get(ALARM_TEXT);
			level1 = Integer.parseInt(mAlarm.get(LEVEL1_ATTEMPTS));
			level2 = Integer.parseInt(mAlarm.get(LEVEL2_ATTEMPTS));
			level3 = Integer.parseInt(mAlarm.get(LEVEL3_ATTEMPTS));
			
			timeDiff = 0;
			sLastNotified = mAlarm.get(LAST_NOTIFIED);
			
			if(sLastNotified != null && !"".equals(sLastNotified))
			{
				timeDiff = (timeStamp.getTime() - format.parse(sLastNotified).getTime()) / (60 * 1000);
			}
			else
			{
				timeDiff = 120;
			}
			
			sCntrlAlarm = RDMServicesUtils.getControllerType(mAlarm.get(ROOM_ID)) + "." + sAlarm;
			if(mNotificationAlarms.containsKey(sCntrlAlarm))
			{
				mNotify = mNotificationAlarms.get(sCntrlAlarm);
				sNotifyBy = mNotify.get(NOTIFY_BY);
				firstNotify = Integer.parseInt(mNotify.get(LEVEL1_ATTEMPTS));
				secondNotify = Integer.parseInt(mNotify.get(LEVEL2_ATTEMPTS));
				thirdNotify = Integer.parseInt(mNotify.get(LEVEL3_ATTEMPTS));
				notifyDuration = Integer.parseInt(mNotify.get(NOTIFY_DURATION));
				
				if(timeDiff < notifyDuration)
				{
					continue;
				}
				else if(level1 < firstNotify)
				{
					sNotifyUser = mNotify.get(NOTIFY_LEVEL1);

					level1++;
					mAlarm.put(LEVEL1_ATTEMPTS, Integer.toString(level1));
					mAlarm.put(LEVEL2_ATTEMPTS, Integer.toString(0));
					mAlarm.put(LEVEL3_ATTEMPTS, Integer.toString(0));
				}
				else if(level2 < secondNotify)
				{
					sNotifyUser = mNotify.get(NOTIFY_LEVEL2);
					
					level2++;
					mAlarm.put(LEVEL1_ATTEMPTS, Integer.toString(level1));
					mAlarm.put(LEVEL2_ATTEMPTS, Integer.toString(level2));
					mAlarm.put(LEVEL3_ATTEMPTS, Integer.toString(0));
				}
				else if(level3 < thirdNotify)
				{
					sNotifyUser = mNotify.get(NOTIFY_LEVEL3);
					
					level3++;
					mAlarm.put(LEVEL1_ATTEMPTS, Integer.toString(level1));
					mAlarm.put(LEVEL2_ATTEMPTS, Integer.toString(level2));
					mAlarm.put(LEVEL3_ATTEMPTS, Integer.toString(level3));
				}
				else
				{
					continue;
				}
				
				mlUpdateAlarms.add(mAlarm);
				
				if(NOTIFY_CALL.equalsIgnoreCase(sNotifyBy))
				{
					hsCallUsers.add(sNotifyUser);
				}
				
				if((level1 == 1) || (level2 == 1) || (level3 == 1))
				{
					mlAlarms = ((mSMSUsers.containsKey(sNotifyUser)) ? mSMSUsers.get(sNotifyUser) : new MapList());
					mlAlarms.add(mAlarm);
					mSMSUsers.put(sNotifyUser, mlAlarms);
				}
			}
		}

		java.sql.Timestamp sqlTime = new java.sql.Timestamp(timeStamp.getTime());
		query.updateNotifyAlarms(mlUpdateAlarms, sqlTime);
		
		Map<String, String> mUser = null;
		Map<String, String> mUsers = new HashMap<String, String>();
		MapList mlUsers = RDMServicesUtils.getUserList();
		for(int i=0; i<mlUsers.size(); i++)
		{
			mUser = mlUsers.get(i);
			mUsers.put(mUser.get(USER_ID), mUser.get(CONTACT_NO));
		}
		
		Locale locale = Locale.getDefault();
		String language = locale.getLanguage() + "-" + locale.getCountry();
		
	    String sCallMessage = "<Response><Say language=\""+language+"\">"+resourceBundle.getProperty("DataManager.DisplayText.Call_Message")+"</Say></Response>";
	    sCallMessage = URLEncoder.encode(sCallMessage, "UTF-8").replaceAll("\\+", "%20");
		String sUrl = "http://twimlets.com/echo?Twiml=" + sCallMessage;
		
		String sContact = null;
		Iterator<String> itrUsers = hsCallUsers.iterator();
		while(itrUsers.hasNext())
		{
			try
			{
				sNotifyUser = itrUsers.next();
    			sContact = mUsers.get(sNotifyUser);
    			
    			if(sContact != null && !"".equals(sContact))
    			{
				    List<NameValuePair> params = new ArrayList<NameValuePair>();
				    params.add(new BasicNameValuePair("Url", sUrl));
				    params.add(new BasicNameValuePair("To", "+" + sContact));
				    params.add(new BasicNameValuePair("From", "+" + REG_NUM));
				    
				    System.out.println("calling "+sNotifyUser+" - "+sContact);
				    CallFactory callFactory = client.getAccount().getCallFactory();
				    Call call = callFactory.create(params);
				    System.out.println("Call Status : "+call.getStatus());
    			}
			}
			catch(Exception e)
			{
				System.out.println("Err while making call to user "+sNotifyUser+" : "+e.getMessage());
			}
		}
		
		String sMessage = null;
		itrUsers = mSMSUsers.keySet().iterator();
		while(itrUsers.hasNext())
		{
			try
			{
				sMessage = "";
				sNotifyUser = itrUsers.next();
    			sContact = mUsers.get(sNotifyUser);
    			
    			if(sContact != null && !"".equals(sContact))
    			{
    				mlAlarms = mSMSUsers.get(sNotifyUser);
	    			for(int i=0; i<mlAlarms.size(); i++)
	        		{
	    				mAlarm = mlAlarms.get(i);
	    				if(i > 0)
	    				{
	    					sMessage += "\n";
	    				}
	    				
	    				sMessage += resourceBundle.getProperty("DataManager.DisplayText."+RDMServicesUtils.getControllerType(mAlarm.get(ROOM_ID))) +
	    					" - "+mAlarm.get(ROOM_ID)+" - "+mAlarm.get(OCCURED_ON)+" - "+mAlarm.get(ALARM_TEXT);
	        		}
	    			
	    			if(sMessage != null && !"".equals(sMessage))
	    			{
	    				List<NameValuePair> params = new ArrayList<NameValuePair>();
	    				params.add(new BasicNameValuePair("Url", "https://demo.twilio.com/welcome/sms/reply/"));
	    		        params.add(new BasicNameValuePair("Body", sMessage));
	    		        params.add(new BasicNameValuePair("To", "+" + sContact));
	    		        params.add(new BasicNameValuePair("From", "+" + REG_NUM));
	    		        
	    		        System.out.println("sending SMS to "+sNotifyUser+" - "+sContact);
	    		        MessageFactory messageFactory = client.getAccount().getMessageFactory();
	    		        Message message = messageFactory.create(params);
	    				//System.out.println("SMS Status : "+message.getErrorCode()+" - "+message.getErrorMessage());
	    			}
    			}
    		}
			catch(Exception e)
			{
				System.out.println("Err while sending SMS to user "+sNotifyUser+" : "+e.getMessage());
			}
		}
	}
}
