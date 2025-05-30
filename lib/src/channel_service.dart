part of 'src.dart';

abstract interface class _CallChannelService {
  const _CallChannelService();

  /// {@macro get_current_call_status}
  Future<bool> getCurrentCallStatus();

  /// {@macro call_detect_stream}
  Stream<bool> getCallDetectStream();
}
