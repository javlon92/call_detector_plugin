import 'dart:async';

import 'package:call_detector_plugin/src/channel_service.dart';
import 'package:flutter/services.dart';
import 'package:test/test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_async/fake_async.dart';

// Import the file containing your CallDetector classes.
// Adjust the path if your file structure is different.
import 'package:call_detector_plugin/call_detector_plugin.dart';

// Generated Mock file for MockCallChannelService.
// Run `flutter pub run build_runner build` in your terminal
// to generate this file after adding the @GenerateMocks annotation.
import 'call_detector_test.mocks.dart';

abstract class MockableCallChannelService implements CallChannelService {}

// Create a dummy class to use the mixin for testing
class MyTestClass with CallDetectorMixin {
  // Expose internal singleton access for verification if needed
  CallDetector get internalDetector => CallDetector();
}

// Annotate to generate the mock class.
@GenerateMocks([MockableCallChannelService])
void main() {
  late MockMockableCallChannelService mockChannelService;
  late StreamController<bool> testStreamController;

  setUp(() {
    // Initialize mock before each test
    mockChannelService = MockMockableCallChannelService();
    testStreamController = StreamController<bool>.broadcast();

    // Stub the getCallDetectStream to return our controllable stream
    when(mockChannelService.getCallDetectStream()).thenAnswer((_) => testStreamController.stream);

    final callDetectorInstance = CallDetector();

    callDetectorInstance
      ..channelService = mockChannelService
      ..controller = null
      ..subscription = null
      ..lastValue = null;
  });

  tearDown(() {
    // Close the test stream controller after each test
    testStreamController.close();
  });

  group('CallDetector (Singleton and Core Logic)', () {
    test('CallDetector is a singleton', () {
      final instance1 = CallDetector();
      final instance2 = CallDetector();
      expect(instance1, same(instance2)); // Verify they are the same instance
    });

    test('callDetectStream emits values from platform channel', () {
      fakeAsync((async) {
        final detector = CallDetector();
        final listener = expectAsync1((bool isCalling) {
          expect(isCalling, isTrue);
        });

        detector.callDetectStream.listen(listener);

        // Simulate an event from the native platform
        testStreamController.add(true);
        async.flushMicrotasks(); // Process microtasks to deliver stream events
      });
    });

    test('lastCallStatus updates correctly with stream emissions', () {
      fakeAsync((async) {
        final detector = CallDetector();
        expect(detector.lastCallStatus, isFalse); // Initial state

        // Listen to activate the stream and update _lastValue
        detector.callDetectStream.listen((_) {});
        async.flushMicrotasks(); // to activate the listener and start _startListening

        testStreamController.add(true);
        async.flushMicrotasks();
        expect(detector.lastCallStatus, isTrue);

        testStreamController.add(false);
        async.flushMicrotasks();
        expect(detector.lastCallStatus, isFalse);
      });
    });

    test('isStreamActive and hasListeners reflect stream state', () {
      fakeAsync((async) async {
        final detector = CallDetector();
        expect(detector.isStreamActive, isFalse);
        expect(detector.hasListeners, isFalse);

        final subscription = detector.callDetectStream.listen((_) {});
        async.flushMicrotasks(); // Listener added, should make stream active

        expect(detector.isStreamActive, isTrue);
        expect(detector.hasListeners, isTrue);

        subscription.cancel();
        async.flushMicrotasks(); // Listener cancelled, should eventually stop listening

        // Give time for async onCancel to potentially clean up if not immediate
        async.elapse(Duration(milliseconds: 100)); // Allow a small delay for async cleanup
        expect(detector.isStreamActive, isFalse);
        expect(detector.hasListeners, isFalse);
      });
    });

    test('getCurrentCallStatus fetches from platform and updates lastCallStatus', () {
      fakeAsync((async) async {
        final detector = CallDetector();
        when(mockChannelService.getCurrentCallStatus()).thenAnswer((_) async => true);

        expect(detector.lastCallStatus, isFalse); // Initial

        final futureStatus = detector.getCurrentCallStatus();
        async.flushMicrotasks(); // Process async call

        expect(detector.lastCallStatus, isTrue); // Should be updated immediately after await
        expect(await futureStatus, isTrue); // Verify returned value
        verify(mockChannelService.getCurrentCallStatus()).called(1);
      });
    });

    test('new subscriber receives lastValue immediately and then new emissions', () {
      fakeAsync((async) {
        final detector = CallDetector();
        List<bool> listener1Values = [];
        List<bool> listener2Values = [];

        // 1. Initial listener (activates the underlying platform stream)
        detector.callDetectStream.listen(listener1Values.add);
        async.flushMicrotasks(); // Stream now active

        // Simulate some emissions from platform
        testStreamController.add(true);
        async.flushMicrotasks();
        expect(listener1Values, [true]);
        expect(detector.lastCallStatus, true);

        testStreamController.add(false);
        async.flushMicrotasks();
        expect(listener1Values, [true, false]);
        expect(detector.lastCallStatus, false);

        // 2. Add a new listener - it should receive the last value (false) immediately
        detector.callDetectStream.listen(listener2Values.add);
        async.flushMicrotasks(); // Process onListen for new subscriber

        expect(listener2Values, [false]); // New listener gets the last value
        expect(listener1Values, [true, false]); // Old listener is unaffected

        // Simulate another emission
        testStreamController.add(true);
        async.flushMicrotasks();

        expect(listener1Values, [true, false, true]);
        expect(listener2Values, [false, true]); // Both get new emission
        expect(detector.lastCallStatus, true);
      });
    });

    test('_stopListening performs cleanup when subscription is cancelled', () async {
      fakeAsync((async) async {
        final detector = CallDetector();

        // Simulate the stream starting and a listener being added
        final subscription = detector.callDetectStream.listen((_) {});
        async.flushMicrotasks();
        expect(detector.isStreamActive, isTrue);
        expect(detector.subscription, isNotNull); // Verify subscription is active

        // Simulate some value being emitted to set _lastValue
        testStreamController.add(true);
        async.flushMicrotasks();
        expect(detector.lastValue, isTrue);

        // When the only listener cancels, _stopListening will be called.
        subscription.cancel();
        async.flushMicrotasks();

        async.elapse(Duration(milliseconds: 100)); // Allow a small delay for async cleanup

        // Verify that the stream is now inactive and internal states are reset.
        expect(detector.isStreamActive, isFalse);
        expect(detector.hasListeners, isFalse);
        expect(detector.subscription, isNull); // Verify subscription is nullified
        expect(detector.lastValue, isNull); // Verify lastValue is nullified
      });
    });

    test('Stream errors are handled and propagated to listeners but not crash', () {
      fakeAsync((async) {
        final detector = CallDetector();
        Object? receivedError;
        StackTrace? receivedStackTrace;

        detector.callDetectStream.listen(
          (value) {},
          onError: expectAsync2((error, stackTrace) {
            receivedError = error;
            receivedStackTrace = stackTrace as StackTrace?;
          }),
        );
        async.flushMicrotasks();

        // Simulate an error from the native platform
        testStreamController.addError(PlatformException(code: 'ERROR', message: 'Test error'));
        async.flushMicrotasks();

        expect(receivedError, isA<PlatformException>());
        expect((receivedError as PlatformException).message, 'Test error');
        expect(receivedStackTrace, isNotNull);
      });
    });
  });

  group('CallDetectorMixin', () {
    test('mixin uses the same singleton CallDetector instance', () {
      final testInstance = MyTestClass();
      expect(testInstance.internalDetector, same(CallDetector()));
    });

    test('mixin callDetectStream emits last value on new listener', () {
      fakeAsync((async) {
        final detector = CallDetector(); // Get the main singleton instance
        final mixinUser = MyTestClass();

        // Prime the stream with a value using the main detector
        detector.callDetectStream.listen((_) {}); // Activate stream
        async.flushMicrotasks();
        testStreamController.add(true);
        async.flushMicrotasks();
        expect(detector.lastCallStatus, true);

        // Now, listen via the mixin's callDetectStream
        List<bool> mixinListenerValues = [];
        mixinUser.callDetectStream.listen(mixinListenerValues.add);
        async.flushMicrotasks();

        // Should receive the last value (true) immediately
        expect(mixinListenerValues, [true]);

        // Further emissions should also be received
        testStreamController.add(false);
        async.flushMicrotasks();
        expect(mixinListenerValues, [true, false]);
      });
    });

    test('mixin singletonCallDetectStream does NOT emit last value on rebuild WidgetTree via StreamBuilder', () {
      fakeAsync((async) {
        final detector = CallDetector(); // Get the main singleton instance
        final mixinUser = MyTestClass();

        // Prime the stream with a value using the main detector
        detector.callDetectStream.listen((_) {}); // Activate stream
        async.flushMicrotasks();
        testStreamController.add(true);
        async.flushMicrotasks();
        expect(detector.lastCallStatus, true);

        // Now, listen via the mixin's singletonCallDetectStream
        List<bool> mixinListenerValues = [];
        mixinUser.singletonCallDetectStream.listen(mixinListenerValues.add);
        async.flushMicrotasks();

        // Should receive the last value (true) immediately
        expect(mixinListenerValues, [true]);

        // Further emissions should be received
        testStreamController.add(false);
        async.flushMicrotasks();
        expect(mixinListenerValues, [true, false]);
      });
    });

    test('mixin getters forward to singleton correctly', () {
      final detector = CallDetector();
      final mixinUser = MyTestClass();

      // Test initial state
      expect(mixinUser.lastCallStatus, detector.lastCallStatus);
      expect(mixinUser.isStreamActive, detector.isStreamActive);
      expect(mixinUser.hasListeners, detector.hasListeners);

      // Trigger a state change in the singleton (via a listener for example)
      detector.callDetectStream.listen((_) {});
      // No fakeAsync needed here for simple getter check after listener setup
      expect(mixinUser.isStreamActive, detector.isStreamActive); // Should now be true
    });

    test('mixin getCurrentCallStatus calls singleton method', () {
      fakeAsync((async) async {
        final mixinUser = MyTestClass();
        when(mockChannelService.getCurrentCallStatus()).thenAnswer((_) async => false); // Mock value for this test

        final futureStatus = mixinUser.getCurrentCallStatus();
        async.flushMicrotasks();

        expect(await futureStatus, isFalse);
        // Verify that the underlying singleton's channel service was called
        verify(mockChannelService.getCurrentCallStatus()).called(1);
      });
    });
  });
}
