package com.pugdogdev.wsll.activity;

import com.pugdogdev.wsll.OfflineListActivity;
import com.pugdogdev.wsll.R;
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

        TabSpec firstTabSpec = tabHost.newTabSpec("tid1");
        firstTabSpec.setIndicator("Brocabs");
        firstTabSpec.setContent(new Intent(this, OfflineListActivity.class));

        TabSpec secondTabSpec = tabHost.newTabSpec("tid2");
        secondTabSpec.setIndicator("Categories");
        secondTabSpec.setContent(new Intent(this, CategoryListActivity.class));

        TabSpec thirdTabSpec = tabHost.newTabSpec("tid3");
        thirdTabSpec.setIndicator("Stores");
        thirdTabSpec.setContent(new Intent(this, StoreListActivity.class));

        TabSpec fourthTabSpec = tabHost.newTabSpec("tid4");
        fourthTabSpec.setIndicator("Spirits");
        fourthTabSpec.setContent(new Intent(this, SpiritListActivity.class));

        tabHost.addTab(firstTabSpec);
        tabHost.addTab(secondTabSpec);
        tabHost.addTab(thirdTabSpec);
        tabHost.addTab(fourthTabSpec);
    }
}
