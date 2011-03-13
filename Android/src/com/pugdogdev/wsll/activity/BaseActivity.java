package com.pugdogdev.wsll.activity;

import com.pugdogdev.wsll.HttpConnection;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.os.Handler;
import android.os.Message;

public abstract class BaseActivity extends Activity {
	ProgressDialog progress;

	public BaseActivity() {
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

	public void downloadObject(String url) {
        progress = ProgressDialog.show(this, "Refreshing...","Just chill bro.", true, false);
        
	    Handler handler = new Handler () {
	        public void handleMessage(Message message) {
	            switch (message.what) {
	                case HttpConnection.DID_SUCCEED:
	                    String response = (String)message.obj;
	                    parseObject(response);
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

	public abstract void parseObject(String jsonRep);

}