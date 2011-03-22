package com.pugdogdev.wsll;

import android.app.TabActivity;
import android.content.Intent;
import android.os.Bundle;
import android.widget.TabHost;
import android.widget.TabHost.TabSpec;

import com.pugdogdev.wsll.activity.CategoryListActivity;
import com.pugdogdev.wsll.activity.SpiritListActivity;
import com.pugdogdev.wsll.activity.StoreListActivity;

public class LiquorLocatorTabBarActivity extends TabActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tab);

        TabHost tabHost = (TabHost)findViewById(android.R.id.tabhost);

        TabSpec categoryTab = tabHost.newTabSpec("categories");
        categoryTab.setIndicator("Categories");
        categoryTab.setContent(new Intent(this, CategoryListActivity.class));

        TabSpec storeTab = tabHost.newTabSpec("stores");
        storeTab.setIndicator("Stores");
        storeTab.setContent(new Intent(this, StoreListActivity.class));

        TabSpec searchTab = tabHost.newTabSpec("search");
        searchTab.setIndicator("Spirits");
        searchTab.setContent(new Intent(this, SpiritListActivity.class));

        TabSpec localTab = tabHost.newTabSpec("local");
        localTab.setIndicator("Local");
        localTab.setContent(new Intent(this, SpiritListActivity.class));

        tabHost.addTab(categoryTab);
        tabHost.addTab(storeTab);
        tabHost.addTab(searchTab);
        tabHost.addTab(localTab);
    }
}
