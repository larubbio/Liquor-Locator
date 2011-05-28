package com.pugdogdev.wsll.model;

import org.codehaus.jackson.annotate.JsonProperty;

public class Category {
	@JsonProperty("cat") String name;
	String count;
	
	public String getName() {
		return name;
	}
	public void setName(String cat) {
		this.name = cat;
	}
	public String getCount() {
		return count;
	}
	public void setCount(String count) {
		this.count = count;
	}
}
