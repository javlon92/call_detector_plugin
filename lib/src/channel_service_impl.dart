import 'dart:async';
import 'package:flutter/services.dart';
import 'channel_service.dart';
import 'call_detector_constants.dart';

class CallChannelServiceImpl implements CallChannelService {
  static final MethodChannel _methodChannel = MethodChannel(ChannelConstants.callDetectorMethod.channel);
  static final EventChannel _eventChannel = EventChannel(ChannelConstants.callDetectorEvent.channel);

  const CallChannelServiceImpl();

  /// {@macro get_current_call_status}
  @override
  Future<bool> getCurrentCallStatus() async {
    try {
      return await _methodChannel.invokeMethod<bool>(MethodConstants.getCurrentStatus.method) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// {@macro call_detect_stream}
  @override
  Stream<bool> getCallDetectStream() => _eventChannel.receiveBroadcastStream().cast<bool>();
}
