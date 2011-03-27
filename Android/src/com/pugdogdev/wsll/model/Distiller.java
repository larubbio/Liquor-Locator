package com.pugdogdev.wsll.model;

import java.util.List;

import org.codehaus.jackson.annotate.JsonIgnore;
import org.codehaus.jackson.annotate.JsonProperty;

import android.location.Location;

public class Distiller {
	int id;
	String name;
	@JsonProperty("in_store") boolean inStore;
	String url;
	@JsonProperty("lat") String latitude;
	@JsonProperty("long") String longitude;
	String street;
	String address;
	List<Spirit> spirits;
	
	@JsonIgnore Location location;
	
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public boolean isInStore() {
		return inStore;
	}
	public void setInStore(boolean in_store) {
		this.inStore = in_store;
	}
	public String getUrl() {
		return url;
	}
	public void setUrl(String url) {
		this.url = url;
	}
	public String getLatitude() {
		return latitude;
	}
	public void setLatitude(String latitude) {
		this.latitude = latitude;
	}
	public String getLongitude() {
		return longitude;
	}
	public void setLongitude(String longitude) {
		this.longitude = longitude;
	}
	public String getStreet() {
		return street;
	}
	public void setStreet(String street) {
		this.street = street;
	}
	public String getAddress() {
		return address;
	}
	public void setAddress(String address) {
		this.address = address;
	}
	public List<Spirit> getSpirits() {
		return spirits;
	}
	public void setSpirits(List<Spirit> spirits) {
		this.spirits = spirits;
	}
	public Location getLocation() {
		
		// Looks like some python has leaked into my json.
		if (location == null && ((latitude != null && !latitude.equals("None") &&
				                  longitude != null && !longitude.equals("None")))) {
			location = new Location("");
			location.setLatitude(new Double(latitude).doubleValue());
			location.setLongitude(new Double(longitude).doubleValue());
		}
		
		return location;
	}
}
