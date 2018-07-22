package com.client.export;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;

import com.client.db.DataQuery;
import com.client.util.MapList;
import com.client.util.RDMServicesConstants;
import com.client.util.RDMServicesUtils;

public class ExportAlarms extends HttpServlet
{
	private static final long serialVersionUID = 1L;

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
	
	private MapList getAlarms(HttpServletRequest request) throws Exception
	{
		String sRoom = request.getParameter("lstController");
		String sStage = request.getParameter("lstStage");
		String sAlarmTypes = request.getParameter("lstTypes");
		String sFromDate = request.getParameter("start_date");
		String sToDate = request.getParameter("end_date");
		String showOpenAlarms = request.getParameter("openAlarms");
		String BNo = request.getParameter("BatchNo");
		String sLimit = request.getParameter("limit");
		int limit = 0;
		if(sLimit != null && !"".equals(sLimit))
		{
			try
			{
				limit = Integer.parseInt(sLimit);
			}
			catch(NumberFormatException e)
			{
				limit = 0;
			}
		}
		
		DataQuery query = new DataQuery();
		MapList mlAlarms = query.getAlarmLogHistory(sRoom, sStage, BNo, 
			sAlarmTypes, sFromDate, sToDate, showOpenAlarms, limit);
		
		return mlAlarms;
	}
	
	private File writeToExcel(HttpServletRequest request) throws Exception 
	{
		String filepath = RDMServicesUtils.getClassLoaderpath("../../export");		
		File file = File.createTempFile("ExportAlarmData", ".xls", new File(filepath));
		file.setReadable(true, false);
		file.setWritable(true, false);
		file.setExecutable(true, false);
		file.deleteOnExit();
		
		MapList mlAlarms = getAlarms(request);
		
		HSSFWorkbook workbook = new HSSFWorkbook();
		HSSFSheet sheet = workbook.createSheet("Alarms");
		
		addFilters(sheet, request);
		addHeaders(sheet);
		addAlarms(sheet, mlAlarms);
		
	    FileOutputStream out = new FileOutputStream(file);
	    workbook.write(out);
	    out.close();
		     
		return file;
	}
	
	private void addFilters(HSSFSheet sheet, HttpServletRequest request)
	{
		String sRoom = request.getParameter("lstController");
		String sStage = request.getParameter("lstStage");
		String BNo = request.getParameter("BatchNo");
		String[] saAlarmTypes = request.getParameterValues("lstTypes");
		String sFromDate = request.getParameter("start_date");
		String sToDate = request.getParameter("end_date");
		String showOpenAlarms = request.getParameter("openAlarms");
		showOpenAlarms = (showOpenAlarms == null ? "" :showOpenAlarms);
		
		String sAlarmTypes = "";
		if(saAlarmTypes != null)
		{
			int iSz = saAlarmTypes.length;
			if(iSz > 0)
			{
				StringBuilder sbTypes = new StringBuilder();
				for(int i=0; i<iSz; i++)
				{
					if(i > 0)
					{
						sbTypes.append(", ");
					}
					sbTypes.append(saAlarmTypes[i]);
				}
				sAlarmTypes = sbTypes.toString();
			}
		}
		
		Row row = sheet.createRow(0);
		Cell cell = row.createCell(0);
		cell.setCellValue("Controller");		
		cell = row.createCell(1);
		cell.setCellValue(sRoom);
		
		row = sheet.createRow(1);
		cell = row.createCell(0);
		cell.setCellValue("Stage");		
		cell = row.createCell(1);
		cell.setCellValue(sStage);
		
		row = sheet.createRow(2);
		cell = row.createCell(0);
		cell.setCellValue("Batch No");		
		cell = row.createCell(1);
		cell.setCellValue(BNo);
		
		row = sheet.createRow(3);
		cell = row.createCell(0);
		cell.setCellValue("Alarm Type(s)");
		cell = row.createCell(1);
		cell.setCellValue(sAlarmTypes);
		
		row = sheet.createRow(4);
		cell = row.createCell(0);
		cell.setCellValue("From Date");
		cell = row.createCell(1);
		cell.setCellValue(sFromDate);
		
		row = sheet.createRow(5);
		cell = row.createCell(0);
		cell.setCellValue("To Date");
		cell = row.createCell(1);
		cell.setCellValue(sToDate);
		
		row = sheet.createRow(6);
		cell = row.createCell(0);
		cell.setCellValue("Show Open Alarms");
		cell = row.createCell(1);
		cell.setCellValue(showOpenAlarms);
	}
	
	private void addHeaders(HSSFSheet sheet)
	{
		Row row = sheet.createRow(7);
		row = sheet.createRow(8);
		
		Cell cell = row.createCell(0);
		cell.setCellValue("Room No");
		
		cell = row.createCell(1);
		cell.setCellValue("Stage");
		
		cell = row.createCell(2);
		cell.setCellValue("Batch No");
		
		cell = row.createCell(3);
		cell.setCellValue("Serial No");
		
		cell = row.createCell(4);
		cell.setCellValue("Description");
		
		cell = row.createCell(5);
		cell.setCellValue("Occured On");
		
		cell = row.createCell(6);
		cell.setCellValue("Accepted");
		
		cell = row.createCell(7);
		cell.setCellValue("Accepted By");
		
		cell = row.createCell(8);
		cell.setCellValue("Cleared On");
	}
	
	private void addAlarms(HSSFSheet sheet, MapList mlAlarms) throws Exception
	{
		int rownum = 9;
		Row row = null;
		Cell cell = null;
		
		String sAcceptedBy = null;
		Map<String, String> mUsers = RDMServicesUtils.getUserNames(true);
		
		Map<String, String> mLog = null;		
		for(int i=0, iSz=mlAlarms.size(); i<iSz; i++)
		{
			mLog = mlAlarms.get(i);
			
			row = sheet.createRow(rownum++);
			
			cell = row.createCell(0);
			cell.setCellValue(mLog.get(RDMServicesConstants.ROOM_ID));
			
			cell = row.createCell(1);
			cell.setCellValue(mLog.get(RDMServicesConstants.STAGE_NUMBER));
			
			cell = row.createCell(2);
			cell.setCellValue(mLog.get(RDMServicesConstants.BATCH_NO));
			
			cell = row.createCell(3);
			cell.setCellValue(mLog.get(RDMServicesConstants.SERIAL_ID));
			
			cell = row.createCell(4);
			cell.setCellValue(mLog.get(RDMServicesConstants.ALARM_TEXT));
			
			cell = row.createCell(5);
			cell.setCellValue(mLog.get(RDMServicesConstants.OCCURED_ON));
			
			cell = row.createCell(6);
			cell.setCellValue(mLog.get(RDMServicesConstants.ACCEPTED_ON));
			
			sAcceptedBy = mLog.get(RDMServicesConstants.ACCEPTED_BY);
			if(mUsers.containsKey(sAcceptedBy))
			{
				sAcceptedBy = mUsers.get(sAcceptedBy);
			}

			cell = row.createCell(7);
			cell.setCellValue(sAcceptedBy);
			
			cell = row.createCell(8);
			cell.setCellValue(mLog.get(RDMServicesConstants.CLEARED_ON));
		}
	}
} 
