package com.client.util;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@SuppressWarnings("serial")
public class StringList implements Serializable
{
	private List<String> list;
	
	public StringList() 
    {
		list = new ArrayList<String>();
    }
	
	public int size() 
    {
        return list.size();
    }
	
	public boolean contains(String s) 
    {
        return list.contains(s);
    }
	
	public boolean contains(StringList sl) 
    {
        for(int i=0, iSz=sl.size(); i<iSz; i++)
        {
        	if(list.contains(sl.get(i)))
        	{
        		return true;
        	}
        }
		return false;
    }
	
	public boolean isEmpty() 
    {
        return list.isEmpty();
    }

    public String get(int i) 
    {
        return list.get(i);
    }
    
    public boolean add(String value)
    {
    	if(list.contains(value))
    	{
    		return true;
    	}
    	return list.add(value);
    }
    
    public void add(int idx, String value)
    {
    	if(list.contains(value))
    	{
    		return;
    	}
    	list.add(idx, value);
    }
    
    public boolean remove(String s) 
    {
        return list.remove(s);
    }
    
    public String remove(int i) 
    {
        return list.remove(i);
    }
    
    public boolean removeAll(StringList sl) 
    {
        return list.removeAll(sl.list);
    }
    
    public void clear()
    {
        list.clear();
    }
    
    public String toString() 
    {
        return list.toString();
    }
    
    public void addAll(StringList sl)
    {
    	this.list.addAll(sl.list);
    }
    
    public void addAll(String[] sArr)
    {
    	for (String s : sArr)   
    	{   
    		this.add(s);   
    	}
    }
    
    public int indexOf(String s)
    {
    	return list.indexOf(s);
    }
    
    public void sort()   
    {   
    	String[] sArr = this.toArray();
    	Arrays.sort(sArr, new IntuitiveStringComparator<String>());
    	
    	this.clear();
    	for (String s : sArr)   
    	{   
    		this.add(s);   
    	}
    }
    
    public String join(char ch) 
    {
    	StringBuilder sb = new StringBuilder();
    	for(int i=0, iSz=list.size(); i<iSz; i++)
    	{
    		if(i > 0)
    		{
    			sb.append(ch);
    		}
    		sb.append(list.get(i));
    	}
    	
        return sb.toString();
    }
    
    public static StringList split(String s, String c) 
    {
    	String[] sa = s.trim().split(c);
    	
    	StringList sl = new StringList();
    	for(int i=0; i<sa.length; i++)
    	{
    		if(!sa[i].trim().isEmpty())
    		{
    			sl.add(sa[i].trim());
    		}
    	}
    	
    	return sl;
    }
    
    public String[] toArray() 
    {
    	String[] s = new String[list.size()];
    	s = (String [])list.toArray(s);
        return s;
    }
}
