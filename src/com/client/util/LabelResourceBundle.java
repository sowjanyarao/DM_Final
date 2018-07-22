package com.client.util;

import java.util.Locale;
import java.util.ResourceBundle;

public class LabelResourceBundle
{
	private ResourceBundle defResourceBundle = null;
	private ResourceBundle userResourceBundle = null;
	
	public LabelResourceBundle()
	{
		defResourceBundle = ResourceBundle.getBundle("DataManagerStringResource");
	}
	
	public LabelResourceBundle(Locale l)
	{
		defResourceBundle = ResourceBundle.getBundle("DataManagerStringResource");
		userResourceBundle = ResourceBundle.getBundle("DataManagerStringResource", l);
	}
	
    public String getProperty(String sProperty) 
    {
    	if(userResourceBundle != null && userResourceBundle.containsKey(sProperty))
    	{
    		String sValue = (String)userResourceBundle.getObject(sProperty);
    		return sValue.trim();
    	}
    	else if(defResourceBundle != null && defResourceBundle.containsKey(sProperty))
    	{
    		String sValue = (String)defResourceBundle.getObject(sProperty);
    		return sValue.trim();
    	}
		return sProperty;
    }
}
