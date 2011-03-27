package com.pugdogdev.wsll.activity;

import java.io.IOException;
import java.util.ArrayList;

import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;
import org.codehaus.jackson.type.TypeReference;

import android.app.Activity;
import android.content.Intent;
import android.content.res.Resources.NotFoundException;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TableRow.LayoutParams;
import android.widget.TextView;
import android.widget.Toast;

import com.flurry.android.FlurryAgent;
import com.pugdogdev.wsll.LiquorLocator;
import com.pugdogdev.wsll.NetHelper;
import com.pugdogdev.wsll.R;
import com.pugdogdev.wsll.model.Distiller;

public class LocalActivity extends Activity implements OnClickListener, LiquorLocatorActivity {
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
        	ObjectMapper mapper = new ObjectMapper();
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

		RelativeLayout layout = (RelativeLayout)findViewById(R.id.localDistillersLayout);
		
        TextView withInventory = (TextView)findViewById(R.id.withInventoryLabel);
        withInventory.setVisibility(View.VISIBLE);

        TextView withOutInventory = (TextView)findViewById(R.id.withOutInventoryLabel);
        withOutInventory.setVisibility(View.VISIBLE);

        int withInventoryLastId = R.id.withInventoryLabel;
        int withOutInventoryLastId = R.id.withOutInventoryLabel;
        for (Distiller d : distillers) {
            LayoutInflater inflater = LayoutInflater.from(this);
            
            View item = inflater.inflate(R.layout.list_item, null);
            
            ImageView disclosure = (ImageView)item.findViewById(R.id.disclosure);
            disclosure.setImageResource(R.drawable.disclosure);
            
            TextView label = (TextView)item.findViewById(R.id.term);
            label.setText(d.getName());
            
            item.setOnClickListener((OnClickListener)this);
            item.setTag(d.getId());
            
            RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(LayoutParams.FILL_PARENT, 
                                                                                 LayoutParams.WRAP_CONTENT);
            if (d.isInStore()) {
                params.addRule(RelativeLayout.BELOW, withInventoryLastId );
                item.setId(withInventoryLastId + 2);
                withInventoryLastId = item.getId();
        	} else {
                params.addRule(RelativeLayout.BELOW, withOutInventoryLastId );
                item.setId(withOutInventoryLastId + 2);
                withOutInventoryLastId = item.getId();
        	}    
            item.setLayoutParams( params );
            layout.addView(item);
        }

        RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(LayoutParams.FILL_PARENT, 
        																	 LayoutParams.WRAP_CONTENT);
        params.addRule(RelativeLayout.BELOW, withInventoryLastId );
        withOutInventory.setLayoutParams(params);

        FlurryAgent.logEvent("DistillersView");
    }


    @Override
    public void onClick(View v) {
      	Integer id = (Integer)v.getTag();
       	Intent i = new Intent(this, DistillerDetailActivity.class);
       	i.putExtra("distillerId", id);
       	
       	startActivity(i);
    }

	@Override
	public Activity getActivity() {
		return this;
	}
	
    @Override
    public void onStop() {
    	super.onStop();
        FlurryAgent.onEndSession(this);
    }
}