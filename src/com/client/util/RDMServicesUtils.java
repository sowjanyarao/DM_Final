package com.client.util;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.ResourceBundle;
import java.util.Set;
import java.util.TimeZone;

import com.client.ServicesSession;
import com.client.db.DataQuery;
import com.client.util.MapList;

public class RDMServicesUtils extends RDMServicesConstants
{
	private static ArrayList<String[]> CONTROLLER_STAGES = null;
	private static Map<String, ArrayList<String[]>> CONTROLLER_TYPE_STAGES = null;
	private static Map<String, Map<String, ParamSettings>> ROOMS_OVERVIEW_PARAMS = new HashMap<String, Map<String, ParamSettings>>();
	private static Map<String, Map<String, String[]>> PARAM_COL_NAMES = new HashMap<String, Map<String, String[]>>();
	private static Map<String, Map<String, ParamSettings>> MULTI_ROOMVIEW_PARAMS = new HashMap<String, Map<String, ParamSettings>>();
	private static Map<String, Map<String, ParamSettings>> SINGLE_ROOMVIEW_PARAMS = new HashMap<String, Map<String, ParamSettings>>();
	private static Map<String, Map<String, ParamSettings>> ROOM_IMAGEVIEW_PARAMS = new HashMap<String, Map<String, ParamSettings>>();
	private static Map<String, Map<String, ParamSettings>> GRAPH_VIEW_PARAMS = new HashMap<String, Map<String, ParamSettings>>();
	private static Map<String, Map<String, ParamSettings>> GENERAL_OVERVIEW_PARAMS = new HashMap<String, Map<String, ParamSettings>>();
	private static Map<String, ArrayList<String>> DISPLAY_ORDER = new HashMap<String, ArrayList<String>>();
	private static Map<String, Map<String, Integer>> GRAPH_SCALE = new HashMap<String, Map<String, Integer>>();
	private static Map<String, Map<Integer, String>> GROUP_HEADERS = new HashMap<String, Map<Integer, String>>();
	private static Map<String, Map<String, String>> DISPLAY_PARAM_HEADERS = new HashMap<String, Map<String, String>>();
	private static Map<String, Map<String, Object>> USER_VIEWS = null;	
	private static Map<String, StringList> PARAM_GROUPS = new HashMap<String, StringList>();
	private static Map<String, StringList> ON_OFF_VALUES = new HashMap<String, StringList>();
	private static Map<String, StringList> RESET_VALUES = new HashMap<String, StringList>();
	private static Map<String, StringList> MANUAL_PARAMS = new HashMap<String, StringList>();
	private static Map<String, StringList> COOLING_STEAM_PARAMS = new HashMap<String, StringList>();
	private static Map<String, StringList> COMP_ERROR_PARAMS = new HashMap<String, StringList>();
	private static Map<String, String> ACTIVE_DEPTS = null;
	private static Map<String, String> LIST_OF_TASKS = null;
	private static Map<String, Integer> TASK_ALERT_DURATION = null;
	private static Map<String, String> ATTRIBUTE_UNITS = null;
	private static Map<String, String> MAX_WEIGHTS = null;
	private static MapList CONTROLLER_ROOMS = null;
	private static MapList DEPT_INFO = null;
	private static MapList ADMIN_TASKS = null;
	private static MapList TASK_ATTRIBUTES = null;
	private static MapList SCALE_LIST = null;
	private static MapList USER_LIST = null;
	private static StringList YIELD_ATTRS = null;
	private static StringList OVERAGE_ATTRS = null;
	private static StringList PRODUCTIVITY_TASKS = null;
	
	private static ResourceBundle resourceBundle = null;
	static
	{
		resourceBundle = ResourceBundle.getBundle("RDMServices");
	}
 
    public static String getProperty(String sProperty) 
    {
    	if(resourceBundle.containsKey(sProperty))
    	{
    		String sValue = (String)resourceBundle.getObject(sProperty);
    		return sValue.trim();
    	}

		return "";
    }
    
    public static String getClassLoaderpath()
    {
    	return getClassLoaderpath("");
    }
    
    public static String getClassLoaderpath(String sName)
    {
    	String sPath = "";
    	ClassLoader loader = Thread.currentThread().getContextClassLoader();
    	
    	String osName = System.getProperty("os.name");
		boolean isWinOS = osName.startsWith("Windows");
		if(isWinOS)
		{
			sPath = loader.getResource(sName).getPath();
		}
		else
		{
			sPath = loader.getResource("").getPath();
			if(!"".equals(sName))
			{
				int idx = sPath.indexOf("WEB-INF");
				sPath = sPath.substring(0, idx) + sName.replaceAll("../../", "");
			}
		}
    	
    	return sPath;
    }
    
    public static String getPassword(String type) throws IOException
    {
    	FileReader fr = null;
		BufferedReader br = null;
		String password = "";
		
		try
		{
			File f = new File(getClassLoaderpath(), type);
			fr = new FileReader(f);
			br = new BufferedReader(fr);
			password = br.readLine();
		}
		finally
		{
			br.close();
			fr.close();
		}
		
		return password;
    }
    
    private static ArrayList<String[]> getControllerStages() throws Exception 
    {
    	if(CONTROLLER_STAGES == null)
    	{
    		DataQuery query = new DataQuery();
    		CONTROLLER_STAGES = query.getControllerStages();
    	}
    	return CONTROLLER_STAGES;
    }
    
    public static Map<String, ArrayList<String[]>> getControllerTypeStages() throws Exception 
    {
    	if(CONTROLLER_TYPE_STAGES == null)
    	{
    		CONTROLLER_TYPE_STAGES = new HashMap<String, ArrayList<String[]>>();
    		if(CONTROLLER_STAGES == null)
        	{
        		getControllerStages();
        	}

    		String cntrlType = null;
    		ArrayList<String[]> alStages = null;
        	for(int i=0; i<CONTROLLER_STAGES.size(); i++)
        	{
        		cntrlType = CONTROLLER_STAGES.get(i)[2];
        		
        		if(CONTROLLER_TYPE_STAGES.containsKey(cntrlType))
        		{
        			alStages = CONTROLLER_TYPE_STAGES.get(cntrlType);
        		}
        		else
        		{
        			alStages = new ArrayList<String[]>();
        		}
        		alStages.add(CONTROLLER_STAGES.get(i));
        		
        		CONTROLLER_TYPE_STAGES.put(cntrlType, alStages);
        	}
    	}
    	return CONTROLLER_TYPE_STAGES;
    }
    
    public static ArrayList<String[]> getControllerStages(String cntrlType) throws Exception 
    {
    	if(CONTROLLER_STAGES == null)
    	{
    		getControllerStages();
    	}
    	
    	ArrayList<String[]> alStages = new ArrayList<String[]>();
    	for(int i=0; i<CONTROLLER_STAGES.size(); i++)
    	{
    		if(cntrlType.equals(CONTROLLER_STAGES.get(i)[2]))
    		{
    			alStages.add(CONTROLLER_STAGES.get(i));
    		}
    	}
    	
    	return alStages;
    }
    
    public static String getStageName(String cntrlType, String stageSeq) throws Exception 
    {
    	if(CONTROLLER_STAGES == null)
    	{
    		getControllerStages();
    	}
    	
    	String sStgSeq = "";
		if(stageSeq.endsWith(".0"))
		{
			sStgSeq = stageSeq.substring(0, stageSeq.indexOf("."));
		}
		else
		{
			sStgSeq = stageSeq.replace('.', ' ');
		}

    	String[] saCntrlStgs = null;
    	for(int i=0; i<CONTROLLER_STAGES.size(); i++)
    	{
    		saCntrlStgs = CONTROLLER_STAGES.get(i);
    		if(cntrlType.equals(saCntrlStgs[2]) && (stageSeq.equals(saCntrlStgs[0]) || sStgSeq.equals(saCntrlStgs[0])))
    		{
    			return CONTROLLER_STAGES.get(i)[1];
    		}
    	}
    	
    	return "";
    }
    
    public static String[] getControllerStage(String cntrlType, String stageSeq) throws Exception 
    {
    	if(CONTROLLER_STAGES == null)
    	{
    		getControllerStages();
    	}
    	
    	String sStgSeq = "";
		if(stageSeq.endsWith(".0"))
		{
			sStgSeq = stageSeq.substring(0, stageSeq.indexOf("."));
		}
		else
		{
			sStgSeq = stageSeq.replace('.', ' ');
		}
    	
    	String[] saCntrlStgs = null;
    	for(int i=0; i<CONTROLLER_STAGES.size(); i++)
    	{
    		saCntrlStgs = CONTROLLER_STAGES.get(i);
    		if(cntrlType.equals(saCntrlStgs[2]) && (stageSeq.equals(saCntrlStgs[0]) || sStgSeq.equals(saCntrlStgs[0])))
    		{
    			return CONTROLLER_STAGES.get(i);
    		}
    	}
    	
    	return new String[]{"", "", ""};
    }
    
    public static String[] getCurrentPhase(String sController) throws Exception 
    {
    	DataQuery query = new DataQuery();
		String sPhase = query.getCurrentStage(sController);
		
		String cntrlType = getControllerType(sController);
		String sStageName = getStageName(cntrlType, sPhase);
		
		return new String[] {sPhase, sStageName};
    }
    
    public static Map<String, ParamSettings> getRoomsOverViewParamaters(String cntrlType) throws Exception 
    {
    	Map<String, ParamSettings> map = ROOMS_OVERVIEW_PARAMS.get(cntrlType);
    	if(map == null)
    	{
    		DataQuery query = new DataQuery();
    		map = query.getViewParameters(ROOMS_OVERVIEW, cntrlType);
    		
    		ROOMS_OVERVIEW_PARAMS.put(cntrlType, map);
    	}
    	return map;
    }
    
    public static Map<String, ParamSettings> getMultiRoomViewParamaters(String cntrlType) throws Exception 
    {
    	Map<String, ParamSettings> map = MULTI_ROOMVIEW_PARAMS.get(cntrlType);
    	if(map == null)
    	{
    		DataQuery query = new DataQuery();
    		map = query.getViewParameters(MULTIROOMS_VIEW, cntrlType);
    		
    		MULTI_ROOMVIEW_PARAMS.put(cntrlType, map);
    	}
    	return map;
    }
    
    public static Map<String, ParamSettings> getSingleRoomViewParamaters(String cntrlType) throws Exception 
    {
    	Map<String, ParamSettings> map = SINGLE_ROOMVIEW_PARAMS.get(cntrlType);
    	if(map == null)
    	{
    		DataQuery query = new DataQuery();
    		map = query.getSingleRoomViewParameters(cntrlType);
    		
    		SINGLE_ROOMVIEW_PARAMS.put(cntrlType, map);
    	}

    	return map;
    }
    
    public static Map<String, StringList> getSingleRoomViewParamHeaders(String cntrlType) throws Exception 
    {
    	Map<String, StringList> mParamHeaders = new HashMap<String, StringList>();
    	
    	Map<String, ParamSettings> mViewParams = getSingleRoomViewParamaters(cntrlType);    	
    	ArrayList<String> alParams = RDMServicesUtils.getDisplayOrder(cntrlType);
    	
    	Map<Integer, String> mDisplayHeaders = RDMServicesUtils.getHeaders(cntrlType);
    	ArrayList<Integer> alDisplayOrder = new ArrayList<Integer>();
    	alDisplayOrder.addAll(mDisplayHeaders.keySet());
    	Collections.sort(alDisplayOrder);
    	
    	boolean bDispOrd = false;
    	int iDispOrd = 0;
    	String sParam = null;
    	String sHeader = null;
    	StringList slParams = null;
    	ParamSettings paramSettings = null;
    	
    	for(int i=0; i<alParams.size(); i++)
		{
			sParam = (String)alParams.get(i);
			paramSettings = mViewParams.get(sParam);
			if(paramSettings == null)
			{
				continue;
			}

			bDispOrd = false;
			iDispOrd = paramSettings.getDisplayOrder();
			for(int n=alDisplayOrder.size()-1; n>=0; n--)
			{
				if(iDispOrd >= alDisplayOrder.get(n))
				{
					iDispOrd = alDisplayOrder.get(n);
					bDispOrd = true;
					break;
				}
			}

			sHeader = (bDispOrd ? mDisplayHeaders.get(iDispOrd) : "General");
				
			slParams = (mParamHeaders.containsKey(sHeader) ? mParamHeaders.get(sHeader) : new StringList());				
			slParams.add(sParam);
			mParamHeaders.put(sHeader, slParams);
		}

    	return mParamHeaders;
    }
    
    public static Map<String, ParamSettings> getGraphViewParamaters(String cntrlType) throws Exception
    {
    	Map<String, ParamSettings> map = GRAPH_VIEW_PARAMS.get(cntrlType);
    	if(map == null)
    	{
    		DataQuery query = new DataQuery();
    		map = query.getViewParameters(GRAPH_VIEW, cntrlType);
    		
    		GRAPH_VIEW_PARAMS.put(cntrlType, map);
    	}
    	return map;
    }
    
    public static Map<String, ParamSettings> getRoomImageParamaters(String cntrlType) throws Exception
    {
    	Map<String, ParamSettings> map = ROOM_IMAGEVIEW_PARAMS.get(cntrlType);
    	if(map == null)
    	{
    		DataQuery query = new DataQuery();
    		map = query.getViewParameters(SINGLEROOM_VIEW, cntrlType);
    		 
    		ROOM_IMAGEVIEW_PARAMS.put(cntrlType, map);
    	}
    	return map;
    }
    
    public static Map<String, ParamSettings> getGeneralViewParams(String cntrlType) throws Exception
	{
    	Map<String, ParamSettings> map = GENERAL_OVERVIEW_PARAMS.get(cntrlType);
    	if(map == null)
    	{
    		DataQuery query = new DataQuery();
    		map = query.getGeneralParamAdminSettings(cntrlType);
    		 
    		GENERAL_OVERVIEW_PARAMS.put(cntrlType, map);
    	}
    	return map;
	}
    
    public static ArrayList<String> getDisplayOrder(String cntrlType) throws Exception
	{
    	ArrayList<String> al = DISPLAY_ORDER.get(cntrlType);
    	if(al == null)
    	{
    		DataQuery query = new DataQuery();
    		if(cntrlType.startsWith("General"))
    		{
    			al = query.getGeneralParamDisplayOrder(cntrlType);
    		}
    		else
    		{
    			al = query.getDisplayOrder(cntrlType);
    		}
    		DISPLAY_ORDER.put(cntrlType, al);
    	}
    	return al;
	}
    
    public static Map<String, Integer> getGraphScale(String sCntrlType) throws Exception
	{
    	Map<String, Integer> map = GRAPH_SCALE.get(sCntrlType);
    	if(map == null)
    	{
    		DataQuery query = new DataQuery();
    		map = query.getGraphScale(sCntrlType);
    		
    		GRAPH_SCALE.put(sCntrlType, map);
    	}
    	return map;
	}
    
    public static StringList getParamGroup(String cntrlType) throws Exception
	{
    	StringList sl = PARAM_GROUPS.get(cntrlType);
    	if(sl == null)
    	{
    		DataQuery query = new DataQuery();
        	sl = query.getParamGroup(cntrlType);
        	
        	PARAM_GROUPS.put(cntrlType, sl);
    	}
    	return sl;
	}
    
    public static int getGraphYieldScale()
	{
    	int iYieldScale = 1;
    	try
    	{
    		String sYieldScale = getProperty("rdmservices.graph.yield.scale");
	    	if(sYieldScale != null && !"".equals(sYieldScale))
	    	{
	    		iYieldScale = Integer.parseInt(sYieldScale);
	    	}
    	}
    	catch(Exception e)
    	{
    		iYieldScale = 1;
    	}
    	return iYieldScale;
	}
    
    public static void setViewParamaters(String cntrlType) throws Throwable
    {
    	DataQuery query = new DataQuery();
    	boolean bIsNotGeneral = !cntrlType.startsWith("General");
    	
    	GRAPH_VIEW_PARAMS.put(cntrlType, query.getViewParameters(GRAPH_VIEW, cntrlType));
		GRAPH_SCALE.put(cntrlType, query.getGraphScale(cntrlType));
		
    	if(bIsNotGeneral)
    	{
    		DISPLAY_ORDER.put(cntrlType, query.getDisplayOrder(cntrlType)); 
    		ROOMS_OVERVIEW_PARAMS.put(cntrlType, query.getViewParameters(ROOMS_OVERVIEW, cntrlType));		
    		MULTI_ROOMVIEW_PARAMS.put(cntrlType, query.getViewParameters(MULTIROOMS_VIEW, cntrlType));
    		SINGLE_ROOMVIEW_PARAMS.put(cntrlType, query.getSingleRoomViewParameters(cntrlType));
    		ROOM_IMAGEVIEW_PARAMS.put(cntrlType, query.getViewParameters(SINGLEROOM_VIEW, cntrlType));
    		PARAM_COL_NAMES.put(cntrlType, query.getParamColNames(cntrlType));
    		PARAM_GROUPS.put(cntrlType, query.getParamGroup(cntrlType));
        	ON_OFF_VALUES.put(cntrlType, query.getOnOffParams(cntrlType));
        	RESET_VALUES.put(cntrlType, query.getResetParams(cntrlType));
    	}
    	else
    	{
    		DISPLAY_ORDER.put(cntrlType, query.getGeneralParamDisplayOrder(cntrlType));
    		ON_OFF_VALUES.put(cntrlType, query.getOnOffParams(cntrlType));
    		GENERAL_OVERVIEW_PARAMS.put(cntrlType, query.getGeneralParamAdminSettings(cntrlType));
    	}
    }

    public static MapList getUserList() throws Exception
	{
    	if(USER_LIST == null)
    	{
    		DataQuery query = new DataQuery();
    		USER_LIST = query.getUserList();
    	}
    	return USER_LIST;
	}
    
    public static Map<String, String> getUser(String userId) throws Exception
	{
    	MapList mlUsers = getUserList();

    	Map<String, String> mInfo = new HashMap<String, String>();
    	for(int i=0; i<mlUsers.size(); i++)
		{
			mInfo = mlUsers.get(i);
			if(userId.equals(mInfo.get(USER_ID)))
			{
				return mInfo;
			}
		}
    	
    	return null;
	}
    
    public static boolean updateUser(String userId, Map<String, String> mInfo) throws Exception
	{
    	DataQuery query = new DataQuery();
    	boolean b = query.updateUser(userId, mInfo);
    	USER_LIST = query.getUserList();
    	return b;
	}
    
    public static boolean addUser(Map<String, String> mInfo) throws Exception
	{
    	DataQuery query = new DataQuery();
    	boolean b = query.addUser(mInfo);
    	USER_LIST = query.getUserList();
    	return b;
	}
    
    public static boolean deleteUser(String userId) throws Exception
	{
    	DataQuery query = new DataQuery();
    	boolean b = query.deleteUser(userId);
    	USER_LIST = query.getUserList();
    	return b;
	}
    
    public static boolean blockUser(String userId) throws Exception
    {
    	DataQuery query = new DataQuery();
    	boolean b = query.updateUserStatus(userId, "Y");
		USER_LIST = query.getUserList();
		return b;
	}
    
    public static boolean unblockUser(String userId) throws Exception
    {
    	DataQuery query = new DataQuery();
    	boolean b = query.updateUserStatus(userId, "N");
		USER_LIST = query.getUserList();
		return b;
	}
    
    public static MapList getRoomsList() throws Exception
	{
    	if(CONTROLLER_ROOMS == null)
    	{
    		DataQuery query = new DataQuery();
    		CONTROLLER_ROOMS = query.getRoomsList();
    	}
    	return CONTROLLER_ROOMS;
	}
    
    public static boolean updateRoom(ServicesSession RDMSession, String roomId, Map<String, String> mInfo) throws Exception
	{
    	DataQuery query = new DataQuery();
    	boolean b = query.updateRoom(RDMSession, roomId, mInfo);
    	CONTROLLER_ROOMS = query.getRoomsList();
    	return b;
	}
    
    public static boolean addRoom(ServicesSession RDMSession, Map<String, String> mInfo) throws Exception
	{
    	DataQuery query = new DataQuery();
    	boolean b = query.addRoom(RDMSession, mInfo);
    	CONTROLLER_ROOMS = query.getRoomsList();
    	return b;
	}
    
    public static String getControllerType(String sRoom) throws Exception
	{
    	if(CONTROLLER_ROOMS == null)
    	{
    		getRoomsList();
    	}
    	
    	Map<String, String> mRoom = null;
    	for(int i=0; i<CONTROLLER_ROOMS.size(); i++)
    	{
    		mRoom = CONTROLLER_ROOMS.get(i);
    		if(sRoom != null && sRoom.equals(mRoom.get(ROOM_ID)))
    		{
    			return mRoom.get(CNTRL_TYPE);
    		}							
    	}
    	
    	return "";
	}
    
    public static StringList getTypeControllers(String sCntrlType) throws Exception
	{
    	if(CONTROLLER_ROOMS == null)
    	{
    		getRoomsList();
    	}
    	
    	Map<String, String> mRoom = null;
    	StringList slRooms = new StringList();
    	for(int i=0; i<CONTROLLER_ROOMS.size(); i++)
    	{
    		mRoom = CONTROLLER_ROOMS.get(i);
    		if(sCntrlType != null && sCntrlType.equals(mRoom.get(CNTRL_TYPE)))
    		{
    			slRooms.add(mRoom.get(ROOM_ID));
    		}							
    	}
    	
    	return slRooms;
	}
    
    public static boolean isGeneralController(String sRoom) throws Exception
	{
		return getControllerType(sRoom).startsWith("General");
	}
    
    public static MapList getStageList() throws Exception
	{
    	DataQuery query = new DataQuery();
    	return query.getStageList();
	}
    
    public static boolean updateStage(Map<String, String> mInfo) throws Exception
	{
    	DataQuery query = new DataQuery();
    	boolean b = query.updateStage(mInfo);
    	CONTROLLER_STAGES = query.getControllerStages();
    	return b;
	}
    
    public static boolean addStage(Map<String, String> mInfo) throws Exception
	{
    	DataQuery query = new DataQuery();
    	boolean b = query.addStage(mInfo);
    	CONTROLLER_STAGES = query.getControllerStages();
    	return b;
	}
    
    public static boolean deleteStage(String sStageId, String cntrlType) throws Exception
	{
    	DataQuery query = new DataQuery();
    	boolean b = query.deleteStage(sStageId, cntrlType);
    	CONTROLLER_STAGES = query.getControllerStages();
    	return b;
	}
    
    public static MapList getHeaders() throws Exception
	{
    	DataQuery query = new DataQuery();
    	return query.getHeaders();
	}
    
    public static Map<Integer, String> getHeaders(String cntrlType) throws Exception
	{
    	Map<Integer, String> map = GROUP_HEADERS.get(cntrlType);
    	if(map == null)
    	{
    		DataQuery query = new DataQuery();
    		map = query.getHeaders(cntrlType);
    		 
    		GROUP_HEADERS.put(cntrlType, map);
    	}
    	
    	return map;
	}
    
    public static boolean updateHeader(String cntrlType, Map<String, String> mInfo) throws Exception
	{
    	DataQuery query = new DataQuery();
    	boolean b = query.updateHeader(mInfo);
    	GROUP_HEADERS.put(cntrlType, query.getHeaders(cntrlType));
    	DISPLAY_PARAM_HEADERS.put(cntrlType, query.displayHeaders(cntrlType));
    	return b;
	}
    
    public static boolean addHeader(String cntrlType, Map<String, String> mInfo) throws Exception
	{
    	DataQuery query = new DataQuery();
    	boolean b = query.addHeader(mInfo);
    	GROUP_HEADERS.put(cntrlType, query.getHeaders(cntrlType));
    	DISPLAY_PARAM_HEADERS.put(cntrlType, query.displayHeaders(cntrlType));
    	return b;
	}
    
    public static boolean deleteHeader(String cntrlType, int iHeaderLoc) throws Exception
	{
    	DataQuery query = new DataQuery();
    	boolean b = query.deleteHeader(iHeaderLoc, cntrlType);
    	GROUP_HEADERS.put(cntrlType, query.getHeaders(cntrlType));
    	DISPLAY_PARAM_HEADERS.put(cntrlType, query.displayHeaders(cntrlType));
    	return b;
	}
    
    public static Map<String, String> displayHeaders(String cntrlType) throws Exception
	{
    	Map<String, String> map = DISPLAY_PARAM_HEADERS.get(cntrlType);
    	if(map == null)
    	{
    		DataQuery query = new DataQuery();
    		map = query.displayHeaders(cntrlType);
    		
    		DISPLAY_PARAM_HEADERS.put(cntrlType, map);
    	}

    	return map;
	}
	
    public static StringList getImageDisplayParams(String sParamKey, String sCntrlType)
    {
    	StringList slParams = new StringList();
    	
    	String sParams = getProperty("rdmservices."+sCntrlType+"." + sParamKey);
		String[] saParams = sParams.split(",");
    	
		for(int i=0; i<saParams.length; i++)
    	{
			slParams.add(saParams[i]);
    	}
    	return slParams;
    }
    
    public static Map<String, String[]> getParamColNames(String cntrlType) throws Exception
    {
    	Map<String, String[]> map = PARAM_COL_NAMES.get(cntrlType);
    	if(map == null)
    	{
    		DataQuery query = new DataQuery();
	    	map = query.getParamColNames(cntrlType);
	    	 
	    	PARAM_COL_NAMES.put(cntrlType, map);
	    }
	    
	    return map;
	}
    
    public static MapList getAdminTasks(boolean bRefresh) throws Exception
	{
    	if((ADMIN_TASKS == null) || bRefresh)
    	{
    		DataQuery query = new DataQuery();
    		ADMIN_TASKS = query.getAdminTasks();
    		
    		LIST_OF_TASKS = new HashMap<String, String>();
    		TASK_ALERT_DURATION = new HashMap<String, Integer>();
    		PRODUCTIVITY_TASKS = new StringList();
    		Map<String, String> mTask = null;
    		String sTaskId = null;
    		
    		for(int i=0; i<ADMIN_TASKS.size(); i++)
    		{
    			mTask = ADMIN_TASKS.get(i);
    			sTaskId = mTask.get(TASK_ID);
    			
    			LIST_OF_TASKS.put(sTaskId, mTask.get(TASK_NAME));
    			TASK_ALERT_DURATION.put(sTaskId, Integer.valueOf(mTask.get(DURATION_ALERT)));
    			
    			if("TRUE".equalsIgnoreCase(mTask.get(PRODUCTIVITY_TASK)))
				{
    				PRODUCTIVITY_TASKS.add(sTaskId);
				}
    		}
    	}
    	
    	return ADMIN_TASKS;
	}
    
    public static Map<String, String> listAdminTasks() throws Exception
	{
    	if(LIST_OF_TASKS == null)
    	{
    		getAdminTasks(false);
    	}
    	return LIST_OF_TASKS;
	}
    
    public static Map<String, Integer> getTaskAlertDuration() throws Exception
	{
    	if(TASK_ALERT_DURATION == null)
    	{
    		getAdminTasks(false);
    	}
    	return TASK_ALERT_DURATION;
	}
    
    public static StringList getProductivityTasks() throws Exception
	{
    	if(PRODUCTIVITY_TASKS == null)
    	{
    		getAdminTasks(false);
    	}
    	return PRODUCTIVITY_TASKS;
	}
    
    public static MapList getAdminTasks(String sUserDept) throws Exception
	{
    	StringList slUserDept = new StringList();
    	if(!"".equals(sUserDept))
    	{
    		if(sUserDept.contains("|"))
    		{
    			slUserDept = StringList.split(sUserDept, "\\|");
    		}
    		else 
    		{
    			slUserDept.add(sUserDept);
    		}
    	}
    	
    	return getAdminTasks(slUserDept);
	}
    
    public static MapList getAdminTasks(StringList slUserDept) throws Exception
	{
    	MapList mlTasks = getAdminTasks(false);
    	if(slUserDept.isEmpty())
    	{
    		return mlTasks;
    	}
    	
    	String sTaskDept = null;
    	StringList slTaskDept = null;
    	Map<String, String> mTask = null;
    	MapList mlAdminTasks = new MapList();
    	
    	for(int i=0; i<mlTasks.size(); i++)
    	{
    		mTask = mlTasks.get(i);
    		sTaskDept = mTask.get(DEPARTMENT_NAME);
    		
    		slTaskDept = StringList.split(sTaskDept, "\\|");
    		if("".equals(sTaskDept) || slTaskDept.contains(slUserDept))
    		{
    			mlAdminTasks.add(mTask);
    		}
    	}
    	
    	return mlAdminTasks;
	}
    
    public static MapList getCommentTasks(String sUserDept) throws Exception
	{
    	StringList slUserDept = new StringList();
    	if(!"".equals(sUserDept))
    	{
    		if(sUserDept.contains("|"))
    		{
    			slUserDept = StringList.split(sUserDept, "\\|");
    		}
    		else 
    		{
    			slUserDept.add(sUserDept);
    		}
    	}
    	
    	return getCommentTasks(slUserDept);
	}
    
	public static MapList getCommentTasks(StringList slUserDept) throws Exception
	{
		MapList mlTasks = getAdminTasks(false);
    	if(slUserDept.isEmpty())
    	{
    		return mlTasks;
    	}
    	
    	String sTaskDept = null;
    	StringList slTaskDept = null;
    	Map<String, String> mTask = null;
    	MapList mlAdminTasks = new MapList();
    	
    	for(int i=0; i<mlTasks.size(); i++)
    	{
    		mTask = mlTasks.get(i);
    		sTaskDept = mTask.get(DEPARTMENT_NAME);
    		
    		slTaskDept = StringList.split(sTaskDept, "\\|");
    		if("".equals(sTaskDept) || slTaskDept.contains(slUserDept))
    		{
    			mlAdminTasks.add(mTask);
    		}
    	}
    	
    	return mlAdminTasks;
	}
    
    public static Map<String, String> getAdminTask(String sTaskId) throws Exception
	{
    	Map<String, String> mTask = null;

    	MapList mlAdminTasks = getAdminTasks(false);
    	for(int i=0; i<mlAdminTasks.size(); i++)
    	{
    		mTask = mlAdminTasks.get(i);
    		if(sTaskId.equals(mTask.get(TASK_ID)))
    		{
    			return mTask;
    		}
    	}
    	
    	return null;
	}
    
    public static boolean addAdminTask(Map<String, String> mInfo) throws Exception
	{
    	DataQuery query = new DataQuery();
    	boolean b = query.addAdminTask(mInfo);
    	getAdminTasks(true);
    	return b;
	}
    
    public static boolean updateAdminTask(Map<String, String> mInfo) throws Exception
	{
    	DataQuery query = new DataQuery();
    	boolean b = query.updateAdminTask(mInfo);
    	getAdminTasks(true);
    	return b;
	}
    
    public static boolean deleteAdminTask(String sTaskId) throws Exception
	{
    	DataQuery query = new DataQuery();
    	boolean b = query.deleteAdminTask(sTaskId);
    	getAdminTasks(true);
    	return b;
	}
    
    private static void updateAttributeDetails() throws Exception
	{
    	Map<String, String> mInfo;
    	String sAttrName = null;
    	ATTRIBUTE_UNITS = new HashMap<String, String>();
    	MAX_WEIGHTS = new HashMap<String, String>();
    	YIELD_ATTRS = new StringList();
    	OVERAGE_ATTRS = new StringList();
    	
    	getAdminAttributes();
		for(int i=0; i<TASK_ATTRIBUTES.size(); i++)
		{
			mInfo = TASK_ATTRIBUTES.get(i);
			sAttrName = mInfo.get(ATTRIBUTE_NAME);
			
			ATTRIBUTE_UNITS.put(sAttrName, mInfo.get(ATTRIBUTE_UNIT));
			MAX_WEIGHTS.put(sAttrName, mInfo.get(MAX_WEIGHT));
			
			if(YIELD.equals(mInfo.get(CALCULATE)))
			{
				YIELD_ATTRS.add(sAttrName);
			}
			else if(OVERAGE.equals(mInfo.get(CALCULATE)))
			{
				OVERAGE_ATTRS.add(sAttrName);
			}
		}
	}

    public static Map<String, String> getAttributeUnits() throws Exception
	{
    	if(ATTRIBUTE_UNITS == null)
    	{
    		updateAttributeDetails();
    	}

		return ATTRIBUTE_UNITS;
	}

    public static Map<String, String> getMaxWeights() throws Exception
	{
    	if(MAX_WEIGHTS == null)
    	{
    		updateAttributeDetails();
    	}

		return MAX_WEIGHTS;
	}
    
    public static StringList getYieldAttributes() throws Exception
	{
    	if(YIELD_ATTRS == null)
    	{
    		updateAttributeDetails();
    	}

		return YIELD_ATTRS;
	}
    
    public static StringList getOverageAttributes() throws Exception
	{
    	if(OVERAGE_ATTRS == null)
    	{
    		updateAttributeDetails();
    	}

		return OVERAGE_ATTRS;
	}
    
    public static MapList getAdminAttributes() throws Exception
	{
    	if(TASK_ATTRIBUTES == null)
    	{
    		DataQuery query = new DataQuery();
    		TASK_ATTRIBUTES = query.getAdminAttributes();
    	}
    	
    	return TASK_ATTRIBUTES;
	}
    
    public static boolean addAdminAttribute(Map<String, String> mAttribute) throws Exception
	{
    	DataQuery query = new DataQuery();
    	boolean b = query.addAdminAttribute(mAttribute);
    	TASK_ATTRIBUTES = query.getAdminAttributes();
    	
    	updateAttributeDetails();

    	return b;
	}
    
    public static boolean updateAdminAttribute(Map<String, String> mAttribute) throws Exception
	{
    	DataQuery query = new DataQuery();
    	boolean b = query.updateAdminAttribute(mAttribute);
    	TASK_ATTRIBUTES = query.getAdminAttributes();
    	
    	updateAttributeDetails();
    	
    	String sAttrName = mAttribute.get(ATTRIBUTE_NAME);
		String sOldAttrName = mAttribute.get("OLD_ATTRIBUTE_NAME");
		if(!sAttrName.equals(sOldAttrName))
		{
			getAdminTasks(true);
		}
		
    	return b;
	}
    
    public static boolean deleteAdminAttribute(String sAttrName) throws Exception
	{
    	DataQuery query = new DataQuery();
    	boolean b = query.deleteAdminAttribute(sAttrName);
    	TASK_ATTRIBUTES = query.getAdminAttributes();
    	
    	updateAttributeDetails();
    	getAdminTasks(true);

    	return b;
	}
    
    public static MapList getAssigneeList(String sDept, boolean includeBlocked) throws Exception
	{
    	StringList slDept = new StringList();
    	if(!"".equals(sDept))
    	{
    		if(sDept.contains("|"))
    		{
    			slDept = StringList.split(sDept, "\\|");
    		}
    		else 
    		{
    			slDept.add(sDept);
    		}
    	}
    	
    	return getAssigneeList(slDept, includeBlocked);
	}
    
    public static MapList getAssigneeList(StringList slDept, boolean includeBlocked) throws Exception
	{
    	StringList slRoles = new StringList();
    	slRoles.add(ROLE_HELPER);
    	slRoles.add(ROLE_SUPERVISOR);
		
		return getUsers(slRoles, slDept, includeBlocked);
	}
    
    public static MapList getTaskOwners(String sDept, boolean includeBlocked) throws Exception
	{
    	StringList slDept = new StringList();
    	if(!"".equals(sDept))
    	{
    		if(sDept.contains("|"))
    		{
    			slDept = StringList.split(sDept, "\\|");
    		}
    		else 
    		{
    			slDept.add(sDept);
    		}
    	}
    	
    	return getTaskOwners(slDept, includeBlocked);
	}
    
    public static MapList getTaskOwners(StringList slDept, boolean includeBlocked) throws Exception
	{
    	StringList slRoles = new StringList();
    	slRoles.add(ROLE_SUPERVISOR);
		
		return getUsers(slRoles, slDept, includeBlocked);
	}
    
    public static MapList getManagers(String sDept, boolean includeBlocked) throws Exception
	{
    	StringList slDept = new StringList();
    	if(!"".equals(sDept))
    	{
    		if(sDept.contains("|"))
    		{
    			slDept = StringList.split(sDept, "\\|");
    		}
    		else 
    		{
    			slDept.add(sDept);
    		}
    	}
    	
    	return getManagers(slDept, includeBlocked);
	}
    
    public static MapList getManagers(StringList slDept, boolean includeBlocked) throws Exception
	{
    	StringList slRoles = new StringList();
    	slRoles.add(ROLE_MANAGER);
		
		return getUsers(slRoles, slDept, includeBlocked);
	}
    
    public static MapList getAdministrators(String sDept, boolean includeBlocked) throws Exception
	{
    	StringList slDept = new StringList();
    	if(!"".equals(sDept))
    	{
    		if(sDept.contains("|"))
    		{
    			slDept = StringList.split(sDept, "\\|");
    		}
    		else 
    		{
    			slDept.add(sDept);
    		}
    	}
    	
    	return getAdministrators(slDept, includeBlocked);
	}
    
    public static MapList getAdministrators(StringList slDept, boolean includeBlocked) throws Exception
	{
    	StringList slRoles = new StringList();
    	slRoles.add(ROLE_ADMIN);
		
		return getUsers(slRoles, slDept, includeBlocked);
	}
    
    public static MapList getUsers(String sRole, String sDept, boolean includeBlocked) throws Exception
	{
    	Map<String, String> mUser = null;
		MapList mlUsers = getUserList();
		MapList mlUserList = new MapList();
		boolean blocked = false;
		String sDepts = null;
		String sSecDept = null;
		StringList slUserDepts = null;
		StringList slDepts = StringList.split(sDept, "\\|");
		StringList slRoles = StringList.split(sRole, "\\|");
		
		for(int i=0; i<mlUsers.size(); i++)
		{
			mUser = mlUsers.get(i);
			blocked = ("Y".equals(mUser.get(BLOCKED)));
			
			if(!includeBlocked && blocked)
			{
				continue;
			}
			
			sDepts = mUser.get(RDMServicesConstants.DEPARTMENT_NAME);
			sSecDept = mUser.get(RDMServicesConstants.SEC_DEPARTMENT);
			if(!RDMServicesUtils.isNullOrEmpty(sSecDept))
			{
				sDepts += "|" + sSecDept;
			}
			slUserDepts = StringList.split(sDepts, "\\|");
			
			if((slRoles.contains(mUser.get(ROLE_NAME)) || "".equals(sRole))
				&& (slDepts.contains(slUserDepts) || "".equals(sDept)))
			{
				mlUserList.add(mUser);
			}
		}
		
		return mlUserList;
	}
    
    public static MapList getUsers(String sUserId, String sFName, String sLName, String sDept, boolean includeBlocked) throws Exception
	{
    	return getUsers(sUserId, sFName, sLName, sDept, includeBlocked, false);
	}
    
    public static MapList getUsers(String sUserId, String sFName, String sLName, String sDept, boolean includeBlocked, boolean isHRM) throws Exception
	{
    	Map<String, String> mUser = null;
		MapList mlUsers = getUserList();
		MapList mlUserList = new MapList();
		
		boolean blocked = false;
		boolean training = false;
		boolean mbUserId;
		boolean mbFName;
		boolean mbLName;
		boolean mbDept;
		boolean bUserId = "".equals(sUserId);
		boolean bFName = "".equals(sFName);
		boolean bLName = "".equals(sLName);
		boolean bDept = "".equals(sDept);
		boolean bNull = (bUserId && bFName && bLName && bDept);

		String msUserId;
		String msFName;
		String msLName;
		sUserId = sUserId.toLowerCase();
		sFName = sFName.toLowerCase();
		sLName = sLName.toLowerCase();
		String sDepts = null;
		String sSecDept = null;
		StringList slUserDepts = null;
		StringList slDepts = StringList.split(sDept, "\\|");
		
		for(int i=0; i<mlUsers.size(); i++)
		{
			mUser = mlUsers.get(i);
			
			msUserId = mUser.get(USER_ID).toLowerCase();
			msFName = mUser.get(FIRST_NAME).toLowerCase();
			msLName = mUser.get(LAST_NAME).toLowerCase();
			blocked = ("Y".equals(mUser.get(BLOCKED)));
			training = ("Y".equals(mUser.get(TRAINING)));
			
			if(!includeBlocked && blocked)
			{
				continue;
			}
			
			if(isHRM && !training)
			{
				continue;
			}
			
			mbUserId = true;
			if(!bUserId)
			{
				mbUserId = msUserId.contains(sUserId);
			}
			
			mbFName = true;
			if(!bFName)
			{
				mbFName = msFName.contains(sFName);
			}
			
			mbLName = true;
			if(!bLName)
			{
				mbLName = msLName.contains(sLName);
			}
			
			sDepts = mUser.get(RDMServicesConstants.DEPARTMENT_NAME);
			sSecDept = mUser.get(RDMServicesConstants.SEC_DEPARTMENT);
			if(!RDMServicesUtils.isNullOrEmpty(sSecDept))
			{
				sDepts += "|" + sSecDept;
			}
			slUserDepts = StringList.split(sDepts, "\\|");
			mbDept = (bDept || slUserDepts.contains(slDepts));
			
			if(bNull || (mbUserId && mbFName && mbLName && mbDept))
			{
				mlUserList.add(mUser);
			}
		}
		
		return mlUserList;
	}
    
    private static MapList getUsers(StringList slRoles, StringList slDepts, boolean includeBlocked) throws Exception
	{
    	Map<String, String> mUser = null;
		Map<String, String> mAssignee = null;
		MapList mlUsers = getUserList();
		MapList mlAssignees = new MapList();
		boolean blocked = false;
		String sRole = null;
		String sDepts = null;
		String sSecDept = null;
		StringList slUserDepts = null;
		
		for(int i=0; i<mlUsers.size(); i++)
		{
			mUser = mlUsers.get(i);
			sRole = mUser.get(ROLE_NAME);
			sDepts = mUser.get(RDMServicesConstants.DEPARTMENT_NAME);
			sSecDept = mUser.get(RDMServicesConstants.SEC_DEPARTMENT);
			if(!RDMServicesUtils.isNullOrEmpty(sSecDept))
			{
				sDepts += "|" + sSecDept;
			}
			slUserDepts = StringList.split(sDepts, "\\|");
			blocked = ("Y".equals(mUser.get(BLOCKED)));
			
			if(!includeBlocked && blocked)
			{
				continue;
			}

			if(slRoles.contains(sRole) && (slDepts.isEmpty() || slDepts.contains(slUserDepts)))
			{
				mAssignee = new HashMap<String, String>();
				mAssignee.put(USER_ID, mUser.get(USER_ID));
				mAssignee.put(DISPLAY_NAME, mUser.get(LAST_NAME)+", "+mUser.get(FIRST_NAME));
				
				mlAssignees.add(mAssignee);
			}
		}
		
		return mlAssignees;
	}
    
    public static Map<String, String> getUserNames() throws Exception
	{
    	return getUserNames(true);
	}
    
    public static Map<String, String> getUserNames(boolean includeBlocked) throws Exception
	{
    	Map<String, String> mUsers = new HashMap<String, String>();
		Map<String, String> mInfo = null;
		MapList mlUsers = getUserList();
		boolean blocked = false;
		
		for(int i=0; i<mlUsers.size(); i++)
		{
			mInfo = mlUsers.get(i);
			blocked = ("Y".equals(mInfo.get(BLOCKED)));
			
			if(!(!includeBlocked && blocked))
			{
				mUsers.put(mInfo.get(USER_ID), (mInfo.get(LAST_NAME)+", "+mInfo.get(FIRST_NAME)));
			}
		}
		
		return mUsers;
	}
    
    public static MapList getScalesList() throws Exception
	{
    	if(SCALE_LIST == null)
    	{
    		DataQuery query = new DataQuery();
    		SCALE_LIST = query.getScalesList();
    	}
    	return SCALE_LIST;
	}
    
    public static boolean updateScale(String scaleId, Map<String, String> mInfo) throws Exception
	{
    	DataQuery query = new DataQuery();
    	boolean bFlag = query.updateScale(scaleId, mInfo);
    	SCALE_LIST = query.getScalesList();
    	
    	return bFlag;
	}
    
    public static boolean addScale(Map<String, String> mInfo) throws Exception
	{
    	DataQuery query = new DataQuery();
    	boolean bFlag = query.addScale(mInfo);
    	SCALE_LIST = query.getScalesList();
    	
    	return bFlag;
	}
    
    public static boolean deleteScale(String scaleId) throws Exception
	{
    	DataQuery query = new DataQuery();
    	boolean bFlag = query.deleteScale(scaleId);
    	SCALE_LIST = query.getScalesList();
    	return bFlag;
	}
    
    public static Map<String, String> getDepartments() throws Exception
	{
    	if(ACTIVE_DEPTS == null)
    	{
    		getAllDepartments();
    	}
    	return ACTIVE_DEPTS;
	}
    
    public static MapList getAllDepartments() throws Exception
	{
    	if(DEPT_INFO == null)
    	{
    		DataQuery query = new DataQuery();
    		DEPT_INFO = query.getDepartments();
    		
    		ACTIVE_DEPTS = new HashMap<String, String>();
    		Map<String, String> mDept = null;    		
    		for(int i=0; i<DEPT_INFO.size(); i++)
    		{
    			mDept = DEPT_INFO.get(i);
    			if("Y".equals(mDept.get(DEPT_ISACTIVE)))
    			{
    				ACTIVE_DEPTS.put(mDept.get(DEPARTMENT_NAME), mDept.get(DESCRIPTION));
    			}
    		}
    	}
    	return DEPT_INFO;
	}
    
    public static boolean updateDepartment(Map<String, String> mInfo) throws Exception
	{
    	DataQuery query = new DataQuery();
    	boolean b = query.updateDepartment(mInfo);
    	
    	DEPT_INFO = null;
		ACTIVE_DEPTS = null;
		getAllDepartments();

    	return b;
	}
    
    public static boolean addDepartment(Map<String, String> mInfo) throws Exception
	{
    	DataQuery query = new DataQuery();
    	boolean b = query.addDepartment(mInfo);

    	DEPT_INFO = null;
		ACTIVE_DEPTS = null;
		getAllDepartments();

    	return b;
	}
    
    public static Map<String, Map<String, Object>> getUserViews() throws Exception
    {
    	if(USER_VIEWS == null)
    	{
    		DataQuery query = new DataQuery();
    		USER_VIEWS = query.getUserViews();
    	}
    	return USER_VIEWS;
	}
    
    public static void updateUserView(Map<String, String> mInfo) throws Exception
    {
    	DataQuery query = new DataQuery();
		query.updateUserView(mInfo);

		USER_VIEWS = query.getUserViews();
	}
    
    public static Map<String, Object> getViewAccess(String sView) throws Exception
    {
    	getUserViews();

    	Map<String, Object> mView = USER_VIEWS.get(sView);
    	mView = (mView == null ? new HashMap<String, Object>() : mView);
    	
    	return mView;
	}
    
    public static StringList getOnOffParams(String cntrlType) throws Exception
	{
		StringList sl = ON_OFF_VALUES.get(cntrlType);
    	if(sl == null)
    	{
    		DataQuery query = new DataQuery();
        	sl = query.getOnOffParams(cntrlType);
        	
        	ON_OFF_VALUES.put(cntrlType, sl);
    	}
    	return sl;
	}
    
    public static StringList getResetParams(String cntrlType) throws Exception
	{
		StringList sl = RESET_VALUES.get(cntrlType);
    	if(sl == null)
    	{
    		DataQuery query = new DataQuery();
        	sl = query.getResetParams(cntrlType);
        	
        	RESET_VALUES.put(cntrlType, sl);
    	}
    	return sl;
	}
    
    public static StringList getManualParams(String sCntrlType) throws Exception
	{
    	StringList slParams = MANUAL_PARAMS.get(sCntrlType);
    	if(slParams == null)
    	{
    		DataQuery query = new DataQuery();
    		slParams = query.getManualParams(sCntrlType);
    		
    		MANUAL_PARAMS.put(sCntrlType, slParams);
    	}
    	return slParams;
	}
    
    public static StringList getCoolingSteamParams(String sCntrlType) throws Exception
	{
    	StringList slParams = COOLING_STEAM_PARAMS.get(sCntrlType);
    	if(slParams == null)
    	{
    		DataQuery query = new DataQuery();
    		slParams = query.getCoolingSteamParams(sCntrlType);
    		
    		COOLING_STEAM_PARAMS.put(sCntrlType, slParams);
    	}
    	return slParams;
	}
    
    public static StringList getCompErrorParams(String sCntrlType) throws Exception
	{
    	StringList slErrorParams = COMP_ERROR_PARAMS.get(sCntrlType);
    	if(slErrorParams == null)
    	{
    		DataQuery query = new DataQuery();
    		slErrorParams = query.getCompErrorParams(sCntrlType);
    		
    		COMP_ERROR_PARAMS.put(sCntrlType, slErrorParams);
    	}
    	return slErrorParams;
	}
    
    public static Map<java.util.Date, Map<String, String[]>> getUserLogs() throws Exception
	{
    	DataQuery query = new DataQuery();
		return query.getUserLogs();
	}
    
    public static Map<String, String> getLogTime(String sOID) throws Exception
    {
    	DataQuery query = new DataQuery();
		return query.getLogTime(sOID);
	}
    
    public static Map<String, Map<String, MapList>> getTimesheets(Map<String, String> mInfo) throws Exception
    {
    	DataQuery query = new DataQuery();
		return query.getTimesheets(mInfo);
	}
    
    public static boolean updateTimesheet(String sUserId, String sOID, String sLogIn, String sLogOut, String shiftCode) throws Exception
    {
    	DataQuery query = new DataQuery();
    	
    	String sDate = sLogIn.substring(0, sLogIn.indexOf(' '));
		return query.updateTimesheet(sUserId, sOID, sDate, sLogIn, sLogOut, shiftCode);
    }
    
    public static boolean deleteTimesheet(String sUserId, String sOID) throws Exception
    {
    	DataQuery query = new DataQuery();
		return query.deleteTimesheet(sUserId, sOID);
    }
    
    public static String getProductType(String sController) throws Exception
    {
		DataQuery query = new DataQuery();
		return query.getProductType(sController);
    }
    
    public static String getBatchDefType(String sController, String sBatchNo) throws Exception
	{
		DataQuery qry = new DataQuery();
		return qry.getBatchDefType(sController, sBatchNo);
	}
    
    public static String getBatchNo(String sController) throws Exception
    {
		DataQuery query = new DataQuery();
		return query.getBatchNo(sController);
    }
    
    public static MapList getBatchNos(String sCntrlType, String sProductType) throws Exception
	{
    	DataQuery query = new DataQuery();
		return query.getBatchNos(sCntrlType, sProductType);
	}
    
    public static MapList getBatchNos(String sMonth, String sYear, String sCntrlType, String sProductType) throws Exception
	{
    	String sStartDt = sYear + "-" + RDMServicesConstants.CALENDAR_DAYS.get(sMonth)[0];
		String sEndDt = sYear + "-" + RDMServicesConstants.CALENDAR_DAYS.get(sMonth)[1];
		
		DataQuery query = new DataQuery();
		return query.getBatchLoad(sStartDt, sEndDt, sCntrlType, sProductType, false, true);
	}
    
    public static void addBatchNo(String rmId, String sBNo) throws Exception
	{
    	DataQuery query = new DataQuery();
		query.addBatchNo(rmId, sBNo, "");
	}
    
    public static void updateBatchNo(String rmId, String sBNo) throws Exception
	{
    	DataQuery query = new DataQuery();
		query.updateBatchNo(rmId, sBNo, "");
	}

    public static void closeBatchNo(String sController) throws Exception
	{
    	DataQuery query = new DataQuery();
		query.closeBatchNo(sController, null);
	}
    
    public static void readAdminSettingsFromCSV(String sCntrlType, String sFilePath) throws Throwable
	{
		DataQuery query = new DataQuery();
		query.readAdminSettingsFromCSV(sCntrlType, sFilePath);
	}
    
    public static Map<String, String> getAccountCredentials() throws Exception
	{
		DataQuery query = new DataQuery();
		return query.getAccountCredentials();
	}
    
    public static void setAccountCredentials(Map<String, String> mAcctCredentials) throws Exception
	{
		DataQuery query = new DataQuery();
		query.setAccountCredentials(mAcctCredentials);
	}
    
    public static MapList getUserActivityLog(String sFromDate, String sToDate) throws Exception
	{
		DataQuery query = new DataQuery();
		return query.getUserActivityLog(sFromDate, sToDate);
	}

    public static String timeToShortString(Date tm)
	{
		String sTime = "";
		SimpleDateFormat sdf = new SimpleDateFormat("HH:mm", Locale.getDefault());

		if (tm != null)
		{
			sTime = sdf.format(tm);
		}

		return sTime;
	}
	
	public static String dateToShortString(Date dt)
	{
		String sDate = "";
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd", Locale.getDefault());

		if (dt != null)
		{
			sDate = sdf.format(dt);
		}

		return sDate;
	}
	
	public static String dateToLongString(Date dt)
	{
		String sDate = "";
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss", Locale.getDefault());

		if (dt != null)
		{
			sDate = sdf.format(dt);
		}
		return sDate;
	}
	
    public static java.sql.Date getDate()
    {
    	DateFormat sqlDateFormatter = new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault());
    	
    	java.util.Date dt = new java.util.Date();
    	return java.sql.Date.valueOf(sqlDateFormatter.format(dt));
    }

    public static java.sql.Time getTime()
	{
		java.util.Date dt = new java.util.Date();
		return (new java.sql.Time(dt.getTime()));
	}
    
    public static StringList sort(StringList list)   
    {   
    	list.sort();  
    	return list;
    }
    
    public static StringList getSortedKeySet(Set<String> set)   
    {
	    String[] sArr = new String[set.size()];
	    
		StringList sl = new StringList();
		sl.addAll(set.toArray(sArr));
		sl.sort();
		
		return sl;
    }

    public static ArrayList<Date[]> getDateRangesBetween(String sStartDate, String sEndDate) throws ParseException 
	{
    	ArrayList<Date[]> datesBetween = new ArrayList<Date[]>();
    	
    	DateFormat dateformat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault());
		TimeZone tz = TimeZone.getDefault();
		dateformat.setTimeZone(tz);
    	
    	Calendar start = Calendar.getInstance(tz);
    	Date sdate = (Date)dateformat.parse(sStartDate);
    	start.setTime(sdate);
    	start.add(Calendar.HOUR_OF_DAY, -1);
    	
    	Calendar end = Calendar.getInstance(tz);
    	Date edate = (Date)dateformat.parse(sEndDate);
    	end.setTime(edate);
    	end.add(Calendar.HOUR_OF_DAY, -1);

    	boolean fg = true;
    	Date[] dateRange = null;
    	while (start.compareTo(end) < 0) 
    	{
    		dateRange = new Date[2];
    		dateRange[0] = start.getTime();
    		
    		if(fg)
    		{
    			start.add(Calendar.MINUTE, (60 - start.get(Calendar.MINUTE)));
    			start.add(Calendar.HOUR, (24 - start.get(Calendar.HOUR)));
    			fg = false;
    		}
    		else
    		{
    			start.add(Calendar.DATE, 1);
    		}
    		
    		if(start.compareTo(end) > 0)
    		{
    			dateRange[1] = end.getTime();
    		}
    		else
    		{
    			dateRange[1] = start.getTime();
    		}
    		
    		datesBetween.add(dateRange);
    	}
    	
    	return datesBetween;
	}
    
    public static ArrayList<String> getDatesBetween(String sStartDate, String sEndDate, String format) throws ParseException 
	{
    	ArrayList<String> datesBetween = new ArrayList<String>();
    	if("".equals(sStartDate))
    	{
    		sStartDate = sEndDate;
    	}
    	    	
    	SimpleDateFormat input = new SimpleDateFormat("dd-MM-yyyy", Locale.getDefault());
		SimpleDateFormat output = new SimpleDateFormat(format, Locale.getDefault());

    	Calendar start = Calendar.getInstance();
    	Date sdate = input.parse(sStartDate);
    	start.setTime(sdate);
    	
    	Calendar end = Calendar.getInstance();
    	Date edate = input.parse(sEndDate);
    	end.setTime(edate);

    	String dateRange = null;
    	while (start.compareTo(end) <= 0) 
    	{
    		dateRange = output.format(start.getTime());
    		datesBetween.add(dateRange);
    		
			start.add(Calendar.DATE, 1);
    	}
    	
    	return datesBetween;
	}
    
    public static String convertToSQLDate(String strDate) throws IOException, ParseException
	{
		SimpleDateFormat sdfSource = new SimpleDateFormat("dd-MM-yyyy", Locale.getDefault());
		SimpleDateFormat sdfDestination = new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault());
		
		Date date = sdfSource.parse(strDate);
		strDate = sdfDestination.format(date);
		
		return strDate;	
	}
    
    public static boolean checkConnectionIsAlive(String sControllerIP)
    {
    	try
    	{
		    URL url = new URL("http://" + sControllerIP);
		    HttpURLConnection connection = (HttpURLConnection) url.openConnection();
		    connection.setConnectTimeout(10000);
		    
		    if (connection.getResponseCode() == 200)
		    {
		        return true;
		    }
		    else 
		    {
		    	return false;
		    }
    	}
    	catch(Exception e)
    	{
    		return false;
    	}
    }
    
    public static long calculateDuration(String sStartTime, String sEndTime, SimpleDateFormat format)
	{
    	long lDuration = 0;		
		try
		{
			Date dtStart = null;
			Date dtEnd = null;
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault());
			
			if(sStartTime.isEmpty())
			{
				return 0;
			}
			
			try
			{
				dtStart = format.parse(sStartTime);
			}
			catch(Exception e)
			{
				dtStart = sdf.parse(sStartTime);
			}
		
			if(sEndTime.isEmpty())
			{
				Calendar cal = Calendar.getInstance();
				dtEnd = cal.getTime();
			}
			else
			{
				try
				{
					dtEnd = format.parse(sEndTime);
				}
				catch(Exception e)
				{
					dtEnd = sdf.parse(sEndTime);
				}
			}
			
			long diff = dtEnd.getTime() - dtStart.getTime();
			lDuration = (diff / (60 * 1000));
		}
		catch(ParseException pe)
		{
			//do nothing;
		}
		return lDuration;
	}
    
    public static String convert24to12Hr(String s)
    {
		try
		{
			s = s.replace('/', '-');
			
			SimpleDateFormat in = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss aa");
			SimpleDateFormat out = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    	
			return out.format(in.parse(s));
		}
		catch(ParseException pe)
		{
			return s;
		}
	}

    public static String join(String[] saValues, char c)
    {
    	StringBuilder sbValues = new StringBuilder();
		for(int i=0; i<saValues.length; i++)
		{
			if(i > 0)
			{
				sbValues.append(c);
			}
			sbValues.append(saValues[i]);
		}
		
		return sbValues.toString();
    }
    
    public static boolean isNullOrEmpty(String sValue)
    {
    	return (sValue == null || "".equals(sValue.trim()));
    }
}
