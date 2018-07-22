package com.client.util;

import java.util.HashMap;
import java.util.Map;

public class ParamSettings
{
	private String PARAM_NAME = "";
	private int DISPLAY_ORDER = -1;
	private String STAGE_NAME = "";
	private String ON_OFF_VALUE = "";
	private String RESET_VALUE = "";
	private String PARAM_GROUP = "";
	private String HELPER_ACCESS = "";
	private String SUPERVISOR_ACCESS = "";
	private String MANAGER_ACCESS = "";
	private String ADMIN_ACCESS = "";
	private String ROOMS_OVERVIEW = "";
	private String MULTIROOMS_VIEW = "";
	private String SINGLEROOM_VIEW = "";
	private String GRAPH_VIEW = "";
	private String HELPER_READ = "";
	private String HELPER_WRITE = "";
	private String SUPERVISOR_READ = "";
	private String SUPERVISOR_WRITE = "";
	private String MANAGER_READ = "";
	private String MANAGER_WRITE = "";
	private String ADMIN_READ = "";
	private String ADMIN_WRITE = "";
	private int SCALE_ON_GRAPH = 1;
	private String PARAM_UNIT = "";
	
	private Map<String, ParamSettings> mGrpParams = new HashMap<String, ParamSettings>();
	
	public ParamSettings(String s)
	{
		this.PARAM_NAME = s;
	}
	
	public void setDisplayOrder(int i)
	{
		this.DISPLAY_ORDER = i;
	}
	
	public void setStage(String s)
	{
		this.STAGE_NAME = s;
	}
	
	public void setParamGroup(String s)
	{
		this.PARAM_GROUP = s;
	}
	
	public void setOnOffValue(String s)
	{
		this.ON_OFF_VALUE = s;
	}
	
	public void setResetValue(String s)
	{
		this.RESET_VALUE = s;
	}
	
	public void setHelperAccess(String s)
	{
		this.HELPER_ACCESS = s;
	}
	
	public void setSupervisorAccess(String s)
	{
		this.SUPERVISOR_ACCESS = s;
	}
	
	public void setManagerAccess(String s)
	{
		this.MANAGER_ACCESS = s;
	}
	
	public void setAdminAccess(String s)
	{
		this.ADMIN_ACCESS = s;
	}
	
	public void setRoomsOverview(String s)
	{
		this.ROOMS_OVERVIEW = s;
	}
	
	public void setMultiRoomView(String s)
	{
		this.MULTIROOMS_VIEW = s;
	}
	
	public void setSingleRoomView(String s)
	{
		this.SINGLEROOM_VIEW = s;
	}
	
	public void setGraphView(String s)
	{
		this.GRAPH_VIEW = s;
	}
	
	public void setHelperRead(String s)
	{
		this.HELPER_READ = s;
	}
	
	public void setHelperWrite(String s)
	{
		this.HELPER_WRITE = s;
	}
	
	public void setSupervisorRead(String s)
	{
		this.SUPERVISOR_READ = s;
	}
	
	public void setSupervisorWrite(String s)
	{
		this.SUPERVISOR_WRITE = s;
	}
	
	public void setManagerRead(String s)
	{
		this.MANAGER_READ = s;
	}
	
	public void setManagerWrite(String s)
	{
		this.MANAGER_WRITE = s;
	}
	
	public void setAdminRead(String s)
	{
		this.ADMIN_READ = s;
	}
	
	public void setAdminWrite(String s)
	{
		this.ADMIN_WRITE = s;
	}
	
	public void setScaleOnGraph(int i)
	{
		this.SCALE_ON_GRAPH = i;
	}
	
	public void setParamUnit(String s)
	{
		this.PARAM_UNIT = s;
	}
	
	public String getParamName()
	{
		return this.PARAM_NAME;
	}
	
	public int getDisplayOrder()
	{
		return this.DISPLAY_ORDER;
	}
	
	public String getStage()
	{
		return this.STAGE_NAME;
	}
	
	public String getParamGroup()
	{
		return this.PARAM_GROUP;
	}
	
	public String getOnOffValue()
	{
		return this.ON_OFF_VALUE;
	}
	
	public String getResetValue()
	{
		return this.RESET_VALUE;
	}
	
	public String getHelperAccess()
	{
		return this.HELPER_ACCESS;
	}
	
	public String getSupervisorAccess()
	{
		return this.SUPERVISOR_ACCESS;
	}
	
	public String getManagerAccess()
	{
		return this.MANAGER_ACCESS;
	}
	
	public String getAdminAccess()
	{
		return this.ADMIN_ACCESS;
	}
	
	public String getRoomsOverview()
	{
		return this.ROOMS_OVERVIEW;
	}
	
	public String getMultiRoomView()
	{
		return this.MULTIROOMS_VIEW;
	}
	
	public String getSingleRoomView()
	{
		return this.SINGLEROOM_VIEW;
	}
	
	public String getGraphView()
	{
		return this.GRAPH_VIEW;
	}
	
	public String getHelperRead()
	{
		return this.HELPER_READ;
	}
	
	public String getHelperWrite()
	{
		return this.HELPER_WRITE;
	}
	
	public String getSupervisorRead()
	{
		return this.SUPERVISOR_READ;
	}
	
	public String getSupervisorWrite()
	{
		return this.SUPERVISOR_WRITE;
	}
	
	public String getManagerRead()
	{
		return this.MANAGER_READ;
	}
	
	public String getManagerWrite()
	{
		return this.MANAGER_WRITE;
	}
	
	public String getAdminRead()
	{
		return this.ADMIN_READ;
	}
	
	public String getAdminWrite()
	{
		return this.ADMIN_WRITE;
	}
	
	public int getScaleOnGraph()
	{
		return this.SCALE_ON_GRAPH;
	}
	
	public String getParamUnit()
	{
		return this.PARAM_UNIT;
	}
	
	public void setGroupParams(String s, ParamSettings p)
	{
		this.mGrpParams.put(s, p);
	}
	
	public ParamSettings getGroupParams(String s)
	{
		if(this.mGrpParams.containsKey(s))
		{
			return this.mGrpParams.get(s);
		}
		
		return null;
	}
	
	public boolean hasGroupParams()
	{
		if(this.mGrpParams.size() > 0 && !this.mGrpParams.isEmpty())
		{
			return true;
		}
		return false;
	}
}
