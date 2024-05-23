import UIKit
import Network
import Flutter
import flutter_local_notifications



@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var group: NWConnectionGroup? = nil

    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // This is required to make any communication available in the action isolate.
        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
            GeneratedPluginRegistrant.register(with: registry)
        }
        SwiftFlutterForegroundTaskPlugin.setPluginRegistrantCallback(registerPlugins)
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }
        initLog(app: self)
        registerMulticastChannel(app: self)
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func registerMulticastChannel(app: FlutterAppDelegate) {
        let controller = app.window?.rootViewController as! FlutterViewController
        let multicastChannel = FlutterMethodChannel(name: "com.ifreedomer.flix/multicast", binaryMessenger: controller.binaryMessenger)
        
        multicastChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if (call.method == "startMulticast") {
//                let args = call.arguments as! Dictionary<String, Any>
//                let host = args["host"] as! String
//                let port = args["port"] as! UInt16
//                self?.startMulticast(host: host, port: port)
            } else if (call.method == "scan") {
                let args = call.arguments as! Dictionary<String, Any>
                let host = args["host"] as! String
                let port = args["port"] as! UInt16
                self?.scan(result: result, channel: multicastChannel, host: host, port: port)
            } else if (call.method == "ping") {
                let content = call.arguments as! String
                self?.ping(result: result, content: content)
            } else if (call.method == "pong") {
                let content = call.arguments as! String
                self?.pong(result: result, content: content)
            } else {
                result(FlutterMethodNotImplemented)
            }
            
        })
    }
    
    
    func startMulticast(host: String, port: UInt16) {
   
        
    }
    
    func scan(result: FlutterResult, channel: FlutterMethodChannel, host: String, port: UInt16) {
        group?.cancel()
        guard let multicast = try? NWMulticastGroup(for: [.hostPort(host: NWEndpoint.Host.ipv4(IPv4Address(host)!), port: NWEndpoint.Port(rawValue: port)!)])
        else {
            log(level: LogLevel.Error, msg: "joint multicast group failed!")
            result("")
            return
        }
        group = NWConnectionGroup(with: multicast, using: .udp)
        
        group!.stateUpdateHandler = { state in
            log(level: LogLevel.Debug, msg: "Multicast state: \(String(describing: state))")
        }
        group!.setReceiveHandler { message, content, isComplete in
            log(level: LogLevel.Debug, msg: "Receive message from \(String(describing: message.remoteEndpoint))")
            
            // 接收数据
            if (content != nil) {
                let json = String(decoding: content!, as: UTF8.self)
                var args = [String: String]()
                args["message"] = json
                if case NWEndpoint.hostPort(let host, _) = message.remoteEndpoint! {
                    if case NWEndpoint.Host.ipv4(let ipv4Address) = host {
                        args["fromIp"] = String(describing: ipv4Address)
                    }
                }
                channel.invokeMethod("receiveMulticastMessage", arguments: args)
//                resut(json)
            } else {
                log(level: LogLevel.Error, msg: "Multicast content should not be nil")
            }
            
        }
        
        group!.start(queue: .main)
        result("")

    }
    
    func ping(result: FlutterResult, content: String) {
        group!.send(content: Data(content.utf8)) { error in
            if error != nil {
                log(level: LogLevel.Error, msg: "Ping error \(String(describing: error))")
            }
        }
        result("")
    }
    
    func pong(result: FlutterResult, content: String) {
        group!.send(content: Data(content.utf8)) { error in
            if error != nil {
                log(level: LogLevel.Error, msg: "Pong error \(String(describing: error))")
            }
        }
        result("")
    }
}

    // here
func registerPlugins(registry: FlutterPluginRegistry) {
    GeneratedPluginRegistrant.register(with: registry)
}
