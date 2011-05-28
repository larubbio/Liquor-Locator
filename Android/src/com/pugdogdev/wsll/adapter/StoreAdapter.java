package com.pugdogdev.wsll.adapter;

import java.util.ArrayList;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.pugdogdev.wsll.R;
import com.pugdogdev.wsll.model.Store;

public class StoreAdapter extends ArrayAdapter<Store> {
    public StoreAdapter(Context context, int textViewResourceId, ArrayList<Store> items) {
        super(context, textViewResourceId, items);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View row = convertView;
        
        if (row == null) {
            LayoutInflater inflater = LayoutInflater.from(this.getContext());
            
            row = inflater.inflate(R.layout.list_item_store, null);
            
            ImageView disclosure = (ImageView)row.findViewById(R.id.disclosure);
            disclosure.setImageResource(R.drawable.disclosure);
        }
        
        TextView label = (TextView)row.findViewById(R.id.label);
        TextView distance = (TextView)row.findViewById(R.id.distance);
        TextView distanceLabel = (TextView)row.findViewById(R.id.distanceLabel);

        Store store = (Store)this.getItem(position);
        label.setText(store.getName());
        
        if (store.getDistanceToUser() != null) {
        	distance.setVisibility(View.VISIBLE);
        	distanceLabel.setVisibility(View.VISIBLE);
        	
        	distance.setText(String.format("%.2f", store.getDistanceToUser().floatValue()));
        } else {
        	distance.setVisibility(View.GONE);
        	distanceLabel.setVisibility(View.GONE);
        }
        row.setOnClickListener((OnClickListener)this.getContext());
        row.setTag(position);
        
        return row;
    }
}
