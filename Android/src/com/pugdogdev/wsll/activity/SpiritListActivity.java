package com.pugdogdev.wsll.activity;

import java.io.IOException;
import java.util.ArrayList;

import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;
import org.codehaus.jackson.type.TypeReference;

import com.pugdogdev.wsll.HttpConnection;
import com.pugdogdev.wsll.R;
import com.pugdogdev.wsll.adapter.ShortSpiritAdapter;
import com.pugdogdev.wsll.model.ShortSpirit;

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

public class SpiritListActivity extends ListActivity implements OnClickListener  {
	Button refresh;
	ProgressDialog progress;
	String category;
	ArrayList<ShortSpirit> spiritList = new ArrayList<ShortSpirit>();

    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.spirits);
        
        category = (String)this.getIntent().getSerializableExtra("category");
        
        refresh=(Button)findViewById(R.id.online_refresh);
        refresh.setOnClickListener(this);
    }
 
    public void loadShortSpirits(String jsonRep) { 
        
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
    
    public void downloadShortSpirits() {
        Handler handler = new Handler () {
            public void handleMessage(Message message) {
                switch (message.what) {
                    case HttpConnection.DID_START:
                        refresh.setText("Refreshing...");
                        break;
                    case HttpConnection.DID_SUCCEED:
                        refresh.setText("Refresh");
                        String response = (String)message.obj;
                        loadShortSpirits(response);
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

        String url = "http://wsll.pugdogdev.com/spirits";
        if (category != null) {
        	url += "?category=" + category;
        }
        new HttpConnection(handler).get(url);
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
            downloadShortSpirits();
        }
    }
}
