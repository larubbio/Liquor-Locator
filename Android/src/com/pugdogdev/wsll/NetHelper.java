package com.pugdogdev.wsll;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.os.Handler;
import android.os.Message;

import com.pugdogdev.wsll.activity.LiquorLocatorActivity;

public class NetHelper {
	ProgressDialog progress;
	LiquorLocatorActivity lla;

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

	public void downloadObject(String url) {
        progress = ProgressDialog.show(lla.getActivity(), "Refreshing...","Just chill bro.", true, false);
        
	    Handler handler = new Handler () {
	        public void handleMessage(Message message) {
	            switch (message.what) {
	                case HttpConnection.DID_SUCCEED:
	                    String response = (String)message.obj;
	                    lla.parseJson(response);
	                    progress.dismiss();
	                    break;
	                case HttpConnection.DID_ERROR:
	                    Exception e = (Exception) message.obj;
	                    e.printStackTrace();
	                    progress.dismiss();
	                    handleError(e);
	                    break;
	            }
	        }
	    };
	
	
	    new HttpConnection(handler).get(url);
	}
}