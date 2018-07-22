package com.client.views;

import java.text.DecimalFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import com.client.db.DataQuery;
import com.client.util.IntuitiveStringComparator;
import com.client.util.MapList;
import com.client.util.RDMServicesConstants;
import com.client.util.RDMServicesUtils;
import com.client.util.StringList;

public class UserTasks extends RDMServicesConstants
{
	private final static String BLANK_SPACE_SFX = "&nbsp;(";
	private final static String PFX_BLANK_SPACE = ")&nbsp;";
	private final static String COLON_BLANK_SPACE = "):&nbsp;";
	private final static String FONT_BLUE = "<font color=blue>";
	private final static String FONT_RED = "<font color=red>";
	private final static String FONT_END = "</font>";
	
	private final static DecimalFormat df = new DecimalFormat("#.####");
	private final static SimpleDateFormat format = new SimpleDateFormat("MM/dd/yyyy HH:mm", Locale.getDefault());
	
	public UserTasks()
	{
		
	}

    public StringList createUserTask(Map<String, String> mTask, String[] saAssignees) throws Exception
	{
    	DataQuery query = new DataQuery();
    	
    	String sRoomId = mTask.get(ROOM_ID);
		boolean bGeneral = RDMServicesUtils.isGeneralController(sRoomId);

		if(!"".equals(sRoomId) && !bGeneral)
		{
			String sStage = query.getCurrentStage(sRoomId);
			sStage = (sStage == null ? "" : sStage);
		
			String sBatchNo = query.getBatchNo(sRoomId);
			sBatchNo = (sBatchNo == null ? "" : sBatchNo);
		
			mTask.put(STAGE_NUMBER, sStage);
			mTask.put(BATCH_NO, sBatchNo);
		}

		return query.createUserTask(mTask, saAssignees);
	}
    
    public StringList copyUserTasks(Map<String, String> mTask, String[] saTasks) throws Exception
	{
    	StringList slReturn = new StringList();

    	String sTasks = "";
		int iLen = saTasks.length;
		if(iLen > 1)
		{
			for(int i=0; i<iLen; i++)
			{
				if(i > 0)
				{
					sTasks += "','";
				}
				sTasks += saTasks[i];
			}
		}
		else
		{
			sTasks = saTasks[0];
		}
		
		DataQuery query = new DataQuery();
		MapList mlTasks = query.searchUserTasks("", sTasks, "", "", "", "", "", "", "", "", "", true, true, false, false, false, -1, "");
		
		String sRoomId = mTask.get(ROOM_ID);
		boolean bGeneral = RDMServicesUtils.isGeneralController(sRoomId);

		if(!"".equals(sRoomId) && !bGeneral)
		{
			String sStage = query.getCurrentStage(sRoomId);
			sStage = (sStage == null ? "" : sStage);
			
			String sBatchNo = query.getBatchNo(sRoomId);
			sBatchNo = (sBatchNo == null ? "0" : sBatchNo);
			
			mTask.put(STAGE_NUMBER, sStage);
			mTask.put(BATCH_NO, sBatchNo);
		}
		
		mTask.put(STATUS, TASK_STATUS_NOT_STARTED);

		String sAssignee = mTask.get(ASSIGNEE);
		Map<String, String> mCopyTask = null;
		for(int i=0; i<mlTasks.size(); i++)
		{
			mCopyTask = mlTasks.get(i);
		
			mTask.put(TASK_ID, mCopyTask.get(TASK_ID));
			mTask.put(PARENT_TASK, mCopyTask.get(PARENT_TASK));
			
			if("".equals(sAssignee))
			{
				mTask.put(CO_OWNERS, mCopyTask.get(CO_OWNERS));
				slReturn.addAll(query.createUserTask(mTask, new String[] {mCopyTask.get(ASSIGNEE)}));
			}
			else
			{
				slReturn.addAll(query.createUserTask(mTask, new String[] {sAssignee}));
			}
		}
			
		return slReturn;
	}
    
    public boolean updateUserTask(String sUserId, Map<String, String> mTask) throws Exception
	{
    	DataQuery query = new DataQuery();
    	return query.updateUserTask(sUserId, mTask);
	}
    
    public boolean startUserTasks(String sUserId, StringList slTasks) throws Exception
	{
    	DataQuery query = new DataQuery();
    	return query.startUserTasks(sUserId, slTasks);
	}
    
    public String completeUserTasks(String sUserId, StringList slTasks) throws Exception
	{
    	DataQuery query = new DataQuery();
    	return query.completeUserTasks(sUserId, slTasks);
	}
    
    public boolean deleteUserTasks(StringList slTasks) throws Exception
	{
    	DataQuery query = new DataQuery();
    	return query.deleteUserTasks(slTasks);
	}
    
    public Map<String, TaskInfo> searchTasks(String sRoom, String sTask, String sDept, String sOwner, String sAssignee, 
    		String sFromDate, String sToDate, String sStatus, String sBatchNo, String sStage, 
    			boolean childTasks, boolean parentTasks, boolean coOwners, int limit, String sSearchType) throws Exception
	{
    	Map<String, TaskInfo> mTasks = new HashMap<String, TaskInfo>();
    	SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy");
    	
    	DataQuery query = new DataQuery();
    	MapList mlTasks = query.searchUserTasks(sRoom, "", sTask, sDept, sOwner, sAssignee, sFromDate, sToDate, 
    			sStatus, "", sStage, childTasks, parentTasks, coOwners, true, true, limit, sSearchType);
    	
    	boolean bUserBased = USER_BASED.equals(sSearchType);
    	boolean bRoomBased = ROOM_BASED.equals(sSearchType);
    	boolean bDateBased = DATE_BASED.equals(sSearchType);
    	
    	String sGroup = null;
    	String sPrevGroup = null;
    	Map<String, String> mTask = null;
    	TaskInfo taskInfo = null;
    	
    	for(int i=0,iSz=mlTasks.size(); i<iSz; i++)
    	{
    		mTask = mlTasks.get(i);
    		
    		if(bUserBased)
    		{
    			sGroup = mTask.get(ASSIGNEE);
    			sGroup = ("".equals(sGroup) ? NO_USER : sGroup);
    		}
    		else if(bRoomBased)
    		{
    			sGroup = mTask.get(ROOM_ID);
    			sGroup = ("".equals(sGroup) ? NO_ROOM : sGroup);
    		}
    		else if(bDateBased)
    		{
    			sGroup = mTask.get(ACTUAL_START);
    			sGroup = (sGroup == null || "".equals(sGroup) ? mTask.get(ESTIMATED_START) : sGroup);
    			sGroup = (sGroup == null || "".equals(sGroup) ? NO_DATE : sdf.format(format.parse(sGroup)));
    		}
    		
    		if(!sGroup.equals(sPrevGroup))
    		{
    			if(sPrevGroup != null)
    			{
    				if(bUserBased)
    	    		{
    					taskInfo.setProductivity();
    	    		}
    				mTasks.put(sPrevGroup, taskInfo);
    			}

    			taskInfo = new TaskInfo(sGroup);
    			sPrevGroup = new String(sGroup);
    		}
    		
    		taskInfo.addTask(mTask);
    	}
    	
    	if(taskInfo != null)
		{
    		if(bUserBased)
    		{
				taskInfo.setProductivity();
    		}
			mTasks.put(sPrevGroup, taskInfo);
		}
    	
    	return mTasks;
	}
    
    public Map<String, MapList> getProductivity() throws Exception
	{
    	StringList slTasks = RDMServicesUtils.getProductivityTasks();
    	slTasks.sort();
    	
    	Map<String, MapList> mTasks = new HashMap<String, MapList>();
    	MapList mlTasks = null;
    	String sTaskId = null;
    	String sTaskName = null;
    	
    	for(int i=0; i<slTasks.size(); i++)
    	{
    		sTaskId = slTasks.get(i);
    		sTaskName = RDMServicesUtils.listAdminTasks().get(sTaskId);
    		
    		mlTasks = getProductivity(sTaskId);
    		mTasks.put((sTaskId + "(" + sTaskName + ")"), mlTasks);
    	}
    	
    	return mTasks;
	}
    
    private MapList getProductivity(String sTaskId) throws Exception
	{
    	SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy");
    	
    	DataQuery query = new DataQuery();
    	MapList mlTasks = query.searchUserTasks("", "", sTaskId, "", "", "", sdf.format(new Date()), "", 
    		TASK_PRODUCTIVITY, "", "", true, false, false, true, false, -1, USER_BASED);
    	
    	double productivity;
    	String sUserId = null;
    	String sGroup = null;
    	String sPrevGroup = null;
    	Map<String, String> mTask = null;
    	Map<String, TaskInfo> mTasks = new HashMap<String, TaskInfo>();
    	MapList mlProductivity = new MapList();
    	TaskInfo taskInfo = null;
    	
    	for(int i=0,iSz=mlTasks.size(); i<iSz; i++)
    	{
    		mTask = mlTasks.get(i);
    		
			sGroup = mTask.get(ASSIGNEE);
			sGroup = ("".equals(sGroup) ? NO_USER : sGroup);
    		if(!sGroup.equals(sPrevGroup))
    		{
    			if(sPrevGroup != null)
    			{
					taskInfo.setProductivity();
    				mTasks.put(sPrevGroup, taskInfo);
    			}

    			taskInfo = new TaskInfo(sGroup);
    			sPrevGroup = new String(sGroup);
    		}
    		
    		taskInfo.addTask(mTask);
    	}
    	
    	if(taskInfo != null)
		{
			taskInfo.setProductivity();
			mTasks.put(sPrevGroup, taskInfo);
		}
    	
    	List<String> alNames = sort(mTasks, USER_BASED);
    	for(int i=0; i<alNames.size(); i++)
    	{
    		taskInfo = mTasks.get(alNames.get(i));
    		productivity = taskInfo.getProductivity();
    			
    		if(productivity > 0) 
    		{
	    		sUserId = taskInfo.getGroupName();
    		
    			mTask = new HashMap<String, String>();
        		mTask.put(ASSIGNEE, sUserId);
        		mTask.put(DURATION, Long.toString(taskInfo.getTime()));
        		mTask.put(PRODUCTIVITY, Double.toString(productivity));
        		mlProductivity.add(mTask);
    		}
    	}
    	
    	return mlProductivity;
	}
    
    public MapList searchUserTasks(String sRoom, String sTaskId, StringList slDept, String sOwner, String sAssignee, 
		String sFromDate, String sToDate, String sStatus, String sBatchNo, String sStage, 
			boolean childTasks, boolean parentTasks, boolean coOwners, int limit) throws Exception
	{
    	return searchUserTasks(sRoom, sTaskId, slDept.join('|'), sOwner, sAssignee, sFromDate, sToDate, 
    			sStatus, sBatchNo, sStage, childTasks, parentTasks, coOwners, limit);
	}
    
    public MapList searchUserTasks(String sRoom, String sTaskId, String sDept, String sOwner, String sAssignee, 
    		String sFromDate, String sToDate, String sStatus, String sBatchNo, String sStage, 
    			boolean childTasks, boolean parentTasks, boolean coOwners, int limit) throws Exception
	{
    	DataQuery query = new DataQuery();
    	return query.searchUserTasks(sRoom, "", sTaskId, sDept, sOwner, sAssignee, sFromDate, sToDate, 
    			sStatus, sBatchNo, sStage, childTasks, parentTasks, coOwners, false, false, limit, "");
	}
    
    public MapList getOpenTasks(String sAssignee) throws Exception
	{
    	DataQuery query = new DataQuery();
    	return query.searchUserTasks("", "", "", "", "", sAssignee, "", "", 
    		TASK_STATUS_OPEN, "", "", true, true, false, true, true, -1, USER_BASED);
	}
    
    public MapList moveToUserTasks(String sRoom, String sTaskId, String sOwner, String sAssignee) throws Exception
	{
    	DataQuery query = new DataQuery();
    	return query.searchUserTasks(sRoom, "", sTaskId, "", sOwner, sAssignee, "", "", 
    			TASK_STATUS_WIP, "", "", true, false, true, false, false, -1, "");
	}
    
    public Map<String, String> userTaskDetails(String sTask) throws Exception
	{
    	Map<String, String> mTask = null;
    	
    	DataQuery query = new DataQuery();
    	MapList mlTasks = query.searchUserTasks("", sTask, "", "", "", "", "", "", "", "", "", true, true, false, true, true, -1, "");
    	
    	if(mlTasks.size() > 0)
    	{
    		mTask = mlTasks.get(0);
    	}
    	else
    	{
    		mTask = new HashMap<String, String>();
    	}

    	return mTask;
	}
    
    public MapList getTaskWBS(String sTask) throws Exception
	{
    	MapList mlTaskWBS = new MapList();
    	
    	Map<String, String> mTask = userTaskDetails(sTask);
    	if(!mTask.isEmpty())
    	{
	    	mTask.put(TASK_WBS_LEVEL, Integer.toString(0));
	    	mlTaskWBS.add(mTask);
	    	
	    	getTaskWBS(sTask, mlTaskWBS, 0, true);
    	}

    	return mlTaskWBS;
	}
    
    private MapList getTaskWBS(String sParentTask, MapList mlTaskWBS, int level, boolean deliverables) throws Exception
	{
    	Map<String, String> mTask = null;
    	String sChildTask = null;
    	level = level + 1;
    	
    	DataQuery query = new DataQuery();
    	MapList mlTasks = query.getChildTasks(sParentTask, deliverables);
    	
    	int iSz = mlTasks.size();
    	if(iSz > 0)
    	{
    		if(mlTaskWBS.size() > 0)
    	    {
    			int idx = mlTaskWBS.size() - 1;
    			mTask = mlTaskWBS.get(idx);
    			mTask.put(HAS_CHILD_TASKS, "True");
    			mlTaskWBS.set(idx, mTask);
    	    }
    		
	    	for(int i=0; i<iSz; i++)
	    	{
	    		mTask = mlTasks.get(i);
	    		sChildTask = mTask.get(TASK_AUTONAME);
	    		mTask.put(TASK_WBS_LEVEL, Integer.toString(level));
	    		
	    		mlTaskWBS.add(mTask);
	    		getTaskWBS(sChildTask, mlTaskWBS, level, deliverables);
	    	}
    	}
    	else if(mlTaskWBS.size() > 0)
    	{
    		int idx = mlTaskWBS.size() - 1;
    		mTask = mlTaskWBS.get(idx);
    		mTask.put(HAS_CHILD_TASKS, "False");
    		mlTaskWBS.set(idx, mTask);
    	}

    	return mlTaskWBS;
	}
    
    public MapList getTaskDeliverables(String sTaskId) throws Exception
	{
    	DataQuery query = new DataQuery();
    	return query.getTaskDeliverables(sTaskId);
	}
    
    public Map<String, String> getDeliverableDetails(String sDeliverableId) throws Exception
	{
    	DataQuery query = new DataQuery();
    	return query.getDeliverableDetails(sDeliverableId);
	}
    
    public boolean addDeliverable(String sTaskId, String sDeliverableId, Map<String, String> mDeliverable) throws Exception
	{
    	DataQuery query = new DataQuery();
    	return query.addDeliverable(sTaskId, sDeliverableId, mDeliverable);
	}
    
    public boolean addDeliverable(String sDeliverableId, Map<String, String> mDeliverable) throws Exception
	{
    	DataQuery query = new DataQuery();
    	return query.addDeliverable(sDeliverableId, mDeliverable);
	}
    
    public boolean updateDeliverable(String sDeliverableId, Map<String, String> mDeliverable) throws Exception
	{
    	DataQuery query = new DataQuery();
    	return query.updateDeliverable(sDeliverableId, mDeliverable);
	}
    
    public boolean deleteDeliverable(String sUserId, String sTaskId, String sDeliverableId) throws Exception
	{
    	DataQuery query = new DataQuery();
    	return query.deleteDeliverable(sUserId, sTaskId, sDeliverableId);
	}
    
    public void downloadTaskDeliverables(String sUser, StringList slTaskIds) throws Exception
    {
    	DataQuery query = new DataQuery();
		query.downloadTaskDeliverables(sUser, slTaskIds);
	}
    
    public void downloadDeliverables(String sUser, StringList slDeliverableIds) throws Exception
    {
    	DataQuery query = new DataQuery();
		query.downloadDeliverables(sUser, slDeliverableIds);
	}
    
    public void resetDownloadFlag(String[] saDeliverableIds) throws Exception
    {
    	DataQuery query = new DataQuery();
		query.resetDownloadFlag(saDeliverableIds);
	}
    
    public List<String> sort(Map<String, TaskInfo> mTasks, String sortBy)
    {
    	String sName;
    	List<String> lSorted = new ArrayList<String>();
    	
    	if(USER_BASED.equals(sortBy))
		{
        	double dProductivity;
        	long lDuration;
        	Map<Double, String> mProductivity = new HashMap<Double, String>();
        	Map<Long, String> mZeroProductivity = new HashMap<Long, String>();
        	
        	TaskInfo taskInfo = null;
        	
	    	Iterator<String> itrTask = mTasks.keySet().iterator();
			while(itrTask.hasNext())
			{
				sName = itrTask.next();
				taskInfo = mTasks.get(sName);
				
				dProductivity = taskInfo.getProductivity();
				if(dProductivity == 0)
				{
					lDuration = taskInfo.getTime();
					if(mZeroProductivity.containsKey(lDuration))
					{
						mZeroProductivity.put(lDuration, (sName + "," + mZeroProductivity.get(lDuration)));
					}
					else
					{
						mZeroProductivity.put(lDuration, sName);
					}
				}
				else
				{
					if(mProductivity.containsKey(dProductivity))
					{
						mProductivity.put(dProductivity, (sName + "," + mProductivity.get(dProductivity)));
					}
					else
					{
						mProductivity.put(dProductivity, sName);
					}
				}
			}
			
			String[] saNames = null;
			List<Double> lDProductivity = new ArrayList<Double>(mProductivity.keySet());
    		Collections.sort(lDProductivity);    		
    		for(int i=(lDProductivity.size()-1); i>=0; i--)
    		{
    			dProductivity = lDProductivity.get(i);
    			sName = mProductivity.get(dProductivity);
    			
    			if(sName.contains(","))
    			{
    				saNames = sName.split(",");
    				for(int j=0; j<saNames.length; j++)
    				{
    					lSorted.add(saNames[j]);
    				}
    			}
    			else
    			{
    				lSorted.add(sName);
    			}
    		}
    		
    		List<Long> lLProductivity = new ArrayList<Long>(mZeroProductivity.keySet());
    		Collections.sort(lLProductivity);
    		for(int i=0; i<lLProductivity.size(); i++)
    		{
    			lDuration = lLProductivity.get(i);
    			sName = mZeroProductivity.get(lDuration);
    			
    			if(sName.contains(","))
    			{
    				saNames = sName.split(",");
    				for(int j=0; j<saNames.length; j++)
    				{
    					lSorted.add(saNames[j]);
    				}
    			}
    			else
    			{
    				lSorted.add(sName);
    			}
    		}
		}
    	else if(ROOM_BASED.equals(sortBy))
    	{
    		List<String> lNames = new ArrayList<String>(mTasks.keySet());
    		
    		String[] sArr = new String[lNames.size()];
    		sArr = (String[])lNames.toArray(sArr);
        	Arrays.sort(sArr, new IntuitiveStringComparator<String>());
        	
        	for (String s : sArr)   
        	{   
        		lSorted.add(s);   
        	}
    	}
    	else if(DATE_BASED.equals(sortBy))
    	{
    		lSorted = new ArrayList<String>(mTasks.keySet());
    		Collections.sort(lSorted, new Comparator<String>() {
    			SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy");
    	        @Override
    	        public int compare(String o1, String o2)
    	        {
    	            try
    	            {
    	                return sdf.parse(o1).compareTo(sdf.parse(o2));
    	            }
    	            catch (ParseException e)
    	            {
    	                throw new IllegalArgumentException(e);
    	            }
    	        }
    	    });
    	}
    	
    	return lSorted;
    }
    
    public boolean moveTaskDeliverables(String sUserId, String sTaskId, String sSrcTaskId, StringList slDeliverableIds) throws Exception
	{
		DataQuery query = new DataQuery();
		return query.moveTaskDeliverables(sUserId, sTaskId, sSrcTaskId, slDeliverableIds);
	}
    
    public Map<String, String> getUserTaskCnt() throws Exception
	{
		DataQuery query = new DataQuery();
		return query.getUserTaskCnt();
	}
    
    public class TaskInfo
    {
    	private double dProductivity;
    	private long lDuration;
    	private long lProdHrs;
    	private String sGroup;
    	private Map<String, Integer[]> mDeliverableCnt;
    	private Map<String, Double[]> mDeliverableQty;
    	private MapList mlTasks;
    	private StringList slTasks;
    	
    	public TaskInfo(String s) throws Exception
    	{
    		this.dProductivity = 0;
    		this.lDuration = 0;
    		this.sGroup = s;
    		this.mDeliverableCnt = new HashMap<String, Integer[]>();
    		this.mDeliverableQty = new HashMap<String, Double[]>();
    		slTasks = RDMServicesUtils.getProductivityTasks();
        	
    		this.mlTasks = new MapList();
    	}
    	
    	public String getGroupName()
    	{
    		return this.sGroup;
    	}
    	
    	public Map<String, Integer[]> getSize()
    	{
    		return this.mDeliverableCnt;
    	}
    	
    	public Map<String, Double[]> getQuantity()
    	{
    		return this.mDeliverableQty;
    	}
    	
    	public long getTime()
    	{
    		return this.lDuration;
    	}
    	
    	public void setProductivity() throws Exception
    	{
        	double dQuantity = 0.0;
        	String sAttribute = null;

    		Iterator<String> itr = mDeliverableQty.keySet().iterator();
    		while(itr.hasNext())
    		{
    			sAttribute = itr.next();
				dQuantity = dQuantity + mDeliverableQty.get(sAttribute)[0].doubleValue();
    		}
    		
    		if(this.lProdHrs > 0)
    		{
    			this.dProductivity = ((dQuantity / this.lProdHrs) * 60);
    		}
    	}
    	
    	public double getProductivity()
    	{
    		return this.dProductivity;
    	}
    	
    	public MapList getTasks()
    	{
    		return this.mlTasks;
    	}
    	
    	public void addTask(Map<String, String> mTask) throws Exception
    	{
    		String sTaskId = mTask.get(TASK_AUTONAME);    		
    		String actStart = mTask.get(ACTUAL_START);
    		String actEnd = mTask.get(ACTUAL_END);
    		
    		long lTaskDuration = RDMServicesUtils.calculateDuration(actStart, actEnd, format);
    		this.lDuration += lTaskDuration;
    		
    		if(slTasks.contains(mTask.get(TASK_ID)))
    		{
    			this.lProdHrs += lTaskDuration;
    		}
    		
    		int iSz = Integer.parseInt(mTask.get(DELIVERABLE_CNT));
    		if(iSz > 0)
    		{
    			String[] saDeliverables = addDeliverables(sTaskId);
    			
    			mTask.put(TASK_DELIVERABLES, saDeliverables[0]);
        		mTask.put(FIRST_DELIVERABLE_CREATED_ON, saDeliverables[1]);
        		mTask.put(LAST_DELIVERABLE_CREATED_ON, saDeliverables[2]);
    		}
    		else
    		{
    			mTask.put(TASK_DELIVERABLES, "");
        		mTask.put(FIRST_DELIVERABLE_CREATED_ON, "");
        		mTask.put(LAST_DELIVERABLE_CREATED_ON, "");
    		}
    		
    		mlTasks.add(mTask);
    	}
    	
    	private String[] addDeliverables(String sTaskId) throws Exception
        {
    		boolean downloadFlag;
    		int iTotal = 0;
        	int iNotDownload = 0;
        	double dTotal = 0.0;
        	double dNotDownload = 0.0;
        	double dAttrOverage = 0.0;
        	String sAttrName = null;
        	String sAttrValue = null;
        	String sfxOverage = "_" + OVERAGE;
        	String BLANK = "";
        	String EMPTY = "0.0";
        	String sFstDelCreatedOn = "";
        	String sLstDelCreatedOn = "";
        	StringBuilder sbReturn = new StringBuilder();
        	String[] saDeliverables = new String[3];
        	Iterator<String> itr = null;
        	Map<String, String> mDeliverable = null;
        	Map<String, Double[]> mTaskDeliverables = new HashMap<String, Double[]>();
        	
        	MapList mlTaskDels = getTaskDeliverables(sTaskId);
    		for(int x=0, iSz=mlTaskDels.size(); x<iSz; x++)
    		{
    			mDeliverable = mlTaskDels.get(x);
    			downloadFlag = Boolean.parseBoolean(mDeliverable.get(DOWNLOAD_FLAG));

    			if(x == 0)
    			{
    				sFstDelCreatedOn = mDeliverable.get(CREATED_ON);
    				if(iSz == 1)
        			{
        				sLstDelCreatedOn = mDeliverable.get(CREATED_ON);
        			}
    			}
    			else if(x == (iSz - 1))
    			{
    				sLstDelCreatedOn = mDeliverable.get(CREATED_ON);
    			}
    			
    			mDeliverable.remove(DELIVERABLE_ID);
    			mDeliverable.remove(CREATED_ON);
    			mDeliverable.remove(DOWNLOAD_FLAG);
    			mDeliverable.remove(DOWNLOAD_BY);
    			mDeliverable.remove(DOWNLOAD_ON);

    			itr = mDeliverable.keySet().iterator();
    			while(itr.hasNext())
    			{
    				sAttrName = itr.next();
    				sAttrValue = mDeliverable.get(sAttrName);
    				if(sAttrName.endsWith(sfxOverage) || (sAttrValue == null || BLANK.equals(sAttrValue) || EMPTY.equals(sAttrValue)))
    				{
    					continue;
    				}
    				
    				iTotal = 0;	iNotDownload = 0;
    				if(mDeliverableCnt.containsKey(sAttrName))
    				{
    					iTotal = mDeliverableCnt.get(sAttrName)[0].intValue();
    					iNotDownload = mDeliverableCnt.get(sAttrName)[1].intValue();
    				}

    				iTotal = iTotal + 1;
    				if(!downloadFlag)
    				{
    					iNotDownload = iNotDownload + 1;
    				}
    				mDeliverableCnt.put(sAttrName, new Integer[] {new Integer(iTotal), new Integer(iNotDownload)});
    			
    				dTotal = 0.0; dNotDownload = 0.0; dAttrOverage = 0.0;
    				if(mTaskDeliverables.containsKey(sAttrName))
    				{
    					dTotal = mTaskDeliverables.get(sAttrName)[0].doubleValue();
    					dNotDownload = mTaskDeliverables.get(sAttrName)[1].doubleValue();
    					dAttrOverage = mTaskDeliverables.get(sAttrName)[2].doubleValue();
    				}

    				dTotal = dTotal + Double.parseDouble(sAttrValue);
    				dAttrOverage = dAttrOverage + Double.parseDouble(mDeliverable.get(sAttrName + sfxOverage));
    				if(!downloadFlag)
    				{
    					dNotDownload = dNotDownload + Double.parseDouble(sAttrValue);
    				}
    				mTaskDeliverables.put(sAttrName, new Double[] {new Double(dTotal), new Double(dNotDownload), new Double(dAttrOverage)});
    			}
    		}
    		
    		itr = mTaskDeliverables.keySet().iterator();
    		while(itr.hasNext())
    		{
    			sAttrName = itr.next();

    			dTotal = mTaskDeliverables.get(sAttrName)[0].doubleValue();
    			dNotDownload = mTaskDeliverables.get(sAttrName)[1].doubleValue();
    			dAttrOverage = mTaskDeliverables.get(sAttrName)[2].doubleValue();
    			
    			sbReturn.append(sAttrName);
    			sbReturn.append(BLANK_SPACE_SFX);
    			sbReturn.append(RDMServicesUtils.getAttributeUnits().get(sAttrName));
    			sbReturn.append(COLON_BLANK_SPACE);
    			sbReturn.append(FONT_BLUE);
    			sbReturn.append(Double.valueOf(df.format(dTotal)));
    			sbReturn.append(FONT_END);
    			sbReturn.append(BLANK_SPACE_SFX);
    			sbReturn.append(FONT_RED);
    			sbReturn.append(Double.valueOf(df.format(dAttrOverage)));
    			sbReturn.append(FONT_END);
    			sbReturn.append(PFX_BLANK_SPACE);
    			
    			if(mDeliverableQty.containsKey(sAttrName))
    			{
    				dTotal = dTotal + mDeliverableQty.get(sAttrName)[0].doubleValue();
    				dNotDownload = dNotDownload + mDeliverableQty.get(sAttrName)[1].doubleValue();
    				dAttrOverage = dAttrOverage + mDeliverableQty.get(sAttrName)[2].doubleValue();
    			}
    			mDeliverableQty.put(sAttrName, new Double[] {new Double(dTotal), new Double(dNotDownload), new Double(dAttrOverage)});

    		}
    		
    		saDeliverables[0] = sbReturn.toString();
    		saDeliverables[1] = sFstDelCreatedOn;
    		saDeliverables[2] = sLstDelCreatedOn;
    		
    		return saDeliverables;
    	}
    }
}
