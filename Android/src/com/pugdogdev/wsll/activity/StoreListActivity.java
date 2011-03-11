package com.pugdogdev.wsll.activity;

import java.io.IOException;
import java.util.ArrayList;

import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;
import org.codehaus.jackson.type.TypeReference;
import com.pugdogdev.wsll.HttpConnection;
import com.pugdogdev.wsll.R;
import com.pugdogdev.wsll.adapter.StoreAdapter;
import com.pugdogdev.wsll.model.Store;

import android.app.AlertDialog;
import android.app.ListActivity;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.res.Resources.NotFoundException;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.Toast;

public class StoreListActivity extends ListActivity implements OnClickListener  {
	Button refresh;
	ProgressDialog progress;
	ArrayList<Store> storeList = new ArrayList<Store>();

    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.stores);
        refresh=(Button)findViewById(R.id.online_refresh);
        refresh.setOnClickListener(this);
    }
 
    public void loadStores(String jsonRep) { 
        
        try {
        	ObjectMapper mapper = new ObjectMapper(); // can reuse, share globally
        	storeList = mapper.readValue(jsonRep, new TypeReference<ArrayList<Store>>() {});
        } catch (JsonParseException e) {
            Toast.makeText(this, "JsonParseException: " + e.toString(), 2000).show();
		} catch (JsonMappingException e) {
            Toast.makeText(this, "JsonMappingException: " + e.toString(), 2000).show();
		} catch (NotFoundException e) {
            Toast.makeText(this, "NotFoundException: " + e.toString(), 2000).show();
		} catch (IOException e) {
            Toast.makeText(this, "IOException: " + e.toString(), 2000).show();
		}

        setListAdapter(new StoreAdapter(this, android.R.layout.simple_list_item_1, storeList));
    }
    
    public void downloadStores() {
        Handler handler = new Handler () {
            public void handleMessage(Message message) {
                switch (message.what) {
                    case HttpConnection.DID_START:
                        refresh.setText("Refreshing...");
                        break;
                    case HttpConnection.DID_SUCCEED:
                        refresh.setText("Refresh");
                        String response = (String)message.obj;
                        loadStores(response);
                        progress.dismiss();
                        break;
                    case HttpConnection.DID_ERROR:
                        refresh.setText("Refresh");
                        Exception e = (Exception) message.obj;
                        e.printStackTrace();
                        progress.dismiss();
                        handleError(e);
                        break;
                }
            }
        };

        new HttpConnection(handler).get("http://wsll.pugdogdev.com/stores");
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
    
    @Override
    public void onClick(View v) {
        if (v == refresh) {
            progress = ProgressDialog.show(this, "Refreshing...","Just chill bro.",true,false);
            downloadStores();
        }
    }
}
