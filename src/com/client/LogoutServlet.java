package com.client;

import java.util.Enumeration;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.client.db.DataQuery;
import com.client.util.User;

public class LogoutServlet extends HttpServlet 
{
	private static final long serialVersionUID = 1L;

	public void init(ServletConfig config) throws ServletException 
	{
		super.init(config);
	}
	
	public void doGet(HttpServletRequest request, HttpServletResponse response)
	{
		doPost(request, response);
	}
	
	public void doPost(HttpServletRequest request, HttpServletResponse response)
	{
		try 
		{
			HttpSession session = request.getSession(true);
			String user = ((User)session.getAttribute("currentSessionUser")).getUser();
			
			StringBuilder logDetails = new StringBuilder();
			logDetails.append("<b>IP:</b> ");
			logDetails.append(request.getParameter("ip"));
			logDetails.append("<br>");
			logDetails.append("<b>Hostname:</b> ");
			logDetails.append(request.getParameter("hostname"));
			logDetails.append("<br>");
			logDetails.append("<b>Location:</b> ");
			logDetails.append(request.getParameter("city"));
			logDetails.append(", ");
			logDetails.append(request.getParameter("region"));
			logDetails.append(", ");
			logDetails.append(request.getParameter("country"));
			
			DataQuery query = new DataQuery();
			query.logUserActivity(user, logDetails.toString(), false, ""); 
			
			Enumeration<String> attrNames = session.getAttributeNames();
			while(attrNames.hasMoreElements())
			{
				session.removeAttribute(attrNames.nextElement());
			}
			session.invalidate();
			
			response.sendRedirect("logout.jsp");
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
	}
	
	public void destroy() 
	{
 
	}
	
}