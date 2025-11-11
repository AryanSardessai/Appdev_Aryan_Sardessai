package com.example.exp11counter
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test
class CounterTest {
    private lateinit var counter: Counter
    @Before
    fun setup() {
        counter = Counter()
    }
    @Test
    fun initialValue_isZero() {
        assertEquals(0, counter.getCount())
    }
    @Test
    fun increment_increasesByOne() {
        counter.increment()
        assertEquals(1, counter.getCount())
    }
    @Test
    fun decrement_decreasesByOne() {
        counter.increment()
        counter.increment()
        counter.decrement()
        assertEquals(1, counter.getCount())
    }
    @Test
    fun decrement_doesNotGoBelowZero() {
        counter.decrement()
        assertEquals(0, counter.getCount())
    }
    @Test
    fun reset_setsCountToZero() {
        counter.increment()
        counter.increment()
        counter.reset()
        assertEquals(0, counter.getCount())
    }
}
