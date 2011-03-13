package com.pugdogdev.wsll.activity;

import java.io.IOException;

import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;

import android.content.Intent;
import android.content.res.Resources.NotFoundException;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.pugdogdev.wsll.R;
import com.pugdogdev.wsll.model.Store;

public class StoreDetailActivity extends BaseActivity implements OnClickListener {
	Button viewInventory;
	Integer storeId;
    Store store;
    
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.store_detail);
        
        storeId = (Integer)this.getIntent().getSerializableExtra("storeId");
        
        String url = "http://wsll.pugdogdev.com/store/" + storeId;
        downloadObject(url);
    }
    
    @Override
    public void parseObject(String jsonRep) { 
        
        try {
        	ObjectMapper mapper = new ObjectMapper(); // can reuse, share globally
        	store = mapper.readValue(jsonRep, Store.class);
        } catch (JsonParseException e) {
            Toast.makeText(this, "JsonParseException: " + e.toString(), 2000).show();
		} catch (JsonMappingException e) {
            Toast.makeText(this, "JsonMappingException: " + e.toString(), 2000).show();
		} catch (NotFoundException e) {
            Toast.makeText(this, "NotFoundException: " + e.toString(), 2000).show();
		} catch (IOException e) {
            Toast.makeText(this, "IOException: " + e.toString(), 2000).show();
		}
		
        TextView name = (TextView)findViewById(R.id.storeName);
        name.setText(store.getName());

        viewInventory = (Button)findViewById(R.id.viewInventory);
        viewInventory.setVisibility(View.VISIBLE);
        viewInventory.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
    	if (v == viewInventory) {      	
  			Intent i = new Intent(this, CategoryListActivity.class);
        	i.putExtra("storeId", storeId);
        	startActivity(i);
    	}
    }
}