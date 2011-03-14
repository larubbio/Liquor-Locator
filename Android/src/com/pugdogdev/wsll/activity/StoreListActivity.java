package com.pugdogdev.wsll.activity;

import java.io.IOException;
import java.util.ArrayList;

import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;
import org.codehaus.jackson.type.TypeReference;

import android.app.Activity;
import android.app.ListActivity;
import android.content.Intent;
import android.content.res.Resources.NotFoundException;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Toast;

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

        String url = "http://wsll.pugdogdev.com/stores";
        if (spiritId != null) {
        	url = "http://wsll.pugdogdev.com/spirit/" + spiritId + "/stores";
        }
        
        net.downloadObject(url);
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
