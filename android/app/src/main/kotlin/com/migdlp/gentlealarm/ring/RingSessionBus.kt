package com.migdlp.gentlealarm.ring

import java.util.concurrent.CopyOnWriteArrayList

object RingSessionBus {
    val listeners = CopyOnWriteArrayList<(SessionSnapshot?) -> Unit>()

    @Volatile
    private var current: SessionSnapshot? = null

    fun current(): SessionSnapshot? = current

    fun publish(s: SessionSnapshot?) {
        current = s
        listeners.forEach { it(s) }
    }
}
