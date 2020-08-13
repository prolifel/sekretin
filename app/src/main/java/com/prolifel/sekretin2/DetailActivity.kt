package com.prolifel.sekretin2

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import com.bumptech.glide.Glide
import com.bumptech.glide.request.RequestOptions
import kotlinx.android.synthetic.main.activity_detail.*
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

        // cari view nya
        val tvNamaAppReceived: TextView = findViewById(R.id.tv_namaApp_received)
        val tvEmailReceived: TextView = findViewById(R.id.tv_email_received)
        val tvPassReceived: TextView = findViewById(R.id.tv_pass_received)
        val tvIconReceived: ImageView = findViewById(R.id.tv_icon_received)

        // terima data dari intent
        val namaApp = intent.getStringExtra(DETAIL_NAMA)
        val emailApp = intent.getStringExtra(DETAIL_EMAIL)
        val passApp = intent.getStringExtra(DETAIL_PASS)
        val iconApp = intent.getIntExtra(DETAIL_ICON, 0)

        // assign data ke local val
        val strNamaApp = namaApp
        val strEmailApp = emailApp
        val strPassApp = passApp

        // assign local val ke view
        tvNamaAppReceived.text = strNamaApp
        tvEmailReceived.text = strEmailApp
        tvPassReceived.text = strPassApp

        // assign iconApp ke view
        Glide.with(this)
            .load(iconApp)
            .apply(RequestOptions().override(320, 128))
            .into(tvIconReceived)

        // logic for copy password
        val btnCopy = findViewById<Button>(R.id.btn_copy)
        btnCopy.setOnClickListener{
            val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            val clip: ClipData = ClipData.newPlainText("text", passApp)
            clipboard.setPrimaryClip(clip)
            Toast.makeText(this@DetailActivity, "Password telah disalin", Toast.LENGTH_SHORT).show()
        }

        // logic back button
        val buttonBack = findViewById<ImageButton>(R.id.button_back)
        buttonBack.setOnClickListener {
            finish()
        }
    }
}