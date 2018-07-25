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

public class ExportLogs extends HttpServlet
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
	
	private MapList getLogs(HttpServletRequest request) throws Exception
	{
		String sRoom = request.getParameter("lstController");
		String sStage = request.getParameter("lstStage");
		String BNo = request.getParameter("BatchNo");
		String sFromDate = request.getParameter("start_date");
		String sToDate = request.getParameter("end_date");
		String sParams = request.getParameter("params");
		String showSysLogs = request.getParameter("sysLogs");
		showSysLogs = ((showSysLogs == null) ? "" : showSysLogs);
		
		sParams = ((sParams == null) ? "" : sParams.trim());
		sParams = sParams.replaceAll("\\r", ",").replaceAll("\\n", ",").replaceAll(",,", ",");
		
		BNo = ((BNo == null) ? "" : BNo.trim());
		BNo = BNo.replaceAll("\\s", ",").replaceAll(",,", ",");
		
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
		MapList mlLogs = query.getLogHistory(sRoom, sStage, BNo, 
			sFromDate, sToDate, sParams, showSysLogs, limit);
		
		return mlLogs;
	}
	
	private File writeToExcel(HttpServletRequest request) throws Exception 
	{
		String filepath = "";
		try{
			filepath = RDMServicesUtils.getClassLoaderpath("../../export");		
		}catch(Exception e) {
			filepath = RDMServicesUtils.getClassLoaderpath("");		
		}
		File file = File.createTempFile("ExportLogsData", ".xls", new File(filepath));
		file.setReadable(true, false);
		file.setWritable(true, false);
		file.setExecutable(true, false);
		file.deleteOnExit();
		
		MapList mlLogs = getLogs(request);
		
		HSSFWorkbook workbook = new HSSFWorkbook();
		HSSFSheet sheet = workbook.createSheet("Logs");
		
		addFilters(sheet, request);
		addHeaders(sheet);
		addLogs(sheet, mlLogs);
		
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
		String sFromDate = request.getParameter("start_date");
		String sToDate = request.getParameter("end_date");
		String sParams = request.getParameter("params");
		String showSysLogs = request.getParameter("sysLogs");
		
		showSysLogs = ((showSysLogs == null) ? "" : showSysLogs);
		
		sParams = ((sParams == null) ? "" : sParams.trim());
		sParams = sParams.replaceAll("\\s", ",").replaceAll(",,", ",");
		
		BNo = ((BNo == null) ? "" : BNo.trim());
		BNo = BNo.replaceAll("\\s", ",").replaceAll(",,", ",");
		
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
		cell.setCellValue("Parameter(s)");
		cell = row.createCell(1);
		cell.setCellValue(sParams);
		
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
		cell.setCellValue("Show System Logs");
		cell = row.createCell(1);
		cell.setCellValue(showSysLogs);
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
		cell.setCellValue("Logged By");
		
		cell = row.createCell(4);
		cell.setCellValue("Logged On");
		
		cell = row.createCell(5);
		cell.setCellValue("Parameter");
		
		cell = row.createCell(6);
		cell.setCellValue("Text");
	}
	
	private void addLogs(HSSFSheet sheet, MapList mlLogs) throws Exception
	{
		int rownum = 9;
		Row row = null;
		Cell cell = null;
		
		String sLoggedBy = null;
		Map<String, String> mUsers = RDMServicesUtils.getUserNames(true);
		
		Map<String, String> mLog = null;		
		for(int i=0, iSz=mlLogs.size(); i<iSz; i++)
		{
			mLog = mlLogs.get(i);
			
			row = sheet.createRow(rownum++);
			
			cell = row.createCell(0);
			cell.setCellValue(mLog.get(RDMServicesConstants.ROOM_ID));
			
			cell = row.createCell(1);
			cell.setCellValue(mLog.get(RDMServicesConstants.STAGE_NUMBER));
			
			cell = row.createCell(2);
			cell.setCellValue(mLog.get(RDMServicesConstants.BATCH_NO));
			
			sLoggedBy = mLog.get(RDMServicesConstants.LOGGED_BY);
			if(mUsers.containsKey(sLoggedBy))
			{
				sLoggedBy = mUsers.get(sLoggedBy);
			}

			cell = row.createCell(3);
			cell.setCellValue(sLoggedBy);
			
			cell = row.createCell(4);
			cell.setCellValue(mLog.get(RDMServicesConstants.LOGGED_ON));
			
			cell = row.createCell(5);
			cell.setCellValue(mLog.get(RDMServicesConstants.PARAM_NAME));
			
			cell = row.createCell(6);
			cell.setCellValue(mLog.get(RDMServicesConstants.LOG_TEXT));
		}
	}
} 
