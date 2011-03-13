package com.pugdogdev.wsll.activity;

import java.io.IOException;

import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;

import android.content.Intent;
import android.content.res.Resources.NotFoundException;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.pugdogdev.wsll.R;
import com.pugdogdev.wsll.model.Spirit;

public class SpiritDetailActivity extends BaseActivity implements OnClickListener {
	Button viewStores;
	String spiritId;
    Spirit spirit;
    
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.spirit_detail);
        
        spiritId = (String)this.getIntent().getSerializableExtra("spiritId");
        
        String url = "http://wsll.pugdogdev.com/spirit/" + spiritId;
        downloadObject(url);
    }
    
    @Override
	public void parseObject(String jsonRep) { 
        
        try {
        	ObjectMapper mapper = new ObjectMapper(); // can reuse, share globally
        	spirit = mapper.readValue(jsonRep, Spirit.class);
        } catch (JsonParseException e) {
            Toast.makeText(this, "JsonParseException: " + e.toString(), 2000).show();
		} catch (JsonMappingException e) {
            Toast.makeText(this, "JsonMappingException: " + e.toString(), 2000).show();
		} catch (NotFoundException e) {
            Toast.makeText(this, "NotFoundException: " + e.toString(), 2000).show();
		} catch (IOException e) {
            Toast.makeText(this, "IOException: " + e.toString(), 2000).show();
		}
		
        TextView name = (TextView)findViewById(R.id.spiritName);
        name.setText(spirit.getBrandName());

        TextView cost = (TextView)findViewById(R.id.cost);
        cost.setText("Cost: " + spirit.getRetailPrice());

        TextView size = (TextView)findViewById(R.id.size);
        size.setText("Size: " + spirit.getSize());

        viewStores = (Button)findViewById(R.id.viewStores);
        viewStores.setVisibility(View.VISIBLE);
        viewStores.setOnClickListener(this);
    }
    
	@Override
    public void onClick(View v) {
    	if (v == viewStores) {
        	Intent i = new Intent(this, StoreListActivity.class);
        	i.putExtra("spiritId", spirit.getId());
        	startActivity(i);
    	}
    }
}