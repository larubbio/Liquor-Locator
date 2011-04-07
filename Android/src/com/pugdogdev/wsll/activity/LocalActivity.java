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

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.res.Resources.NotFoundException;
import android.os.AsyncTask;
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
import com.pugdogdev.wsll.ActivityBar;
import com.pugdogdev.wsll.LiquorLocator;
import com.pugdogdev.wsll.R;
import com.pugdogdev.wsll.model.Distiller;

public class LocalActivity extends Activity implements OnClickListener {
	ActivityBar activityBar;
	
    ArrayList<Distiller> distillers;
	DownloadTask downloadTask;
	ProgressDialog progress;
	String url;
	
    @SuppressWarnings("unchecked")
	@Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FlurryAgent.onStartSession(this, ((LiquorLocator)getApplicationContext()).getFlurryKey());
        setContentView(R.layout.local);
		
		activityBar = new ActivityBar(this, "Local Distillers");
		
        url = "http://wsll.pugdogdev.com/distillers";
        
        distillers = (ArrayList<Distiller>)((LiquorLocator)this.getApplicationContext()).getCachedObjects(url);
		if (distillers != null) {
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
		
		((LiquorLocator)getApplicationContext()).putCachedObjects(url, distillers);
		
		setUI();
		progress.dismiss();
    }
    
    
    public void setUI() {
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

		((LiquorLocator)this.getApplicationContext()).setAdView(this);
		
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