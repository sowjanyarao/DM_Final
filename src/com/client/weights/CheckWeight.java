package com.client.weights;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.ConnectException;
import java.net.Socket;

public class CheckWeight 
{
	public CheckWeight()
	{
		
	}

	public double readWeight(String sIP, int iPort) throws IOException
	{
		Socket connection = null;
		StringBuilder instr = new StringBuilder();
		
		BufferedOutputStream bos = null;
		OutputStreamWriter osw = null;
		
		BufferedInputStream bis = null;
		InputStreamReader isr = null;
		
		try
		{
			connection = new Socket(sIP, iPort);
		
			bos = new BufferedOutputStream(connection.getOutputStream());
			osw = new OutputStreamWriter(bos, "US-ASCII");
			
			String proc1 = "Read Weight" + (char)13;
			osw.write(proc1);
			osw.flush();
		
			bis = new BufferedInputStream(connection.getInputStream());
			isr = new InputStreamReader(bis, "US-ASCII");

			int c;
			while((c = isr.read()) != 13)
			{
				instr.append((char)c);
			}
		}
		catch(ConnectException e)
		{
			throw new ConnectException("Unable to connect to Weighing Scale, please check with the Administrator");
		}
		finally
		{
			if(osw != null)
			{
				osw.close();
				bos.close();
			}
			
			if(isr != null)
			{
				isr.close();
				bis.close();
			}

			if(connection != null)
			{
				connection.close();
			}
		}
		
		return Double.parseDouble(instr.toString());
	}
}
