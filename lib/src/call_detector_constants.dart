part of 'src.dart';

enum _ChannelConstants {
  callDetectorMethod("call_detector_method_channel"),
  callDetectorEvent("call_detector_event_channel");

  const _ChannelConstants(this.channel);

  final String channel;
}

enum _MethodConstants {
  getCurrentStatus("get_current_status");

  const _MethodConstants(this.method);

  final String method;
}
