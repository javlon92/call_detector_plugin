package com.example.call_detector_plugin

import com.example.call_detector_plugin.OnChangeListener
import android.content.Context
import android.media.AudioManager
import android.util.Log
import androidx.core.content.ContextCompat
import java.util.concurrent.Executor

class AudioModeListener(
    private val context: Context,
    private val audioManager: AudioManager,
    onCallStatusChanged: (Boolean) -> Unit,
) : OnChangeListener(onCallStatusChanged) {

    private val onModeChangedListener = AudioManager.OnModeChangedListener { mode ->  // Android 12+ (API 31+)
        val callMode = CallAudioMode.from(mode)
        // Log.d(TAG, "Audio mode changed callMode = $callMode")

        isInCall = callMode.isInCall
    }

    override fun startListening() {
        // Log.d(TAG, "AudioModeListener startListening")

        audioManager.addOnModeChangedListener(  // Android 12+ (API 31+)
            ContextCompat.getMainExecutor(context),
            onModeChangedListener
        )
    }

    override fun stopListening() {
        // Log.d(TAG, "AudioModeListener stopListening")

        audioManager.removeOnModeChangedListener(onModeChangedListener)  // Android 12+ (API 31+)
    }

    private companion object {
        const val TAG = "AudioModeListener" // Для логгирования
    }
}