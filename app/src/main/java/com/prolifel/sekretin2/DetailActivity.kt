package com.prolifel.sekretin2

import android.content.Intent
import android.os.Bundle
import android.widget.ImageView
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import com.bumptech.glide.Glide
import com.bumptech.glide.request.RequestOptions
import kotlinx.android.synthetic.main.card_row.*

class DetailActivity : AppCompatActivity() {
    companion object {
        const val DETAIL_NAMA = "detail_nama"
        const val DETAIL_EMAIL = "detail_email"
        const val DETAIL_PASS = "detail_pass"
        const val DETAIL_ICON = "detail_icon"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_detail)

        val tvDataReceived: TextView = findViewById(R.id.tv_data_received)
        val tvIconReceived: ImageView = findViewById(R.id.tv_icon_received)

        val namaApp = intent.getStringExtra(DETAIL_NAMA)
        val emailApp = intent.getStringExtra(DETAIL_EMAIL)
        val passApp = intent.getStringExtra(DETAIL_PASS)
        val iconApp = intent.getIntExtra(DETAIL_ICON, 0)

        val text = "Name : $namaApp \n $emailApp \n $passApp"

        tvDataReceived.text = text
//        tvIconReceived.setImageResource(iconApp)
        Glide.with(this)
            .load(iconApp)
            .apply(RequestOptions().override(200, 140))
            .into(tvIconReceived)
    }
}