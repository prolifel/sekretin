package com.prolifel.sekretin2

object AplikasiData {
    private val aplikasiName = arrayOf(
        "Instagram",
        "Twitter",
        "Discord",
        "Gmail",
        "LinkedIn",
        "Pinterest",
        "Tik Tok",
        "LINE",
        "Tokopedia",
        "Gojek",
        "Grab",
        "Shopee")

    private val aplikasiEmail = arrayOf(
        /*Instagram*/   "oamityadav47p@technt.org",
        /*Twitter*/     "cmjoujzf@leakygutawarness.com",
        /*Discord*/     "ikik@createphase.com",
        /*Gmail*/       "gmotamrd.3@gothill.com",
        /*LinkedIn*/    "hamid.oubaha.751@bengbeng.me",
        /*Pinterest*/   "tteodora_stefanii@walmartttshops.com",
        /*Tik Tok*/     "bzeeshan.munawarn@walmartttshops.com",
        /*LINE*/        "ybeatrizsampaio2o@ilavana.com",
        /*Tokopedia*/   "smatheussoares18@pvtnetflix.com",
        /*Gojek*/       "phamoudisuliman7@cryptoligarch.com",
        /*Grab*/        "nbrah@intersectinglives.net",
        /*Shopee*/      "mmohammed-elkhalx@cryptoligarch.com")

    private val aplikasiIcon = intArrayOf(
        R.drawable.instagram,
        R.drawable.twitter,
        R.drawable.discord,
        R.drawable.gmail,
        R.drawable.linkedin_bigger,
        R.drawable.pinterest_bigger,
        R.drawable.tiktok,
        R.drawable.line,
        R.drawable.tokopedia,
        R.drawable.gojek,
        R.drawable.grab,
        R.drawable.shopee)

    val listData: ArrayList<Aplikasi>
        get() {
            val list = arrayListOf<Aplikasi>()
            for (position in aplikasiName.indices) {
                val app = Aplikasi()
                app.nama = aplikasiName[position]
                app.email = aplikasiEmail[position]
                app.icon = aplikasiIcon[position]
                list.add(app)
            }
            return list
        }
}