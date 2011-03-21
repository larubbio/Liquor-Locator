package com.pugdogdev.wsll.model;

import java.util.List;

import org.codehaus.jackson.annotate.JsonIgnore;
import org.codehaus.jackson.annotate.JsonIgnoreProperties;
import org.codehaus.jackson.annotate.JsonProperty;

import android.location.Location;

@JsonIgnoreProperties(ignoreUnknown=true)
public class Store {
	int id;
	String name;
	String city;
	String address;
	String address2;
	String zip;
	@JsonProperty("lat") String _latitude;
	@JsonProperty("long") String _longitude;
	List<Contact> contacts;
	List<Hour> hours;
	
	@JsonIgnore Location location;
	@JsonIgnore Float distanceToUser;
	
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
	public String getCity() {
		return city;
	}
	public void setCity(String city) {
		this.city = city;
	}
	public String getAddress() {
		return address;
	}
	public void setAddress(String address) {
		this.address = address;
	}
	public String getAddress2() {
		return address2;
	}
	public void setAddress2(String address2) {
		this.address2 = address2;
	}
	public String getZip() {
		return zip;
	}
	public void setZip(String zip) {
		this.zip = zip;
	}
	public String getLatitude() {
		return _latitude;
	}
	public void setLatitude(String latitude) {
		this._latitude = latitude;
	}
	public String getLongitude() {
		return _longitude;
	}
	public void setLongitude(String longitude) {
		this._longitude = longitude;
	}
	public List<Contact> getContacts() {
		return contacts;
	}
	public void setContacts(List<Contact> contacts) {
		this.contacts = contacts;
	}
	public List<Hour> getHours() {
		return hours;
	}
	public void setHours(List<Hour> hours) {
		this.hours = hours;
	}
	public void setDistanceToUser(Location userLocation) {
		if (userLocation != null && getLocation() != null) {
			float dist = userLocation.distanceTo(getLocation());
			distanceToUser = new Float(dist * (float)0.000621371192);
		}
	}
	public Float getDistanceToUser() {
		return distanceToUser;
	}
	public Location getLocation() {
		
		// Looks like some python has leaked into my json.
		if (location == null && ((_latitude != null && !_latitude.equals("None") &&
				                  _longitude != null && !_longitude.equals("None")))) {
			location = new Location("");
			location.setLatitude(new Double(_latitude).doubleValue());
			location.setLongitude(new Double(_longitude).doubleValue());
		}
		
		return location;
	}
}
