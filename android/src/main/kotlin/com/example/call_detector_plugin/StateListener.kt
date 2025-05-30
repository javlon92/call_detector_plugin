package com.example.call_detector_plugin

interface StateListener {

    fun startListening()

    fun stopListening()

    fun restartListening() {
        stopListening()
        startListening()
    }
}
