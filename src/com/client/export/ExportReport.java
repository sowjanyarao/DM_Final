package com.client.export;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.channels.FileChannel;
import java.text.SimpleDateFormat;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang3.math.NumberUtils;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;

import com.client.db.DataQuery;
import com.client.reports.ReportDAO;
import com.client.util.MapList;
import com.client.util.RDMServicesConstants;
import com.client.util.RDMServicesUtils;
import com.client.util.StringList;

public class ExportReport extends HttpServlet
{
	private static final long serialVersionUID = 1L;
	private static final SimpleDateFormat sdfIn = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	private static final SimpleDateFormat sdfOut = new SimpleDateFormat("dd-MMM-yyyy hh:mm:ss a");
	
	private static final String LOGGEDUSER = "#LOGGEDUSER";
	private static final String SYSTEMUSERS = "#SYSTEMUSERS";
	private static final String REMARKS = "Remarks";
	private static final String LOGGEDBY = "Logged By";
	private static final String MODIFIEDBY = "Modified By";	
	private static final String MODIFIEDON = "Modified On";	
	
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
	
	private MapList getRecords(HttpServletRequest request) throws Exception 
	{
		String sColumn = null;
		String sName = null;
		String sValue = null;
		String[] saDateCol = null;
		Map<String, String[]> mDateCols = new HashMap<String, String[]>();
		Map<String, String> mSearchCriteria = new HashMap<String, String>();

		Enumeration<String> enumeration = request.getParameterNames();
		while (enumeration.hasMoreElements())
		{
			sName = (String) enumeration.nextElement();
			if(sName.startsWith("Column"))
			{
				sValue = request.getParameter(sName);
				if("".equals(sValue))
				{
					continue;
				}
				if(sName.endsWith("_From") || sName.endsWith("_To"))
				{
					sColumn = sName.substring(0, sName.indexOf("_"));						
					saDateCol = (mDateCols.containsKey(sColumn) ? mDateCols.get(sColumn) : new String[] {"", ""});
					
					if(sName.endsWith("_From"))
					{
						saDateCol[0] = sValue;
					}
					else if(sName.endsWith("_To"))
					{
						saDateCol[1] = sValue;
					}
					
					mDateCols.put(sColumn, saDateCol);						
				}
				else
				{
					if(sName.endsWith("_Manual"))
					{
						sName = sName.substring(0, sName.indexOf("_"));
					}
					
					if(mSearchCriteria.containsKey(sName))
					{
						if("".equals(mSearchCriteria.get(sName)))
						{
							mSearchCriteria.put(sName, sValue);
						}
					}
					else
					{
						mSearchCriteria.put(sName, sValue);
					}
				}
			}
		}
		
		Iterator<String> itrDateCols = mDateCols.keySet().iterator();
		while(itrDateCols.hasNext())
		{
			sName = itrDateCols.next();

			saDateCol = mDateCols.get(sName);
			sValue = ("".equals(saDateCol[0]) ? "NA" : saDateCol[0]) + "|" + ("".equals(saDateCol[1]) ? "NA" : saDateCol[1]);
			if(!sValue.equals("NA|NA"))
			{
				mSearchCriteria.put(sName, sValue);
			}
		}
		
		MapList mlRecords = null;
		ReportDAO reportDAO = new ReportDAO();
		if(!mSearchCriteria.isEmpty() && mSearchCriteria.size() > 0)
		{
			String sReport = request.getParameter("report");
			mlRecords = reportDAO.getRecords(sReport, mSearchCriteria);
		}
		
		return mlRecords;
	}
	
	private File writeToExcel(HttpServletRequest request) throws Exception 
	{
		String sReport = request.getParameter("report");
		String sTemplate = request.getParameter("template");
		String sColumn = null;
		StringList slColumns = new StringList();
		
		String templatePath = RDMServicesUtils.getClassLoaderpath("../../reports/templates");		
		File fTemplate = new File(templatePath, sTemplate);
		
		MapList mlRecords = getRecords(request);
		if(mlRecords == null || mlRecords.isEmpty())
		{
			return fTemplate;
		}
		
		String reportPath = RDMServicesUtils.getClassLoaderpath("../../reports/records");
		File fReport = File.createTempFile(sReport, ".xls", new File(reportPath));
		fReport.setReadable(true, false);
		fReport.setWritable(true, false);
		fReport.setExecutable(true, false);
		fReport.deleteOnExit();
		copyFiles(fTemplate, fReport); 
		
		ReportDAO reportGenerator = new ReportDAO();
		Map<String, String> mReport = reportGenerator.getReport(sReport);
		int iHeader = Integer.parseInt(mReport.get(RDMServicesConstants.HEADER_ROW));
		
		FileInputStream fis = new FileInputStream(fReport);
		HSSFWorkbook workbook = new HSSFWorkbook(fis);
		HSSFSheet worksheet = workbook.getSheetAt(0);
		HSSFRow row = worksheet.getRow(iHeader - 1);
		HSSFCell cell = null;
		
		int iCols = row.getLastCellNum();
		iCols = ((iCols > 50) ? 50 : iCols);
		for(int i=0; i<iCols; i++)
		{
			cell = row.getCell(i);
			if(cell == null)
			{
				continue;
			}
			
			cell.setCellType(HSSFCell.CELL_TYPE_STRING);
			sColumn = cell.getStringCellValue();
			sColumn = (sColumn == null ? "" : sColumn.trim());
			if(!"".equals(sColumn))
			{
				if(sColumn.equalsIgnoreCase(REMARKS))
				{
					slColumns.add(REMARKS);
				}
				else if(sColumn.equalsIgnoreCase(LOGGEDBY))
				{
					slColumns.add(LOGGEDBY);
				}
				else if(sColumn.equalsIgnoreCase(MODIFIEDBY))
				{
					slColumns.add(MODIFIEDBY);
				}
				else if(sColumn.equalsIgnoreCase(MODIFIEDON))
				{
					slColumns.add(MODIFIEDON);
				}
				else
				{
					slColumns.add(sColumn);
				}
			}
		}
		
		fis.close();
		
		if(!slColumns.contains(REMARKS))
		{
			cell = row.createCell(slColumns.size());
			cell.setCellValue(REMARKS);
			slColumns.add(REMARKS);
		}
		
		if(!slColumns.contains(LOGGEDBY))
		{
			cell = row.createCell(slColumns.size());
			cell.setCellValue(LOGGEDBY);
			slColumns.add(LOGGEDBY);
		}
		
		if(!slColumns.contains(MODIFIEDBY))
		{
			cell = row.createCell(slColumns.size());
			cell.setCellValue(MODIFIEDBY);
			slColumns.add(MODIFIEDBY);
		}
		
		if(!slColumns.contains(MODIFIEDON))
		{
			cell = row.createCell(slColumns.size());
			cell.setCellValue(MODIFIEDON);
			slColumns.add(MODIFIEDON);
		}
		
		Map<String, String> mUsers = RDMServicesUtils.getUserNames(true);
		
		DataQuery query = new DataQuery();
		Map<String, String> mReportCols = query.getReportColumnHeaders(sReport, false);
		Map<String, String[]> mReportRanges = query.getReportColumnRanges(sReport);
		
		Map<String, String> mRecord = null;
		String sValue = null;
		String[] sRanges = null;
		for(int i=0; i<mlRecords.size(); i++)
		{
			row = worksheet.createRow(i + iHeader);
			
			mRecord = mlRecords.get(i);
			for(int j=0, iSz=slColumns.size(); j<iSz; j++)
			{
				sColumn = mReportCols.get(slColumns.get(j));
				if(sColumn != null && !"".equals(sColumn))
				{
					sValue = mRecord.get(sColumn);
					sValue = (sValue == null ? "" : sValue);
					
					if(((j == 0) || MODIFIEDON.equals(slColumns.get(j))) && !"".equals(sValue))
					{
						try
						{
							sValue = sdfOut.format(sdfIn.parse(sValue));
						}
						catch(Exception e)
						{
							//do nothing
						}
						if(sValue.endsWith("12:00 AM"))
						{
							sValue = sValue.substring(0, sValue.indexOf(' '));
						}
					}
				}
				else
				{
					sValue = "";
				}
				
				sRanges = mReportRanges.get(sColumn);
				if(sRanges != null && (LOGGEDUSER.equals(sRanges[0]) || SYSTEMUSERS.equals(sRanges[0])))
				{
					if(mUsers.containsKey(sValue))
					{
						sValue = mUsers.get(sValue) + "(" + sValue + ")";
					}
				}
				
				if((LOGGEDBY.equals(slColumns.get(j)) || MODIFIEDBY.equals(slColumns.get(j))) && mUsers.containsKey(sValue))
				{
					sValue = mUsers.get(sValue) + "(" + sValue + ")";
				}
				
				cell = row.createCell(j);
				if(NumberUtils.isNumber(sValue))
				{
					cell.setCellValue(Double.parseDouble(sValue));
				}
				else
				{
					cell.setCellValue(sValue);
				}
			}
		}
			
		FileOutputStream out = new FileOutputStream(fReport);
	    workbook.write(out);
	    out.close();
		     
		return fReport;
	}

	private static void copyFiles(File source, File dest) throws IOException 
	{
	    FileChannel sourceChannel = null;
	    FileChannel destChannel = null;
	    
	    FileInputStream fis = null;
	    FileOutputStream fos= null;
	    try 
	    {
	    	fis = new FileInputStream(source);
	        sourceChannel = fis.getChannel();
	        
	        fos = new FileOutputStream(dest);
	        destChannel = fos.getChannel();
	        
	        destChannel.transferFrom(sourceChannel, 0, sourceChannel.size());
	    }
	    finally
	    {
	    	fis.close();
	    	fos.close();
	    	
    		sourceChannel.close();
    		destChannel.close();
	    } 
	} 
}
