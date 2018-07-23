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

public class ExportComments extends HttpServlet
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
	
	private MapList getComments(HttpServletRequest request) throws Exception
	{
		String sRoom = request.getParameter("lstController");
		String sStage = request.getParameter("lstStage");
		String text = request.getParameter("abbr");
		String dept = request.getParameter("dept");
		String sFromDate = request.getParameter("start_date");
		String sToDate = request.getParameter("end_date");
		String sGlobal = request.getParameter("global");
		boolean bGlobal = "Y".equals(sGlobal);
		String sClosed = request.getParameter("closed");
		boolean bClosed = "Y".equals(sClosed);
		String sLoggedBy = request.getParameter("logByMe");
		String BNo = request.getParameter("BatchNo");
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
		MapList mlComments = query.getUserComments(sRoom, sStage, BNo, 
			sFromDate, sToDate, sLoggedBy, text, dept, bGlobal, bClosed, limit);
		
		return mlComments;
	}
	
	private File writeToExcel(HttpServletRequest request) throws Exception 
	{
		String filepath = "";	
		try {
			RDMServicesUtils.getClassLoaderpath("../../export");	
		}
		catch(Exception e) {
			RDMServicesUtils.getClassLoaderpath("");	
		}	
		File file = File.createTempFile("ExportCommentsData", ".xls", new File(filepath));
		file.setReadable(true, false);
		file.setWritable(true, false);
		file.setExecutable(true, false);
		file.deleteOnExit();
		
		MapList mlComments = getComments(request);
		
		HSSFWorkbook workbook = new HSSFWorkbook();
		HSSFSheet sheet = workbook.createSheet("Comments");
		
		addFilters(sheet, request);
		addHeaders(sheet);
		addComments(sheet, mlComments);
		
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
		String text = request.getParameter("abbr");
		String sDept = request.getParameter("dept");
		String sFromDate = request.getParameter("start_date");
		String sToDate = request.getParameter("end_date");
		String sGlobal = request.getParameter("global");
		String sClosed = request.getParameter("closed");
		String sLogByMe = request.getParameter("logByMe");
		
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
		cell.setCellValue("Department");		
		cell = row.createCell(1);
		cell.setCellValue(sDept);
		
		row = sheet.createRow(3);
		cell = row.createCell(0);
		cell.setCellValue("Batch No");		
		cell = row.createCell(1);
		cell.setCellValue(BNo);
		
		row = sheet.createRow(4);
		cell = row.createCell(0);
		cell.setCellValue("Text");
		cell = row.createCell(1);
		cell.setCellValue(text);
		
		row = sheet.createRow(5);
		cell = row.createCell(0);
		cell.setCellValue("From Date");
		cell = row.createCell(1);
		cell.setCellValue(sFromDate);
		
		row = sheet.createRow(6);
		cell = row.createCell(0);
		cell.setCellValue("To Date");
		cell = row.createCell(1);
		cell.setCellValue(sToDate);
		
		row = sheet.createRow(7);
		cell = row.createCell(0);
		cell.setCellValue("Logged By Me");
		cell = row.createCell(1);
		cell.setCellValue(sLogByMe);
		
		row = sheet.createRow(8);
		cell = row.createCell(0);
		cell.setCellValue("Show Only Alerts");
		cell = row.createCell(1);
		cell.setCellValue("Y".equals(sGlobal) ? "Yes" : "No");
		
		row = sheet.createRow(9);
		cell = row.createCell(0);
		cell.setCellValue("Include Closed");
		cell = row.createCell(1);
		cell.setCellValue("Y".equals(sClosed) ? "Yes" : "No");
	}
	
	private void addHeaders(HSSFSheet sheet)
	{
		Row row = sheet.createRow(10);
		row = sheet.createRow(11);
		
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
		cell.setCellValue("Text");
		
		cell = row.createCell(6);
		cell.setCellValue("Comments");
		
		cell = row.createCell(7);
		cell.setCellValue("Alert");
		
		cell = row.createCell(8);
		cell.setCellValue("Department");
	}
	
	private void addComments(HSSFSheet sheet, MapList mlComments) throws Exception
	{
		int rownum = 12;
		Row row = null;
		Cell cell = null;

		String sLoggedBy = null;
		String sCategory = null;
		String sDesc = null;
		String sNoDays = null;
		Map<String, String> mUsers = RDMServicesUtils.getUserNames(true);
		
		Map<String, String> mTasks = RDMServicesUtils.listAdminTasks();
		
		Map<String, String> mLog = null;		
		for(int i=0, iSz=mlComments.size(); i<iSz; i++)
		{
			mLog = mlComments.get(i);
			
			row = sheet.createRow(rownum++);
			
			cell = row.createCell(0);
			cell.setCellValue(mLog.get(RDMServicesConstants.ROOM_ID));
			
			sNoDays = mLog.get(RDMServicesConstants.RUNNING_DAY);
			sNoDays = ((sNoDays == null || "0".equals(sNoDays)) ? "" : " ("+sNoDays+")");
			cell = row.createCell(1);
			cell.setCellValue(mLog.get(RDMServicesConstants.STAGE_NUMBER) + sNoDays);
			
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
			
			sCategory = mLog.get(RDMServicesConstants.CATEGORY);
			sCategory = (sCategory == null ? "" : sCategory);
			
			sDesc = mTasks.get(sCategory);
			sDesc = (sDesc == null ? "" : sDesc);

			cell = row.createCell(5);
			cell.setCellValue(sCategory+" ("+sDesc+")");
			
			cell = row.createCell(6);
			cell.setCellValue(mLog.get(RDMServicesConstants.REVIEW_COMMENTS).replaceAll("<br>", "\n"));
			
			cell = row.createCell(7);
			cell.setCellValue("Y".equals(mLog.get(RDMServicesConstants.GLOBAL_ALERT)) ? "Yes" : "No");
			
			cell = row.createCell(8);
			cell.setCellValue((mLog.get(RDMServicesConstants.DEPARTMENT_NAME)).replaceAll("\\|", "\n"));
		}
	}
} 
