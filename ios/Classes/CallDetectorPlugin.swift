import Flutter
import UIKit
import Foundation
import CallKit

/* CallDetectorPlugin for iOS 10+ */
public final class CallDetectorPlugin: NSObject, FlutterPlugin {
    private let eventChannel: FlutterEventChannel
    private let callStateDelegate: CallStateDelegate
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        // Log.info("CallDetectorPlugin register")
        let methodChannel = FlutterMethodChannel(name: ChannelConstants.methodChannel, binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: ChannelConstants.eventChannel, binaryMessenger: registrar.messenger())
        
        let delegate = CallStateDelegate()
        let plugin = CallDetectorPlugin(eventChannel: eventChannel, callStateDelegate: delegate)
        
        registrar.addMethodCallDelegate(plugin, channel: methodChannel)
        eventChannel.setStreamHandler(delegate)
    }
    
    init(eventChannel: FlutterEventChannel, callStateDelegate: CallStateDelegate) {
        // Log.info("CallDetectorPlugin init")
        self.eventChannel = eventChannel
        self.callStateDelegate = callStateDelegate
        super.init()
    }
    
    deinit {
        eventChannel.setStreamHandler(nil)
        callStateDelegate.dispose()
        // Log.error("CallDetectorPlugin deinit")
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case MethodConstants.getCurrentStatus:
            let currentStatus = callStateDelegate.getCurrentStatus()
            // Log.info("GetCurrentStatus method called, status = \(currentStatus)")
            result(currentStatus)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
