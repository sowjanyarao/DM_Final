package com.client.rules;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.ScriptException;

import com.client.db.DataQuery;
import com.client.util.MapList;
import com.client.util.RDMServicesConstants;
import com.client.util.RDMServicesUtils;
import com.client.util.StringList;

public class RuleEngine extends RDMServicesConstants
{
	private static final ScriptEngineManager manager = new ScriptEngineManager();
	private static final ScriptEngine engine = manager.getEngineByName("js");
	private static Map<String, MapList> USER_RULES = new HashMap<String, MapList>();
	private static Map<String, StringList> RULE_PARAMS = new HashMap<String, StringList>();
	private static Map<String, Integer> RULE_CHECK = new HashMap<String, Integer>();
	private final SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy HH:mm", Locale.getDefault());
	private final DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd hh:mm", Locale.getDefault());
	
	public RuleEngine()
	{
	}
	
	public void evaluateUserRules(String sController, Set<String> keys) throws Exception
	{
		String sCntrlType = RDMServicesUtils.getControllerType(sController);
		MapList mlRules = getUserRules(sCntrlType);
		if(mlRules.isEmpty())
		{
			return;			
		}
		
		StringList slParams = RULE_PARAMS.get(sCntrlType);
		int iRuleCheck = (RULE_CHECK.get(sCntrlType)).intValue();
		
		DataQuery query = new DataQuery();
		MapList mlParamData = query.getControllerData(sController, slParams, keys, iRuleCheck);
		ArrayList<String> alOpenAlarms = getOpenAlarms(sController);
		
		int iExec = 0;
		String sRule = null;
		String sRuleId = null;
		String sRuleDesc = null;
		String sOccured = null;
		String sCleared = null;
		Map<String, String> mRule = null;
		Map<String, String> mParams = null;
		Map<String, String> mAlarm = null;
		Map<String, String> mClosedAlarms = new HashMap<String, String>();
		MapList mlAlarms = new MapList();
		
		for(int i=0; i<mlRules.size(); i++)
		{
			try
			{
				mRule = mlRules.get(i);
				sRule = mRule.get(RULE_EXPRESSION);
				sRuleId = mRule.get(RULE_OID);
				sRuleDesc = mRule.get(RULE_DESCRIPTION);
				iExec = (Integer.parseInt(mRule.get(RULE_EXECUTE)) / 5) + 1;
				
				int iChk = 0;
				sOccured = "";
				for(int j=0; j<iExec; j++)
				{
					mParams = mlParamData.get(j);
					if(evaluateRule(sRule, mParams))
					{
						iChk++;
						sOccured = mParams.get("timestamp");
					}
					else
					{
						sCleared = mParams.get("timestamp");
					}
				}
				
				if(iChk == iExec)
				{
					if(!alOpenAlarms.contains(sRuleId))
					{
						mAlarm = new HashMap<String, String>();
						mAlarm.put(ACCEPTED_ON, "");
						mAlarm.put(ACCEPTED_BY, "");
						mAlarm.put(CLEARED_ON, "");
						mAlarm.put(OCCURED_ON, sdf.format((Date)formatter.parse(sOccured)));
						mAlarm.put(SERIAL_ID, sRuleId);
						mAlarm.put(ALARM_TEXT, sRuleDesc);
						
						mlAlarms.add(mAlarm);
					}
				}
				else
				{
					if(alOpenAlarms.contains(sRuleId))
					{
						mClosedAlarms.put(sRuleId, sdf.format((Date)formatter.parse(sCleared)));
					}
				}
			}
			catch(Exception e)
			{
				System.out.println(sController + "[evaluateUserRules] : "+e.getLocalizedMessage());
			}
		}

		if(mlAlarms.size() > 0)
		{
			query.saveAlarmLogs(sController, mlAlarms);
		}
		
		if(!mClosedAlarms.isEmpty())
		{
			query.closeOpenAlarms("SYSTEM", sController, mClosedAlarms);
		}
	}
	
	private boolean evaluateRule(String sRule, Map<String, String> mParams)
	{
		try
		{
			int idx1 = 0;
			int idx2 = 0;
			String sParam = null;
	
			while(sRule.contains("'"))
			{
				idx1 = sRule.indexOf("'") + 1;
				idx2 = sRule.indexOf("'", idx1);
	
				sParam = sRule.substring(idx1, idx2).trim();
				if(mParams.containsKey(sParam))
				{
					sRule = sRule.replaceAll(("'"+sParam+"'"), mParams.get(sParam));
				}
				else
				{
					sRule = sRule.replaceAll(("'"+sParam+"'"), sParam);
				}
			}
			sRule = sRule.toLowerCase().replaceAll("on", "1").replaceAll("off", "0");

			return evaluateRule(sRule);
		}
		catch(Exception e)
		{
			System.out.println("Err while eval Rule : "+sRule);
			return false;
		}
	}
	
	public Map<String, String> evaluateUserRules(String sController, Map<String, String[]> mParams) throws Exception
	{
		int idx1 = 0;
		int idx2 = 0;
		String sParam = null;
		String sRule = null;
		String sRuleId = null;
		Map<String, String> mRule = null;
		Map<String, String> mRules = new HashMap<String, String>();
		String sCntrlType = RDMServicesUtils.getControllerType(sController);
		
		MapList mlRules = getUserRules(sCntrlType);
		for(int i=0; i<mlRules.size(); i++)
		{
			try
			{
				mRule = mlRules.get(i);
				sRule = mRule.get(RULE_EXPRESSION);
				sRuleId = mRule.get(RULE_OID);
				
				while(sRule.contains("'"))
				{
					idx1 = sRule.indexOf("'") + 1;
					idx2 = sRule.indexOf("'", idx1);
	
					sParam = sRule.substring(idx1, idx2).trim();
					if(mParams.containsKey(sParam))
					{
						sRule = sRule.replaceAll(("'"+sParam+"'"), mParams.get(sParam)[0]);
					}
					else
					{
						sRule = sRule.replaceAll(("'"+sParam+"'"), sParam);
					}
				}
				sRule = sRule.toLowerCase().replaceAll("on", "1").replaceAll("off", "0");

				mRules.put(sRuleId, (evaluateRule(sRule) ? "TRUE" : "FALSE"));
			}
			catch(Exception e)
			{
				System.out.println("Err while eval Rule : "+sRule);
				mRules.put(sRuleId, "FALSE");
			}
		}
		
		return mRules;
	}
	
	private boolean evaluateRule(String sRule) throws ScriptException
	{
		boolean bStartsWith = false;
		boolean bEndsWith = false;
		boolean bContains = false;
		int idx1 = 0;
		int idx2 = 0;
		String leftExpr = null;
		String rightExpr = null;
		String sOperand = null;
		String sRuleExpr1 = "";
		String sRuleExpr2 = null;
		String sRuleExpr3 = null;
		String[] saRuleExpr_OR = null;
		
		String[] saRuleExpr_AND = sRule.split("\\&\\&");
		for(int j=0; j<saRuleExpr_AND.length; j++)
		{
			sRuleExpr2 = "";
			saRuleExpr_OR = saRuleExpr_AND[j].trim().split("\\|\\|");
			for(int k=0; k<saRuleExpr_OR.length; k++)
			{
				idx1 = 0; idx2 = 0;
				sRuleExpr3 = saRuleExpr_OR[k].trim();
				
				bStartsWith = sRuleExpr3.startsWith("(");
				bEndsWith = sRuleExpr3.endsWith(")");
				bContains = sRuleExpr3.contains(")");
				
				if((idx1 = sRuleExpr3.indexOf("==")) > 0)
				{
					idx2 = idx1 + 2;
					sOperand = " == ";
				}
				else if((idx1 = sRuleExpr3.indexOf("!=")) > 0)
				{
					idx2 = idx1 + 2;
					sOperand = " != ";
				}
				else if((idx1 = sRuleExpr3.indexOf(">=")) > 0)
				{
					idx2 = idx1 + 2;
					sOperand = " >= ";
				}
				else if((idx1 = sRuleExpr3.indexOf("<=")) > 0)
				{
					idx2 = idx1 + 2;
					sOperand = " <= ";
				}
				else if((idx1 = sRuleExpr3.indexOf(">")) > 0)
				{
					idx2 = idx1 + 1;
					sOperand = " > ";
				}
				else if((idx1 = sRuleExpr3.indexOf("<")) > 0)
				{
					idx2 = idx1 + 1;
					sOperand = " < ";
				}
				
				if((bStartsWith && !bEndsWith && !bContains) || (bStartsWith && bEndsWith))
				{
					sRuleExpr3 = sRuleExpr3.substring(1, sRuleExpr3.length());
					idx1--;
				}
				if(bEndsWith)
				{
					sRuleExpr3 = sRuleExpr3.substring(0, (sRuleExpr3.length()-1));
				}
				
				leftExpr = sRuleExpr3.substring(0, idx1).trim();
				rightExpr = sRuleExpr3.substring(idx2).trim();

				//sRuleExpr3 = "(Math.round("+leftExpr+" * 10) / 10)" + sOperand + "(Math.round("+rightExpr+" * 10) / 10)";
				sRuleExpr3 = "Math.round("+leftExpr+")" + sOperand + "Math.round("+rightExpr+")";
				
				if((bStartsWith && !bEndsWith && !bContains) || (bStartsWith && bEndsWith))
				{
					sRuleExpr3 = "(" + sRuleExpr3;
				}
				if(bEndsWith)
				{
					sRuleExpr3 = sRuleExpr3 + ")";
				}
				
				if(k > 0)
				{
					sRuleExpr2 += " || ";
				}
				sRuleExpr2 += sRuleExpr3;
			}
			
			if(j > 0)
			{
				sRuleExpr1 += " && ";
			}
			sRuleExpr1 += sRuleExpr2;
		}
		
		Object result = engine.eval(sRuleExpr1);
		if(result == null)
		{
			return false;
		}
		return "true".equalsIgnoreCase(result.toString());
	}
	
	public MapList getUserRules() throws Exception
	{
		MapList mlRules = new MapList();
		Iterator<String> itrRules = USER_RULES.keySet().iterator();
		while(itrRules.hasNext())
		{
			mlRules.addAll(getUserRules(itrRules.next()));
		}
		
    	return mlRules;
	}
	
	public MapList getUserRules(String sCntrlType) throws Exception
	{
		MapList mlRules = USER_RULES.get(sCntrlType);
		if(mlRules == null || mlRules.isEmpty())
		{
			updateRuleParams(sCntrlType);
			mlRules = USER_RULES.get(sCntrlType);
		}
		
    	return mlRules;
	}
	
	public Map<String, String> getUserRule(String oid, String sCntrlType) throws Exception
	{
		String sRuleId = null;
		Map<String, String> mRule = null;
		MapList mlRules = getUserRules(sCntrlType);
		
		for(int i=0; i<mlRules.size(); i++)
		{
			mRule = mlRules.get(i);
			sRuleId = mRule.get(RULE_OID);

			if(oid.equals(sRuleId))
			{
				return mRule;
			}
		}
		
		return null;
	}
	
	public void addUserRule(String sRule, String sExec, String sRuleDesc, String sCntrlType) throws Exception
	{
		DataQuery query = new DataQuery();
		query.addUserRule(sRule, sExec, sRuleDesc, sCntrlType);
		updateRuleParams(sCntrlType);
	}
	
	public void updateRule(String oid, String sRule, String sExec, String sRuleDesc, String sCntrlType) throws Exception
	{
		DataQuery query = new DataQuery();
    	query.updateRule(oid, sRule, sExec, sRuleDesc);
    	updateRuleParams(sCntrlType);
	}
	
	public void deleteRule(String oid, String sCntrlType) throws Exception
	{
		DataQuery query = new DataQuery();
		query.deleteRule(oid);
		updateRuleParams(sCntrlType);
	}
	
	private void updateRuleParams(String sCntrlType) throws Exception
	{
		int idx1 = 0;
		int idx2 = 0;
		int iRule = 0;
		String sParam = null;
		String sRule = null;
		Map<String, String> mRule = null;
		
		DataQuery query = new DataQuery();
		MapList mlRules = query.getUserRules(sCntrlType);
		USER_RULES.put(sCntrlType, mlRules);
		
		int iRuleCheck;
		StringList slParams = null;
		for(int i=0; i<mlRules.size(); i++)
		{
			mRule = mlRules.get(i);
			sRule = mRule.get(RULE_EXPRESSION);
			iRule = (Integer.parseInt(mRule.get(RULE_EXECUTE)) / 5) + 1;
			
			if(RULE_CHECK.containsKey(sCntrlType))
			{
				iRuleCheck = (RULE_CHECK.get(sCntrlType)).intValue();
			}
			else
			{
				iRuleCheck = 1;
			}
			RULE_CHECK.put(sCntrlType, Integer.valueOf((iRule > iRuleCheck) ? iRule : iRuleCheck));
			
			while(sRule.contains("'"))
			{
				idx1 = sRule.indexOf("'") + 1;
				idx2 = sRule.indexOf("'", idx1);
				sParam = sRule.substring(idx1, idx2).trim();
				sRule = sRule.substring(idx2 +1);
				
				slParams = RULE_PARAMS.get(sCntrlType);
				if(slParams == null)
				{
					slParams = new StringList();
				}
				if(!slParams.contains(sParam))
				{
					slParams.add(sParam);
					RULE_PARAMS.put(sCntrlType, slParams);
				}
			}
		}
	}
	
	private ArrayList<String> getOpenAlarms(String sRoom) throws Exception
	{
		ArrayList<String> alOpenAlarms = new ArrayList<String>();
		
		Map<String, String> mAlarm = null;
		DataQuery query = new DataQuery();
		MapList mlOpenAlarms = query.getOpenAlarms(sRoom);
		
		for(int i=0, iSz=mlOpenAlarms.size(); i<iSz; i++)
		{
			mAlarm = mlOpenAlarms.get(i);
			alOpenAlarms.add(mAlarm.get(SERIAL_ID));
		}
		
		return alOpenAlarms;
	}
}
