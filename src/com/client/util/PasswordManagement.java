package com.client.util;

import java.security.SecureRandom;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.client.db.DataQuery;

public class PasswordManagement extends HttpServlet 
{
	private static final long serialVersionUID = 1L;

	public void init(ServletConfig config) throws ServletException 
	{
		super.init(config);
	}
	
	public void doGet(HttpServletRequest request, HttpServletResponse response)
	{
		try
		{
			String sUserName = request.getParameter("id");
			String sAction = request.getParameter("action");

			DataQuery qry = new DataQuery();
			Map<String, String> mUserInfo = qry.getUserDetails(sUserName);

			String flag;
			if(mUserInfo.isEmpty() || mUserInfo.size() == 0)
			{
				flag = "nouser";
			}
			else
			{
				String eMail = mUserInfo.get(RDMServicesConstants.EMAIL);
				if(eMail == null || "".equals(eMail))
				{
					flag = "nomail";
				}
				else
				{
					if("reset.password".equals(sAction))
					{
						String password = generatePassword();
						
						Map<String, String> mUpdatePwd = new HashMap<String, String>();
						mUpdatePwd.put(RDMServicesConstants.PASSWORD, password);
						
						qry.updateUser(sUserName, mUpdatePwd);
						
						mUserInfo.put(RDMServicesConstants.PASSWORD, password);
					}
					
					Mail.sendMail(mUserInfo, sAction);
					flag = "success";
				}
			}
			
			if("forgot.password".equals(sAction))
			{
				response.sendRedirect("services/forgotPassword.jsp?flag="+flag);
			}
			else if("reset.password".equals(sAction))
			{
				response.sendRedirect("services/resetUserPassword.jsp?flag="+flag);
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
	}
	
	private String generatePassword()
	{
		String symbols = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz"; 
		Random random = new SecureRandom();

		char[] buf = new char[10];
		for(int idx=0; idx<buf.length; idx++)
		{
			buf[idx] = symbols.charAt(random.nextInt(symbols.length()));
		}
		return new String(buf);
	}
	
	public void destroy() 
	{
 
	}
}