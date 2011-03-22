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
import com.pugdogdev.wsll.model.ShortSpirit;

public class ShortSpiritAdapter extends ArrayAdapter<ShortSpirit> {
    public ShortSpiritAdapter(Context context, int textViewResourceId, ArrayList<ShortSpirit> items) {
        super(context, textViewResourceId, items);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View row = convertView;
        
        if (row == null) {
            LayoutInflater inflater = LayoutInflater.from(this.getContext());
            
            row = inflater.inflate(R.layout.list_item_spirit, null);
            
            ImageView disclosure = (ImageView)row.findViewById(R.id.disclosure);
            disclosure.setImageResource(R.drawable.disclosure);
        }
        
        TextView label = (TextView)row.findViewById(R.id.label);
        TextView labelCenter = (TextView)row.findViewById(R.id.labelCenter);
        TextView count = (TextView)row.findViewById(R.id.count);
        TextView size = (TextView)row.findViewById(R.id.size);
        TextView sizeLabel = (TextView)row.findViewById(R.id.sizeLabel);
        TextView price = (TextView)row.findViewById(R.id.price);
        TextView priceLabel = (TextView)row.findViewById(R.id.priceLabel);

        ShortSpirit rowItem = (ShortSpirit)this.getItem(position);
        
        if (rowItem.getCount() != null) {
        	size.setVisibility(View.GONE);
        	sizeLabel.setVisibility(View.GONE);
        	price.setVisibility(View.GONE);
        	priceLabel.setVisibility(View.GONE);
        	label.setVisibility(View.GONE);
        	
        	count.setText(rowItem.getCount());
        	count.setVisibility(View.VISIBLE);

            labelCenter.setText(rowItem.getName());
            labelCenter.setVisibility(View.VISIBLE);
        } else {
        	count.setVisibility(View.GONE);
        	labelCenter.setVisibility(View.GONE);
        	
        	size.setText(rowItem.getSize());
        	price.setText(rowItem.getPrice());
            label.setText(rowItem.getName());

        	size.setVisibility(View.VISIBLE);
        	sizeLabel.setVisibility(View.VISIBLE);
        	price.setVisibility(View.VISIBLE);
        	priceLabel.setVisibility(View.VISIBLE);
        	label.setVisibility(View.VISIBLE);
        }
        row.setOnClickListener((OnClickListener)this.getContext());
        row.setTag(position);
        
        return row;
    }
}
