package com.example.call_detector_plugin

import com.example.call_detector_plugin.OnChangeListener
import android.media.AudioManager
import com.example.call_detector_plugin.AudioFocusState
import android.media.AudioFocusRequest
import android.media.AudioAttributes
import android.os.Build
import android.util.Log
import kotlinx.coroutines.*
import kotlin.coroutines.CoroutineContext

class AudioFocusListener(
    private val audioManager: AudioManager,
    onCallStatusChanged: (Boolean) -> Unit,
) : OnChangeListener(onCallStatusChanged), CoroutineScope {

    private var focusRequest: AudioFocusRequest? = null
    private var audioFocusState: AudioFocusState = AudioFocusState.GAIN
    private var callMode: CallAudioMode = CallAudioMode.CURRENT
    private val job = SupervisorJob()
    override val coroutineContext: CoroutineContext
        get() = Dispatchers.Main + job
    private var pollingJob: Job? = null

    private val focusChangeListener = AudioManager.OnAudioFocusChangeListener { focusChanged ->
        audioFocusState = AudioFocusState.from(focusChanged)
        callMode = CallAudioMode.from(audioManager.mode)
        // Log.d(TAG, "Focus changed = $audioFocusState, callMode = $callMode")

        onFocusChanged()
    }

    override fun startListening() {
        // Log.d(TAG, "AudioFocusListener startListening")
        requestFocus()
    }

    override fun stopListening() {
        // Log.d(TAG, "AudioFocusListener stopListening")
        abandonFocus()
        pollingJob?.cancel()
        pollingJob = null
        job.cancel()
    }

    private fun reportCallStatus() {
        val callAudioMode = CallAudioMode.from(audioManager.mode)
        val currentStatus = callAudioMode.isInCall

        if (currentStatus != isInCall) {
            pollingJob?.takeIf { it.isActive && audioFocusState.isNotUnknown }?.cancel()
        }

        // Log.d(TAG, "CheckCallStatus: AudioManager mode = $callAudioMode, isInCall = $currentStatus, Last Reported: $isInCall")
        isInCall = currentStatus
    }

    private fun startGetCallStatusPolling(pollIntervalMs: Int = 500, maxAttempts: Int = 7) {
        pollingJob?.cancel()
        pollingJob = launch {
            var attempts = 1
            while (isActive && attempts <= maxAttempts) {
                reportCallStatus()
                delay(pollIntervalMs.toLong())
                attempts++
            }
        }
    }

    private fun onFocusChanged() {
        if (audioFocusState.isLossTransient && callMode.isRingingOrNormal || audioFocusState.isUnknown) { // Входящий, исходящий вызов
            startGetCallStatusPolling(pollIntervalMs = 1000, maxAttempts = Int.MAX_VALUE)
        } else if (audioFocusState.isLoss) { // Потеря фокуса
            restartListening()
        } else {
            startGetCallStatusPolling()
        }
    }

    @Synchronized // Добавим @Synchronized для безопасности при доступе с разных потоков, хотя обычно это вызывается с главного.
    private fun requestFocus(): Boolean {
        val result = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {  // Android 8+ (API 26+)
            focusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK)
                .setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_VOICE_COMMUNICATION)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                        .build()
                )
                .setOnAudioFocusChangeListener(focusChangeListener)
                .setAcceptsDelayedFocusGain(true)
                .build()
            // Log.d(TAG, "Requesting focus for Android 8+ (API 26+)")
            audioManager.requestAudioFocus(focusRequest!!)
        } else {                                                             // Android 7.1- (API 25-)
            // Log.d(TAG, "Requesting focus for Android 7.1- (API 25-)")
            @Suppress("DEPRECATION")
            audioManager.requestAudioFocus(
                focusChangeListener,
                AudioManager.STREAM_VOICE_CALL,
                AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK
            )
        }

        val isGranted = result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
        // Log.d(TAG, "Audio focus request result: $result, Granted: $isGranted")

        if (isGranted) {
            audioFocusState = AudioFocusState.GAIN
            onFocusChanged()
        } else {
            audioFocusState = AudioFocusState.UNKNOWN
            onFocusChanged()
        }
        return isGranted
    }

    @Synchronized // Добавим @Synchronized для безопасности при доступе с разных потоков, хотя обычно это вызывается с главного.
    private fun abandonFocus() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && focusRequest != null) {  // Android 8+ (API 26+)
            // Log.d(TAG, "Abandoning focus for Android 8+ (API 26+)")
            audioManager.abandonAudioFocusRequest(focusRequest!!)
            focusRequest = null
        } else {                                                                       // Android 7.1- (API 25-)
            // Log.d(TAG, "Abandoning focus for Android 7.1- (API 25-)")
            @Suppress("DEPRECATION")
            audioManager.abandonAudioFocus(focusChangeListener)
        }
    }

    private companion object {
        const val TAG = "AudioFocusListener" // Для логгирования
    }
}