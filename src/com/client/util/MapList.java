package com.client.util;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MapList
{
	private List<Map<String, String>> list;
	
    public MapList() 
    {
    	list = new ArrayList<Map<String, String>>();
    }    
	
    public int size() 
    {
        return list.size();
    }
    
	public boolean contains(Map<String, String> map) 
    {
        return list.contains(map);
    }
	
	public boolean isEmpty() 
    {
        return list.isEmpty();
    }

	public Map<String, String> get(int i) 
    {
        return list.get(i);
    }
    
	public boolean add(Map<String, String> value) 
    {
        return list.add(value);
    }

	public int addAll(MapList l) 
    {
        for(int i=0; i<l.size(); i++)
        {
        	list.add(l.get(i));
        }
        return list.size();
    }
	
	public void insertAt(int i, Map<String, String> value) 
    {
        list.add(i, value);
    }
	
	public void set(int i, Map<String, String> value) 
    {
        list.set(i, value);
    }
	
	public boolean remove(Map<String, String> value) 
    {
        return list.remove(value);
    }
    
    public Map<String, String> remove(int i) 
    {
        return list.remove(i);
    }
	
	public String toString() 
    {
        return list.toString();
    }
	
	public void sort(String sKey) 
    {
		sort(sKey, null);
    }
	
	public void sort(String sKey1, String sKey2) 
    {
		String s = null;
		StringList sl = new StringList();
		Map<String, String> m = null;
		Map<String, Map<String, String>> map = new HashMap<String, Map<String, String>>();
		
		for(int i=0; i<list.size(); i++)
        {
			m = list.get(i);
			s = m.get(sKey1);
			if(sKey2 != null && !"".equals(sKey2))
			{
				s = s + m.get(sKey2);
			}
			
			sl.add(s);
			map.put(s, m);
        }
		
		sl.sort();
		list = new ArrayList<Map<String, String>>();

		for(int i=0; i<sl.size(); i++)
        {
			s = sl.get(i);
			list.add(map.get(s));
        }
    }
}
