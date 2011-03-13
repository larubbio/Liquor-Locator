package com.pugdogdev.wsll.activity;

import java.io.IOException;

import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.Resources.NotFoundException;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.pugdogdev.wsll.HttpConnection;
import com.pugdogdev.wsll.R;
import com.pugdogdev.wsll.model.Store;

public class StoreDetailActivity extends Activity implements OnClickListener {
	Button viewInventory;
	ProgressDialog progress;
	Integer storeId;
    Store store;
    
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.store_detail);
        
        storeId = (Integer)this.getIntent().getSerializableExtra("storeId");
        
        progress = ProgressDialog.show(this, "Refreshing...","Just chill bro.",true,false);
        downloadStore();
    }
    
    public void loadStore(String jsonRep) { 
        
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
    
	public void handleError(Exception e) {
	    AlertDialog alertDialog = new AlertDialog.Builder(this).create();
	    alertDialog.setTitle("Uh, error bro");
	    alertDialog.setMessage("There was a problem: " + e.toString());
	    alertDialog.setButton("OK", new DialogInterface.OnClickListener() {
	           public void onClick(DialogInterface dialog, int which) {
	                  // here you can add functions
	               }
	    });
	    alertDialog.show();
	}
	
	public void downloadStore() {
        Handler handler = new Handler () {
            public void handleMessage(Message message) {
                switch (message.what) {
                    case HttpConnection.DID_SUCCEED:
                        String response = (String)message.obj;
                        loadStore(response);
                        progress.dismiss();
                        break;
                    case HttpConnection.DID_ERROR:
                        Exception e = (Exception) message.obj;
                        e.printStackTrace();
                        progress.dismiss();
                        handleError(e);
                        break;
                }
            }
        };

        String url = "http://wsll.pugdogdev.com/store/" + storeId;
        new HttpConnection(handler).get(url);
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