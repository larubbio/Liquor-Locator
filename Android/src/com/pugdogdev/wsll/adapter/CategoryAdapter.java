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
import com.pugdogdev.wsll.model.Category;

public class CategoryAdapter extends ArrayAdapter<Category> {
    public CategoryAdapter(Context context, int textViewResourceId, ArrayList<Category> items) {
        super(context, textViewResourceId, items);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View row = convertView;
        
        if (row == null) {
            LayoutInflater inflater = LayoutInflater.from(this.getContext());
            
            row = inflater.inflate(R.layout.list_item_with_count, null);
            
            ImageView disclosure = (ImageView)row.findViewById(R.id.disclosure);
            disclosure.setImageResource(R.drawable.disclosure);
        }
        
        TextView label = (TextView)row.findViewById(R.id.term);
        TextView count = (TextView)row.findViewById(R.id.count);
        
        Category rowItem = (Category)this.getItem(position);
        
        label.setText(rowItem.getName());
        count.setText(rowItem.getCount());

        row.setOnClickListener((OnClickListener)this.getContext());
        row.setTag(position);
        
        return row;
    }
}
