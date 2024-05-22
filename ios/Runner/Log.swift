//
//  Log.swift
//  Runner
//
//  Created by heiha on 2024/5/22.
//

import Foundation

enum LogLevel: String {
    case Error = "error"
    case Critical = "critical"
    case Info = "info"
    case Debug = "debug"
    case Verbose = "verbose"
    case Warning = "warning"
    case Exception = "exception"
}

class Log {
    var logChannel: FlutterMethodChannel?
    
    func initialize(app: FlutterAppDelegate) {
        let controller = app.window?.rootViewController as! FlutterViewController
        logChannel = FlutterMethodChannel(name: "com.ifreedomer.flix/log", binaryMessenger: controller.binaryMessenger)
    }
    
    func log(level: LogLevel, msg: String) {
        print(msg)
        logChannel?.invokeMethod("log", arguments: ["level": level.rawValue, "msg": msg])
    }
}

private var logObject = Log()

func initLog(app: FlutterAppDelegate) {
    logObject.initialize(app: app)
}

func log(level: LogLevel, msg: String) {
    logObject.log(level: level, msg: msg)
}


