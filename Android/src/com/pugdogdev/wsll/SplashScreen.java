package com.pugdogdev.wsll;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.location.Criteria;
import android.location.LocationManager;
import android.os.Bundle;
import android.view.MotionEvent;
	 
public class SplashScreen extends Activity {
	protected boolean _active = true;
//	protected int _splashTime = 5000; // time to display the splash screen in ms
	protected int _splashTime = 5;
	
	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.splash);
		
		// Just get the instance so it inits and starts getting the location
		LocationHelper lh = LocationHelper.getInstance();
		
		LocationManager locationManager; 
		String context = Context.LOCATION_SERVICE; 
		locationManager = (LocationManager)getSystemService(context); 

		Criteria crta = new Criteria(); 
		crta.setAccuracy(Criteria.ACCURACY_FINE); 
		crta.setAltitudeRequired(false); 
		crta.setBearingRequired(false); 
		crta.setCostAllowed(true); 
		crta.setPowerRequirement(Criteria.POWER_LOW); 
		String provider = locationManager.getBestProvider(crta, true); 

//		String provider = LocationManager.GPS_PROVIDER; 
		lh.setLocation(locationManager.getLastKnownLocation(provider)); 

		locationManager.requestLocationUpdates(provider, 1000, 0, lh); 
		
		Thread splashThread = new Thread() {
			@Override
			public void run() {
				try {
					int waited = 0;
					while (_active && waited < _splashTime) {
						sleep(100);
						waited += 100;
					}
				} catch (InterruptedException e) {
					// do nothing
				} finally {
					finish();
					Intent i = new Intent();
					i.setClassName("com.pugdogdev.wsll",
					               "com.pugdogdev.wsll.LiquorLocatorTabBarActivity");
					startActivity(i);
				}
			}
		};
		splashThread.start();
	}
	
	@Override
	public boolean onTouchEvent(MotionEvent event) {
	    if (event.getAction() == MotionEvent.ACTION_DOWN) {
	        _active = false;
	    }
	    return true;
	}
}
