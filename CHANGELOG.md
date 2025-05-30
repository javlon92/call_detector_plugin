## 1.0.0 - 9 June 2025

* **Initial Release of CallDetector Plugin:**
    * **Core Functionality:** Introduced the `CallDetector` plugin for Flutter, designed to monitor the status of GSM/CDMA (VoIP/Video Call) phone calls.
    * **Real-time Call State Monitoring:** Implemented real-time detection for incoming, outgoing, and active call states, providing a stream of events (`callDetectStream`).
    * **Platform Synchronization:** Established bidirectional interaction with native Android and iOS platforms via `MethodChannel` and `EventChannel` for reliable call information.
    * **Multiple Subscribers Support:** Utilized a `broadcast` stream to allow multiple components within an application to receive call updates simultaneously.
    * **Last Known Status:** Enabled the retrieval of the last known call status, ensuring new subscribers immediately get up-to-date information.
    * **Integration Mixins:** Provided convenient mixins (`CallDetectorMixin`) for seamless integration with Bloc/Cubit, StatefulWidget, and StatelessWidget, simplifying call status management within various architectural patterns.