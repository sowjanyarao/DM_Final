package com.client.util;

import java.util.HashMap;
import java.util.Map;

public class RDMServicesConstants 
{
	public final static String DATABASE = "DATABASE";
	public final static String LICENSE = "LICENSE";

	public final static String PARAM_NAME = "PARAM_NAME";
	public final static String PARAM_GROUP = "PARAM_GROUP";
	public final static String PARAM_VALUE = "PARAM_VALUE";
	public final static String PARAM_UNIT = "PARAM_UNIT";
	public final static String MIN_PARAM_VALUE = "MIN_PARAM_VALUE";
	public final static String MAX_PARAM_VALUE = "MAX_PARAM_VALUE";
	
	public final static String DEFAULT_PRODUCT = "DEFAULT_PRODUCT";
	public final static String DISPLAY_ORDER = "DISPLAY_ORDER";
	public final static String STAGE_NAME = "STAGE_NAME";
	public final static String ROOMS_OVERVIEW = "ROOMS_OVERVIEW";
	public final static String MULTIROOMS_VIEW = "MULTIROOMS_VIEW";
	public final static String SINGLEROOM_VIEW = "SINGLEROOM_VIEW";
	public final static String GRAPH_VIEW = "GRAPH_VIEW";
	public final static String HELPER_READ = "HELPER_READ";
	public final static String HELPER_WRITE = "HELPER_WRITE";
	public final static String SUPERVISOR_READ = "SUPERVISOR_READ";
	public final static String SUPERVISOR_WRITE = "SUPERVISOR_WRITE";
	public final static String MANAGER_READ = "MANAGER_READ";
	public final static String MANAGER_WRITE = "MANAGER_WRITE";
	public final static String ADMIN_READ = "ADMIN_READ";
	public final static String ADMIN_WRITE = "ADMIN_WRITE";
	public final static String SCALE_ON_GRAPH = "SCALE_ON_GRAPH";
	public final static String ON_OFF_VALUE = "ON_OFF_VALUE";
	public final static String RESET_VALUE = "RESET_VALUE";
	
	public final static String ROLE_HELPER = "Helper";
	public final static String ROLE_SUPERVISOR = "Supervisor";
	public final static String ROLE_MANAGER = "Manager";
	public final static String ROLE_ADMIN = "Administrator";
	public final static String ROLE_TIMEKEEPER = "TimeKeeper";
	public final static String USER_SYSTEM = "SYSTEM";
	
	public final static String USER_ACCESS = "USER_ACCESS";
	public final static String ACCESS_NONE = "None";
	public final static String ACCESS_READ = "Read";
	public final static String ACCESS_WRITE = "Write";
	
	public final static String USER_ID = "USER_ID";
	public final static String PASSWORD = "PASSWORD";
	public final static String FIRST_NAME = "FIRST_NAME";
	public final static String LAST_NAME = "LAST_NAME";
	public final static String EMAIL = "EMAIL";
	public final static String ROLE_NAME = "ROLE_NAME";
	public final static String DISPLAY_NAME = "DISPLAY_NAME";
	public final static String GENDER = "GENDER";
	public final static String ADDRESS = "ADDRESS";
	public final static String DATE_OF_JOIN = "DATE_OF_JOIN";
	public final static String DATE_OF_BIRTH = "DATE_OF_BIRTH";
	public final static String CONTACT_NO = "CONTACT_NO";
	public final static String BLOCKED = "BLOCKED";
	public final static String HOME_PAGE = "HOME_PAGE";
	public final static String LOCALE = "LOCALE";
	public final static String TRAINING = "TRAINING";
	
	public final static String ACCEPTED_ON = "ACCEPTED";
	public final static String ACCEPTED_BY = "ACCEPTED_BY";
	public final static String MUTED_ON = "MUTED_ON";
	public final static String MUTED_BY = "MUTED_BY";
	public final static String CLEARED_ON = "CLEARED_ON";
	public final static String OCCURED_ON = "OCCURED_ON";
	public final static String SERIAL_ID = "SERIAL_ID";
	public final static String ALARM_TEXT = "TEXT";
	public final static String NOTIFY_ALARM = "NOTIFY_ALARM";
	public final static String LAST_NOTIFIED = "LAST_NOTIFIED";
	
	public final static String ROOM_ID = "RM_ID";
	public final static String ROOM_IP = "RM_IP";
	public final static String CNTRL_TYPE = "CNTRL_TYPE";
	public final static String ROOM_STATUS = "RM_STATUS";
	
	public final static String STAGE_NUMBER = "STAGE_NUMBER";
	public final static String STAGE_DESC = "STAGE_DESC";
	
	public final static String ACTIVE = "Active";
	public final static String INACTIVE = "Inactive";

	public final static String COMMENTS = "COMMENTS";
	public final static String COMMENT_ID = "CMT_ID";
	public final static String LOGGED_BY = "LOGGED_BY";
	public final static String LOGGED_ON = "LOGGED_ON";
	public final static String LOG_TEXT = "LOG_TEXT";
	public final static String GLOBAL_ALERT = "GLOBAL";
	public final static String CATEGORY = "CATEGORY";
	public final static String CLOSED_COMMENT = "CLOSED";
	public final static String REVIEW_COMMENTS = "REVIEW_COMMENTS";
	public final static String RUNNING_DAY = "RUNNING_DAY";

	public final static String TYPE_GROWER = "Grower";
	public final static String TYPE_BUNKER = "Bunker";
	public final static String TYPE_TUNNEL = "Tunnel";
	public final static String TYPE_GENERAL_GROWER = "General.Grower";
	public final static String TYPE_GENERAL_BUNKER = "General.Bunker";
	public final static String TYPE_GENERAL_TUNNEL = "General.Tunnel";
	public final static String CNTRL_DEF_TYPE = "CNTRL_DEF_TYPE";
	
	public final static String HEADER_NAME = "HEADER_NAME";
	public final static String HEADER_LOC = "HEADER_LOC";
	
	public final static String BATCH_NO = "BATCH_NO";
	public final static String START_DT = "START_DT";
	public final static String END_DT = "END_DT";
	public final static String DEF_VAL_TYPE = "DEF_VAL_TYPE";
	
	public final static String TASK_ID = "TASK_ID";
	public final static String TASK_NAME = "TASK_NAME";
	public final static String TASK_ATTRIBUTES = "TASK_ATTRIBUTES";
	public final static String DURATION_ALERT = "DURATION_ALERT";
	public final static String PRODUCTIVITY_TASK = "PRODUCTIVITY_TASK";
	
	public final static String ATTRIBUTE_NAME = "ATTRIBUTE_NAME";
	public final static String ATTRIBUTE_VALUE = "ATTRIBUTE_VALUE";
	public final static String ATTRIBUTE_UNIT = "ATTRIBUTE_UNIT";
	public final static String MAX_WEIGHT = "MAX_WEIGHT";
	public final static String READ_WEIGHTS = "READ_WEIGHTS";
	public final static String TARE_WEIGHT = "TARE_WEIGHT";
	public final static String CALCULATE = "CALCULATE";
	public final static String YIELD = "YIELD";
	
	public final static String ON_DATE = "ON_DATE";
	public final static String DAILY_YIELD = "DAILY_YIELD";
	public final static String EST_YIELD = "EST_YIELD";
	
	public final static String RULE_EXPRESSION = "RULE_EXPRESSION";
	public final static String RULE_EXECUTE = "RULE_EXECUTE";
	public final static String RULE_OID = "RULE_OID";
	public final static String RULE_DESCRIPTION = "RULE_DESC";
	
	public static final String TASK_AUTONAME = "TASK_AUTONAME";
	public static final String NOTES = "NOTES";
	public static final String STATUS = "STATUS";
	public static final String OWNER = "OWNER";
	public static final String CO_OWNERS = "CO_OWNERS";
	public static final String ASSIGNEE = "ASSIGNEE";
	public static final String CREATED_BY = "CREATED_BY";
	public static final String ESTIMATED_START = "ESTIMATED_START";
	public static final String ESTIMATED_END = "ESTIMATED_END";
	public static final String ACTUAL_START = "ACTUAL_START";
	public static final String ACTUAL_END = "ACTUAL_END";
	public static final String PARENT_TASK = "PARENT_TASK";
	public static final String TASK_WBS_LEVEL = "TASK_WBS_LEVEL";
	public static final String WBS_TASKS = "WBS_TASKS";
	public static final String HAS_CHILD_TASKS = "HAS_CHILD_TASKS";
	public static final String SYSTEM_LOG = "SYSTEM_LOG";
	public static final String DELIVERABLE_CNT = "DELIVERABLE_CNT";
	public static final String CREATED_ON = "CREATED_ON";
	public static final String DELIVERABLE_ID = "DELIVERABLE_ID";
	public static final String NO_CHILD_TASKS = "NO_CHILD_TASKS";
	public static final String NO_CHILD_TASKS_CLOSED = "NO_CHILD_TASKS_CLOSED";
	public static final String DOWNLOAD_FLAG = "DOWNLOAD_FLAG";
	public static final String DOWNLOAD_BY = "DOWNLOAD_BY";
	public static final String DOWNLOAD_ON = "DOWNLOAD_ON";
	public static final String NOT_DOWNLOADED = "NOT_DOWNLOADED";
	public static final String TASK_DELIVERABLES = "TASK_DELIVERABLES";
	public static final String DURATION = "DURATION";
	public static final String PRODUCTIVITY = "PRODUCTIVITY";
	public static final String OVERAGE = "OVERAGE";
	public static final String FIRST_DELIVERABLE_CREATED_ON = "FIRST_DELIVERABLE_CREATED_ON";
	public static final String LAST_DELIVERABLE_CREATED_ON = "LAST_DELIVERABLE_CREATED_ON";
	public static final String ATTACHMENTS = "ATTACHMENTS";
	
	public final static String TASK_STATUS_NOT_STARTED = "Not Started";
	public final static String TASK_STATUS_STARTED = "Started";
	public final static String TASK_STATUS_WIP = "WIP";
	public final static String TASK_STATUS_OPEN = "OPEN";
	public final static String TASK_STATUS_WIP_25 = "WIP (25%)";
	public final static String TASK_STATUS_WIP_50 = "WIP (50%)";
	public final static String TASK_STATUS_WIP_75 = "WIP (75%)";
	public final static String TASK_STATUS_COMPLETED = "Completed";
	public final static String TASK_STATUS_CANCELLED = "Cancelled";
	public final static String TASK_PRODUCTIVITY = "TASK_PRODUCTIVITY";

	public final static String SCALE_ID = "SCALE_ID";
	public final static String SCALE_IP = "SCALE_IP";
	public final static String SCALE_PORT = "SCALE_PORT";
	public final static String SCALE_STATUS = "STATUS";
	
	public final static String DEPARTMENT_NAME = "DEPARTMENT_NAME";
	public final static String SEC_DEPARTMENT = "SEC_DEPARTMENT";
	public final static String DESCRIPTION = "DESCRIPTION";
	public final static String DEPT_ISACTIVE = "ISACTIVE";
	
	public final static String VIEW_NAME = "VIEW_NAME";
	public final static String DEPT_NAME = "DEPT_NAME";
	public final static String HIDE_VIEW = "HIDE_VIEW";
	
	public final static String HOME = "HOME";
	public final static String SHORTLINKS = "SHORTLINKS";
	public final static String ACTIONS_CREATE_TASK = "ACTIONS.CREATE.TASK";
	public final static String ACTIONS_UPDATE_BNO = "ACTIONS.UPDATE.BNO";
	public final static String ROOMS_VIEW_DASHBOARD_GROWER = "ROOMSVIEW.DASHBOARD.GROWER";
	public final static String ROOMS_VIEW_DASHBOARD_BUNKER = "ROOMSVIEW.DASHBOARD.BUNKER";
	public final static String ROOMS_VIEW_DASHBOARD_TUNNEL= "ROOMSVIEW.DASHBOARD.TUNNEL";
	public final static String ROOMS_VIEW_SINGLE_ROOM = "ROOMSVIEW.SINGLEROOM";
	public final static String ROOMS_VIEW_MULTI_ROOM_GROWER = "ROOMSVIEW.MULTIROOM.GROWER";
	public final static String ROOMS_VIEW_MULTI_ROOM_BUNKER = "ROOMSVIEW.MULTIROOM.BUNKER";
	public final static String ROOMS_VIEW_MULTI_ROOM_TUNNEL = "ROOMSVIEW.MULTIROOM.TUNNEL";
	public final static String VIEWS_GRAPH_ATTRDATA = "VIEWS.GRAPH.ATTRDATA";
	public final static String VIEWS_GRAPH_PRODUCTIVITY = "VIEWS.GRAPH.PRODUCTIVITY";
	public final static String VIEWS_GRAPH_BATCHLOAD = "VIEWS.GRAPH.BATCHLOAD";
	public final static String VIEWS_ALARMS = "VIEWS.ALARMS";
	public final static String VIEWS_LOGS = "VIEWS.LOGS";
	public final static String VIEWS_COMMENTS = "VIEWS.COMMENTS";
	public final static String VIEWS_TASKS = "VIEWS.TASKS";
	public final static String VIEWS_YIELDS = "VIEWS.YIELDS";
	public final static String VIEWS_REPORTS = "VIEWS.REPORTS";
	public final static String VIEWS_TIMESHEETS = "VIEWS.TIMESHEETS";
	public final static String VIEWS_PRODUCTIVITY = "VIEWS.PRODUCTIVITY";
	
	public final static String NO_ROOM = "NO_ROOM";
	public final static String NO_USER = "NO_USER";
	public final static String NO_DEPT = "NO_DEPT";
	public final static String NO_DATE = "NO_DATE";
	public final static String ROOM_BASED = "ROOM_BASED";
	public final static String USER_BASED = "USER_BASED";
	public final static String DATE_BASED = "DATE_BASED";
	
	public final static String OID = "oid"; 
	public final static String LOG_DATE = "LOG_DATE";
	public final static String LOG_IN = "LOG_IN";
	public final static String LOG_OUT = "LOG_OUT";
	public final static String DEPT_IN = "DEPT_IN";
	public final static String DEPT_OUT = "DEPT_OUT";
	public final static String SHIFT_CODE = "SHIFT_CODE";
	public final static String T_DEL_QTY = "T_DEL_QTY";
	public final static String PRODUCTIVE_HRS = "PRODUCTIVE_HRS";
	public final static String T_DAYS = "T_DAYS";
	
	public final static String ALARM = "ALARM";
	public final static String NOTIFY_BY = "NOTIFY_BY";
	public final static String NOTIFY_SMS = "SMS";
	public final static String NOTIFY_CALL = "CALL";
	public final static String NOTIFY_DURATION = "NOTIFY_DURATION";
	public final static String NOTIFY_LEVEL1 = "NOTIFY_LEVEL1";
	public final static String NOTIFY_LEVEL2 = "NOTIFY_LEVEL2";
	public final static String NOTIFY_LEVEL3 = "NOTIFY_LEVEL3";
	public final static String LEVEL1_ATTEMPTS = "LEVEL1_ATTEMPTS";
	public final static String LEVEL2_ATTEMPTS = "LEVEL2_ATTEMPTS";
	public final static String LEVEL3_ATTEMPTS = "LEVEL3_ATTEMPTS";
	
	public final static String REPORT = "REPORT";
	public final static String TEMPLATE = "TEMPLATE";
	public final static String COLUMN_KEY = "COLUMN_KEY";
	public final static String COLUMN_HEADER = "COLUMN_HEADER";
	public final static String COLUMN_FORMULA = "COLUMN_FORMULA";
	public final static String COLUMN_RANGES = "COLUMN_RANGES";
	public final static String SEARCH_COLUMNS = "SEARCH_COLUMNS";
	public final static String HEADER_ROW = "HEADER_ROW";
	public final static String FORMULA_ROW = "FORMULA_ROW";
	public final static String RANGES_ROW = "RANGES_ROW";
	public final static String CALC_BASED_ON = "CALC_BASED_ON";
	public final static String EDITABLE_ROW = "EDITABLE_ROW";
	public final static String READ_ONLY_COLUMN = "READ_ONLY_COLUMN";
	public final static String READ_ACCESS = "READ_ACCESS";
	public final static String WRITE_ACCESS = "WRITE_ACCESS";
	public final static String MODIFY_ACCESS = "MODIFY_ACCESS";
	public final static String READ_DEPT = "READ_DEPT";
	public final static String WRITE_DEPT = "WRITE_DEPT";
	public final static String MODIFY_DEPT = "MODIFY_DEPT";
	public final static String ALLOW_MULTIPLE_UPDATES = "ALLOW_MULTIPLE_UPDATES";
	public final static String IS_UPDATED = "IS_UPDATED";
	
	public static final String BASEDON = "#BasedOn";
	public static final String REMARKS = "Remarks";
	public static final String LOGGEDBY = "Logged By";
	public static final String MODIFIEDBY = "Modified By";	
	public static final String MODIFIEDON = "Modified On";	
	
	public final static String CNTRL_UID = "CNTRL_UID";
	public final static String CNTRL_PWD = "CNTRL_PWD";
	public final static String ACCT_SID = "ACCT_SID";
	public final static String AUTH_CODE = "AUTH_CODE";
	public final static String REG_NUMBER = "REG_NUMBER";
	public final static String MAIL_HOST = "MAIL_HOST";
	public final static String MAIL_PORT = "MAIL_PORT";
	public final static String FROM_ADDRESS = "FROM_ADDRESS";
	public final static String MAILID_PWD = "MAILID_PWD";
	public final static String BACKUP_PATH = "BACKUP_PATH";
	public final static String ACCT_KEY_NAME = "ACCT_KEY_NAME";
	public final static String ACCT_KEY_VAL = "ACCT_KEY_VAL";
	
	public final static String USER_IP = "USER_IP";

	public final static Map<String, String> SET_PARAMS = new HashMap<String, String>();
	static
	{
		SET_PARAMS.put("set CO2", "ppm");
		SET_PARAMS.put("set comp temp", "Deg. C");
		SET_PARAMS.put("set rH", "%rH");
		SET_PARAMS.put("set temp", "Deg. C");
		SET_PARAMS.put("set O2", "%");
		SET_PARAMS.put("set fan", "%");
	}

	public final static Map<String, String[]> CALENDAR_DAYS = new HashMap<String, String[]>();
	static
	{
		CALENDAR_DAYS.put("Jan", new String[]{"01-01", "01-31"});
		CALENDAR_DAYS.put("Feb", new String[]{"02-01", "02-28"});
		CALENDAR_DAYS.put("Mar", new String[]{"03-01", "03-31"});
		CALENDAR_DAYS.put("Apr", new String[]{"04-01", "04-30"});
		CALENDAR_DAYS.put("May", new String[]{"05-01", "05-31"});
		CALENDAR_DAYS.put("Jun", new String[]{"06-01", "06-30"});
		CALENDAR_DAYS.put("Jul", new String[]{"07-01", "07-31"});
		CALENDAR_DAYS.put("Aug", new String[]{"08-01", "08-31"});
		CALENDAR_DAYS.put("Sep", new String[]{"09-01", "09-30"});
		CALENDAR_DAYS.put("Oct", new String[]{"10-01", "10-31"});
		CALENDAR_DAYS.put("Nov", new String[]{"11-01", "11-30"});
		CALENDAR_DAYS.put("Dec", new String[]{"12-01", "12-31"});
	}
}
