package com.migdlp.gentlealarm.alarm

import org.json.JSONArray
import org.json.JSONObject

class InvalidSpecException(val field: String) : IllegalArgumentException(field)

data class AlarmSpec(
    val id: String,
    val enabled: Boolean = true,
    val hour: Int = 7,
    val minute: Int = 30,
    val weekdays: List<Int> = emptyList(),
    val label: String = "",
    val soundId: String = "birds_dawn",
    val customSoundUri: String? = null,
    val customSoundName: String? = null,
    val sunriseMinutes: Int = 20,
    val rampMinutes: Int = 3,
    val maxVolumePercent: Int = 70,
    val vibrate: Boolean = true,
    val skipRingAtEpochMs: Long? = null,
    val scheduledRingAtEpochMs: Long? = null,
    val createdAtEpochMs: Long = 0L,
) {
    fun validate(): AlarmSpec {
        if (id.isEmpty()) throw InvalidSpecException("id")
        if (hour !in 0..23) throw InvalidSpecException("hour")
        if (minute !in 0..59) throw InvalidSpecException("minute")
        if (weekdays.any { it !in 1..7 }) throw InvalidSpecException("weekdays")
        val trimmed = label.trim()
        if (trimmed.codePointCount(0, trimmed.length) > 40) throw InvalidSpecException("label")
        if (soundId !in SOUND_IDS) throw InvalidSpecException("soundId")
        if (soundId == "custom") {
            if (customSoundUri.isNullOrEmpty()) throw InvalidSpecException("customSoundUri")
            if (customSoundName.isNullOrEmpty()) throw InvalidSpecException("customSoundName")
        }
        if (sunriseMinutes !in SUNRISE_OPTIONS) throw InvalidSpecException("sunriseMinutes")
        if (rampMinutes !in RAMP_OPTIONS) throw InvalidSpecException("rampMinutes")
        if (maxVolumePercent !in 10..100 || maxVolumePercent % 10 != 0) {
            throw InvalidSpecException("maxVolumePercent")
        }
        return copy(label = trimmed, weekdays = weekdays.distinct().sorted())
    }

    fun toJson(): JSONObject = JSONObject().apply {
        put("id", id)
        put("enabled", enabled)
        put("hour", hour)
        put("minute", minute)
        put("weekdays", JSONArray(weekdays))
        put("label", label)
        put("soundId", soundId)
        put("customSoundUri", customSoundUri ?: JSONObject.NULL)
        put("customSoundName", customSoundName ?: JSONObject.NULL)
        put("sunriseMinutes", sunriseMinutes)
        put("rampMinutes", rampMinutes)
        put("maxVolumePercent", maxVolumePercent)
        put("vibrate", vibrate)
        put("skipRingAtEpochMs", skipRingAtEpochMs ?: JSONObject.NULL)
        put("scheduledRingAtEpochMs", scheduledRingAtEpochMs ?: JSONObject.NULL)
        put("createdAtEpochMs", createdAtEpochMs)
    }

    fun toMap(): Map<String, Any?> = mapOf(
        "id" to id,
        "enabled" to enabled,
        "hour" to hour,
        "minute" to minute,
        "weekdays" to weekdays,
        "label" to label,
        "soundId" to soundId,
        "customSoundUri" to customSoundUri,
        "customSoundName" to customSoundName,
        "sunriseMinutes" to sunriseMinutes,
        "rampMinutes" to rampMinutes,
        "maxVolumePercent" to maxVolumePercent,
        "vibrate" to vibrate,
        "skipRingAtEpochMs" to skipRingAtEpochMs,
        "scheduledRingAtEpochMs" to scheduledRingAtEpochMs,
        "createdAtEpochMs" to createdAtEpochMs,
    )

    companion object {
        val SOUND_IDS = setOf(
            "birds_dawn", "soft_waves", "light_rain", "chimes",
            "calm_piano", "singing_bowls", "custom",
        )
        val SUNRISE_OPTIONS = setOf(0, 5, 10, 15, 20, 30, 45)
        val RAMP_OPTIONS = setOf(1, 2, 3, 5, 10)

        private fun JSONObject.str(k: String): String? =
            if (isNull(k)) null else getString(k)

        private fun JSONObject.lng(k: String): Long? =
            if (isNull(k)) null else getLong(k)

        fun fromMap(m: Map<*, *>): AlarmSpec {
            val d = AlarmSpec(id = "")
            fun int(k: String, def: Int) = (m[k] as? Number)?.toInt() ?: def
            fun lng(k: String) = (m[k] as? Number)?.toLong()
            return AlarmSpec(
                id = m["id"] as? String ?: "",
                enabled = m["enabled"] as? Boolean ?: d.enabled,
                hour = int("hour", d.hour),
                minute = int("minute", d.minute),
                weekdays = (m["weekdays"] as? List<*>)?.map { (it as Number).toInt() } ?: d.weekdays,
                label = m["label"] as? String ?: d.label,
                soundId = m["soundId"] as? String ?: d.soundId,
                customSoundUri = m["customSoundUri"] as? String,
                customSoundName = m["customSoundName"] as? String,
                sunriseMinutes = int("sunriseMinutes", d.sunriseMinutes),
                rampMinutes = int("rampMinutes", d.rampMinutes),
                maxVolumePercent = int("maxVolumePercent", d.maxVolumePercent),
                vibrate = m["vibrate"] as? Boolean ?: d.vibrate,
                skipRingAtEpochMs = lng("skipRingAtEpochMs"),
                scheduledRingAtEpochMs = lng("scheduledRingAtEpochMs"),
                createdAtEpochMs = lng("createdAtEpochMs") ?: d.createdAtEpochMs,
            )
        }

        fun fromJson(o: JSONObject): AlarmSpec {
            val d = AlarmSpec(id = o.optString("id", ""))
            val days = o.optJSONArray("weekdays")
            return AlarmSpec(
                id = o.optString("id", d.id),
                enabled = o.optBoolean("enabled", d.enabled),
                hour = o.optInt("hour", d.hour),
                minute = o.optInt("minute", d.minute),
                weekdays = if (days == null) d.weekdays else List(days.length()) { days.getInt(it) },
                label = o.optString("label", d.label),
                soundId = o.optString("soundId", d.soundId),
                customSoundUri = o.str("customSoundUri"),
                customSoundName = o.str("customSoundName"),
                sunriseMinutes = o.optInt("sunriseMinutes", d.sunriseMinutes),
                rampMinutes = o.optInt("rampMinutes", d.rampMinutes),
                maxVolumePercent = o.optInt("maxVolumePercent", d.maxVolumePercent),
                vibrate = o.optBoolean("vibrate", d.vibrate),
                skipRingAtEpochMs = o.lng("skipRingAtEpochMs"),
                scheduledRingAtEpochMs = o.lng("scheduledRingAtEpochMs"),
                createdAtEpochMs = o.optLong("createdAtEpochMs", d.createdAtEpochMs),
            )
        }
    }
}
