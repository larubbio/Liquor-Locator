package com.pugdogdev.wsll;

import com.google.android.maps.GeoPoint;
import com.google.android.maps.OverlayItem;
import com.pugdogdev.wsll.model.Store;

public class StoreOverlayItem extends OverlayItem {
	Store store;
	
	public StoreOverlayItem(GeoPoint point, String title, String snippet, Store store) {
		super(point, title, snippet);
		
		this.store = store;
	}

	public Store getStore() {
		return store;
	}

	public void setStore(Store store) {
		this.store = store;
	}

}
