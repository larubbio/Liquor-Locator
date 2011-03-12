package com.pugdogdev.wsll.activity;

import java.io.IOException;
import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;
import com.pugdogdev.wsll.HttpConnection;
import com.pugdogdev.wsll.R;
import com.pugdogdev.wsll.model.Spirit;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.res.Resources.NotFoundException;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.TextView;
import android.widget.Toast;

public class SpiritDetailActivity extends Activity implements OnClickListener {
	ProgressDialog progress;
	String spiritId;
    Spirit spirit;
    
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.spirit_detail);
        
        spiritId = (String)this.getIntent().getSerializableExtra("spiritId");
        
        progress = ProgressDialog.show(this, "Refreshing...","Just chill bro.",true,false);
        downloadSpirits();
    }
    
    public void loadSpirits(String jsonRep) { 
        
        try {
        	ObjectMapper mapper = new ObjectMapper(); // can reuse, share globally
        	spirit = mapper.readValue(jsonRep, Spirit.class);
        } catch (JsonParseException e) {
            Toast.makeText(this, "JsonParseException: " + e.toString(), 2000).show();
		} catch (JsonMappingException e) {
            Toast.makeText(this, "JsonMappingException: " + e.toString(), 2000).show();
		} catch (NotFoundException e) {
            Toast.makeText(this, "NotFoundException: " + e.toString(), 2000).show();
		} catch (IOException e) {
            Toast.makeText(this, "IOException: " + e.toString(), 2000).show();
		}
		
        TextView term = (TextView)findViewById(R.id.spiritName);
        term.setText(spirit.getBrandName());
    }
    
    public void downloadSpirits() {
        Handler handler = new Handler () {
            public void handleMessage(Message message) {
                switch (message.what) {
                    case HttpConnection.DID_SUCCEED:
                        String response = (String)message.obj;
                        loadSpirits(response);
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

        String url = "http://wsll.pugdogdev.com/spirit/" + spiritId;
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
    }
}