package com.migdlp.gentlealarm.alarm

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

class AlarmStore(private val kv: KeyValueStore) {

    @Synchronized
    fun list(): List<AlarmSpec> {
        val raw = kv.getString(ALARMS_KEY) ?: return emptyList()
        return try {
            val arr = JSONArray(raw)
            List(arr.length()) { AlarmSpec.fromJson(arr.getJSONObject(it)) }
        } catch (e: Exception) {
            emptyList()
        }
    }

    @Synchronized
    fun get(id: String): AlarmSpec? = list().firstOrNull { it.id == id }

    @Synchronized
    fun upsert(spec: AlarmSpec) {
        val all = list().toMutableList()
        val i = all.indexOfFirst { it.id == spec.id }
        if (i >= 0) all[i] = spec else all.add(spec)
        write(all)
    }

    @Synchronized
    fun delete(id: String): Boolean {
        val all = list().toMutableList()
        if (!all.removeAll { it.id == id }) return false
        write(all)
        return true
    }

    @Synchronized
    fun saveSession(json: JSONObject) = kv.putString(SESSION_KEY, json.toString())

    @Synchronized
    fun loadSession(): JSONObject? = try {
        kv.getString(SESSION_KEY)?.let { JSONObject(it) }
    } catch (e: Exception) {
        null
    }

    @Synchronized
    fun clearSession() = kv.putString(SESSION_KEY, null)

    private fun write(all: List<AlarmSpec>) {
        val arr = JSONArray()
        all.forEach { arr.put(it.toJson()) }
        kv.putString(ALARMS_KEY, arr.toString())
        kv.putInt(SCHEMA_KEY, 1)
    }

    companion object {
        const val ALARMS_KEY = "alarms_v1"
        const val SCHEMA_KEY = "schema_version"
        const val SESSION_KEY = "active_session"
        fun from(context: Context) = AlarmStore(SharedPrefsKeyValueStore(context))
    }
}
