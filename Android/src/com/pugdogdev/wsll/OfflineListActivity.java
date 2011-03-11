package com.pugdogdev.wsll;

import com.pugdogdev.wsll.BrocabAdapter;

import android.app.ListActivity;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.content.Intent;
import android.content.res.Resources.NotFoundException;

import java.util.ArrayList;
import java.io.IOException;
import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;
import org.codehaus.jackson.type.TypeReference;
import android.widget.Toast;

public class OfflineListActivity extends ListActivity implements OnClickListener {
    ArrayList<Brocab> brocabList;

    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);   
        loadBrocabulary();
    }
 
    public void loadBrocabulary() { 
        try {
        	ObjectMapper mapper = new ObjectMapper(); // can reuse, share globally
        	brocabList = mapper.readValue(getResources().openRawResource(R.raw.brocabs), new TypeReference<ArrayList<Brocab>>() {});
        } catch (JsonParseException e) {
            Toast.makeText(this, "JsonParseException: " + e.toString(), 2000).show();
		} catch (JsonMappingException e) {
            Toast.makeText(this, "JsonMappingException: " + e.toString(), 2000).show();
		} catch (NotFoundException e) {
            Toast.makeText(this, "NotFoundException: " + e.toString(), 2000).show();
		} catch (IOException e) {
            Toast.makeText(this, "IOException: " + e.toString(), 2000).show();
		}

        setListAdapter(new BrocabAdapter(this,android.R.layout.simple_list_item_1,brocabList));
    }
    
    @Override
    public void onClick(View v) {
        Brocab brocab = brocabList.get((Integer)v.getTag());
        Intent i = new Intent(this, BrocabDetailActivity.class);
        i.putExtra("brocab",brocab);
        startActivity(i);
    }
 }