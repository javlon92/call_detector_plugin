part of 'src.dart';

mixin _CallDetectSubscriptionMixin {
  StreamController<bool>? _controller;
  StreamSubscription<bool>? _subscription;
  bool? _lastValue;
  final _CallChannelService _channelService = const _CallChannelServiceImpl();

  /// {@macro last_call_status}
  bool get _lastCallStatus => _lastValue ?? false;

  set _lastCallStatus(bool newValue) {
    _lastValue = newValue;
  }

  /// {@macro is_stream_active}
  bool get _isStreamActive => !(_controller?.isClosed ?? true);

  /// {@macro has_listeners}
  bool get _hasListeners => _controller?.hasListener ?? false;

  /// {@macro call_detect_stream}
  Stream<bool> get _streamBroadcast {
    return Stream<bool>.multi(
      (subscriber) {
        _controller ??= StreamController<bool>.broadcast(
          onListen: _startListening,
          onCancel: () async {
            await _stopListening();
          },
          sync: true,
        );

        final subscription = _controller!.stream.listen(
          subscriber.add,
          onError: subscriber.addError,
          onDone: subscriber.close,
          cancelOnError: false,
        );

        /// Passing [_lastValue] only to a new subscriber - when a new listener is connected.
        if (_lastValue != null) {
          subscriber.add(_lastCallStatus);
        }

        subscriber
          ..onPause = subscription.pause
          ..onResume = subscription.resume
          ..onCancel = subscription.cancel;
      },
    );
  }

  void _startListening() {
    _subscription ??= _channelService.getCallDetectStream().listen(
      _safeAdd,
      onError: _safeAddError,
      onDone: () async {
        await _closeController();
      },
      cancelOnError: false,
    );
  }

  Future<void> _stopListening() async {
    try {
      await _subscription?.cancel();
    } on PlatformException catch (e, s) {
      if ((e.message ?? '').contains('No active stream to cancel')) {
        return;
      }
      _safeAddError(e, s);
    } finally {
      _subscription = null;
      _lastValue = null;
    }
  }

  Future<void> _closeController() async {
    if (_isStreamActive) {
      await _controller?.close();
      _controller = null;
      _lastValue = null;
    }
  }

  void _safeAdd(bool callStatus) {
    _lastValue = callStatus;
    if (_isStreamActive) {
      _controller!.add(callStatus);
    }
  }

  void _safeAddError(Object error, [StackTrace? stackTrace]) {
    if (_isStreamActive) {
      _controller!.addError(error, stackTrace);
    }
  }
}
