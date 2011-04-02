package com.pugdogdev.wsll.activity;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.LinearLayout;

import com.flurry.android.FlurryAgent;
import com.pugdogdev.wsll.LiquorLocator;
import com.pugdogdev.wsll.R;

public class DashboardActivity extends Activity implements OnClickListener {
	LinearLayout categories;
	LinearLayout stores;
	LinearLayout search;
	LinearLayout local;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FlurryAgent.onStartSession(this, ((LiquorLocator)getApplicationContext()).getFlurryKey());
        setContentView(R.layout.dashboard);

        categories = (LinearLayout)findViewById(R.id.categoriesDash);
        categories.setOnClickListener(this);
        
        stores = (LinearLayout)findViewById(R.id.storesDash);
        stores.setOnClickListener(this);
        
        search = (LinearLayout)findViewById(R.id.searchDash);
        search.setOnClickListener(this);
        
        local = (LinearLayout)findViewById(R.id.localDash);
        local.setOnClickListener(this);
    }
    
    @Override
    public void onPause() {
    	super.onPause();
    }
    
    @Override
    public void onResume() {
    	super.onResume();
    	FlurryAgent.onPageView();
    }
    @Override
    public void onClick(View v) {
    	if (v == categories) {      	
  			Intent i = new Intent(this, CategoryListActivity.class);
        	startActivity(i);
    	} else if (v == stores) {
  			Intent i = new Intent(this, StoreListActivity.class);
        	startActivity(i);
        } else if (v == search) {
  			Intent i = new Intent(this, SearchActivity.class);
        	startActivity(i);
        } else if (v == local) {
  			Intent i = new Intent(this, LocalActivity.class);
        	startActivity(i);
        }
    }
}