package com.pugdogdev.wsll;

import java.util.HashMap;

import android.app.Application;

public class LiquorLocator extends Application {
//	private String flurryKey = "5KQFDW1H3BAM5JYA3QXQ"; // Release Key
	private String flurryKey = "HNVL69NJ7XM4V6S1WZXB"; // Development Key
	
	private HashMap<String, String> cache = new HashMap<String, String>();
	
	public String getCachedJson(String url) {
		if (cache.containsKey(url)) {
			return cache.get(url);
		}
		
		return null;
	}
	
	public void putCachedJson(String url, String json) {
		cache.put(url, json);
	}
	
	public String getFlurryKey(){
		return flurryKey;
	}

	public void setFlurryKey(String s){
		flurryKey = s;
	}
}
