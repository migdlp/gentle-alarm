package com.migdlp.gentlealarm.ring

import org.json.JSONObject

data class SessionSnapshot(
    val alarmId: String,
    val label: String,
    val ringAtEpochMs: Long,
    val sunriseStartEpochMs: Long,
    val state: String,
    val stateSinceEpochMs: Long,
    val snoozesLeft: Int,
    val autoSnoozeUsed: Boolean,
    val snoozeUntilEpochMs: Long?,
    val segmentStartEpochMs: Long?,
    val endReason: String?,
    val isPreview: Boolean,
    val soundFallback: Boolean,
    val brightnessRampFromSnooze: Boolean,
) {
    fun toJson(): JSONObject = JSONObject().apply {
        put("alarmId", alarmId)
        put("label", label)
        put("ringAtEpochMs", ringAtEpochMs)
        put("sunriseStartEpochMs", sunriseStartEpochMs)
        put("state", state)
        put("stateSinceEpochMs", stateSinceEpochMs)
        put("snoozesLeft", snoozesLeft)
        put("autoSnoozeUsed", autoSnoozeUsed)
        put("snoozeUntilEpochMs", snoozeUntilEpochMs ?: JSONObject.NULL)
        put("segmentStartEpochMs", segmentStartEpochMs ?: JSONObject.NULL)
        put("endReason", endReason ?: JSONObject.NULL)
        put("isPreview", isPreview)
        put("soundFallback", soundFallback)
        put("brightnessRampFromSnooze", brightnessRampFromSnooze)
    }

    fun toMap(): Map<String, Any?> = mapOf(
        "alarmId" to alarmId,
        "label" to label,
        "ringAtEpochMs" to ringAtEpochMs,
        "sunriseStartEpochMs" to sunriseStartEpochMs,
        "state" to state,
        "stateSinceEpochMs" to stateSinceEpochMs,
        "snoozesLeft" to snoozesLeft,
        "autoSnoozeUsed" to autoSnoozeUsed,
        "snoozeUntilEpochMs" to snoozeUntilEpochMs,
        "segmentStartEpochMs" to segmentStartEpochMs,
        "endReason" to endReason,
        "isPreview" to isPreview,
        "soundFallback" to soundFallback,
        "brightnessRampFromSnooze" to brightnessRampFromSnooze,
    )

    companion object {
        fun fromJson(o: JSONObject): SessionSnapshot = SessionSnapshot(
            alarmId = o.getString("alarmId"),
            label = o.getString("label"),
            ringAtEpochMs = o.getLong("ringAtEpochMs"),
            sunriseStartEpochMs = o.getLong("sunriseStartEpochMs"),
            state = o.getString("state"),
            stateSinceEpochMs = o.getLong("stateSinceEpochMs"),
            snoozesLeft = o.getInt("snoozesLeft"),
            autoSnoozeUsed = o.getBoolean("autoSnoozeUsed"),
            snoozeUntilEpochMs = if (o.isNull("snoozeUntilEpochMs")) null else o.getLong("snoozeUntilEpochMs"),
            segmentStartEpochMs = if (o.isNull("segmentStartEpochMs")) null else o.getLong("segmentStartEpochMs"),
            endReason = if (o.isNull("endReason")) null else o.getString("endReason"),
            isPreview = o.getBoolean("isPreview"),
            soundFallback = o.optBoolean("soundFallback", false),
            brightnessRampFromSnooze = o.optBoolean("brightnessRampFromSnooze", false),
        )
    }
}
