package com.pugdogdev.wsll.model;

import org.codehaus.jackson.annotate.JsonProperty;

public class ShortDistiller {
	@JsonProperty("in_store") boolean inStore;
	String name;
	int id;
	
	public boolean isInStore() {
		return inStore;
	}
	public void setInStore(boolean inStore) {
		this.inStore = inStore;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
}
