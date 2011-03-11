package com.pugdogdev.wsll.model;

import java.util.List;

import org.codehaus.jackson.annotate.JsonProperty;

public class Distiller {
	int id;
	String name;
	String url;
	@JsonProperty("lat") float latitude;
	@JsonProperty("long") float longitude;
	String street;
	String address;
	List<Spirit> spirits;
	
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
	public String getUrl() {
		return url;
	}
	public void setUrl(String url) {
		this.url = url;
	}
	public float getLatitude() {
		return latitude;
	}
	public void setLatitude(float latitude) {
		this.latitude = latitude;
	}
	public float getLongitude() {
		return longitude;
	}
	public void setLongitude(float longitude) {
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
	
}
