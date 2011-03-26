package com.pugdogdev.wsll.activity;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;
import org.codehaus.jackson.type.TypeReference;

import android.app.Activity;
import android.content.Intent;
import android.content.res.Resources.NotFoundException;
import android.graphics.drawable.Drawable;
import android.location.Location;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ListView;
import android.widget.Toast;
import android.widget.ViewSwitcher;

import com.google.android.maps.GeoPoint;
import com.google.android.maps.MapActivity;
import com.google.android.maps.MapController;
import com.google.android.maps.MapView;
import com.google.android.maps.Overlay;
import com.google.android.maps.OverlayItem;
import com.pugdogdev.wsll.LocationHelper;
import com.pugdogdev.wsll.MapPinOverlay;
import com.pugdogdev.wsll.NetHelper;
import com.pugdogdev.wsll.R;
import com.pugdogdev.wsll.adapter.SpiritInventoryAdapter;
import com.pugdogdev.wsll.adapter.StoreAdapter;
import com.pugdogdev.wsll.model.SpiritInventory;
import com.pugdogdev.wsll.model.Store;

public class StoreListActivity extends MapActivity implements OnClickListener, LiquorLocatorActivity  {
    String spiritId;
    ListView listView;
    ViewSwitcher viewSwitcher;
    Button toggle;
    MapView mapView;
    List<Overlay> mapOverlays;
    
    ArrayList<Store> storeList = new ArrayList<Store>();
	ArrayList<SpiritInventory> inventoryList = new ArrayList<SpiritInventory>();

	NetHelper net;
	
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.stores);
        net = new NetHelper(this);
        
        spiritId = (String)this.getIntent().getSerializableExtra("spiritId");

        String url = "http://wsll.pugdogdev.com/";
        String path = null;
        if (spiritId != null) {
        	path = "spirit/" + spiritId + "/stores";
        } else {
        	path = "stores";
        }
        url += path;
        net.downloadObject(url);

        listView = (ListView)findViewById(R.id.storeList);
        viewSwitcher = (ViewSwitcher)findViewById(R.id.switcher);
        toggle = (Button)findViewById(R.id.toggle);
        toggle.setOnClickListener(this);
        mapView = (MapView)findViewById(R.id.mapView);
        mapOverlays = mapView.getOverlays();
        mapView.setBuiltInZoomControls(true);
    }
 
    @Override
    public void onStart() {
    	super.onStart();
    	setDistanceAndSort();
    }

	private void setDistanceAndSort() {
		Location userLocation = LocationHelper.getInstance().getLocation(); 
        
        MapController mc = mapView.getController();
        Drawable drawable = this.getResources().getDrawable(R.drawable.pushpin);
        MapPinOverlay itemizedOverlay = new MapPinOverlay(drawable);

        
		if (storeList != null) {
			for (Store s : storeList) {
				s.setDistanceToUser(userLocation);

				addMapPin(itemizedOverlay, drawable, mc, s);
			}

			Collections.sort(storeList, new Comparator<Store>(){

				public int compare(Store s1, Store s2) {
					int ret = 0;
					Float d1 = s1.getDistanceToUser();
					Float d2 = s2.getDistanceToUser();

					// If I do not have a distance, set it to something larger than the state
					// This could be because no GPS signal, or bad geocoding
					// The sort will default to name
					if (d1 == null)
						d1 = new Float(99999);
					
					if (d2 == null)
						d2 = new Float(99999);

					ret = d1.compareTo(d2);

					// If they are the same distance, sort by name
					if (ret == 0) {
						ret = s1.getName().compareTo(s2.getName());
					}

					return ret;
				}

			});   		 
		}

		if (inventoryList != null) {
			for (SpiritInventory si : inventoryList) {
				si.getStore().setDistanceToUser(userLocation);
				addMapPin(itemizedOverlay, drawable, mc, si.getStore());
			}

			Collections.sort(inventoryList, new Comparator<SpiritInventory>(){

				public int compare(SpiritInventory si1, SpiritInventory si2) {
					Store s1 = si1.getStore();
					Store s2 = si2.getStore();
					Float d1 = s1.getDistanceToUser();
					Float d2 = s2.getDistanceToUser();
					int ret = 0;
					
					// If I do not have a distance, set it to something larger than the state
					// This could be because no GPS signal, or bad geocoding
					// The sort will default to name
					if (d1 == null)
						d1 = new Float(99999);
					
					if (d2 == null)
						d2 = new Float(99999);

					ret = d1.compareTo(d2);

					// If they are the same distance, sort by name
					if (ret == 0) {
						ret = s1.getName().compareTo(s2.getName());
					}
					
					return ret;
				}

			});   		 
		}
		
        if (userLocation != null) {
            GeoPoint p = new GeoPoint((int) (userLocation.getLatitude() * 1E6), 
            						  (int) (userLocation.getLongitude() * 1E6));

        	mc.animateTo(p);
        	mc.setZoom(14);
        }
     
        itemizedOverlay.populateOverlay();
        mapOverlays.add(itemizedOverlay);

        mapView.invalidate();       
	}
    
	private void addMapPin(MapPinOverlay itemizedOverlay, Drawable drawable, MapController mc, Store store) {
		try {
			double lat = Double.parseDouble(store.getLatitude());
			double lng = Double.parseDouble(store.getLongitude());

			GeoPoint p = new GeoPoint((int) (lat * 1E6), 
					(int) (lng * 1E6));

			OverlayItem overlayItem = new OverlayItem(p, store.getName(), "");
			itemizedOverlay.addOverlay(overlayItem);
		} catch (NumberFormatException e) {
			// I want to ignore this an just not plot the store
		}
	}
	
    @Override
    public void parseJson(String jsonRep) { 
        
        try {
        	ObjectMapper mapper = new ObjectMapper(); // can reuse, share globally
        	
        	if (spiritId != null) {
        		inventoryList = mapper.readValue(jsonRep, new TypeReference<ArrayList<SpiritInventory>>() {});
        	} else {
        		storeList = mapper.readValue(jsonRep, new TypeReference<ArrayList<Store>>() {});
        	}
        } catch (JsonParseException e) {
            Toast.makeText(this, "JsonParseException: " + e.toString(), 2000).show();
		} catch (JsonMappingException e) {
            Toast.makeText(this, "JsonMappingException: " + e.toString(), 2000).show();
		} catch (NotFoundException e) {
            Toast.makeText(this, "NotFoundException: " + e.toString(), 2000).show();
		} catch (IOException e) {
            Toast.makeText(this, "IOException: " + e.toString(), 2000).show();
		}

    	if (spiritId != null) {
    		listView.setAdapter(new SpiritInventoryAdapter(this, android.R.layout.simple_list_item_1, inventoryList));
    	} else {
    		listView.setAdapter(new StoreAdapter(this, android.R.layout.simple_list_item_1, storeList));
    	}
    	
    	setDistanceAndSort();
    }
    
    @Override
    public void onClick(View v) {
    	if (v == toggle) {
    		viewSwitcher.showNext();
    	} else {
    		Store s;
    		if (spiritId != null) {
    			s = ((SpiritInventory)inventoryList.get((Integer)v.getTag())).getStore();
    		} else {
    			s = storeList.get((Integer)v.getTag());
    		}
    		Intent i = new Intent(this, StoreDetailActivity.class);
    		i.putExtra("storeId", s.getId());
    		startActivity(i);
    	}
    }

	@Override
	public Activity getActivity() {
		return this;
	}

	@Override
	protected boolean isRouteDisplayed() {
		// TODO Auto-generated method stub
		return false;
	}
}
