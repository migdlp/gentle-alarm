package com.migdlp.gentlealarm.alarm

import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class AlarmStoreTest {
    private val kv = InMemoryKeyValueStore()
    private val store = AlarmStore(kv)

    @Test fun emptyAtStart() = assertTrue(store.list().isEmpty())

    @Test fun upsertAdds() {
        store.upsert(AlarmSpec("a"))
        store.upsert(AlarmSpec("b"))
        assertEquals(listOf("a", "b"), store.list().map { it.id })
        assertEquals(1, kv.getInt("schema_version", 0))
    }

    @Test fun upsertReplaces() {
        store.upsert(AlarmSpec("a", hour = 6))
        store.upsert(AlarmSpec("a", hour = 8))
        assertEquals(1, store.list().size)
        assertEquals(8, store.get("a")!!.hour)
    }

    @Test fun deleteRemoves() {
        store.upsert(AlarmSpec("a"))
        assertTrue(store.delete("a"))
        assertTrue(store.list().isEmpty())
    }

    @Test fun deleteMissingReturnsFalse() = assertFalse(store.delete("zzz"))

    @Test fun getMissingIsNull() = assertNull(store.get("zzz"))

    @Test fun sessionLifecycle() {
        assertNull(store.loadSession())
        store.saveSession(JSONObject().put("alarmId", "a"))
        assertEquals("a", store.loadSession()!!.getString("alarmId"))
        store.clearSession()
        assertNull(store.loadSession())
    }

    @Test fun corruptedAlarmsGiveEmptyList() {
        kv.putString("alarms_v1", "no-json")
        assertTrue(store.list().isEmpty())
    }
}
