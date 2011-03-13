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
import com.pugdogdev.wsll.adapter.CategoryAdapter;
import com.pugdogdev.wsll.model.Category;

public class CategoryListActivity extends BaseListActivity implements OnClickListener  {
	Integer storeId;
	ArrayList<Category> categoryList = new ArrayList<Category>();

    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.stores);
        
        storeId = (Integer)this.getIntent().getSerializableExtra("storeId");
        
        String url = "http://wsll.pugdogdev.com/categories";
        if (storeId != null) {
        	url = "http://wsll.pugdogdev.com/store/" + storeId + "/categories";
        }
        downloadObjects(url);
    }
 
    @Override
	public void parseObjects(String jsonRep) { 
        
        try {
        	ObjectMapper mapper = new ObjectMapper(); // can reuse, share globally
        	categoryList = mapper.readValue(jsonRep, new TypeReference<ArrayList<Category>>() {});
        } catch (JsonParseException e) {
            Toast.makeText(this, "JsonParseException: " + e.toString(), 2000).show();
		} catch (JsonMappingException e) {
            Toast.makeText(this, "JsonMappingException: " + e.toString(), 2000).show();
		} catch (NotFoundException e) {
            Toast.makeText(this, "NotFoundException: " + e.toString(), 2000).show();
		} catch (IOException e) {
            Toast.makeText(this, "IOException: " + e.toString(), 2000).show();
		}

        setListAdapter(new CategoryAdapter(this, android.R.layout.simple_list_item_1, categoryList));
    }
	
	@Override
    public void onClick(View v) {
      	Category cat = categoryList.get((Integer)v.getTag());
       	Intent i = new Intent(this, SpiritListActivity.class);
       	i.putExtra("category", cat.getName());
       	
       	if (storeId != null) {
           	i.putExtra("storeId", storeId);       		
       	}
       	startActivity(i);
    }
}
