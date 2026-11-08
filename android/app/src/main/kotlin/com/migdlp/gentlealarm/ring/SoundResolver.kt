package com.migdlp.gentlealarm.ring

sealed interface Resolved {
    val fallback: Boolean
    data class Raw(val name: String, override val fallback: Boolean) : Resolved
    data class Uri(val uri: String, override val fallback: Boolean) : Resolved
}

object SoundResolver {
    val BUILT_IN = listOf(
        "birds_dawn", "soft_waves", "light_rain", "chimes", "calm_piano", "singing_bowls",
    )

    fun resolve(soundId: String, customUri: String?, canRead: (String) -> Boolean): Resolved = when {
        soundId in BUILT_IN -> Resolved.Raw(soundId, false)
        soundId == "custom" && customUri != null && canRead(customUri) -> Resolved.Uri(customUri, false)
        else -> Resolved.Raw("birds_dawn", true)
    }
}
