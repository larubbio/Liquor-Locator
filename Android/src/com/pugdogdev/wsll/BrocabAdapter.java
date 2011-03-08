package com.pugdogdev.wsll;

import java.util.ArrayList;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

public class BrocabAdapter extends ArrayAdapter<String> {
    public BrocabAdapter(Context context, int textViewResourceId, ArrayList<String> items) {
        super(context, textViewResourceId, items);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View row = convertView;
        
        if (row == null) {
            LayoutInflater inflater = LayoutInflater.from(this.getContext());
            
            row = inflater.inflate(R.layout.list_item_with_disclosure,null);
            
            ImageView disclosure = (ImageView)row.findViewById(R.id.disclosure);
            disclosure.setImageResource(R.drawable.disclosure);
        }
        
        TextView label = (TextView)row.findViewById(R.id.term);
        label.setText(this.getItem(position));
        
        row.setOnClickListener((OnClickListener)this.getContext());
        row.setTag(position);
        
        return row;
    }
}
