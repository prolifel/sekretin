package com.prolifel.sekretin2

import com.prolifel.sekretin2.R
import android.annotation.SuppressLint
import android.content.Intent
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.Toolbar
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView


class HomeScreen : AppCompatActivity() {
    private lateinit var rvApp: RecyclerView
    private var list: ArrayList<Aplikasi> = arrayListOf()

    @SuppressLint("WrongViewCast")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_home_screen)

        // define toolbar
        val toolbar = findViewById<Toolbar>(R.id.home_toolbar)
        setSupportActionBar(toolbar)

        // Add list
        rvApp = findViewById(R.id.rv_app)
        rvApp.setHasFixedSize(true)

        // Show list
        list.addAll(AplikasiData.listData)
        showRecyclerList()
    }

    private fun showRecyclerList() {
        rvApp.layoutManager = LinearLayoutManager(this)
        val listAppAdapter = ListAplikasiAdapter(list)
        rvApp.adapter = listAppAdapter
    }

    // show menu profile
    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.menu_profile, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem?): Boolean {
        when (item?.itemId) {
            R.id.menu_button_profile -> {
                // klik tombol profile, intent ke profileactivity
                val intent = Intent(this@HomeScreen, ProfileActivity::class.java)
                startActivity(intent)
            }
            else -> {
            }
        }
        return true
    }
}