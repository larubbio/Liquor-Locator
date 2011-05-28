package com.pugdogdev.wsll.activity;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.HttpConnectionParams;
import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.Resources.NotFoundException;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.location.Location;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TableLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.flurry.android.FlurryAgent;
import com.google.android.maps.GeoPoint;
import com.google.android.maps.MapActivity;
import com.google.android.maps.MapController;
import com.google.android.maps.MapView;
import com.google.android.maps.Overlay;
import com.google.android.maps.OverlayItem;
import com.pugdogdev.wsll.ActivityBar;
import com.pugdogdev.wsll.LiquorLocator;
import com.pugdogdev.wsll.LocationHelper;
import com.pugdogdev.wsll.MapPinOverlay;
import com.pugdogdev.wsll.R;
import com.pugdogdev.wsll.model.Contact;
import com.pugdogdev.wsll.model.Hour;
import com.pugdogdev.wsll.model.Store;

public class StoreDetailActivity extends MapActivity implements OnClickListener {
	ActivityBar activityBar;
	Button viewInventory;
	Button directions;
	Integer storeId;
    Store store;
    List<Overlay> mapOverlays;
    Drawable drawable;
    MapPinOverlay itemizedOverlay;
    DownloadTask downloadTask;
	ProgressDialog progress;
	String url;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FlurryAgent.onStartSession(this, ((LiquorLocator)getApplicationContext()).getFlurryKey());
        setContentView(R.layout.store_detail);
        
		activityBar = new ActivityBar(this);
		
        storeId = (Integer)this.getIntent().getSerializableExtra("storeId");
        
        url = "http://wsll.pugdogdev.com/store/" + storeId + "?hoursByDay";
		store = (Store)((LiquorLocator)this.getApplicationContext()).getCachedObjects(url);
		if (store != null) {
			setUI();
		} else {
			progress = ProgressDialog.show(this, "Refreshing...","Just chill bro.", true, false);
			downloadTask = new DownloadTask();
			downloadTask.execute(url);
		}
    }
    
    @Override
    public void onPause() {
    	super.onPause();
    	
    	if (progress != null) {
    		progress.dismiss();
    		progress = null;
    	}
    	
    	if (downloadTask != null) {
    		downloadTask.cancel(true);
    	}
    }
    
    @Override
    public void onResume() {
    	super.onResume();
    	FlurryAgent.onPageView();
    }
    
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
		
		((LiquorLocator)getApplicationContext()).putCachedObjects(url, store);
		
		setUI();
        progress.dismiss();
    }
    
    public void setUI() {
    	activityBar.setTitle(store.getName());
    	
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

        MapView mapView = (MapView) findViewById(R.id.mapView);
        double lat = Double.parseDouble(store.getLatitude());
        double lng = Double.parseDouble(store.getLongitude());

        MapController mc = mapView.getController();
        GeoPoint p = new GeoPoint((int) (lat * 1E6), 
        						  (int) (lng * 1E6));
 
        mapOverlays = mapView.getOverlays();
        drawable = this.getResources().getDrawable(R.drawable.pushpin);
        itemizedOverlay = new MapPinOverlay(drawable, this);
        OverlayItem overlayItem = new OverlayItem(p, "", "");
        itemizedOverlay.addOverlay(overlayItem);
        itemizedOverlay.populateOverlay();
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

        	if (c.getRole().equals("District Manager")) {
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

		((LiquorLocator)this.getApplicationContext()).setAdView(this);
		
        Map<String, String> parameters = new HashMap<String, String>();
    	parameters.put("Store", store.getName());
        FlurryAgent.logEvent("StoreDetail", parameters);
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
        	if (store != null)
        		i.putExtra("storeName", store.getName());
        	startActivity(i);
    	} else if (v == directions) {
    		Location userLocation = LocationHelper.getInstance().getLocation(); 

    		if (userLocation != null) {
				String startLocationParameter = String.format("%f,%f", userLocation.getLatitude(), userLocation.getLongitude());
				String destinationLocationParameter = String.format("%s,%s", store.getLatitude(), store.getLongitude());
				String googleURL = String.format("http://maps.google.com/maps?daddr=%s&saddr=%s", destinationLocationParameter, startLocationParameter);
		
				Intent intent = new Intent(android.content.Intent.ACTION_VIEW, 
									       Uri.parse(googleURL));
				startActivity(intent);
    		} else {
    		    AlertDialog alertDialog = new AlertDialog.Builder(this).create();
    		    alertDialog.setTitle("Uh, where are you?");
    		    alertDialog.setMessage("Sorry, but I don't know where you are so I can't give you directions");
    		    alertDialog.setButton("OK", new DialogInterface.OnClickListener() {
    		           public void onClick(DialogInterface dialog, int which) {
    		                  dialog.dismiss();
    		               }
    		    });
    		    alertDialog.show();
    		}
    	}
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
    
    private class DownloadTask extends AsyncTask<String, Void, String> {
        protected String doInBackground(String... urls) {
        	String result = "";
        	
        	HttpClient httpClient = new DefaultHttpClient();
    		HttpConnectionParams.setSoTimeout(httpClient.getParams(), 25000);
   			HttpResponse response = null;
			HttpGet httpGet = new HttpGet(urls[0]);
			
			try {
				response = httpClient.execute(httpGet);
				BufferedReader br = new BufferedReader(new InputStreamReader(response.getEntity().getContent()));
				String line;
				while ((line = br.readLine()) != null)
					result += line;
				
			} catch (ClientProtocolException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
            return result;
        }

        protected void onPostExecute(String result) {
        	parseJson(result);
        }
    }
}