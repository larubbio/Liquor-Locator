package com.pugdogdev.wsll.activity;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
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
import org.codehaus.jackson.type.TypeReference;

import android.app.ProgressDialog;
import android.content.Intent;
import android.content.res.Resources.NotFoundException;
import android.graphics.drawable.Drawable;
import android.location.Location;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.Toast;
import android.widget.ViewSwitcher;

import com.flurry.android.FlurryAgent;
import com.google.android.maps.GeoPoint;
import com.google.android.maps.MapActivity;
import com.google.android.maps.MapController;
import com.google.android.maps.MapView;
import com.google.android.maps.Overlay;
import com.pugdogdev.wsll.ActivityBar;
import com.pugdogdev.wsll.LiquorLocator;
import com.pugdogdev.wsll.LocationHelper;
import com.pugdogdev.wsll.MapPinOverlay;
import com.pugdogdev.wsll.R;
import com.pugdogdev.wsll.StoreOverlayItem;
import com.pugdogdev.wsll.adapter.SpiritInventoryAdapter;
import com.pugdogdev.wsll.adapter.StoreAdapter;
import com.pugdogdev.wsll.model.SpiritInventory;
import com.pugdogdev.wsll.model.Store;

public class StoreListActivity extends MapActivity implements OnClickListener  {
	ActivityBar activityBar;
    String spiritId;
    ListView listView;
    ViewSwitcher viewSwitcher;
    MapView mapView;
    List<Overlay> mapOverlays;
    
    ImageView listIcon;
    ImageView mapIcon;
    boolean showingListView = true;
    
    String url;
	DownloadStoreList downloadTask;
	ProgressDialog progress;
	
	private static final String TAG = "StoreListActivity";
	
    ArrayList<Store> storeList = new ArrayList<Store>();
	ArrayList<SpiritInventory> inventoryList = new ArrayList<SpiritInventory>();
	
    /** Called when the activity is first created. */
    @SuppressWarnings("unchecked")
	@Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FlurryAgent.onStartSession(this, ((LiquorLocator)getApplicationContext()).getFlurryKey());
        setContentView(R.layout.stores);
        
        activityBar = new ActivityBar(this);
        
        spiritId = (String)this.getIntent().getSerializableExtra("spiritId");
        String spiritName = (String)this.getIntent().getSerializableExtra("spiritName");

        url = "http://wsll.pugdogdev.com/";
        String path = null;
        
        Map<String, String> parameters = new HashMap<String, String>();
        if (spiritId != null) {
        	activityBar.setTitle(String.format("Stores w/ %s", spiritName));
        	
        	path = "spirit/" + spiritId + "/stores";
        	
        	parameters.put("Spirit", spiritName);
            FlurryAgent.logEvent("StoresView", parameters);
        } else {
        	activityBar.setTitle("Stores");

        	path = "stores";
        	
            FlurryAgent.logEvent("StoresView");       	
        }
        url += path;

        Object cachedObjects = ((LiquorLocator)this.getApplicationContext()).getCachedObjects(url);

        listView = (ListView)findViewById(R.id.storeList);
        viewSwitcher = (ViewSwitcher)findViewById(R.id.switcher);

        mapView = (MapView)findViewById(R.id.mapView);
        mapOverlays = mapView.getOverlays();
        mapView.setBuiltInZoomControls(true);
        
        listIcon = new ImageView(this);
        listIcon.setOnClickListener(this);

        mapIcon = new ImageView(this);
        mapIcon.setOnClickListener(this);

        Boolean savedConfig = (Boolean)getLastNonConfigurationInstance();
        if (savedConfig != null) {
        	showingListView = savedConfig.booleanValue();
        }
        setActivityBarIcons();
        
        if (!showingListView) {
        	viewSwitcher.showNext();
        }
        
        activityBar.addIcon(listIcon);
        activityBar.addIcon(mapIcon);
        
		if (cachedObjects != null) {
	    	if (spiritId != null) {
	    		inventoryList = (ArrayList<SpiritInventory>)cachedObjects;
				listView.setAdapter(new SpiritInventoryAdapter(this, android.R.layout.simple_list_item_1, inventoryList));
	    	} else {
	    		storeList = (ArrayList<Store>)cachedObjects;
	    		listView.setAdapter(new StoreAdapter(this, android.R.layout.simple_list_item_1, storeList));
	    	}
	    	setDistanceAndSort();
		} else {
			progress = ProgressDialog.show(this, "Refreshing...","Just chill bro.", true, false);
			downloadTask = new DownloadStoreList();
			downloadTask.execute(url);
		}
		
		((LiquorLocator)this.getApplicationContext()).setAdView(this);
	}
 
    @Override
    public Object onRetainNonConfigurationInstance() {
        return new Boolean(showingListView);
    }
    
    private void setActivityBarIcons() {
		if (showingListView == true) {
			listIcon.setImageDrawable(this.getResources().getDrawable(R.drawable.list_selected));
			mapIcon.setImageDrawable(this.getResources().getDrawable(R.drawable.map));
		} else {
			listIcon.setImageDrawable(this.getResources().getDrawable(R.drawable.list));
			mapIcon.setImageDrawable(this.getResources().getDrawable(R.drawable.map_selected));			
		}
    }
    
    @Override
    public void onStart() {
    	super.onStart();
    	setDistanceAndSort();
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
    
	private void setDistanceAndSort() {
		Location userLocation = LocationHelper.getInstance().getLocation(); 
        
        MapController mc = mapView.getController();
        Drawable drawable = this.getResources().getDrawable(R.drawable.pushpin);
        MapPinOverlay itemizedOverlay = new MapPinOverlay(drawable, this);

        
		if (storeList != null) {
			for (Store s : storeList) {
				s.setDistanceToUser(userLocation);

				addMapPin(itemizedOverlay, drawable, mc, s);
			}

			Collections.sort(storeList, new Comparator<Store>(){

				public int compare(Store s1, Store s2) {
					int ret = 0;
					Float d1 = s1.getDistanceToUser();
					Float d2 = s2.getDistanceToUser();

					// If I do not have a distance, set it to something larger than the state
					// This could be because no GPS signal, or bad geocoding
					// The sort will default to name
					if (d1 == null)
						d1 = new Float(99999);
					
					if (d2 == null)
						d2 = new Float(99999);

					ret = d1.compareTo(d2);

					// If they are the same distance, sort by name
					if (ret == 0) {
						ret = s1.getName().compareTo(s2.getName());
					}

					return ret;
				}

			});   		 
		}

		if (inventoryList != null) {
			for (SpiritInventory si : inventoryList) {
				si.getStore().setDistanceToUser(userLocation);
				addMapPin(itemizedOverlay, drawable, mc, si.getStore());
			}

			Collections.sort(inventoryList, new Comparator<SpiritInventory>(){

				public int compare(SpiritInventory si1, SpiritInventory si2) {
					Store s1 = si1.getStore();
					Store s2 = si2.getStore();
					Float d1 = s1.getDistanceToUser();
					Float d2 = s2.getDistanceToUser();
					int ret = 0;
					
					// If I do not have a distance, set it to something larger than the state
					// This could be because no GPS signal, or bad geocoding
					// The sort will default to name
					if (d1 == null)
						d1 = new Float(99999);
					
					if (d2 == null)
						d2 = new Float(99999);

					ret = d1.compareTo(d2);

					// If they are the same distance, sort by name
					if (ret == 0) {
						ret = s1.getName().compareTo(s2.getName());
					}
					
					return ret;
				}

			});   		 
		}
		
        if (userLocation != null) {
            GeoPoint p = new GeoPoint((int) (userLocation.getLatitude() * 1E6), 
            						  (int) (userLocation.getLongitude() * 1E6));

        	mc.animateTo(p);
        	mc.setZoom(14);
        }
     
        itemizedOverlay.populateOverlay();
        mapOverlays.add(itemizedOverlay);

        mapView.invalidate();       
	}
    
	private void addMapPin(MapPinOverlay itemizedOverlay, Drawable drawable, MapController mc, Store store) {
		try {
			double lat = Double.parseDouble(store.getLatitude());
			double lng = Double.parseDouble(store.getLongitude());

			GeoPoint p = new GeoPoint((int) (lat * 1E6), 
					(int) (lng * 1E6));

			StoreOverlayItem overlayItem = new StoreOverlayItem(p, 
					                                            store.getName(),
					                                            store.getAddress(),
														        store);
			itemizedOverlay.addOverlay(overlayItem);
		} catch (NumberFormatException e) {
			// I want to ignore this an just not plot the store
		}
	}
	
    public void parseJson(String jsonRep) { 
        
        try {
        	ObjectMapper mapper = new ObjectMapper(); // can reuse, share globally
        	
        	Log.d(TAG, "About to map items");
        	if (spiritId != null) {
        		inventoryList = mapper.readValue(jsonRep, new TypeReference<ArrayList<SpiritInventory>>() {});
        	} else {
        		storeList = mapper.readValue(jsonRep, new TypeReference<ArrayList<Store>>() {});
        	}
        	Log.d(TAG, "done");
        } catch (JsonParseException e) {
            Toast.makeText(this, "JsonParseException: " + e.toString(), 2000).show();
		} catch (JsonMappingException e) {
            Toast.makeText(this, "JsonMappingException: " + e.toString(), 2000).show();
		} catch (NotFoundException e) {
            Toast.makeText(this, "NotFoundException: " + e.toString(), 2000).show();
		} catch (IOException e) {
            Toast.makeText(this, "IOException: " + e.toString(), 2000).show();
		}

    	if (spiritId != null) {
    		listView.setAdapter(new SpiritInventoryAdapter(this, android.R.layout.simple_list_item_1, inventoryList));
    		((LiquorLocator)getApplicationContext()).putCachedObjects(url, inventoryList);
    	} else {
    		listView.setAdapter(new StoreAdapter(this, android.R.layout.simple_list_item_1, storeList));
    		((LiquorLocator)getApplicationContext()).putCachedObjects(url, storeList);
    	}
    	
    	setDistanceAndSort();
        progress.dismiss();
    }
    
    @Override
    public void onClick(View v) {
    	if (v == listIcon) {
    		if (showingListView == false) {
    			showingListView = true;
    			setActivityBarIcons();
        		viewSwitcher.showNext();
    		}
    	} else if (v == mapIcon) {
    		if (showingListView == true) {
    			showingListView = false;
    			setActivityBarIcons();
        		viewSwitcher.showNext();
    		}    		
    	} else {
    		Store s;
    		if (spiritId != null) {
    			s = ((SpiritInventory)inventoryList.get((Integer)v.getTag())).getStore();
    		} else {
    			s = storeList.get((Integer)v.getTag());
    		}
    		Intent i = new Intent(this, StoreDetailActivity.class);
    		i.putExtra("storeId", s.getId());
    		startActivity(i);
    	}
    }

	@Override
	protected boolean isRouteDisplayed() {
		// TODO Auto-generated method stub
		return false;
	}
	
    @Override
    public void onStop() {
    	super.onStop();
        FlurryAgent.onEndSession(this);
    }
    
    private class DownloadStoreList extends AsyncTask<String, Void, String> {
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
