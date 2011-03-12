package com.pugdogdev.wsll;

import com.pugdogdev.wsll.R;
import com.pugdogdev.wsll.activity.CategoryListActivity;
import com.pugdogdev.wsll.activity.SpiritListActivity;
import com.pugdogdev.wsll.activity.StoreListActivity;

import android.app.TabActivity;
import android.content.Intent;
import android.os.Bundle;
import android.widget.TabHost;
import android.widget.TabHost.TabSpec;

public class LiquorLocatorTabBarActivity extends TabActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tab);

        TabHost tabHost = (TabHost)findViewById(android.R.id.tabhost);

        TabSpec secondTabSpec = tabHost.newTabSpec("tid2");
        secondTabSpec.setIndicator("Categories");
        secondTabSpec.setContent(new Intent(this, CategoryListActivity.class));

        TabSpec thirdTabSpec = tabHost.newTabSpec("tid3");
        thirdTabSpec.setIndicator("Stores");
        thirdTabSpec.setContent(new Intent(this, StoreListActivity.class));

        TabSpec fourthTabSpec = tabHost.newTabSpec("tid4");
        fourthTabSpec.setIndicator("Spirits");
        fourthTabSpec.setContent(new Intent(this, SpiritListActivity.class));

        tabHost.addTab(secondTabSpec);
        tabHost.addTab(thirdTabSpec);
        tabHost.addTab(fourthTabSpec);
    }
}
