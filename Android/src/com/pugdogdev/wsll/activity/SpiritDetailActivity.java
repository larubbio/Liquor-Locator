package com.pugdogdev.wsll.activity;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;
import org.codehaus.jackson.type.TypeReference;

import android.app.Activity;
import android.content.Intent;
import android.content.res.Resources.NotFoundException;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.flurry.android.FlurryAgent;
import com.pugdogdev.wsll.HttpConnection;
import com.pugdogdev.wsll.LiquorLocator;
import com.pugdogdev.wsll.NetHelper;
import com.pugdogdev.wsll.R;
import com.pugdogdev.wsll.model.Spirit;

public class SpiritDetailActivity extends Activity implements OnClickListener, LiquorLocatorActivity {
	Button viewStores;
	String spiritId;
    Spirit spirit;
    ImageView spiritImage;
    TextView attribution;
	NetHelper net;
    
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FlurryAgent.onStartSession(this, ((LiquorLocator)getApplicationContext()).getFlurryKey());
        setContentView(R.layout.spirit_detail);
        net = new NetHelper(this);
        
        spiritId = (String)this.getIntent().getSerializableExtra("spiritId");
        
        String url = "http://wsll.pugdogdev.com/spirit/" + spiritId;
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
        	
       		spirit = mapper.readValue(jsonRep, Spirit.class);
       		String url = "http://ajax.googleapis.com/";
       		String path = "ajax/services/search/images";
       		String query = "v=1.0&q=" + URLEncoder.encode(spirit.getBrandName()) + "&key=" + URLEncoder.encode("ABQIAAAAOtgwyX124IX2Zpe7gGhBsxS3tJNgUZ1nThh1KEATL8UWMaiosxQ7wZ2BhjWP4DLhPcIryslC442YvA");

       		url += path + "?" + query;
       		downloadObject(url);
        } catch (JsonParseException e) {
            Toast.makeText(this, "JsonParseException: " + e.toString(), 2000).show();
		} catch (JsonMappingException e) {
            Toast.makeText(this, "JsonMappingException: " + e.toString(), 2000).show();
		} catch (NotFoundException e) {
            Toast.makeText(this, "NotFoundException: " + e.toString(), 2000).show();
		} catch (IOException e) {
            Toast.makeText(this, "IOException: " + e.toString(), 2000).show();
		}
		
        TextView name = (TextView)findViewById(R.id.spiritName);
        name.setText(spirit.getBrandName());

        TextView cost = (TextView)findViewById(R.id.cost);
        cost.setText("Cost: " + spirit.getRetailPrice());

        TextView size = (TextView)findViewById(R.id.size);
        size.setText("Size: " + spirit.getSize());
        
        spiritImage = (ImageView)findViewById(R.id.spiritImage);
        attribution = (TextView)findViewById(R.id.attribution);

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
        				
        				downloadImage(url);
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
	public Activity getActivity() {
		return this;
	}
	
	public void downloadObject(String url) {
	    Handler handler = new Handler () {
	        public void handleMessage(Message message) {
	            switch (message.what) {
	                case HttpConnection.DID_SUCCEED:
                		String response = (String)message.obj;
                		parseGoogleResult(response);
	                    break;
	                case HttpConnection.DID_ERROR:
	                    Exception e = (Exception) message.obj;
	                    e.printStackTrace();                    
	                    break;
	            }
	        }
	    };
	
	
	    new HttpConnection(handler).get(url);
	}

	public void downloadImage(String url) {
	    Handler handler = new Handler () {
	        public void handleMessage(Message message) {
	            switch (message.what) {
	                case HttpConnection.DID_SUCCEED:
                		Bitmap bm = (Bitmap)message.obj;
                		spiritImage.setImageBitmap(bm);
	                    break;
	                case HttpConnection.DID_ERROR:
	                    Exception e = (Exception) message.obj;
	                    e.printStackTrace();                    
	                    break;
	            }
	        }
	    };
	
	
	    new HttpConnection(handler).bitmap(url);
	}
	
    @Override
    public void onStop() {
    	super.onStop();
        FlurryAgent.onEndSession(this);
    }
}