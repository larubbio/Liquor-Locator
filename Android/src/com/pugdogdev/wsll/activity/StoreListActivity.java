package com.pugdogdev.wsll.activity;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;
import org.codehaus.jackson.type.TypeReference;

import android.app.Activity;
import android.app.ListActivity;
import android.content.Intent;
import android.content.res.Resources.NotFoundException;
import android.location.Location;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Toast;

import com.pugdogdev.wsll.LocationHelper;
import com.pugdogdev.wsll.NetHelper;
import com.pugdogdev.wsll.R;
import com.pugdogdev.wsll.adapter.SpiritInventoryAdapter;
import com.pugdogdev.wsll.adapter.StoreAdapter;
import com.pugdogdev.wsll.model.SpiritInventory;
import com.pugdogdev.wsll.model.Store;

public class StoreListActivity extends ListActivity implements OnClickListener, LiquorLocatorActivity  {
    String spiritId;

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
    }
 
    @Override
    public void onStart() {
    	super.onStart();
    	setDistanceAndSort();
    }

	private void setDistanceAndSort() {
		Location userLocation = LocationHelper.getInstance().getLocation(); 
    	
		if (storeList != null) {
			for (Store s : storeList)
				s.setDistanceToUser(userLocation);

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
			for (SpiritInventory si : inventoryList) 
				si.getStore().setDistanceToUser(userLocation);

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
    		setListAdapter(new SpiritInventoryAdapter(this, android.R.layout.simple_list_item_1, inventoryList));
    	} else {
    		setListAdapter(new StoreAdapter(this, android.R.layout.simple_list_item_1, storeList));
    	}
    	
    	setDistanceAndSort();
    }
    
    @Override
    public void onClick(View v) {
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

	@Override
	public Activity getActivity() {
		return this;
	}
}
