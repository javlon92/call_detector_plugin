package com.example.call_detector_plugin

import android.util.Log

abstract class OnChangeListener(
    private val onCallStatusChanged: (Boolean) -> Unit
) : StateListener {

    // Отвечает за состояние звонка.
    protected var isInCall: Boolean = false
        set(value) { // Используем set для отправки событий только при изменении состояния
            if (field != value) { // Отправляем событие только если статус изменился
                field = value
                // Log.d(TAG, "Sending status to Flutter: $value")
                onCallStatusChanged(value)
            }
        }

    private companion object {
        const val TAG = "OnChangeListener" // Для логгирования
    }
}