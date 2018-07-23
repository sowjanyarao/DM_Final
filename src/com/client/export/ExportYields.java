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

public class ExportYields extends HttpServlet
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
	
	private MapList getYields(HttpServletRequest request) throws Exception
	{
		String sRoom = request.getParameter("lstController");
		String sFromDate = request.getParameter("start_date");
		String sToDate = request.getParameter("end_date");
		String sCond = request.getParameter("cond");
		String sYield = request.getParameter("yield");
		String sBatchNo = request.getParameter("BatchNo");
		String sGroupBy = request.getParameter("groupBy");
		boolean bGroupByDate = "date".equals(sGroupBy);
		
		DataQuery query = new DataQuery();
		MapList mlYields = query.getYields(sRoom, sFromDate, sToDate, sCond, sYield, sBatchNo, bGroupByDate);
		
		return mlYields;
	}
	
	private File writeToExcel(HttpServletRequest request) throws Exception 
	{
		String filepath = "";		
		try {
			filepath = RDMServicesUtils.getClassLoaderpath("../../export");	
		}
		catch(Exception e) {
			filepath = RDMServicesUtils.getClassLoaderpath("");	
		}
		File file = File.createTempFile("ExportDailyYieldData", ".xls", new File(filepath));
		file.setReadable(true, false);
		file.setWritable(true, false);
		file.setExecutable(true, false);
		file.deleteOnExit();
		
		MapList mlYields = getYields(request);
		
		HSSFWorkbook workbook = new HSSFWorkbook();
		HSSFSheet sheet = workbook.createSheet("Daily Yield");
		
		addFilters(sheet, request);
		addHeaders(sheet);
		addYields(sheet, mlYields);
		
	    FileOutputStream out = new FileOutputStream(file);
	    workbook.write(out);
	    out.close();
		     
		return file;
	}
	
	private void addFilters(HSSFSheet sheet, HttpServletRequest request)
	{
		String sRoom = request.getParameter("lstController");
		String sFromDate = request.getParameter("start_date");
		String sToDate = request.getParameter("end_date");
		String sCond = request.getParameter("cond");
		String sYield = request.getParameter("yield");
		String sBatchNo = request.getParameter("BatchNo");
		
		Row row = sheet.createRow(0);
		Cell cell = row.createCell(0);
		cell.setCellValue("Room(s)");		
		cell = row.createCell(1);
		cell.setCellValue(sRoom);
		
		row = sheet.createRow(1);
		cell = row.createCell(0);
		cell.setCellValue("Batch No");		
		cell = row.createCell(1);
		cell.setCellValue(sBatchNo);
		
		row = sheet.createRow(2);
		cell = row.createCell(0);
		cell.setCellValue("From Date");
		cell = row.createCell(1);
		cell.setCellValue(sFromDate);
		
		row = sheet.createRow(3);
		cell = row.createCell(0);
		cell.setCellValue("To Date");
		cell = row.createCell(1);
		cell.setCellValue(sToDate);
		
		row = sheet.createRow(4);
		cell = row.createCell(0);
		cell.setCellValue("Yield");
		cell = row.createCell(1);
		
		if(!"".equals(sYield))
		{
			if("morethan".equals(sCond))
			{
				cell.setCellValue(" > "+sYield);
			}
			else if("lessthan".equals(sCond))
			{
				cell.setCellValue(" < "+sYield);
			}
			else
			{
				cell.setCellValue(" = "+sYield);
			}
		}
		else
		{
			cell.setCellValue("");
		}
	}
	
	private void addHeaders(HSSFSheet sheet)
	{
		Row row = sheet.createRow(4);
		row = sheet.createRow(5);
		
		Cell cell = row.createCell(0);
		cell.setCellValue("Room No");
		
		cell = row.createCell(1);
		cell.setCellValue("Stage");
		
		cell = row.createCell(2);
		cell.setCellValue("Batch No");
		
		cell = row.createCell(3);
		cell.setCellValue("Date");
		
		cell = row.createCell(4);
		cell.setCellValue("Estimated Yield");
		
		cell = row.createCell(5);
		cell.setCellValue("Yield");
		
		cell = row.createCell(6);
		cell.setCellValue("Logged By");
	}
	
	private void addYields(HSSFSheet sheet, MapList mlYields) throws Exception
	{
		int rownum = 6;
		Row row = null;
		Cell cell = null;
		
		String sLoggedBy = null;
		String sNoDays = null;
		Map<String, String> mUsers = RDMServicesUtils.getUserNames(true);
		
		Map<String, String> mLog = null;		
		for(int i=0, iSz=mlYields.size(); i<iSz; i++)
		{
			mLog = mlYields.get(i);
			
			row = sheet.createRow(rownum++);
			
			cell = row.createCell(0);
			cell.setCellValue(mLog.get(RDMServicesConstants.ROOM_ID));
			
			sNoDays = mLog.get(RDMServicesConstants.RUNNING_DAY);
			sNoDays = ((sNoDays == null || "0".equals(sNoDays)) ? "" : " ("+sNoDays+")");
			cell = row.createCell(1);
			cell.setCellValue(mLog.get(RDMServicesConstants.STAGE_NUMBER) + sNoDays);
			
			cell = row.createCell(2);
			cell.setCellValue(mLog.get(RDMServicesConstants.BATCH_NO));
			
			cell = row.createCell(3);
			cell.setCellValue(mLog.get(RDMServicesConstants.ON_DATE));
			
			cell = row.createCell(4);
			cell.setCellValue(Double.parseDouble(mLog.get(RDMServicesConstants.EST_YIELD)));
			
			cell = row.createCell(5);
			cell.setCellValue(Double.parseDouble(mLog.get(RDMServicesConstants.DAILY_YIELD)));
			
			sLoggedBy = mLog.get(RDMServicesConstants.LOGGED_BY);
			if(mUsers.containsKey(sLoggedBy))
			{
				sLoggedBy = mUsers.get(sLoggedBy);
			}
			cell = row.createCell(6);
			cell.setCellValue(sLoggedBy);
		}
	}
} 
