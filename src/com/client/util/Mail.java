package com.client.util;

import java.util.Map;
import java.util.Properties;

import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

public class Mail extends RDMServicesConstants
{
	public static void sendMail(Map<String, String> mUserInfo, String sAction) throws Exception
	{
		try 
		{
			Map<String, String> mAcctCredentials = RDMServicesUtils.getAccountCredentials();
			
			Session session = null;
			Properties props = new Properties();

			String sMailHost = mAcctCredentials.get(MAIL_HOST);
			String sMailPort = mAcctCredentials.get(MAIL_PORT);
			final String sFromAddr = mAcctCredentials.get(FROM_ADDRESS);
			final String sPasswd = mAcctCredentials.get(MAILID_PWD);
			
			if("".equals(sMailHost) || "".equals(sMailPort))
			{
				props.put("mail.smtp.host", "smtp.gmail.com");
				props.put("mail.port", "587");
				props.put("mail.smtp.starttls.enable", "true");
				props.put("mail.smtp.auth", "true");
				//props.put("mail.debug", "true");
				
				session = Session.getInstance(props,
					new javax.mail.Authenticator() {
						protected PasswordAuthentication getPasswordAuthentication() {
							return new PasswordAuthentication(sFromAddr, sPasswd);
						}
					}
				);
			}
			else
			{
				props.put("mail.smtp.host", sMailHost);
				props.put("mail.port", sMailPort);
				props.put("mail.smtp.auth", "false");
				//props.put("mail.debug", "true");
				
				session = Session.getInstance(props);
			}
			
			MimeMessage msg = new MimeMessage(session);
			msg.setFrom(new InternetAddress(sFromAddr));
			msg.setRecipient(Message.RecipientType.TO, new InternetAddress(mUserInfo.get(EMAIL)));
			msg.setSubject(getSubject(sAction, mUserInfo));
			msg.setText(getMessage(sAction, mUserInfo));

			Transport.send(msg);
		}
		catch (MessagingException mex)
		{
			System.out.println("Mail failed, exception : " + mex);
		}
	}
	
	private static String getSubject(String key, Map<String, String> mUserInfo)
	{
		String subject = RDMServicesUtils.getProperty("mail."+key+".subject");
		return String.format(subject, mUserInfo.get(LAST_NAME)+", "+mUserInfo.get(FIRST_NAME), 
			mUserInfo.get(USER_ID), mUserInfo.get(PASSWORD));
	}
	
	private static String getMessage(String key, Map<String, String> mUserInfo)
	{
		String message = RDMServicesUtils.getProperty("mail."+key+".message");
		return String.format(message, mUserInfo.get(LAST_NAME)+", "+mUserInfo.get(FIRST_NAME), 
			mUserInfo.get(USER_ID), mUserInfo.get(PASSWORD));
	}
}