part of 'src.dart';

mixin _CallDetectSubscriptionMixin {
  @protected
  @visibleForTesting
  StreamController<bool>? controller;
  @protected
  @visibleForTesting
  StreamSubscription<bool>? subscription;
  @protected
  @visibleForTesting
  bool? lastValue;
  @protected
  @visibleForTesting
  CallChannelService channelService = const CallChannelServiceImpl();

  /// {@macro last_call_status}
  bool get _lastCallStatus => lastValue ?? false;

  set _lastCallStatus(bool newValue) {
    lastValue = newValue;
  }

  /// {@macro is_stream_active}
  bool get _isStreamActive => !(controller?.isClosed ?? true);

  /// {@macro has_listeners}
  bool get _hasListeners => controller?.hasListener ?? false;

  /// {@macro call_detect_stream}
  Stream<bool> get _streamBroadcast {
    return Stream<bool>.multi(
      (subscriber) {
        controller ??= StreamController<bool>.broadcast(
          onListen: _startListening,
          onCancel: () async {
            await _stopListening();
          },
          sync: true,
        );

        final subscription = controller!.stream.listen(
          subscriber.add,
          onError: subscriber.addError,
          onDone: subscriber.close,
          cancelOnError: false,
        );

        /// Passing [lastValue] only to a new subscriber - when a new listener is connected.
        if (lastValue != null) {
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
    subscription ??= channelService.getCallDetectStream().listen(
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
      await subscription?.cancel();
    } on PlatformException catch (e, s) {
      if ((e.message ?? '').contains('No active stream to cancel')) {
        return;
      }
      _safeAddError(e, s);
    } finally {
      subscription = null;
      lastValue = null;
    }
  }

  Future<void> _closeController() async {
    if (_isStreamActive) {
      await controller?.close();
      controller = null;
      lastValue = null;
    }
  }

  void _safeAdd(bool callStatus) {
    lastValue = callStatus;
    if (_isStreamActive) {
      controller!.add(callStatus);
    }
  }

  void _safeAddError(Object error, [StackTrace? stackTrace]) {
    if (_isStreamActive) {
      controller!.addError(error, stackTrace);
    }
  }
}
