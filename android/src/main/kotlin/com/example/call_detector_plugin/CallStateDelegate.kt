package com.example.call_detector_plugin

import android.content.Context
import android.media.AudioManager
import com.example.call_detector_plugin.AudioFocusState
import com.example.call_detector_plugin.CallAudioMode
import com.example.call_detector_plugin.AudioFocusListener
import com.example.call_detector_plugin.AudioModeListener
import com.example.call_detector_plugin.StateListener
import android.util.Log
import android.os.Build
import io.flutter.plugin.common.EventChannel

class CallStateDelegate(
    private val context: Context
) : EventChannel.StreamHandler {

    private val audioManager: AudioManager by lazy {
        context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    }
    private lateinit var stateListener: StateListener
    private var eventSink: EventChannel.EventSink? = null

    init {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) { // Android 12+ (API 31+)
            stateListener = AudioModeListener(context, audioManager) { isInCall ->
                eventSink?.success(isInCall)
            }
        } else {                                              // Android 11- (API 30-)
            stateListener = AudioFocusListener(audioManager) { isInCall ->
                eventSink?.success(isInCall)
            }
        }
    }

    // FlutterStreamHandler
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        // Log.d(TAG, "CallStateDelegate: onListen called")
        eventSink = events
        stateListener.startListening()
        // Отправляем текущее состояние при подписке
        val currentStatus = getCurrentStatus()
        events?.success(currentStatus)
    }

    override fun onCancel(arguments: Any?) {
        // Log.d(TAG, "CallStateDelegate: onCancel called")
        dispose()
    }

    fun getCurrentStatus(): Boolean {
        val callAudioMode = CallAudioMode.from(audioManager.mode)
        val currentStatus = callAudioMode.isInCall

        // Log.d(TAG, "CheckCallStatus: AudioManager mode = $callAudioMode, isInCall = $currentStatus")
        return currentStatus
    }


    fun dispose() {
        // Log.d(TAG, "CallStateDelegate: dispose")
        stateListener.stopListening()
        eventSink?.endOfStream() // Если нужно явно указать, что стрим завершен для Dart
        eventSink = null
    }

    companion object {
        private const val TAG = "CallStateDelegate" // Для логгирования
    }
}

/**
 * Documentation link: https://developer.android.com/guide/topics/manifest/uses-sdk-element#ApiLevels
 * |---------------------|-----------|--------------------------|
 * | Platform Version    | API Level | VERSION_CODE             |
 * |---------------------|-----------|--------------------------|
 * | Android 16          | 36        | BAKLAVA                  |
 * | Android 15          | 35        | VANILLA_ICE_CREAM        |
 * | Android 14          | 34        | UPSIDE_DOWN_CAKE         |
 * | Android 13          | 33        | TIRAMISU                 |
 * | Android 12L         | 32        | S_V2                     |
 * | Android 12          | 31        | S                        |
 * | Android 11          | 30        | R                        |
 * | Android 10          | 29        | Q                        |
 * | Android 9           | 28        | P                        |
 * | Android 8.1         | 27        | O_MR1                    |
 * | Android 8.0         | 26        | O                        |
 * | Android 7.1         | 25        | N_MR1                    |
 * | Android 7.0         | 24        | N                        |
 * | Android 6.0         | 23        | M                        |
 * | Android 5.1         | 22        | LOLLIPOP_MR1             |
 * | Android 5.0         | 21        | LOLLIPOP                 |
 * | Android 4.4W        | 20        | KITKAT_WATCH             |
 * | Android 4.4         | 19        | KITKAT                   |
 * | Android 4.3         | 18        | JELLY_BEAN_MR2           |
 * | Android 4.2         | 17        | JELLY_BEAN_MR1           |
 * | Android 4.1         | 16        | JELLY_BEAN               |
 * | Android 4.0.3–4.0.4 | 15        | ICE_CREAM_SANDWICH_MR1   |
 * | Android 4.0–4.0.2   | 14        | ICE_CREAM_SANDWICH       |
 * | Android 3.2         | 13        | HONEYCOMB_MR2            |
 * | Android 3.1         | 12        | HONEYCOMB_MR1            |
 * | Android 3.0         | 11        | HONEYCOMB                |
 * | Android 2.3.3–2.3.7 | 10        | GINGERBREAD_MR1          |
 * | Android 2.3–2.3.2   | 9         | GINGERBREAD              |
 * | Android 2.2.x       | 8         | FROYO                    |
 * | Android 2.1         | 7         | ECLAIR_MR1               |
 * | Android 2.0.1       | 6         | ECLAIR_0_1               |
 * | Android 2.0         | 5         | ECLAIR                   |
 * | Android 1.6         | 4         | DONUT                    |
 * | Android 1.5         | 3         | CUPCAKE                  |
 * | Android 1.1         | 2         | BASE_1_1                 |
 * | Android 1.0         | 1         | BASE                     |
 * |---------------------|-----------|--------------------------|
 */