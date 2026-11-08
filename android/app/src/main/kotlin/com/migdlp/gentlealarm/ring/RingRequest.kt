package com.migdlp.gentlealarm.ring

import org.json.JSONObject

data class RingRequest(
    val config: SessionConfig,
    val soundId: String,
    val customSoundUri: String?,
    val maxVolumePercent: Int,
    val sunriseMinutes: Int,
    val rampMinutes: Int,
    val quietSunrise: Boolean,
) {
    fun toJson(): JSONObject = JSONObject().apply {
        put("alarmId", config.alarmId)
        put("label", config.label)
        put("ringAtMs", config.ringAtMs)
        put("sunriseStartMs", config.sunriseStartMs)
        put("vibrate", config.vibrate)
        put("isPreview", config.isPreview)
        put("skipSunrise", config.skipSunrise)
        put("soundId", soundId)
        put("customSoundUri", customSoundUri ?: JSONObject.NULL)
        put("maxVolumePercent", maxVolumePercent)
        put("sunriseMinutes", sunriseMinutes)
        put("rampMinutes", rampMinutes)
        put("quietSunrise", quietSunrise)
    }

    companion object {
        fun fromJson(o: JSONObject) = RingRequest(
            config = SessionConfig(
                alarmId = o.getString("alarmId"),
                label = o.optString("label", ""),
                ringAtMs = o.getLong("ringAtMs"),
                sunriseStartMs = o.getLong("sunriseStartMs"),
                vibrate = o.optBoolean("vibrate", true),
                isPreview = o.optBoolean("isPreview", false),
                skipSunrise = o.optBoolean("skipSunrise", false),
            ),
            soundId = o.getString("soundId"),
            customSoundUri = if (o.isNull("customSoundUri")) null else o.getString("customSoundUri"),
            maxVolumePercent = o.getInt("maxVolumePercent"),
            sunriseMinutes = o.getInt("sunriseMinutes"),
            rampMinutes = o.getInt("rampMinutes"),
            quietSunrise = o.optBoolean("quietSunrise", false),
        )
    }
}
