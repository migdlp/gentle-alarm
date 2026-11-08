package com.migdlp.gentlealarm.ring

import org.junit.Assert.assertEquals
import org.junit.Test

class SoundResolverTest {
    @Test fun builtIn() =
        assertEquals(Resolved.Raw("chimes", false), SoundResolver.resolve("chimes", null) { true })

    @Test fun customUnreadableFallsBack() =
        assertEquals(Resolved.Raw("birds_dawn", true), SoundResolver.resolve("custom", "content://x") { false })

    @Test fun customReadable() =
        assertEquals(Resolved.Uri("content://x", false), SoundResolver.resolve("custom", "content://x") { true })

    @Test fun customWithoutUriFallsBack() =
        assertEquals(Resolved.Raw("birds_dawn", true), SoundResolver.resolve("custom", null) { true })

    @Test fun unknownFallsBack() =
        assertEquals(Resolved.Raw("birds_dawn", true), SoundResolver.resolve("unknown", null) { true })
}
