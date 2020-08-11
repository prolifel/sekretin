package com.prolifel.sekretin2

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView

class HomeScreen : AppCompatActivity() {
    private lateinit var rvApp: RecyclerView
    private var list: ArrayList<Aplikasi> = arrayListOf()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_home_screen)

        setSupportActionBar(findViewById(R.id.homeToolbar))

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
}