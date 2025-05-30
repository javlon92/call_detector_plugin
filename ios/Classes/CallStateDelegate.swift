import Foundation
import CallKit
import Flutter

@objc class CallStateDelegate: NSObject, CXCallObserverDelegate, FlutterStreamHandler {
    private let callObserver = CXCallObserver()
    private var eventSink: FlutterEventSink?

    // Отвечает за состояние звонка.
    private(set) var isInCall: Bool = false {
        didSet { // Используем didSet для отправки событий только при изменении состояния
            if oldValue != isInCall { // Отправляем только если значение изменилось
                eventSink?(isInCall)
                // Log.info("Sending status to Flutter: \(isInCall)")
            }
        }
    }

    override init() {
        super.init()
        callObserver.setDelegate(self, queue: nil) // nil означает главный поток (main queue), что обычно подходит для CallKit
        reportCallStatus() // Инициализируем isInCall начальным состоянием
    }

    deinit {
        // Log.error("CallStateDelegate deinit")
        dispose()
    }

    public func getCurrentStatus() -> Bool {
         // Проверяем все текущие звонки. Если хотя бы один не завершен, значит мы в звонке.
         let currentStatus = callObserver.calls.contains { !$0.hasEnded }
         // Log.info("CheckCallStatus: isInCall = \(currentStatus)")
         return currentStatus
    }

    private func reportCallStatus() {
        // Обновляем и потенциально отправляем событие через didSet
        let currentStatus = getCurrentStatus()
        // Log.info("Reporting call status. Current: \(currentStatus), Last Reported: \(isInCall)")
        isInCall = currentStatus
    }

    // FlutterStreamHandler
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        // Log.info("StreamHandler: onListen - called")
        eventSink = events
        // Отправляем текущее состояние при подписке
        let currentStatus = getCurrentStatus()
        events(currentStatus)
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        // Log.error("StreamHandler: onCancel")
        dispose()
        return nil
    }

    // CXCallObserverDelegate
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        // Log.info("CallObserver: isOnHold: \(call.isOnHold) hasConnected: \(call.hasConnected), hasEnded: \(call.hasEnded), isOutgoing: \(call.isOutgoing)")
        // Вместо того чтобы полагаться только на 'call', перепроверяем все звонки,
        // так как callChanged вызывается для каждого изменения состояния одного звонка.
        // Общий статус "в звонке" зависит от наличия хотя бы одного активного звонка.
        reportCallStatus()
    }

    public func dispose() {
        // Log.error("CallStateDelegate: dispose called")
        callObserver.setDelegate(nil, queue: nil) // Отписываемся от делегата
        eventSink = nil // Очищаем eventSink
    }
}