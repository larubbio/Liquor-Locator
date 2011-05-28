package com.pugdogdev.wsll;

import android.app.Activity;
import android.content.Intent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.pugdogdev.wsll.activity.DashboardActivity;

public class ActivityBar implements OnClickListener {
	private Activity parent;
	private String title;
	
	public ActivityBar(Activity parent) {
		this.parent = parent;
		
		ImageView homeButton = (ImageView)parent.findViewById(R.id.homeButton);
		homeButton.setOnClickListener(this);
	}

	public ActivityBar(Activity parent, String title) {
		this.parent = parent;
		this.title = title;
	
		setTitle(title);
		
		ImageView homeButton = (ImageView)parent.findViewById(R.id.homeButton);
		homeButton.setOnClickListener(this);
	}

	public void addIcon(View view) {
		LinearLayout layout = (LinearLayout)parent.findViewById(R.id.actionView);
		layout.addView(view);
	}
	
	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;

		TextView activityBarTitle = (TextView)parent.findViewById(R.id.activityBarTitle);
        activityBarTitle.setText(title);
	}

	@Override
	public void onClick(View v) {
    	Intent i = new Intent(parent, DashboardActivity.class);
    	i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
    	parent.startActivity(i);
	}
}
