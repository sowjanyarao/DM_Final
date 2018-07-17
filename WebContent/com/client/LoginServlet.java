package com.client;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.client.db.DataQuery;
import com.client.util.RDMServicesConstants;
import com.client.util.User;
 
public class LoginServlet extends HttpServlet 
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
			
			String name = request.getParameter("U");
			name = ((name == null || RDMServicesConstants.USER_SYSTEM.equalsIgnoreCase(name)) ? "" : name.trim());
			
			String password = request.getParameter("P");
			password = ((password == null || "PUSH_CONTEXT".equalsIgnoreCase(password) || "RESET_CONTEXT".equalsIgnoreCase(password)) ? "" : password.trim());
			
			String pushContext = request.getParameter("pushContext");
			pushContext = (pushContext == null ? "" : pushContext.trim());
			
			String resetContext = request.getParameter("resetContext");
			resetContext = (resetContext == null ? "" : resetContext.trim());
			
			User contextUser = (User)session.getAttribute("currentSessionUser");
			User ctxtUser = (User)session.getAttribute("contextUser");
			session.removeAttribute("currentSessionUser");
			session.removeAttribute("contextUser");
			
			String winWidth = request.getParameter("winW");
			String winHeight = request.getParameter("winH");
			
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
			
			if("".equals(name))
			{
				response.sendRedirect("login.jsp?login=fail");
			}
			else
			{
				int i = 1;
				User user = new User(name);
				
				if(!"".equals(password))
				{
					i = user.login(password);
					if (i == 0)
					{
						session.setAttribute("windowWidth", winWidth);
						session.setAttribute("windowHeight", winHeight);
					}
				}
				else if("yes".equals(pushContext) && (contextUser != null && RDMServicesConstants.ROLE_ADMIN.equals(contextUser.getRole())))
				{
					i = user.login("PUSH_CONTEXT");
					if (i == 0)
					{
						session.setAttribute("contextUser", contextUser);
					}
				}
				else if("yes".equals(resetContext) && (ctxtUser != null && name.equals(ctxtUser.getUser())))
				{
					i = user.login("RESET_CONTEXT");
				}

				if (i == 0)
				{
					session.setAttribute("currentSessionUser", user);
					
					DataQuery query = new DataQuery();
					query.logUserActivity(name, logDetails.toString(), true, "Log in success");
					
					response.sendRedirect("services/navigator.jsp");
				}
				else if(i == -1)
				{
					response.sendRedirect("login.jsp?login=blocked");
				}
				else
				{
					DataQuery query = new DataQuery();
					query.logUserActivity(name, logDetails.toString(), true, "Log in failed");
					
					response.sendRedirect("login.jsp?login=fail");
				} 
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
			try 
			{
				throw new Exception(e.getLocalizedMessage());
			} 
			catch (Exception e1) 
			{
				e1.printStackTrace();
			}
		}
	}
	
	public void destroy() 
	{
 
	}
	
}