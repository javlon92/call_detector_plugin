import 'dart:async';
import 'package:flutter/foundation.dart';

@protected
abstract interface class CallChannelService {
  const CallChannelService();

  /// {@macro get_current_call_status}
  Future<bool> getCurrentCallStatus();

  /// {@macro call_detect_stream}
  Stream<bool> getCallDetectStream();
}
