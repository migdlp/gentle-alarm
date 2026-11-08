package com.migdlp.gentlealarm.alarm

import android.content.Context

interface KeyValueStore {
    fun getString(k: String): String?
    fun putString(k: String, v: String?)
    fun getInt(k: String, def: Int): Int
    fun putInt(k: String, v: Int)
}

class InMemoryKeyValueStore : KeyValueStore {
    private val map = HashMap<String, Any?>()
    override fun getString(k: String): String? = map[k] as? String
    override fun putString(k: String, v: String?) {
        if (v == null) map.remove(k) else map[k] = v
    }
    override fun getInt(k: String, def: Int): Int = map[k] as? Int ?: def
    override fun putInt(k: String, v: Int) {
        map[k] = v
    }
}

class SharedPrefsKeyValueStore(context: Context) : KeyValueStore {
    private val prefs = context.createDeviceProtectedStorageContext()
        .getSharedPreferences("gentle_alarm_store", Context.MODE_PRIVATE)

    override fun getString(k: String): String? = prefs.getString(k, null)
    override fun putString(k: String, v: String?) {
        prefs.edit().apply { if (v == null) remove(k) else putString(k, v) }.commit()
    }
    override fun getInt(k: String, def: Int): Int = prefs.getInt(k, def)
    override fun putInt(k: String, v: Int) {
        prefs.edit().putInt(k, v).commit()
    }
}
