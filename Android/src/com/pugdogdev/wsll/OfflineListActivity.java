package com.pugdogdev.wsll;

import com.pugdogdev.wsll.BrocabAdapter;

import android.app.ListActivity;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.app.AlertDialog;
import android.content.DialogInterface;

import java.util.ArrayList;
import java.util.Arrays;

public class OfflineListActivity extends ListActivity implements OnClickListener {
	String[] brocabs = {"Brotocol","Brobot","Theodore Broosevelt"};
	ArrayList<String> brocabList = new ArrayList<String>(Arrays.asList(brocabs));
	    
	    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        setListAdapter(new BrocabAdapter(this,
        								 android.R.layout.simple_list_item_1,
        								 brocabList));
    }
 
    @Override
    public void onClick(View v) {
        AlertDialog alertDialog = new AlertDialog.Builder(this).create();
        alertDialog.setTitle("BRO");
        alertDialog.setMessage("Check it: " + brocabs[(Integer) v.getTag()]);
        alertDialog.setButton(AlertDialog.BUTTON_NEUTRAL,"OK",new DialogInterface.OnClickListener() { 
                    public void onClick(DialogInterface dialog, int which) {

                    }
                });     
        alertDialog.show();
    }
 }