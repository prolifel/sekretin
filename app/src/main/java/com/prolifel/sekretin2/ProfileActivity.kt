package com.prolifel.sekretin2

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.Button
import android.widget.ImageButton

class ProfileActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_profile)

        val buttonBack = findViewById<ImageButton>(R.id.button_back)

        buttonBack.setOnClickListener {
            finish()
        }
    }
}