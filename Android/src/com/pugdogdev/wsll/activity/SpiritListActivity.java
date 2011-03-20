package com.pugdogdev.wsll.activity;

import java.io.IOException;
import java.net.URLEncoder;
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
import com.pugdogdev.wsll.adapter.ShortSpiritAdapter;
import com.pugdogdev.wsll.model.ShortSpirit;

public class SpiritListActivity extends ListActivity implements OnClickListener, LiquorLocatorActivity  {
	ArrayList<ShortSpirit> spiritList = new ArrayList<ShortSpirit>();
	NetHelper net;

    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.spirits);
        net = new NetHelper(this);
        
        String category = (String)this.getIntent().getSerializableExtra("category");
        String name = (String)this.getIntent().getSerializableExtra("name");
        Integer storeId = (Integer)this.getIntent().getSerializableExtra("storeId");
        
        String url = "http://wsll.pugdogdev.com/";
        String path = null;
        String query = null;
        
        if (category != null && storeId == null) {
        	path = "spirits";
        	query = "category=" + URLEncoder.encode(category);
        } else if (category != null && storeId != null) {
        	path = "store/" + storeId + "/spirits";
        	query = "category=" + URLEncoder.encode(category);
        } else if (name != null) {
        	path = "spirits";
        	query = "name=" + URLEncoder.encode(name);        	
        } else {
        	path = "spirits";
        }
        url += path;
        if (query != null) {
        	url += "?" + query;
        }
        net.downloadObject(url);
    }
 
    @Override
    public void parseJson(String jsonRep) { 
        
        try {
        	ObjectMapper mapper = new ObjectMapper(); // can reuse, share globally
        	spiritList = mapper.readValue(jsonRep, new TypeReference<ArrayList<ShortSpirit>>() {});
        } catch (JsonParseException e) {
            Toast.makeText(this, "JsonParseException: " + e.toString(), 2000).show();
		} catch (JsonMappingException e) {
            Toast.makeText(this, "JsonMappingException: " + e.toString(), 2000).show();
		} catch (NotFoundException e) {
            Toast.makeText(this, "NotFoundException: " + e.toString(), 2000).show();
		} catch (IOException e) {
            Toast.makeText(this, "IOException: " + e.toString(), 2000).show();
		}

        setListAdapter(new ShortSpiritAdapter(this, android.R.layout.simple_list_item_1, spiritList));
    }
    	    
    @Override
    public void onClick(View v) {
    	ShortSpirit ss = spiritList.get((Integer)v.getTag());
    	Intent i;
    	
    	if (ss.getCount() != null) {
           	i = new Intent(this, SpiritListActivity.class);
           	i.putExtra("name", ss.getName());	
    	} else {
    		i = new Intent(this, SpiritDetailActivity.class);
    		i.putExtra("spiritId", ss.getId());
    	}
    	startActivity(i);
    }

	@Override
	public Activity getActivity() {
		return this;
	}
}
