package com.pugdogdev.wsll;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;

public class BrocabDetailActivity extends Activity implements OnClickListener {
    Button back;
    Button favorite;

    Brocab brocab;
    boolean favorited;
    boolean fromFavorites;
    
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.detail);
        
        brocab = (Brocab)this.getIntent().getSerializableExtra("brocab");
        
        back=(Button)findViewById(R.id.detail_back);
        back.setOnClickListener(this);
        
        favorite=(Button)findViewById(R.id.detail_add);
        favorite.setOnClickListener(this);

        TextView term = (TextView)findViewById(R.id.detail_term);
        term.setText(brocab.getTerm());
        
        TextView description = (TextView)findViewById(R.id.detail_description);
        description.setText(brocab.getDescription());
        
        TextView author = (TextView)findViewById(R.id.detail_author);
        if(brocab.getAuthor() != null && brocab.getAuthor().length() > 0 && !brocab.getAuthor().equals("null")) {
            author.setText("Submitted by " + brocab.getAuthor());
        }
    }
    
    @Override
    public void onClick(View v) {
        if (v == back) {
            finish();
        }
        else if (v == favorite) {
            // Do this later
        }
    }
}