part of 'src.dart';

/// {@template CallDetectorMixin}
///
/// [CallDetectorMixin] provides a convenient way to enable call detection
/// functionality in any class without needing to directly instantiate or manage
/// a [CallDetector] instance.
///
/// This mixin gives access to the singleton instance of [CallDetector]
/// and exposes all of its public methods and getters. Classes that mix this in
/// can easily check call status, subscribe to call events, and manage the
/// detector’s lifecycle without knowing the singleton’s internal details.
///
/// Ideal for use in layers such as [Provider], [Bloc], [Cubit], [StatefulWidget],
/// [StatelessWidget], or any service class that needs call detection functionality.
///
/// ## Example usage:
///
/// ```dart
/// class MyBloc extends Bloc<MyEvent, MyState> with CallDetectorMixin {
///   MyBloc() : super(MyState()) {
///     on<_WatchDetector>(_watchDetector);
///     on<_GetCurrentCallStatus>(_getCurrentCallStatus);
///
///     add(_WatchDetector());
///   }
///
///   Future<void> _watchDetector(_WatchDetector event, Emitter<MyState> emit) {
///     return emit.forEach(
///       callDetectStream,
///       onData: (callStatus) {
///         print('Current call status: $callStatus');
///         return state.copyWith(isInCall: callStatus);
///       },
///     );
///   }
///
///   Future<void> _getCurrentCallStatus(_GetCurrentCallStatus event, Emitter<MyState> emit) async {
///     // ...
///     final currentCallValue = await getCurrentCallStatus();
///     // ...
///   }
/// }
/// ```
///
/// ```dart
/// class MyCubit extends Cubit<MyState> with CallDetectorMixin {
///   StreamSubscription<bool>? subscription;
///
///   MyCubit() : super(const MyState());
///
///   void init() {
///     subscription ??= callDetectStream.listen((isCalling) {
///       if (isCalling) {
///         print('Call is active in MyCubit!');
///       }
///     });
///   }
///
///   Future<void> checkStatus() async {
///     bool status = await getCurrentCallStatus();
///     print('Current call status: $status');
///   }
///
///   @override
///   Future<void> close() async {
///     await subscription?.cancel();
///     return super.close();
///   }
/// }
/// ```
///
/// ```dart
/// class MyWidget extends StatefulWidget {
///   const MyWidget({super.key});
///
///   @override
///   State<MyWidget> createState() => _MyWidgetState();
/// }
///
/// class _MyWidgetState extends State<MyWidget> with CallDetectorMixin {
///   @override
///   Widget build(BuildContext context) {
///     return StreamBuilder<bool>(
///       stream: singletonCallDetectStream,
///       builder: (context, snapshot) {
///         return Text('Current call status: ${snapshot.data}');
///       }
///     );
///   }
/// }
/// ```
///
/// ```dart
/// class MyWidget extends StatelessWidget with CallDetectorMixin {
///   const MyWidget({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     return StreamBuilder<bool>(
///       stream: singletonCallDetectStream,
///       builder: (context, snapshot) {
///         return Text('Current call status: ${snapshot.data}');
///       }
///     );
///   }
/// }
/// ```
///
/// {@endtemplate}
mixin CallDetectorMixin implements _Detector {
  static final _singletonCallDetector = CallDetector();

  static final _singletonStream = _singletonCallDetector.callDetectStream;

  /// {@template last_call_status}
  /// Returns the most recent known call status.
  ///
  /// - [true] - means the last known status was "active call",
  /// - [false] - means "no active call".
  ///
  /// Provides instant access to the latest emitted value
  /// from the stream without needing to listen to it.
  /// {@endtemplate}
  @override
  bool get lastCallStatus => _singletonCallDetector.lastCallStatus;

  /// {@template is_stream_active}
  /// Indicates whether the call detection stream is currently active.
  ///
  /// Returns `true` if the stream controller is not closed and
  /// is ready to emit events. Useful for debugging or verifying
  /// that the detection mechanism is operational.
  /// {@endtemplate}
  @override
  bool get isStreamActive => _singletonCallDetector.isStreamActive;

  /// {@template has_listeners}
  /// Indicates whether there are active listeners on the call detection stream.
  ///
  /// Returns `true` if at least one subscriber is currently
  /// listening to the stream. Can be helpful for optimization decisions
  /// or cleanup logic.
  /// {@endtemplate}
  @override
  bool get hasListeners => _singletonCallDetector.hasListeners;

  /// {@macro call_detect_stream}
  /// Returns a broadcast stream of events that signal changes
  /// in call status.
  ///
  /// `Stream<bool>` that emits `true` when an active call
  /// (incoming or outgoing) is detected, and `false` when the call ends
  /// or no call is active.
  ///
  /// **Note**: This getter returns the same stream as
  /// [singletonCallDetectStream], but unlike [singletonCallDetectStream],
  /// [callDetectStream] will emit the [lastCallStatus] immediately during use [StreamBuilder] a widget tree rebuild,
  /// ensuring UI stays in sync. [singletonCallDetectStream] does not re-emit the last value on rebuild.
  @override
  Stream<bool> get callDetectStream => _singletonCallDetector.callDetectStream;

  /// {@template singleton_call_detect_stream}
  /// Returns a broadcast stream of events that signal changes
  /// in call status.
  ///
  /// `Stream<bool>` that emits `true` when an active call
  /// (incoming or outgoing) is detected, and `false` when the call ends
  /// or no call is active.
  ///
  /// **Note**: This is the same underlying stream as [callDetectStream],
  /// but [singletonCallDetectStream] does **not** emit the [lastCallStatus]
  /// on widget tree rebuild during use [StreamBuilder]. Use if that behavior is needed.
  /// {@endtemplate}
  Stream<bool> get singletonCallDetectStream => _singletonStream;

  /// {@template get_current_call_status}
  /// Asynchronously fetches the current call status from the platform.
  ///
  /// Queries the native platform and returns `true`
  /// if a call is currently active, otherwise `false`.
  /// Useful for getting an immediate snapshot, as opposed to listening
  /// for stream updates.
  /// {@endtemplate}
  @override
  Future<bool> getCurrentCallStatus() => _singletonCallDetector.getCurrentCallStatus();
}
