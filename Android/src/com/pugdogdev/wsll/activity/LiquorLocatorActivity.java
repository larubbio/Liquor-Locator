package com.pugdogdev.wsll.activity;

import android.app.Activity;

public interface LiquorLocatorActivity {

	public abstract void parseJson(String jsonRep);
	public abstract Activity getActivity();
}