enum ChannelConstants {
  callDetectorMethod("call_detector_method_channel"),
  callDetectorEvent("call_detector_event_channel");

  const ChannelConstants(this.channel);

  final String channel;
}

enum MethodConstants {
  getCurrentStatus("get_current_status");

  const MethodConstants(this.method);

  final String method;
}
