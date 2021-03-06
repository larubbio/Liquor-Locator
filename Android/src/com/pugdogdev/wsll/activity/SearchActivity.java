package com.pugdogdev.wsll.activity;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;
import org.codehaus.jackson.type.TypeReference;

import android.app.AlertDialog;
import android.app.ListActivity;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.Resources.NotFoundException;
import android.os.AsyncTask;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.flurry.android.FlurryAgent;
import com.pugdogdev.wsll.ActivityBar;
import com.pugdogdev.wsll.LiquorLocator;
import com.pugdogdev.wsll.R;
import com.pugdogdev.wsll.adapter.ShortSpiritAdapter;
import com.pugdogdev.wsll.model.ShortSpirit;

public class SearchActivity extends ListActivity implements OnClickListener, TextWatcher  {
	ActivityBar activityBar;
	
	ArrayList<ShortSpirit> spiritList = new ArrayList<ShortSpirit>();
	EditText searchBar;
	AsyncTask<URL, Integer, String> searchTask;
	
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FlurryAgent.onStartSession(this, ((LiquorLocator)getApplicationContext()).getFlurryKey());
        setContentView(R.layout.search);
        
		activityBar = new ActivityBar(this, "Search");
		
        searchBar = (EditText)findViewById(R.id.searchBar);
        searchBar.addTextChangedListener(this);
        searchBar.setOnEditorActionListener(onSearch);
        
		((LiquorLocator)this.getApplicationContext()).setAdView(this);
    }
    
    @Override
    public void onResume() {
    	super.onResume();
    	FlurryAgent.onPageView();
    }
    
    @Override
	protected void onPause() {
		super.onPause();

		InputMethodManager imm = (InputMethodManager)getSystemService(Context.INPUT_METHOD_SERVICE);
		imm.hideSoftInputFromWindow(searchBar.getWindowToken(), 0);
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

        setListAdapter(new ShortSpiritAdapter(this, android.R.layout.simple_list_item_1, spiritList));
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
	public void afterTextChanged(Editable s) {
        
        String url = "http://wsll.pugdogdev.com/";
        String path = "spirits";
        String query =  "search=" + URLEncoder.encode(s.toString());
        
        url += path + "?" + query;
        
        try {
        	if (searchTask != null) 
        			searchTask.cancel(true);
        	
        	searchTask = new LoadSearchResultsTask().execute(new URL(url));
		} catch (MalformedURLException e) {
			handleError(e);
		}
	}
	
	
	private class LoadSearchResultsTask extends AsyncTask<URL, Integer, String> {		 
		protected String doInBackground(URL... urls) {      
			String line, result = "";

			try {
				BufferedReader br = new BufferedReader(new InputStreamReader((InputStream) urls[0].getContent()));

				while ((line = br.readLine()) != null)
					result += line;
			} catch (Exception e) {
				handleError(e);
			}

			return result;
		}

	     protected void onPostExecute(String result) {
	         parseJson(result);
	     }
	 }


	@Override
	public void beforeTextChanged(CharSequence s, int start, int count,
			int after) {
	}


	@Override
	public void onTextChanged(CharSequence s, int start, int before, int count) {
	}
	
	private TextView.OnEditorActionListener onSearch=
		new TextView.OnEditorActionListener() {
		public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
			if (actionId == EditorInfo.IME_NULL) {

				InputMethodManager imm=(InputMethodManager)getSystemService(INPUT_METHOD_SERVICE);
				imm.hideSoftInputFromWindow(v.getWindowToken(), 0);
				
				Map<String, String> parameters = new HashMap<String, String>();
				parameters.put("SearchTerm", v.getText().toString());
		    	FlurryAgent.logEvent("Search", parameters);
			}

			return(true);
		}
	};
	
	public void handleError(Exception e) {
	    AlertDialog alertDialog = new AlertDialog.Builder(this).create();
	    alertDialog.setTitle("Uh, error bro");
	    alertDialog.setMessage("There was a problem: " + e.toString());
	    alertDialog.setButton("OK", new DialogInterface.OnClickListener() {
	           public void onClick(DialogInterface dialog, int which) {
	                  // here you can add functions
	               }
	    });
	    alertDialog.show();
	}
	
    @Override
    public void onStop() {
    	super.onStop();
        FlurryAgent.onEndSession(this);
    }
}
