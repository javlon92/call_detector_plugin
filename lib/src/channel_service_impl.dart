part of 'src.dart';

class _CallChannelServiceImpl implements _CallChannelService {
  static final MethodChannel _methodChannel = MethodChannel(_ChannelConstants.callDetectorMethod.channel);
  static final EventChannel _eventChannel = EventChannel(_ChannelConstants.callDetectorEvent.channel);

  const _CallChannelServiceImpl();


  /// {@macro get_current_call_status}
  @override
  Future<bool> getCurrentCallStatus() async {
    try {
      return await _methodChannel.invokeMethod<bool>(_MethodConstants.getCurrentStatus.method) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// {@macro call_detect_stream}
  @override
  Stream<bool> getCallDetectStream() => _eventChannel.receiveBroadcastStream().cast<bool>();
}
