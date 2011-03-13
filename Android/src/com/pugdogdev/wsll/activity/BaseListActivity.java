package com.pugdogdev.wsll.activity;

import com.pugdogdev.wsll.HttpConnection;

import android.app.AlertDialog;
import android.app.ListActivity;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.os.Handler;
import android.os.Message;

public abstract class BaseListActivity extends ListActivity {
	ProgressDialog progress;

	public BaseListActivity() {
		super();
	}

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

	public abstract void parseObjects(String jsonRep);

	public void downloadObjects(String url) {
        progress = ProgressDialog.show(this, "Refreshing...","Just chill bro.", true, false);    

	    Handler handler = new Handler () {
	        public void handleMessage(Message message) {
	            switch (message.what) {
	                case HttpConnection.DID_START:
	                    break;
	                case HttpConnection.DID_SUCCEED:
	                    String response = (String)message.obj;
	                    parseObjects(response);
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