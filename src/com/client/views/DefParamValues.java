package com.client.views;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import com.client.db.DataQuery;
import com.client.util.MapList;
import com.client.util.RDMServicesConstants;
import com.client.util.StringList;

public class DefParamValues extends RDMServicesConstants
{
	public DefParamValues()
	{
		
	}
	
	public MapList getDefaultTypes() throws Exception
	{
		DataQuery query = new DataQuery();
		return query.getDefaultTypes();
	}
	
	public StringList getDefaultTypes(String sCntrlType) throws Exception
	{
		Map<String, String> mDefTypes = null;
		MapList mlDefTypes = getDefaultTypes();
		StringList slDefTypes = new StringList();
		
		for(int i=0; i<mlDefTypes.size(); i++)
		{
			mDefTypes = mlDefTypes.get(i);
			if(sCntrlType.equals(mDefTypes.get(CNTRL_TYPE)))
			{
				slDefTypes.add(mDefTypes.get(CNTRL_DEF_TYPE));
			}
		}
		
		slDefTypes.sort();
		return slDefTypes;
	}
	
	public Map<String, Map<String, String>> getDefaultParamValues(String sCntrlType) throws Exception
	{
		String sDefType = null;
		Map<String, String> mDefValues = null;
		Map<String, Map<String, String>> mCntrlDefValues = new HashMap<String, Map<String, String>>();
			
		DataQuery query = new DataQuery();
		StringList slDefTypes = query.getColumnParameters(sCntrlType+"_DEF_PARAM_VAL");
		slDefTypes.remove(PARAM_NAME);
		
		for(int i=0; i<slDefTypes.size(); i++)
		{
			sDefType = slDefTypes.get(i);
			mDefValues = getDefaultParamValues(sCntrlType, sDefType, null);
			
			mCntrlDefValues.put(sDefType, mDefValues);
		}
		
		return mCntrlDefValues;
	}
	
	public Map<String, String> getDefaultParamValues(String sCntrlType, String sDefType) throws Exception
	{
		return getDefaultParamValues(sCntrlType, sDefType, null);
	}
	
	public Map<String, String> getDefaultParamValues(String sCntrlType, String sDefType, String sParam) throws Exception
	{
		DataQuery query = new DataQuery();
		return query.getDefaultParamValues(sCntrlType, sDefType, sParam);
	}
	
	public void updateDefaultParamValues(String sCntrlType, Map<String, Map<String, String>> mCntrlDefValues) throws Exception
	{
		String sDefType = null;
		Map<String, String> mDefValues = null;
		
		Iterator<String> itrDefVals = mCntrlDefValues.keySet().iterator();
		while(itrDefVals.hasNext())
		{
			sDefType = itrDefVals.next();
			mDefValues = mCntrlDefValues.get(sDefType);
			updateDefaultParamValues(sCntrlType, sDefType, mDefValues);
		}
	}
	
	public void updateDefaultParamValues(String sCntrlType, String sDefType, Map<String, String> mDefValues) throws Exception
	{
		DataQuery query = new DataQuery();
		query.updateDefaultParamValues(sCntrlType, sDefType, mDefValues);
	}
	
	public void addDefaultType(String sCntrlType, String sDefType, String sDesc) throws Exception
	{
		DataQuery query = new DataQuery();
		query.addDefaultType(sCntrlType, sDefType, sDesc);
	}
	
	public void updateDefaultType(String sCntrlType, String sDefType, String sOldDefType, String sDesc) throws Exception
	{
		DataQuery query = new DataQuery();
		query.updateDefaultType(sCntrlType, sDefType, sOldDefType, sDesc);
	}
	
	public void deleteDefaultType(String sCntrlType, String sDefType) throws Exception
	{
		DataQuery query = new DataQuery();
		query.deleteDefaultType(sCntrlType, sDefType);
	}

	public void copyDefaultValues(String sCntrlType, String sToDefType, String sFromDefType) throws Exception
	{
		DataQuery query = new DataQuery();
		query.copyDefaultValues(sCntrlType, sToDefType, sFromDefType);
	}
}
