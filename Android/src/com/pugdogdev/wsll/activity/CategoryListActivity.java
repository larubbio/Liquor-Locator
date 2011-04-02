package com.pugdogdev.wsll.activity;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;

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
import com.pugdogdev.wsll.LiquorLocator;
import com.pugdogdev.wsll.R;
import com.pugdogdev.wsll.adapter.CategoryAdapter;
import com.pugdogdev.wsll.model.Category;

public class CategoryListActivity extends ListActivity implements OnClickListener  {
	Integer storeId;
	ArrayList<Category> categoryList = new ArrayList<Category>();
	DownloadTask downloadTask;
	ProgressDialog progress;
	String url;
	
    /** Called when the activity is first created. */
    @SuppressWarnings("unchecked")
	@Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FlurryAgent.onStartSession(this, ((LiquorLocator)getApplicationContext()).getFlurryKey());
		
        setContentView(R.layout.categories);
        
        storeId = (Integer)this.getIntent().getSerializableExtra("storeId");
        
        url = "http://wsll.pugdogdev.com/";
        String path = null;
        if (storeId != null) {
        	path = "store/" + storeId + "/categories";
        } else {
        	path = "categories";
        }
        url += path;
        
		categoryList = (ArrayList<Category>)((LiquorLocator)this.getApplicationContext()).getCachedObjects(url);
		if (categoryList != null) {
			setListAdapter(new CategoryAdapter(this, android.R.layout.simple_list_item_1, categoryList));
		} else {
			progress = ProgressDialog.show(this, "Refreshing...","Just chill bro.", true, false);
			downloadTask = new DownloadTask();
			downloadTask.execute(url);
		}
		
    	FlurryAgent.logEvent("CategoriesView");
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
    
    /* (non-Javadoc)
	 * @see com.pugdogdev.wsll.activity.LiquorLocatorActivity#parseObjects(java.lang.String)
	 */
	public void parseJson(String jsonRep) { 
        
        try {
        	ObjectMapper mapper = new ObjectMapper();
        	categoryList = mapper.readValue(jsonRep, new TypeReference<ArrayList<Category>>() {});
        } catch (JsonParseException e) {
            Toast.makeText(this, "JsonParseException: " + e.toString(), 2000).show();
		} catch (JsonMappingException e) {
            Toast.makeText(this, "JsonMappingException: " + e.toString(), 2000).show();
		} catch (NotFoundException e) {
            Toast.makeText(this, "NotFoundException: " + e.toString(), 2000).show();
		} catch (IOException e) {
            Toast.makeText(this, "IOException: " + e.toString(), 2000).show();
		}
 
		((LiquorLocator)getApplicationContext()).putCachedObjects(url, categoryList);
		
        setListAdapter(new CategoryAdapter(this, android.R.layout.simple_list_item_1, categoryList));
        progress.dismiss();
    }
    
	@Override
    public void onClick(View v) {
      	Category cat = categoryList.get((Integer)v.getTag());
       	Intent i = new Intent(this, SpiritListActivity.class);
       	i.putExtra("category", cat.getName());
       	
       	if (storeId != null) {
           	i.putExtra("storeId", storeId);       		
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
