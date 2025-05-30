# 📞 CallDetector

[![Pub](https://img.shields.io/pub/v/call_detector_plugin.svg)](https://pub.dev/packages/call_detector_plugin)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

### Written using the languages

[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Swift](https://img.shields.io/badge/swift-F54A2A?style=for-the-badge&logo=swift&logoColor=white)](https://www.swift.org/)
[![Kotlin](https://img.shields.io/badge/kotlin-%237F52FF.svg?style=for-the-badge&logo=kotlin&logoColor=white)](https://kotlinlang.org/)

## Demo

| <img height=500 src="https://github.com/javlon92/call_detector_plugin/blob/master/example/assets/incoming_example.gif?raw=true"/> | <img height=500 src="https://github.com/javlon92/call_detector_plugin/blob/master/example/assets/outgoing_example.gif?raw=true"/> |
|-------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------|

## Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  call_detector_plugin: ^[latest_version]
```

Then run:

```bash
flutter pub get
```

## Features and purpose of CallDetector

`CallDetector` is designed to monitor the status of GSM/CDMA (VoIP/Video Call) phone calls in Flutter applications. It helps you respond to changes in the call status — for example, when a user accepts a call, ends a conversation, or when a call arrives.

### The main tasks that CallDetector solves:

- **Tracking incoming, outgoing, and active calls**  
  Allows the application to determine when a GSM/CDMA (VoIP/Video Call) call is taking place, and at what stage it is currently (active or completed).

- **Real-time response to a call status change**  
  Provides a stream of events that notifies all subscribers at once upon any change in the status of the call.

- **Synchronization with the native platform layer**  
  Bidirectional interaction with Android and iOS takes place through the `MethodChannel` and `EventChannel`, which allows you to receive reliable information about calls.

- **Providing multiple event subscribers**  
  A `broadcast` stream is used so that multiple components in the same application can receive call updates at the same time.

- **Saving the last known call status**  
  A new subscriber immediately receives up-to-date information without having to wait for a new event, which simplifies status management.

### In which scenarios is CallDetector useful:

- Multimedia applications where you need to pause an incoming call.
- Call recording apps that need to know when a conversation starts and ends.
- Social and communication applications that respond to the state of the network and calls.
- Any applications with a user interface that changes during phone events.

---

#### Thus, the `CallDetector` is an important tool for creating a more responsive and "smart" user experience when the state of the call directly affects the logic and behavior of the application.

---

## Usage Example

### mixin for [Bloc and Cubit]

```dart
class MyBloc extends Bloc<MyEvent, MyState> with CallDetectorMixin {
  MyBloc() : super(MyState()) {
    on<_WatchDetector>(_watchDetector);
    on<_GetCurrentCallStatus>(_getCurrentCallStatus);

    add(_WatchDetector());
  }

  Future<void> _watchDetector(_WatchDetector event, Emitter<MyState> emit) {
    return emit.forEach(
      callDetectStream,
      onData: (callStatus) {
        print('Current call status: $callStatus');
        return state.copyWith(isInCall: callStatus);
      },
    );
  }

  Future<void> _getCurrentCallStatus(_GetCurrentCallStatus event, Emitter<MyState> emit) async {
    // ...
    final currentCallValue = await getCurrentCallStatus();
    // ...
  }
}
```

```dart
class MyCubit extends Cubit<MyState> with CallDetectorMixin {
  StreamSubscription<bool>? subscription;

  MyCubit() : super(const MyState());

  void init() {
    subscription ??= callDetectStream.listen((isCalling) {
      if (isCalling) {
        print('Call is active in MyCubit!');
      }
    });
  }

  Future<void> checkStatus() async {
    bool status = await getCurrentCallStatus();
    print('Current call status: $status');
  }

  @override
  Future<void> close() async {
    await subscription?.cancel();
    return super.close();
  }
}
```

### mixin for [StatefulWidget and StatelessWidget]

```dart
class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> with CallDetectorMixin {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: singletonCallDetectStream,
      builder: (context, snapshot) {
        return Text('Current call status: ${snapshot.data}');
      }
    );
  }
}
```

```dart
class MyWidget extends StatelessWidget with CallDetectorMixin {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: singletonCallDetectStream,
      builder: (context, snapshot) {
        return Text('Current call status: ${snapshot.data}');
      }
    );
  }
}
```

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/your-feature`).
3. Commit your changes (`git commit -m 'Add your feature'`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a Pull Request.


## Contacts

<a href="https://t.me/+998934505292"><img src="https://img.shields.io/badge/Telegram-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white" /></a>
<a href="https://www.linkedin.com/in/javlon-nurullayev-138219248/"><img src="https://img.shields.io/badge/linkedin-%230077B5.svg?style=for-the-badge&logo=linkedin&logoColor=white" /></a>
<a href="https://www.instagram.com/javlon_nurullayev"><img src="https://img.shields.io/badge/Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white" /></a>


For issues or suggestions, please open an issue on the [GitHub repository](https://github.com/javlon92/call_detector_plugin).
