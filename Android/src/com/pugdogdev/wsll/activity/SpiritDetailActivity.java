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
import org.apache.http.entity.BufferedHttpEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.HttpConnectionParams;
import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;
import org.codehaus.jackson.type.TypeReference;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.res.Resources.NotFoundException;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.flurry.android.FlurryAgent;
import com.pugdogdev.wsll.ActivityBar;
import com.pugdogdev.wsll.LiquorLocator;
import com.pugdogdev.wsll.R;
import com.pugdogdev.wsll.model.Spirit;

public class SpiritDetailActivity extends Activity implements OnClickListener {
	ActivityBar activityBar;
	
	Button viewStores;
	String spiritId;
    Spirit spirit;
    ImageView spiritImage;
    TextView attribution;

    DownloadTask downloadTask;
    DownloadGoogleTask downloadGoogleTask;
    DownloadImageTask downloadImageTask;
	ProgressDialog progress;
	String url;
    
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FlurryAgent.onStartSession(this, ((LiquorLocator)getApplicationContext()).getFlurryKey());
        setContentView(R.layout.spirit_detail);
        
        spiritImage = (ImageView)findViewById(R.id.spiritImage);
        attribution = (TextView)findViewById(R.id.attribution);
        
        spiritId = (String)this.getIntent().getSerializableExtra("spiritId");
        
        url = "http://wsll.pugdogdev.com/spirit/" + spiritId;
        spirit = (Spirit)((LiquorLocator)this.getApplicationContext()).getCachedObjects(url);
		if (spirit != null) {
	        setUI();
	   		googleImageSearch();
		} else {
			progress = ProgressDialog.show(this, "Refreshing...","Just chill bro.", true, false);
			downloadTask = new DownloadTask();
			downloadTask.execute(url);
		}
		
		activityBar = new ActivityBar(this);
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
    	
    	if (downloadImageTask != null) {
    		downloadImageTask.cancel(true);
    	}

    	if (downloadGoogleTask != null) {
    		downloadGoogleTask.cancel(true);
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
		
		((LiquorLocator)getApplicationContext()).putCachedObjects(url, spirit);
		setUI();
   		googleImageSearch();
		progress.dismiss();
    }

	private void googleImageSearch() {
		String url = "http://ajax.googleapis.com/";
		String path = "ajax/services/search/images";
		String query = "v=1.0&q=" + URLEncoder.encode(spirit.getBrandName()) + "&key=" + URLEncoder.encode("ABQIAAAAOtgwyX124IX2Zpe7gGhBsxS3tJNgUZ1nThh1KEATL8UWMaiosxQ7wZ2BhjWP4DLhPcIryslC442YvA");

		url += path + "?" + query;
		
		downloadGoogleTask = new DownloadGoogleTask();
		downloadGoogleTask.execute(url);
	}
    
    public void setUI() {
    	activityBar.setTitle(spirit.getBrandName());
    	
        TextView name = (TextView)findViewById(R.id.spiritName);
        name.setText(spirit.getBrandName());

        TextView cost = (TextView)findViewById(R.id.cost);
        cost.setText("Cost: " + spirit.getRetailPrice());

        TextView size = (TextView)findViewById(R.id.size);
        size.setText("Size: " + spirit.getSize());

        viewStores = (Button)findViewById(R.id.viewStores);
        viewStores.setVisibility(View.VISIBLE);
        viewStores.setOnClickListener(this);       
        
        Map<String, String> parameters = new HashMap<String, String>();
        parameters.put("Spirit", spirit.getBrandName());
        FlurryAgent.logEvent("SpiritDetail", parameters);
    }

	public void parseGoogleResult(String jsonRep) { 
        
        try {
        	ObjectMapper mapper = new ObjectMapper(); // can reuse, share globally
        	
        	Map<String, Object> imgResp = mapper.readValue(jsonRep, new TypeReference<Map<String, Object>>() { });

        	if (imgResp.containsKey("responseData")) {
        		@SuppressWarnings("unchecked")
        		Map<String, Object> responseData = (Map<String, Object>)imgResp.get("responseData");

        		if (responseData.containsKey("results")) {
        			@SuppressWarnings("unchecked")
        			ArrayList<Object> results = (ArrayList<Object>)responseData.get("results");

        			if (!results.isEmpty()) {
        				@SuppressWarnings("unchecked")
        				Map<String, Object> result = (Map<String, Object>)results.get(0);

        				String url = (String)result.get("url");
        				String visibleUrl = (String)result.get("visibleUrl");
        				//String originalContextUrl = (String)result.get("originalContextUrl");
        				
        				attribution.setText(visibleUrl);
        				
        				downloadImageTask = new DownloadImageTask();
        				downloadImageTask.execute(url);
        			}
        		}
          	}
        } catch (JsonParseException e) {
            Toast.makeText(this, "JsonParseException: " + e.toString(), 2000).show();
		} catch (JsonMappingException e) {
            Toast.makeText(this, "JsonMappingException: " + e.toString(), 2000).show();
		} catch (NotFoundException e) {
            Toast.makeText(this, "NotFoundException: " + e.toString(), 2000).show();
		} catch (IOException e) {
            Toast.makeText(this, "IOException: " + e.toString(), 2000).show();
		}
    }
    
	@Override
    public void onClick(View v) {
    	if (v == viewStores) {
        	Intent i = new Intent(this, StoreListActivity.class);
        	i.putExtra("spiritId", spirit.getId());
        	i.putExtra("spiritName", spirit.getBrandName());
        	startActivity(i);
    	}
    }

    @Override
    public void onStop() {
    	super.onStop();
        FlurryAgent.onEndSession(this);
    }
    
    private class DownloadImageTask extends AsyncTask<String, Void, Bitmap> {
        protected Bitmap doInBackground(String... urls) {
        	Bitmap bm = null;
        	
        	HttpClient httpClient = new DefaultHttpClient();
    		HttpConnectionParams.setSoTimeout(httpClient.getParams(), 25000);
   			HttpResponse response = null;
			HttpGet httpGet = new HttpGet(urls[0]);
			
			try {
				response = httpClient.execute(httpGet);
				BufferedHttpEntity bufHttpEntity;
				bufHttpEntity = new BufferedHttpEntity(response.getEntity());
				bm = BitmapFactory.decodeStream(bufHttpEntity.getContent());
			} catch (ClientProtocolException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
            return bm;
        }

        protected void onPostExecute(Bitmap result) {
        	spiritImage.setImageBitmap(result);
        }
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
    
    private class DownloadGoogleTask extends AsyncTask<String, Void, String> {
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
        	parseGoogleResult(result);
        }
    }
}