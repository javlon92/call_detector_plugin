package com.example.call_detector_plugin

import com.example.call_detector_plugin.CallStateDelegate
import com.example.call_detector_plugin.ChannelConstants
import com.example.call_detector_plugin.MethodConstants
import android.content.Context
import android.os.Build
import android.media.AudioManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.util.Log

/** CallDetectorPlugin for Android 5+ (API 21+) */
final class CallDetectorPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var applicationContext: Context
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var callStateDelegate: CallStateDelegate

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        methodChannel = MethodChannel(binding.binaryMessenger, ChannelConstants.METHOD_CHANNEL)
        eventChannel = EventChannel(binding.binaryMessenger, ChannelConstants.EVENT_CHANNEL)

        callStateDelegate = CallStateDelegate(applicationContext)
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(callStateDelegate)
        // Log.d(TAG, "onAttachedToEngine")
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        callStateDelegate.dispose()
        // Log.d(TAG, "onDetachedFromEngine")
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        // Log.d(TAG, "onMethodCall: ${call.method}")
        when (call.method) {
            MethodConstants.GET_CURRENT_STATUS -> result.success(callStateDelegate.getCurrentStatus())
            else -> result.notImplemented()
        }
    }

    private companion object {
        const val TAG = "CallDetectorPlugin" // Для логгирования
    }
}