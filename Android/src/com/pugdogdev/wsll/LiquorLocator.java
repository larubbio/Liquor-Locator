package com.pugdogdev.wsll;

import java.util.HashMap;

import android.app.Activity;
import android.app.Application;
import android.location.Location;

import com.google.ads.AdRequest;
import com.google.ads.AdView;

public class LiquorLocator extends Application {
//	private String flurryKey = "5KQFDW1H3BAM5JYA3QXQ"; // Release Key
	private String flurryKey = "HNVL69NJ7XM4V6S1WZXB"; // Development Key
	
	private String adMobKey = "a14d9bf7683916f";
	
	private HashMap<String, String> cache = new HashMap<String, String>();
	private HashMap<String, Object> objectCache= new HashMap<String, Object>();
	
	public void setAdView(Activity activity) {
        // Create the adView
        AdView adView = (AdView)activity.findViewById(R.id.adView);
        
        if (adView != null) {
		    // Initiate a generic request to load it with an ad
		    AdRequest request = new AdRequest();
		
			Location userLocation = LocationHelper.getInstance().getLocation(); 
		    if (userLocation != null)
		    	request.setLocation(userLocation);
		    
		    request.setTesting(true);
		    
		    adView.loadAd(request);
        }
	}
	
	public String getCachedJson(String url) {
		if (cache.containsKey(url)) {
			return cache.get(url);
		}
		
		return null;
	}
	
	public void putCachedJson(String url, String json) {
		cache.put(url, json);
	}
	
	public Object getCachedObjects(String url) {
		if (objectCache.containsKey(url)) {
			return objectCache.get(url);
		}
		
		return null;
	}
	
	public void putCachedObjects(String url, Object objects) {
		objectCache.put(url, objects);
	}
	
	public String getFlurryKey(){
		return flurryKey;
	}

	public String getAdMobKey() {
		return adMobKey;
	}

}
