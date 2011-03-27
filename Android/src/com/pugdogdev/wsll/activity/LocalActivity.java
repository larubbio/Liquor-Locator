package com.pugdogdev.wsll.activity;

import java.io.IOException;
import java.util.ArrayList;

import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;
import org.codehaus.jackson.type.TypeReference;

import android.app.Activity;
import android.content.res.Resources.NotFoundException;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.TableRow.LayoutParams;
import android.widget.TextView;
import android.widget.Toast;

import com.flurry.android.FlurryAgent;
import com.google.android.maps.MapActivity;
import com.pugdogdev.wsll.LiquorLocator;
import com.pugdogdev.wsll.NetHelper;
import com.pugdogdev.wsll.R;
import com.pugdogdev.wsll.model.Distiller;

public class LocalActivity extends MapActivity implements OnClickListener, LiquorLocatorActivity {
    NetHelper net;
    ArrayList<Distiller> distillers;
    
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FlurryAgent.onStartSession(this, ((LiquorLocator)getApplicationContext()).getFlurryKey());
        setContentView(R.layout.local);
        net = new NetHelper(this);
        
        String url = "http://wsll.pugdogdev.com/distillers";
        net.downloadObject(url);
    }
    
    @Override
    public void onResume() {
    	super.onResume();
    	FlurryAgent.onPageView();
    }
    
    @Override
    public void parseJson(String jsonRep) { 
        
        try {
        	ObjectMapper mapper = new ObjectMapper(); // can reuse, share globally
        	distillers = mapper.readValue(jsonRep, new TypeReference<ArrayList<Distiller>>() {});
        } catch (JsonParseException e) {
            Toast.makeText(this, "JsonParseException: " + e.toString(), 2000).show();
		} catch (JsonMappingException e) {
            Toast.makeText(this, "JsonMappingException: " + e.toString(), 2000).show();
		} catch (NotFoundException e) {
            Toast.makeText(this, "NotFoundException: " + e.toString(), 2000).show();
		} catch (IOException e) {
            Toast.makeText(this, "IOException: " + e.toString(), 2000).show();
		}

        TableLayout withInventory = (TableLayout)findViewById(R.id.withInventory);
        withInventory.setVisibility(View.VISIBLE);

        TableLayout withOutInventory = (TableLayout)findViewById(R.id.withOutInventory);
        withOutInventory.setVisibility(View.VISIBLE);

        for (Distiller d : distillers) {
            TableRow tr = new TableRow(this);
            tr.setLayoutParams(new LayoutParams(LayoutParams.FILL_PARENT,
                           						LayoutParams.WRAP_CONTENT));
                 
            TextView t = new TextView(this);
            t.setText(d.getName());
            t.setLayoutParams(new LayoutParams(LayoutParams.FILL_PARENT,
                           					   LayoutParams.WRAP_CONTENT));

            tr.addView(t);
            
            if (d.isInStore()) {
                withInventory.addView(tr,new TableLayout.LayoutParams(LayoutParams.FILL_PARENT,
                													  LayoutParams.WRAP_CONTENT));
        	} else {
                withOutInventory.addView(tr,new TableLayout.LayoutParams(LayoutParams.FILL_PARENT,
						  												 LayoutParams.WRAP_CONTENT));
        	
        	}
        }
        FlurryAgent.logEvent("DistillersView");
    }


    @Override
    public void onClick(View v) {
    }

	@Override
	public Activity getActivity() {
		return this;
	}

	@Override
	protected boolean isRouteDisplayed() {
		return false;
	}
	
    @Override
    public void onStop() {
    	super.onStop();
        FlurryAgent.onEndSession(this);
    }
}