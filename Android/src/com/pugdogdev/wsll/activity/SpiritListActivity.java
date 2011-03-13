package com.pugdogdev.wsll.activity;

import java.io.IOException;
import java.util.ArrayList;

import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;
import org.codehaus.jackson.type.TypeReference;

import android.content.Intent;
import android.content.res.Resources.NotFoundException;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Toast;

import com.pugdogdev.wsll.R;
import com.pugdogdev.wsll.adapter.ShortSpiritAdapter;
import com.pugdogdev.wsll.model.ShortSpirit;

public class SpiritListActivity extends BaseListActivity implements OnClickListener  {
	String category;
	Integer storeId;
	ArrayList<ShortSpirit> spiritList = new ArrayList<ShortSpirit>();

    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.spirits);
        
        category = (String)this.getIntent().getSerializableExtra("category");
        storeId = (Integer)this.getIntent().getSerializableExtra("storeId");
        
        String url = "http://wsll.pugdogdev.com/spirits";
        if (category != null && storeId == null) {
        	url += "?category=" + category;
        } else if (category != null && storeId != null) {
        	url = "http://wsll.pugdogdev.com/store/" + storeId + "/spirits?category=" + category;
        }
        downloadObjects(url);
    }
 
    @Override
    public void parseObjects(String jsonRep) { 
        
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
    	Intent i = new Intent(this, SpiritDetailActivity.class);
    	i.putExtra("spiritId", ss.getId());
    	startActivity(i);
    }

	public void loadCategories(String jsonRep) {
	}
}
