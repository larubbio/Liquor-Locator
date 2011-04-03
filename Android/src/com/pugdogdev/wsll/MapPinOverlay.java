package com.pugdogdev.wsll;

import java.util.ArrayList;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.net.Uri;

import com.google.android.maps.ItemizedOverlay;
import com.google.android.maps.OverlayItem;
import com.pugdogdev.wsll.activity.StoreDetailActivity;

public class MapPinOverlay extends ItemizedOverlay<OverlayItem> {
	private ArrayList<OverlayItem> mOverlays = new ArrayList<OverlayItem>();
	private Context mContext;
	
	// Only here so I can reference in onTap
	private int storeId;
	private OverlayItem item;
	
	public MapPinOverlay(Drawable defaultMarker) {
		super(boundCenterBottom(defaultMarker));
	}

	public MapPinOverlay(Drawable defaultMarker, Context context) {
		  this(defaultMarker);
		  mContext = context;
	}
	
	@Override
	protected OverlayItem createItem(int i) {
		return mOverlays.get(i);
	}

	@Override
	public int size() {
		return mOverlays.size();
	}
	
	public void addOverlay(OverlayItem overlay) {
	    mOverlays.add(overlay);
	}
	
	public void populateOverlay() {
		populate();
	}
	
	/* If my storeId is set, go to that store otherwise open a full screen map */
	@Override
	protected boolean onTap(int index) {
		item = mOverlays.get(index);
		
		if (item instanceof StoreOverlayItem) {
			StoreOverlayItem storeItem = (StoreOverlayItem)item;
			storeId = storeItem.getStore().getId();
			
			AlertDialog.Builder dialog = new AlertDialog.Builder(mContext);
			dialog.setTitle(item.getTitle());
			dialog.setMessage(item.getSnippet());
			dialog.setCancelable(false);
			dialog.setPositiveButton("View Store", 
					new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog, int id) {
					Intent i = new Intent(mContext, StoreDetailActivity.class);
					i.putExtra("storeId", storeId);
					mContext.startActivity(i);
				}
			});
			dialog.setNegativeButton("Cancel", 
					new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog, int id) {
					dialog.cancel();
				}
			});
			dialog.show();
		} else {
			AlertDialog.Builder dialog = new AlertDialog.Builder(mContext);
			dialog.setTitle("View map full screen?");
			dialog.setMessage("");
			dialog.setCancelable(false);
			dialog.setPositiveButton("Yes", 
					new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog, int id) {
					String googleURL = String.format("geo:%s", item.routableAddress());

					Intent intent = new Intent(android.content.Intent.ACTION_VIEW, 
							Uri.parse(googleURL));
					mContext.startActivity(intent);
				}
			});
			dialog.setNegativeButton("No", 
					new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog, int id) {
					dialog.cancel();
				}
			});
			dialog.show();	
		}
		return true;
	}
}
