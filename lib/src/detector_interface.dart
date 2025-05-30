part of 'src.dart';

/// An abstract interface defining the core contract for call detector implementations.
///
/// **Purpose**: This interface is used to strictly enforce a consistent structure
/// across all classes that act as call detectors. It ensures that any class
/// implementing `_Detector` will provide methods and properties to:
///
/// - Retrieve the last known call status
/// - Check whether the stream is currently active
/// - Verify if there are active listeners
/// - Access the call detection event stream
/// - Get the platform version
/// - Query the current call status
/// - Properly dispose of resources
///
/// This interface makes it easier to build testable and interchangeable
/// components for call detection logic.
abstract interface class _Detector {
  const _Detector();

  /// {@macro last_call_status}
  bool get lastCallStatus;

  /// {@macro is_stream_active}
  bool get isStreamActive;

  /// {@macro has_listeners}
  bool get hasListeners;

  /// {@macro call_detect_stream}
  Stream<bool> get callDetectStream;

  /// {@macro get_current_call_status}
  Future<bool> getCurrentCallStatus();
}

