package com.prolifel.sekretin2

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.bumptech.glide.request.RequestOptions

class ListAplikasiAdapter(val listApp: ArrayList<Aplikasi>) : RecyclerView.Adapter<ListAplikasiAdapter.ListViewHolder>() {

    override fun onCreateViewHolder(viewGroup: ViewGroup, i: Int): ListViewHolder {
        val view: View = LayoutInflater.from(viewGroup.context).inflate(R.layout.card_row, viewGroup, false)
        return ListViewHolder(view)
    }

    override fun onBindViewHolder(holder: ListViewHolder, position: Int) {
        val app = listApp[position]
        Glide.with(holder.itemView.context)
            .load(app.icon)
            .apply(RequestOptions().override(200, 140))
            .into(holder.imgIcon)
        holder.tvName.text = app.nama
        holder.tvDetail.text = app.email
    }

    override fun getItemCount(): Int {
        return listApp.size
    }

    inner class ListViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var tvName: TextView = itemView.findViewById(R.id.tv_item_name)
        var tvDetail: TextView = itemView.findViewById(R.id.tv_item_detail)
        var imgIcon: ImageView = itemView.findViewById(R.id.img_logoApp)
    }
}