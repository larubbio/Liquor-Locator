package com.pugdogdev.wsll.model;

import org.codehaus.jackson.annotate.JsonProperty;

public class ShortSpirit {
	String id;	
	@JsonProperty("p") String price;
	@JsonProperty("s") String size;
	@JsonProperty("n") String name;
	@JsonProperty("c") String count;
	
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	public String getPrice() {
		return price;
	}
	public void setPrice(String price) {
		this.price = price;
	}
	public String getSize() {
		return size;
	}
	public void setSize(String size) {
		this.size = size;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getCount() {
		return count;
	}
	public void setCount(String count) {
		this.count = count;
	}
}
