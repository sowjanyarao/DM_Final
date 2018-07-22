package com.client.views;

import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import com.client.db.DataQuery;
import com.client.util.MapList;
import com.client.util.RDMServicesConstants;
import com.client.util.RDMServicesUtils;
import com.client.util.StringList;

public class BatchPhaseLoad extends RDMServicesConstants
{
	public BatchPhaseLoad()
	{
	}
    
	public String loadBatchPhaseGraph(String sMonth, String sYear, String sCntrlType, String sProductType, StringList slBatches) throws Exception
	{
    	Map<String, String> mBatchNo = null;
    	String sDuration = null;
    	String sRoomId = null;
		String sBatchNo = null;
		String sHeader = null;
		String seqNum = null;
		String stageName = null;
		String[] saStage = null;
		String SET_DURATION = "set duration";
		
    	String sStartDt = sYear + "-" + RDMServicesConstants.CALENDAR_DAYS.get(sMonth)[0];
		String sEndDt = sYear + "-" + RDMServicesConstants.CALENDAR_DAYS.get(sMonth)[1];
		
		DataQuery query = new DataQuery();
		MapList mlBatchNos = query.getBatchLoad(sStartDt, sEndDt, sCntrlType, sProductType, false, false);
		
		StringBuilder sbParamValues = new StringBuilder();
		sbParamValues.append("Stage");
		sbParamValues.append(",");
		sbParamValues.append(sProductType);
		
		if(slBatches != null)
		{
			slBatches.add(sProductType);
		}
		
		Map<String, String> mPhaseDurations = null;
		Map<String, Map<String, String>> mBatchPhaseDurations = new HashMap<String, Map<String, String>>();

		DefParamValues defParamVal = new DefParamValues();
		Map<String, String> mDefaultDurations = defParamVal.getDefaultParamValues(sCntrlType, sProductType, SET_DURATION);

		for(int i=0; i<mlBatchNos.size(); i++)
		{
			mBatchNo = mlBatchNos.get(i);
			sRoomId = mBatchNo.get(ROOM_ID);
			sBatchNo = mBatchNo.get(BATCH_NO);
			sStartDt = mBatchNo.get(START_DT);
			sEndDt = mBatchNo.get(END_DT);
			
			sHeader = sBatchNo+"("+sRoomId+")";
			sbParamValues.append(",");
			sbParamValues.append(sHeader);
			if(slBatches != null)
			{
				slBatches.add(sHeader);
			}
			
			mPhaseDurations = query.getBatchPhaseDurations(sRoomId, sBatchNo, sStartDt, sEndDt);
			mBatchPhaseDurations.put(sBatchNo, mPhaseDurations);
		}
		
		sbParamValues.append("\n");
		
		ArrayList<String[]> alStages = RDMServicesUtils.getControllerStages(sCntrlType);
		for(int i=1; i<alStages.size(); i++)
		{
			saStage = alStages.get(i);
			seqNum = saStage[0];
			stageName = saStage[1];
			
			sDuration = mDefaultDurations.get(SET_DURATION+" "+stageName+" "+seqNum);
			if(sDuration == null || "".equals(sDuration))
			{
				sDuration = mDefaultDurations.get(SET_DURATION+" phase "+seqNum);
				sDuration = ((sDuration == null || "".equals(sDuration)) ? "0" : sDuration);
			}
			
			sbParamValues.append(i);
			sbParamValues.append(",");
			sbParamValues.append(sDuration);
			
			for(int j=0, iSz=mlBatchNos.size(); j<iSz; j++)
			{
				mBatchNo = mlBatchNos.get(j);
				sBatchNo = mBatchNo.get(BATCH_NO);
				mPhaseDurations = mBatchPhaseDurations.get(sBatchNo);
				sDuration = mPhaseDurations.get(seqNum);
				sDuration = ((sDuration == null || "".equals(sDuration)) ? "0" : sDuration);
				
				sbParamValues.append(",");
				sbParamValues.append(sDuration);
			}
			
			sbParamValues.append("\n");
		}
		
		String sPath = RDMServicesUtils.getClassLoaderpath("../../graphs/ControllerData");
		
		File f = File.createTempFile("ExportPhaseLoadData", ".csv", new File(sPath));
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
    
	public String exportBatchPhaseGraph(String sMonth, String sYear, String sCntrlType, String sProductType, boolean bYield) throws Exception
	{
    	Map<String, String> mBatchNo = null;
    	String sDuration = null;
    	String sRoomId = null;
		String sBatchNo = null;
		String seqNum = null;
		String stageName = null;
		String sYield = null;
		String[] saStage = null;
		String SET_DURATION = "set duration";
		
    	String sStartDt = sYear + "-" + RDMServicesConstants.CALENDAR_DAYS.get(sMonth)[0];
		String sEndDt = sYear + "-" + RDMServicesConstants.CALENDAR_DAYS.get(sMonth)[1];
		
		DefParamValues defParamVal = new DefParamValues();
		Map<String, String> mDefaultDurations = defParamVal.getDefaultParamValues(sCntrlType, sProductType, SET_DURATION);
		
		StringBuilder sbParamValues = new StringBuilder();
		ArrayList<String[]> alStages = RDMServicesUtils.getControllerStages(sCntrlType);
		
		sbParamValues.append("Batch No");
		if(bYield)
		{
			sbParamValues.append(",");
			sbParamValues.append("Yield");
		}
		for(int i=1; i<alStages.size(); i++)
		{
			saStage = alStages.get(i);
			seqNum = saStage[0];
			stageName = saStage[1];
			
			sbParamValues.append(",");
			sbParamValues.append(seqNum + ("".equals(stageName) ? "" : "("+stageName+")"));
		}
		sbParamValues.append("\n");
		
		sbParamValues.append(sProductType);
		if(bYield)
		{
			sbParamValues.append(",");
			sbParamValues.append(" ");
		}
		for(int i=1; i<alStages.size(); i++)
		{
			saStage = alStages.get(i);
			seqNum = saStage[0];
			stageName = saStage[1];
			
			sDuration = mDefaultDurations.get(SET_DURATION+" "+stageName+" "+seqNum);
			if(sDuration == null || "".equals(sDuration))
			{
				sDuration = mDefaultDurations.get(SET_DURATION+" phase "+seqNum);
				sDuration = ((sDuration == null || "".equals(sDuration)) ? "0" : sDuration);
			}
			sbParamValues.append(",");
			sbParamValues.append(sDuration);
		}
		sbParamValues.append("\n");
		
		DataQuery query = new DataQuery();
		MapList mlBatchNos = query.getBatchLoad(sStartDt, sEndDt, sCntrlType, sProductType, bYield, false);
		
		Map<String, String> mPhaseDurations = null;
		for(int i=0; i<mlBatchNos.size(); i++)
		{
			mBatchNo = mlBatchNos.get(i);
			sRoomId = mBatchNo.get(ROOM_ID);
			sBatchNo = mBatchNo.get(BATCH_NO);
			sStartDt = mBatchNo.get(START_DT);
			sEndDt = mBatchNo.get(END_DT);
			mPhaseDurations = query.getBatchPhaseDurations(sRoomId, sBatchNo, sStartDt, sEndDt);
			
			sbParamValues.append(sBatchNo+"("+sRoomId+")");
			if(bYield)
			{
				sYield = mBatchNo.get(DAILY_YIELD);
				sbParamValues.append(",");
				sbParamValues.append((sYield == null ? "" : sYield));
			}
			for(int j=1; j<alStages.size(); j++)
			{
				saStage = alStages.get(j);
				sDuration = mPhaseDurations.get(saStage[0]);
				sDuration = ((sDuration == null || "".equals(sDuration)) ? "0" : sDuration);
				
				sbParamValues.append(",");
				sbParamValues.append(sDuration);
			}
			sbParamValues.append("\n");
		}
		
		String sPath = RDMServicesUtils.getClassLoaderpath("../../export");
		File f = File.createTempFile("ExportPhaseLoadData", ".csv", new File(sPath));
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
