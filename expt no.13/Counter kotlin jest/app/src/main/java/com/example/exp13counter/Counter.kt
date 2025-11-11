package com.example.exp11counter

class Counter {
    private var count = 0

    fun increment() {
        count++
    }

    fun decrement() {
        if (count > 0) count--
    }

    fun reset() {
        count = 0
    }

    fun getCount(): Int = count
}
