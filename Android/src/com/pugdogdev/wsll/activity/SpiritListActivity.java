package com.pugdogdev.wsll.activity;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
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

import android.app.ListActivity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.res.Resources.NotFoundException;
import android.os.AsyncTask;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Toast;

import com.flurry.android.FlurryAgent;
import com.pugdogdev.wsll.ActivityBar;
import com.pugdogdev.wsll.LiquorLocator;
import com.pugdogdev.wsll.R;
import com.pugdogdev.wsll.adapter.ShortSpiritAdapter;
import com.pugdogdev.wsll.model.ShortSpirit;

public class SpiritListActivity extends ListActivity implements OnClickListener  {
	ActivityBar activityBar;
	
	ArrayList<ShortSpirit> spiritList = new ArrayList<ShortSpirit>();
    DownloadTask downloadTask;
	ProgressDialog progress;
	String url;

    /** Called when the activity is first created. */
    @SuppressWarnings("unchecked")
	@Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FlurryAgent.onStartSession(this, ((LiquorLocator)getApplicationContext()).getFlurryKey());
        setContentView(R.layout.spirits);

        activityBar = new ActivityBar(this);
        
        String category = (String)this.getIntent().getSerializableExtra("category");
        String name = (String)this.getIntent().getSerializableExtra("name");
        Integer storeId = (Integer)this.getIntent().getSerializableExtra("storeId");
        String storeName = (String)this.getIntent().getSerializableExtra("storeName");
        
        url = "http://wsll.pugdogdev.com/";
        String path = null;
        String query = null;
                
    	Map<String, String> parameters = new HashMap<String, String>();

        if (category != null && storeId == null) {
        	activityBar.setTitle(category);
        	
        	path = "spirits";
        	query = "category=" + URLEncoder.encode(category);

        	parameters.put("Category", category);
            FlurryAgent.logEvent("SpiritsView", parameters);
        } else if (category != null && storeId != null) {
        	activityBar.setTitle(String.format("%s - %s", storeName, category));

        	path = "store/" + storeId + "/spirits";
        	query = "category=" + URLEncoder.encode(category);

        	parameters.put("Category", category);
        	parameters.put("Store", storeName);
            FlurryAgent.logEvent("StoreInventoryView", parameters);
        } else if (name != null) {
        	activityBar.setTitle(name);

        	path = "spirits";
        	query = "name=" + URLEncoder.encode(name);        	
        	
        	parameters.put("Name", name);
            FlurryAgent.logEvent("SpiritsView", parameters);
        } else {
        	activityBar.setTitle("Spirits");
        	path = "spirits";

            FlurryAgent.logEvent("SpiritsView", parameters);
        }
        url += path;
        if (query != null) {
        	url += "?" + query;
        }

        spiritList = (ArrayList<ShortSpirit>)((LiquorLocator)this.getApplicationContext()).getCachedObjects(url);
		if (spiritList != null) {
	        setListAdapter(new ShortSpiritAdapter(this, android.R.layout.simple_list_item_1, spiritList));
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


		((LiquorLocator)getApplicationContext()).putCachedObjects(url, spiritList);
		
		setListAdapter(new ShortSpiritAdapter(this, android.R.layout.simple_list_item_1, spiritList));
		
		progress.dismiss(); 
    }
    	    
    @Override
    public void onClick(View v) {
    	ShortSpirit ss = spiritList.get((Integer)v.getTag());
    	Intent i;
    	
    	if (ss.getCount() != null) {
           	i = new Intent(this, SpiritListActivity.class);
           	i.putExtra("name", ss.getName());	
    	} else {
    		i = new Intent(this, SpiritDetailActivity.class);
    		i.putExtra("spiritId", ss.getId());
    	}
    	startActivity(i);
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
