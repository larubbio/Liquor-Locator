package com.pugdogdev.wsll.activity;

import java.io.IOException;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.List;

import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;

import android.app.Activity;
import android.content.Intent;
import android.content.res.Resources.NotFoundException;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.location.Location;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TableLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.maps.GeoPoint;
import com.google.android.maps.MapActivity;
import com.google.android.maps.MapController;
import com.google.android.maps.MapView;
import com.google.android.maps.Overlay;
import com.google.android.maps.OverlayItem;
import com.pugdogdev.wsll.LocationHelper;
import com.pugdogdev.wsll.MapPinOverlay;
import com.pugdogdev.wsll.NetHelper;
import com.pugdogdev.wsll.R;
import com.pugdogdev.wsll.model.Contact;
import com.pugdogdev.wsll.model.Hour;
import com.pugdogdev.wsll.model.Store;

public class StoreDetailActivity extends MapActivity implements OnClickListener, LiquorLocatorActivity {
	Button viewInventory;
	Button directions;
	Integer storeId;
    Store store;
    NetHelper net;
    List<Overlay> mapOverlays;
    Drawable drawable;
    MapPinOverlay itemizedOverlay;
    
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.store_detail);
        net = new NetHelper(this);
        
        storeId = (Integer)this.getIntent().getSerializableExtra("storeId");
        
        String url = "http://wsll.pugdogdev.com/store/" + storeId + "?hoursByDay";
        net.downloadObject(url);
    }
    
    @Override
    public void parseJson(String jsonRep) { 
        
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
        TextView address = (TextView)findViewById(R.id.storeAddress);
        TextView street = (TextView)findViewById(R.id.storeCity);
        TextView openOrClosed = (TextView)findViewById(R.id.storeOpenOrClosed);

        TableLayout table = (TableLayout)findViewById(R.id.hoursTable);
        table.setVisibility(View.VISIBLE);
        
        TextView monLabel = (TextView)findViewById(R.id.monLabel);
        TextView monHours = (TextView)findViewById(R.id.monHours);

        TextView tueLabel = (TextView)findViewById(R.id.tueLabel);
        TextView tueHours = (TextView)findViewById(R.id.tueHours);

        TextView wedLabel = (TextView)findViewById(R.id.wedLabel);
        TextView wedHours = (TextView)findViewById(R.id.wedHours);

        TextView thurLabel = (TextView)findViewById(R.id.thurLabel);
        TextView thurHours = (TextView)findViewById(R.id.thurHours);

        TextView friLabel = (TextView)findViewById(R.id.friLabel);
        TextView friHours = (TextView)findViewById(R.id.friHours);

        TextView satLabel = (TextView)findViewById(R.id.satLabel);
        TextView satHours = (TextView)findViewById(R.id.satHours);

        TextView sunLabel = (TextView)findViewById(R.id.sunLabel);
        TextView sunHours = (TextView)findViewById(R.id.sunHours);

        // Get the current day (Sun == 1)
        GregorianCalendar cal = new GregorianCalendar( );
        int day = cal.get( Calendar.DAY_OF_WEEK );
        int curTime = (cal.get( Calendar.HOUR_OF_DAY ) * 100) + cal.get( Calendar.MINUTE );    
        
        // Handle hours
        for (Hour h : store.getHours()) {
            
            if (h.getDay().equals("Sun")) {
                processLablesForDay(sunLabel, sunHours, 
                					openOrClosed, h.getOpen(), h.getClose(), day, 
                					Calendar.SUNDAY, curTime); 
            }
            
            if (h.getDay().equals("Mon")) {
                processLablesForDay(monLabel, monHours, 
    					openOrClosed, h.getOpen(), h.getClose(), day, 
    					Calendar.MONDAY, curTime); 
            }
            
            if (h.getDay().equals("Tue")) {
                processLablesForDay(tueLabel, tueHours, 
    					openOrClosed, h.getOpen(), h.getClose(), day, 
    					Calendar.TUESDAY, curTime); 
            }
            
            if (h.getDay().equals("Wed")) {
                processLablesForDay(wedLabel, wedHours, 
    					openOrClosed, h.getOpen(), h.getClose(), day, 
    					Calendar.WEDNESDAY, curTime); 
            }

            if (h.getDay().equals("Thu")) {
                processLablesForDay(thurLabel, thurHours, 
    					openOrClosed, h.getOpen(), h.getClose(), day, 
    					Calendar.THURSDAY, curTime); 
            }
            
            if (h.getDay().equals("Fri")) {
                processLablesForDay(friLabel, friHours, 
    					openOrClosed, h.getOpen(), h.getClose(), day, 
    					Calendar.FRIDAY, curTime); 
            }
            
            if (h.getDay().equals("Sat")) {
                processLablesForDay(satLabel, satHours, 
    					openOrClosed, h.getOpen(), h.getClose(), day, 
    					Calendar.SATURDAY, curTime); 
            }
        }
                
        name.setText(String.format("%s - #%d", store.getName(), store.getId()));
        address.setText(store.getAddress());
        street.setText(String.format("%s, WA %s", store.getCity(), store.getZip()));
        openOrClosed.setText("CLOSED");

        MapView mapView = (MapView) findViewById(R.id.mapView);
        double lat = Double.parseDouble(store.getLatitude());
        double lng = Double.parseDouble(store.getLongitude());

        MapController mc = mapView.getController();
        GeoPoint p = new GeoPoint((int) (lat * 1E6), 
        						  (int) (lng * 1E6));
 
        mapOverlays = mapView.getOverlays();
        drawable = this.getResources().getDrawable(R.drawable.pushpin);
        itemizedOverlay = new MapPinOverlay(drawable);
        OverlayItem overlayItem = new OverlayItem(p, "", "");
        itemizedOverlay.addOverlay(overlayItem);
        mapOverlays.add(itemizedOverlay);
        
        mc.animateTo(p);
        mc.setZoom(16); 
        mapView.invalidate();
        
        mapView.setVisibility(View.VISIBLE);
        
        TextView storeManager = (TextView)findViewById(R.id.storeManager);
        TextView storeManagerName = (TextView)findViewById(R.id.storeManagerName);
        TextView storeManagerNumber = (TextView)findViewById(R.id.storeManagerNumber);
        
        TextView districtManager = (TextView)findViewById(R.id.districtManager);
        TextView districtManagerName = (TextView)findViewById(R.id.districtManagerName);
        TextView districtManagerNumber = (TextView)findViewById(R.id.districtManagerNumber);
        
        for (Contact c : store.getContacts()) {
        	if (c.getRole().equals("Store Manager")) {
        		storeManager.setVisibility(View.VISIBLE);
        		storeManagerName.setVisibility(View.VISIBLE);
        		storeManagerNumber.setVisibility(View.VISIBLE);
        		
        		storeManagerName.setText(c.getName());
        		storeManagerNumber.setText(c.getNumber());
        	}

        	if (c.getRole().equals("Store Manager")) {
        		districtManager.setVisibility(View.VISIBLE);
        		districtManagerName.setVisibility(View.VISIBLE);
        		districtManagerNumber.setVisibility(View.VISIBLE);
        		
        		districtManagerName.setText(c.getName());
        		districtManagerNumber.setText(c.getNumber());
        	}
        }
        
        viewInventory = (Button)findViewById(R.id.viewInventory);
        viewInventory.setVisibility(View.VISIBLE);
        viewInventory.setOnClickListener(this);

        directions = (Button)findViewById(R.id.directions);
        directions.setVisibility(View.VISIBLE);
        directions.setOnClickListener(this);

    }

    private void processLablesForDay(TextView dayLabel, TextView dayHoursLabel, TextView openOrClosed,
    								 String open, String close, int weekday, 
    								 int today, int curTime) {
    
    	if ( open == null ) {
    		dayHoursLabel.setText("Closed");
    	} else {
    		dayHoursLabel.setText(String.format("%s - %s", open, close));
    	}

    	if (weekday == today) {    
    		dayLabel.setTypeface(Typeface.DEFAULT_BOLD);		
    		dayHoursLabel.setTypeface(Typeface.DEFAULT_BOLD);

    		openOrClosed.setText("CLOSED");
    		if (open != null && close != null) {
    			String[] openItems = open.split(":");
    			int openTime = (Integer.parseInt(openItems[0]) * 100) + Integer.parseInt(openItems[1]);

    			String[] closeItems = close.split(":");
    			int closingTime = ((Integer.parseInt(closeItems[0]) + 12) * 100) + Integer.parseInt(closeItems[1]);

    			if (curTime > openTime && curTime < closingTime) {  
    				openOrClosed.setText("OPEN");
    			}
    		}
    	}
    }

    @Override
    public void onClick(View v) {
    	if (v == viewInventory) {      	
  			Intent i = new Intent(this, CategoryListActivity.class);
        	i.putExtra("storeId", storeId);
        	startActivity(i);
    	} else if (v == directions) {
    		Location userLocation = LocationHelper.getInstance().getLocation(); 
    		
    		String startLocationParameter = String.format("%f,%f", userLocation.getLatitude(), userLocation.getLongitude());
    		String destinationLocationParameter = String.format("%s,%s", store.getLatitude(), store.getLongitude());
    		String googleURL = String.format("http://maps.google.com/maps?daddr=%s&saddr=%s", destinationLocationParameter, startLocationParameter);
    		Intent browserIntent = new Intent("android.intent.action.VIEW", Uri.parse(googleURL));
    		startActivity(browserIntent);
    	}
    	/*
    	    try {
        Intent callIntent = new Intent(Intent.ACTION_CALL);
        callIntent.setData(Uri.parse("tel:123456789"));
        startActivity(callIntent);
    } catch (ActivityNotFoundException e) {
        Log.e("helloandroid dialing example", "Call failed", e);
    }
    	  */
    }

	@Override
	public Activity getActivity() {
		return this;
	}

	@Override
	protected boolean isRouteDisplayed() {
		return false;
	}
}