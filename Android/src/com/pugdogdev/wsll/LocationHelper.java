package com.pugdogdev.wsll;

import android.app.Activity;
import android.location.Location;
import android.location.LocationListener;
import android.os.Bundle;

public class LocationHelper extends Activity implements LocationListener{
	private static LocationHelper instance = null;
	private Location location;

	protected LocationHelper() {

	}
	
	public Location getLocation() {
		return location;
	}

	public void setLocation(Location location) {
		this.location = location;
	}

	public static LocationHelper getInstance() {
		if(instance == null) {
			instance = new LocationHelper();
		}
		return instance;
	}

	@Override
	public void onLocationChanged(Location location) {
		setLocation(location); 
	}

	@Override
	public void onProviderDisabled(String provider) {

	}

	@Override
	public void onProviderEnabled(String provider) {

	}

	@Override
	public void onStatusChanged(String provider, int status, Bundle extras) {

	}
}
