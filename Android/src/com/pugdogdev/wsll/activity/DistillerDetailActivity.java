package com.pugdogdev.wsll.activity;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;

import android.app.Activity;
import android.content.Intent;
import android.content.res.Resources.NotFoundException;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.flurry.android.FlurryAgent;
import com.google.android.maps.GeoPoint;
import com.google.android.maps.MapActivity;
import com.google.android.maps.MapController;
import com.google.android.maps.MapView;
import com.google.android.maps.Overlay;
import com.google.android.maps.OverlayItem;
import com.pugdogdev.wsll.LiquorLocator;
import com.pugdogdev.wsll.MapPinOverlay;
import com.pugdogdev.wsll.NetHelper;
import com.pugdogdev.wsll.R;
import com.pugdogdev.wsll.model.Distiller;
import com.pugdogdev.wsll.model.Spirit;

public class DistillerDetailActivity extends MapActivity implements OnClickListener, LiquorLocatorActivity {
	Integer distillerId;
    Distiller distiller;
    NetHelper net;
    List<Overlay> mapOverlays;
    Drawable drawable;
    MapPinOverlay itemizedOverlay;
    
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FlurryAgent.onStartSession(this, ((LiquorLocator)getApplicationContext()).getFlurryKey());
        setContentView(R.layout.distiller_detail);
        net = new NetHelper(this);
        
        distillerId = (Integer)this.getIntent().getSerializableExtra("distillerId");
        
        String url = "http://wsll.pugdogdev.com/distiller/" + distillerId;
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
        	distiller = mapper.readValue(jsonRep, Distiller.class);
        } catch (JsonParseException e) {
            Toast.makeText(this, "JsonParseException: " + e.toString(), 2000).show();
		} catch (JsonMappingException e) {
            Toast.makeText(this, "JsonMappingException: " + e.toString(), 2000).show();
		} catch (NotFoundException e) {
            Toast.makeText(this, "NotFoundException: " + e.toString(), 2000).show();
		} catch (IOException e) {
            Toast.makeText(this, "IOException: " + e.toString(), 2000).show();
		}
		
        TextView name = (TextView)findViewById(R.id.distillerName);
        TextView street = (TextView)findViewById(R.id.distillerStreet);
        TextView address = (TextView)findViewById(R.id.distillerAddress);
        TextView url = (TextView)findViewById(R.id.url);

        name.setText(distiller.getName());
        street.setText(distiller.getStreet());
        address.setText(distiller.getAddress());
        url.setText(distiller.getUrl());

        TextView spirits = (TextView)findViewById(R.id.spiritsLabel);
        spirits.setVisibility(View.VISIBLE);
        
		LinearLayout layout = (LinearLayout)findViewById(R.id.distillerDetailSpiritLayout);
        for (Spirit s : distiller.getSpirits()) {
        	View row;

        	LayoutInflater inflater = LayoutInflater.from(this);
                
            row = inflater.inflate(R.layout.list_item_spirit, null);
                
            ImageView disclosure = (ImageView)row.findViewById(R.id.disclosure);
            disclosure.setImageResource(R.drawable.disclosure);
                        
            TextView label = (TextView)row.findViewById(R.id.label);
            TextView labelCenter = (TextView)row.findViewById(R.id.labelCenter);
            TextView count = (TextView)row.findViewById(R.id.count);
            TextView size = (TextView)row.findViewById(R.id.size);
            TextView sizeLabel = (TextView)row.findViewById(R.id.sizeLabel);
            TextView price = (TextView)row.findViewById(R.id.price);
            TextView priceLabel = (TextView)row.findViewById(R.id.priceLabel);

           	count.setVisibility(View.GONE);
           	labelCenter.setVisibility(View.GONE);
            	
           	size.setText(s.getSize());
           	price.setText(s.getPrice());
            label.setText(s.getBrandName());

           	size.setVisibility(View.VISIBLE);
           	sizeLabel.setVisibility(View.VISIBLE);
           	price.setVisibility(View.VISIBLE);
           	priceLabel.setVisibility(View.VISIBLE);
           	label.setVisibility(View.VISIBLE);
            
            row.setOnClickListener((OnClickListener)this);
            row.setTag(s.getId());
            
            layout.addView(row);
        }
        
        MapView mapView = (MapView) findViewById(R.id.mapView);
        double lat = Double.parseDouble(distiller.getLatitude());
        double lng = Double.parseDouble(distiller.getLongitude());

        MapController mc = mapView.getController();
        GeoPoint p = new GeoPoint((int) (lat * 1E6), 
        						  (int) (lng * 1E6));
 
        mapOverlays = mapView.getOverlays();
        drawable = this.getResources().getDrawable(R.drawable.pushpin);
        itemizedOverlay = new MapPinOverlay(drawable);
        OverlayItem overlayItem = new OverlayItem(p, "", "");
        itemizedOverlay.addOverlay(overlayItem);
        itemizedOverlay.populateOverlay();
        mapOverlays.add(itemizedOverlay);
        
        mc.animateTo(p);
        mc.setZoom(16); 
        mapView.invalidate();
        
        mapView.setVisibility(View.VISIBLE);
        
        Map<String, String> parameters = new HashMap<String, String>();
    	parameters.put("Distiller", distiller.getName());
        FlurryAgent.logEvent("DistillerDetail", parameters);
    }

    @Override
    public void onClick(View v) {
    	String spiritId = (String)v.getTag();
    	Intent i;
    	
   		i = new Intent(this, SpiritDetailActivity.class);
   		i.putExtra("spiritId", spiritId);
    	
    	startActivity(i);
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