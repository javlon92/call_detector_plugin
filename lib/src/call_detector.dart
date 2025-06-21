part of 'src.dart';

/// {@template CallDetector}
///
/// [CallDetector] is a singleton class designed for detecting and monitoring
/// phone call status on the platform.
///
/// It provides a single access point to a stream of call state events,
/// along with methods to retrieve the current call status.
///
/// [CallDetector] encapsulates the logic for interacting with
/// native platforms to obtain call-related information. It uses `MethodChannel`
/// to invoke native methods, and `EventChannel` to receive streaming updates
/// about the call status. This class is implemented as a singleton to ensure
/// only one instance of the detector exists throughout the app’s lifecycle,
/// preventing resource duplication and conflicts.
///
/// ## Example usage:
///
/// ```dart
/// final callDetector = CallDetector();
/// callDetector.callDetectStream.listen((isCalling) {
///   if (isCalling) {
///     print('Active call detected!');
///   } else {
///     print('Call ended or not active.');
///   }
/// });
/// ```
///
/// {@endtemplate}
class CallDetector with _CallDetectSubscriptionMixin implements _Detector {
  static final _instance = CallDetector._();

  /// {@macro CallDetector}
  CallDetector._();

  /// {@macro CallDetector}
  factory CallDetector() => _instance;

  /// {@macro call_detect_stream}
  @override
  Stream<bool> get callDetectStream => _streamBroadcast;

  /// {@macro last_call_status}
  @override
  bool get lastCallStatus => _lastCallStatus;

  /// {@macro is_stream_active}
  @override
  bool get isStreamActive => _isStreamActive;

  /// {@macro has_listeners}
  @override
  bool get hasListeners => _hasListeners;

  /// {@macro get_current_call_status}
  @override
  Future<bool> getCurrentCallStatus() async => _lastCallStatus = await channelService.getCurrentCallStatus();
}
