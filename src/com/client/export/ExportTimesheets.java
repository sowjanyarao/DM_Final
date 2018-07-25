package com.client.export;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.TreeMap;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;

import com.client.util.MapList;
import com.client.util.RDMServicesConstants;
import com.client.util.RDMServicesUtils;

public class ExportTimesheets extends HttpServlet
{
	private static final long serialVersionUID = 1L;
	
	private static final SimpleDateFormat sdfIn = new SimpleDateFormat("yyyy-MM-dd HH:mm");
	private static final SimpleDateFormat sdfOut = new SimpleDateFormat("dd-MMM-yyyy hh:mm a");

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
	{
		doPost(request, response);
	}
	
	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
	{
		FileInputStream fileInputStream = null;
		PrintWriter out = null;
		try
		{
			out = response.getWriter();
			
			File file = writeToExcel(request);
			fileInputStream = new FileInputStream(file);
			
			response.setHeader("Content-Type", "application/octet-stream");
			response.setHeader("Content-Disposition","attachment; filename=\"" + file.getName() + "\"");
			
			int i;
			while ((i = fileInputStream.read()) != -1)
			{
				out.write(i); 
			}
		}
		catch(Exception e)
		{
			e.printStackTrace(System.out);
		}
		finally
		{
			if(fileInputStream != null)
			{
				fileInputStream.close();
			}
			if(out != null)
			{
				out.close();
			}
		}
	}
	
	private Map<String, Map<String, MapList>> getTimesheets(HttpServletRequest request) throws Exception
	{
		String sUserId = request.getParameter("userId");
		String FName = request.getParameter("FName");
		String LName = request.getParameter("LName");
		String sDept = request.getParameter("dept");
		String start_date = request.getParameter("start_date");
		String end_date = request.getParameter("end_date");
		String loggedIn = request.getParameter("loggedIn");
		String loggedOut = request.getParameter("loggedOut");
		String isHRM = request.getParameter("isHRM");

		Map<String, String> mInfo = new HashMap<String, String>();
		mInfo.put(RDMServicesConstants.USER_ID, sUserId);
		mInfo.put(RDMServicesConstants.FIRST_NAME, FName);
		mInfo.put(RDMServicesConstants.LAST_NAME, LName);
		mInfo.put(RDMServicesConstants.DEPT_NAME, sDept);
		mInfo.put("fromDate", start_date);
		mInfo.put("endDate", end_date);
		mInfo.put("loggedIn", loggedIn);
		mInfo.put("loggedOut", loggedOut);
		mInfo.put("isHRM", isHRM);
			
		return  RDMServicesUtils.getTimesheets(mInfo);
	}
	
	private File writeToExcel(HttpServletRequest request) throws Exception 
	{
		String filepath = "";
		try{
			filepath = RDMServicesUtils.getClassLoaderpath("../../export");		
		}catch(Exception e) {
			filepath = RDMServicesUtils.getClassLoaderpath("");		
		}
		File file = File.createTempFile("ExportTimesheetsData", ".xls", new File(filepath));
		file.setReadable(true, false);
		file.setWritable(true, false);
		file.setExecutable(true, false);
		file.deleteOnExit();
		
		Map<String, Map<String, MapList>> mUserLogs = getTimesheets(request);
		
		HSSFWorkbook workbook = new HSSFWorkbook();
		HSSFSheet sheet = workbook.createSheet("Employee Timesheets");
		
		addHeaders(sheet);
		addTimesheets(sheet, mUserLogs);
		
	    FileOutputStream out = new FileOutputStream(file);
	    workbook.write(out);
	    out.close();
		     
		return file;
	}
	
	private void addHeaders(HSSFSheet sheet)
	{
		Row row = sheet.createRow(0);
		
		Cell cell = row.createCell(0);
		cell.setCellValue("Employee No");
		
		cell = row.createCell(1);
		cell.setCellValue("Employee Name");
		
		cell = row.createCell(2);
		cell.setCellValue("Department");
		
		cell = row.createCell(3);
		cell.setCellValue("Shift Code");

		cell = row.createCell(4);
		cell.setCellValue("SwipeIN_Date");
		
		cell = row.createCell(5);
		cell.setCellValue("Swipe_IN_Hrs\n(In 24 Hr Format)");
		
		cell = row.createCell(6);
		cell.setCellValue("Swipe_IN_Min");
		
		cell = row.createCell(7);
		cell.setCellValue("SwipeOUT_Date");
		
		cell = row.createCell(8);
		cell.setCellValue("Swipe_OUT_Hrs\n(In 24 Hr Format)");
		
		cell = row.createCell(9);
		cell.setCellValue("Swipe_OUT_Min");
		
		cell = row.createCell(10);
		cell.setCellValue("Department In");
		
		cell = row.createCell(11);
		cell.setCellValue("Department Out");
		
		cell = row.createCell(12);
		cell.setCellValue("Productivity");
		
		cell = row.createCell(13);
		cell.setCellValue("Gate Duration");
		
		cell = row.createCell(14);
		cell.setCellValue("Dept Duration");
		
		cell = row.createCell(15);
		cell.setCellValue("Over Time");
		
		cell = row.createCell(16);
		cell.setCellValue("Attendance Status");
	}
	
	private void addTimesheets(HSSFSheet sheet, Map<String, Map<String, MapList>> mUserLogs) throws Exception
	{
		int rownum = 1;
		Row row = null;
		Cell cell = null;
		
		String sUserId = null;
		String sInDate = null;
		String sOutDate = null;
		String sTime = null;
		String sInTimestamp = null;
		String sInTime = null;
		String sInHrs = null;
		String sInMin = null;
		String sOutTimestamp = null;
		String sOutTime = null;
		String sOutHrs = null;
		String sOutMin = null;
		String sDeptIn = null;
		String sDeptOut = null;
		String sGateTime = null;
		Map<String, String> mLogData = null;
		MapList mlLogs = null;
		Map<String, MapList> mLogs = null;
		Map<String, String> mUserDepts = getUserDepts();
		Map<String, String> mUsers = RDMServicesUtils.getUserNames(true);
		
		mUserLogs = new TreeMap<String, Map<String, MapList>>(mUserLogs);
		for (Map.Entry<String, Map<String, MapList>> mUserLog : mUserLogs.entrySet()) 
		{			
			sUserId = mUserLog.getKey();
			mLogs = mUserLogs.get(sUserId);

			mLogs = new TreeMap<String, MapList>(mLogs);
			for (Map.Entry<String, MapList> mLog : mLogs.entrySet()) 
			{
				sInDate = mLog.getKey();
				mLogs = mUserLogs.get(sUserId);
				
				mlLogs = mLogs.get(sInDate);
				for (int i=0; i<mlLogs.size(); i++) 
				{
					sInHrs = ""; sInMin = ""; sOutDate = ""; sOutHrs = ""; sOutMin = ""; sDeptIn = ""; sDeptOut = "";
					mLogData = mlLogs.get(i);

					sTime = mLogData.get(RDMServicesConstants.LOG_IN);
					if(sTime != null && !"".equals(sTime))
					{
						sInTimestamp = sdfOut.format(sdfIn.parse(sTime));
						
						sInTime = sTime.substring(sTime.indexOf(' ')).trim();
						sInHrs = sInTime.substring(0, sInTime.indexOf(':'));
						sInMin = sInTime.substring(sInTime.indexOf(':') + 1);
					}
	
					sTime = mLogData.get(RDMServicesConstants.LOG_OUT);
					if(sTime != null && !"".equals(sTime))
					{
						sOutTimestamp = sdfOut.format(sdfIn.parse(sTime));
						
						sOutDate = sOutTimestamp.substring(0, sOutTimestamp.indexOf(' '));
						sOutTime = sTime.substring(sTime.indexOf(' ')).trim();
						sOutHrs = sOutTime.substring(0, sOutTime.indexOf(':'));
						sOutMin = sOutTime.substring(sOutTime.indexOf(':') + 1);
					}
					
					sTime = mLogData.get(RDMServicesConstants.DEPT_IN);
					if(sTime != null && !"".equals(sTime))
					{
						sDeptIn = sdfOut.format(sdfIn.parse(sTime));
					}
					
					sTime = mLogData.get(RDMServicesConstants.DEPT_OUT);
					if(sTime != null && !"".equals(sTime))
					{
						sDeptOut = sdfOut.format(sdfIn.parse(sTime));
					}
	
					row = sheet.createRow(rownum);
					
					cell = row.createCell(0);
					cell.setCellValue(sUserId);
					
					cell = row.createCell(1);
					cell.setCellValue(mUsers.get(sUserId));
					
					cell = row.createCell(2);
					cell.setCellValue(mUserDepts.get(sUserId));
					
					cell = row.createCell(3);
					cell.setCellValue(mLogData.get(RDMServicesConstants.SHIFT_CODE));
					
					cell = row.createCell(4);
					cell.setCellValue(sInDate);
					
					cell = row.createCell(5);
					cell.setCellValue(sInHrs);
					
					cell = row.createCell(6);
					cell.setCellValue(sInMin);
					
					cell = row.createCell(7);
					cell.setCellValue(sOutDate);
					
					cell = row.createCell(8);
					cell.setCellValue(sOutHrs);
					
					cell = row.createCell(9);
					cell.setCellValue(sOutMin);
					
					cell = row.createCell(10);
					cell.setCellValue(sDeptIn);
					
					cell = row.createCell(11);
					cell.setCellValue(sDeptOut);
					
					cell = row.createCell(12);
					cell.setCellValue(Double.parseDouble(mLogData.get(RDMServicesConstants.PRODUCTIVITY)));
					
					sGateTime = calculateDuration(sInTimestamp, sOutTimestamp);
					cell = row.createCell(13);
					cell.setCellValue(sGateTime);
					
					cell = row.createCell(14);
					cell.setCellValue(calculateDuration(sDeptIn, sDeptOut));
					
					cell = row.createCell(15);
					cell.setCellValue(calculateOvertime(sGateTime));
					
					cell = row.createCell(16);
					cell.setCellValue("");
					
					rownum++;
				}
			}
		}
	}
	
	private String calculateDuration(String sStartTime, String sEndTime)
	{
		try
		{
			if(sStartTime.isEmpty() || sEndTime.isEmpty())
			{
				return "";
			}
			
			Date dtStart = sdfOut.parse(sStartTime);
			Date dtEnd = sdfOut.parse(sEndTime);
	 
			long diff = dtEnd.getTime() - dtStart.getTime();
			long diffMinutes = diff / (60 * 1000) % 60;
			long diffHours = diff / (60 * 60 * 1000);
	
			return ((diffHours < 10 ? ("0" + diffHours) : diffHours) + ":" +
				(diffMinutes < 10 ? ("0" + diffMinutes) : diffMinutes));
		}
		catch(Exception e)
		{
			return "";
		}
	}
	
	private String calculateOvertime(String sTime)
	{
		try 
		{
			if(sTime.isEmpty())
			{
				return "";
			}
			
			SimpleDateFormat format = new SimpleDateFormat("HH:mm");
			long diff = format.parse(sTime).getTime() - format.parse("08:00").getTime();
			if(diff <= 0)
			{
				return "";
			}
			
			long diffMinutes = diff / (60 * 1000) % 60;
			long diffHours = diff / (60 * 60 * 1000) % 24;

			return ((diffHours < 10 ? ("0" + diffHours) : diffHours) + ":" +
				(diffMinutes < 10 ? ("0" + diffMinutes) : diffMinutes));
		 } 
		catch (Exception e) 
		{
			return "";
		}
	}
	
	private static Map<String, String> getUserDepts() throws Exception
	{
    	Map<String, String> mUsers = new HashMap<String, String>();
		Map<String, String> mInfo = null;
		MapList mlUsers = RDMServicesUtils.getUserList();
		
		String sDepts = null;
		String sSecDept = null;
		for(int i=0; i<mlUsers.size(); i++)
		{
			mInfo = mlUsers.get(i);
			sDepts = mInfo.get(RDMServicesConstants.DEPARTMENT_NAME);
			sSecDept = mInfo.get(RDMServicesConstants.SEC_DEPARTMENT);
			
			if(!RDMServicesUtils.isNullOrEmpty(sSecDept))
			{
				sDepts += "|" + sSecDept;
			}
			
			mUsers.put(mInfo.get(RDMServicesConstants.USER_ID), sDepts.replaceAll("\\|", "\n"));
		}
		
		return mUsers;
	}
} 
