package com.pugdogdev.wsll;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

import com.pugdogdev.wsll.activity.LiquorLocatorActivity;

public class NetHelper {
	ProgressDialog progress;
	LiquorLocatorActivity lla;
	String _url;
	
	private static final String TAG = "NetHelper";
	
	public NetHelper(LiquorLocatorActivity lla) {
		this.lla = lla;
	}

	public void handleError(Exception e) {
	    AlertDialog alertDialog = new AlertDialog.Builder(lla.getActivity()).create();
	    alertDialog.setTitle("Uh, error bro");
	    alertDialog.setMessage("There was a problem: " + e.toString());
	    alertDialog.setButton("OK", new DialogInterface.OnClickListener() {
	           public void onClick(DialogInterface dialog, int which) {
	                  // here you can add functions
	               }
	    });
	    alertDialog.show();
	}

	public void cancelRequest() {
		lla = null;
		progress.dismiss();
		progress = null;
	}
	
	public void downloadObject(String url) {
		_url = url;
		String json = ((LiquorLocator)lla.getActivity().getApplicationContext()).getCachedJson(url);
		if (json != null) {
			lla.parseJson(json);
			return;
		}
		
		progress = ProgressDialog.show(lla.getActivity(), "Refreshing...","Just chill bro.", true, false);
		
	    Handler handler = new Handler () {
	        public void handleMessage(Message message) {
	            switch (message.what) {
	                case HttpConnection.DID_SUCCEED:
	                    String response = (String)message.obj;
	    	        	Log.d(TAG, "Recevied message HttpConnection.DID_SUCCEED with response " + response);
	    	        	
	                    if (lla != null) {
		                    ((LiquorLocator)lla.getActivity().getApplicationContext()).putCachedJson(_url, response);
	    	        		lla.parseJson(response);	                  
	                    }
	                    
	                    if (progress != null)
	                    	progress.dismiss();
	                    
	                    break;
	                case HttpConnection.DID_ERROR:
	                	if (lla != null) {
		                    Exception e = (Exception) message.obj;
		    	        	Log.d(TAG, "Recevied message HttpConnection.DID_ERROR with response " + e.getMessage());
		                    e.printStackTrace();                    
	                    	progress.dismiss();
		                    handleError(e);
	                	}
	                    break;
	            }
	        }
	    };
	
	
	    new HttpConnection(handler).get(url);
	}
}