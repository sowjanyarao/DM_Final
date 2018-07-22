package com.client.export;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;

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

public class ExportBatchNos extends HttpServlet
{
	private static final long serialVersionUID = 1L;
	private static final SimpleDateFormat sdfOut = new SimpleDateFormat("MM/dd/yyyy hh:mm a");

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
	
	private MapList getBatchNos(HttpServletRequest request) throws Exception
	{
		String sMonth = request.getParameter("Month");
		String sYear = request.getParameter("Year");
		String sCntrlType = request.getParameter("CntrlType");
		String sDefParamType = request.getParameter("defParamType");
		
		MapList mlBatchNos = null;
		
		if(!"".equals(sMonth) && !"".equals(sYear))
		{
			mlBatchNos = RDMServicesUtils.getBatchNos(sMonth, sYear, sCntrlType, sDefParamType);
		}
		else
		{
			mlBatchNos = RDMServicesUtils.getBatchNos(sCntrlType, sDefParamType);
		}
		
		return mlBatchNos;
	}
	
	private File writeToExcel(HttpServletRequest request) throws Exception 
	{
		String filepath = RDMServicesUtils.getClassLoaderpath("../../export");		
		File file = File.createTempFile("ExportBatchNos", ".xls", new File(filepath));
		file.setReadable(true, false);
		file.setWritable(true, false);
		file.setExecutable(true, false);
		file.deleteOnExit();
		
		MapList mlBatchNos = getBatchNos(request);
		
		HSSFWorkbook workbook = new HSSFWorkbook();
		HSSFSheet sheet = workbook.createSheet("Batch Nos");
		
		addFilters(sheet, request);
		addHeaders(sheet);
		addBatchNos(sheet, mlBatchNos);
		
	    FileOutputStream out = new FileOutputStream(file);
	    workbook.write(out);
	    out.close();
		     
		return file;
	}
	
	private void addFilters(HSSFSheet sheet, HttpServletRequest request)
	{
		String sMonth = request.getParameter("Month");
		String sYear = request.getParameter("Year");
		String sCntrlType = request.getParameter("CntrlType");
		String sDefParamType = request.getParameter("defParamType");
		
		Row row = sheet.createRow(0);
		Cell cell = row.createCell(0);
		cell.setCellValue("Month");		
		cell = row.createCell(1);
		cell.setCellValue(sMonth);
		
		row = sheet.createRow(1);
		cell = row.createCell(0);
		cell.setCellValue("Year");		
		cell = row.createCell(1);
		cell.setCellValue(sYear);
		
		row = sheet.createRow(2);
		cell = row.createCell(0);
		cell.setCellValue("Room Type");		
		cell = row.createCell(1);
		cell.setCellValue(sCntrlType);
		
		row = sheet.createRow(3);
		cell = row.createCell(0);
		cell.setCellValue("Product");
		cell = row.createCell(1);
		cell.setCellValue(sDefParamType);
	}
	
	private void addHeaders(HSSFSheet sheet)
	{
		Row row = sheet.createRow(4);
		row = sheet.createRow(5);
		
		Cell cell = row.createCell(0);
		cell.setCellValue("Room Name");
		
		cell = row.createCell(1);
		cell.setCellValue("Room Type");
		
		cell = row.createCell(2);
		cell.setCellValue("Product");
		
		cell = row.createCell(3);
		cell.setCellValue("Batch No");
		
		cell = row.createCell(4);
		cell.setCellValue("From Date");
		
		cell = row.createCell(5);
		cell.setCellValue("To Date");
		
		cell = row.createCell(6);
		cell.setCellValue("Duration");
	}
	
	private void addBatchNos(HSSFSheet sheet, MapList mlBatchNos) throws Exception
	{
		int rownum = 6;
		Row row = null;
		String roomId = null;
		String sStartTime = null;
		String sEndTime = null;
		Cell cell = null;
		
		Map<String, String> mBatchNo = null;		
		for(int i=0, iSz=mlBatchNos.size(); i<iSz; i++)
		{
			mBatchNo = mlBatchNos.get(i);
			roomId = mBatchNo.get(RDMServicesConstants.ROOM_ID);
			if(RDMServicesUtils.isGeneralController(roomId))
			{
				continue;
			}			
			
			row = sheet.createRow(rownum++);
			
			cell = row.createCell(0);
			cell.setCellValue(roomId);
			
			cell = row.createCell(1);
			cell.setCellValue(mBatchNo.get(RDMServicesConstants.CNTRL_TYPE));
			
			cell = row.createCell(2);
			cell.setCellValue(mBatchNo.get(RDMServicesConstants.DEF_VAL_TYPE));
			
			cell = row.createCell(3);
			cell.setCellValue(mBatchNo.get(RDMServicesConstants.BATCH_NO));
			
			sStartTime = mBatchNo.get(RDMServicesConstants.START_DT);
			cell = row.createCell(4);
			cell.setCellValue(sStartTime);
			
			sEndTime = mBatchNo.get(RDMServicesConstants.END_DT);
			cell = row.createCell(5);
			cell.setCellValue(sEndTime);
			
			cell = row.createCell(6);
			cell.setCellValue(calculateDuration(sStartTime, sEndTime));
		}
	}
	
	private String calculateDuration(String sStartTime, String sEndTime)
	{
		try
		{
			if(sStartTime.isEmpty())
			{
				return "";
			}
			
			Date dtStart = sdfOut.parse(sStartTime);
			Date dtEnd = null;
			if(sEndTime.isEmpty())
			{
				dtEnd = new Date();
			}
			else
			{
				dtEnd = sdfOut.parse(sEndTime);
			}
	 
			long diff = dtEnd.getTime() - dtStart.getTime();
			long diffMinutes = diff / (60 * 1000) % 60;
			long diffHours = diff / (60 * 60 * 1000) % 24;
			long diffDays = diff / (24 * 60 * 60 * 1000);
	
			return diffDays + "D:" + diffHours + "H:" + diffMinutes + "M";
		}
		catch(Exception e)
		{
			return "";
		}
	}
} 
