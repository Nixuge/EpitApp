//
//  Logging.swift
//  EpitApp
//
//  Created by Quenting on 02/04/2025.
//

import Foundation
import OSLog

public enum LogLevel: String {
    case debug
    case info
    case warning
    case error
    case critical
}

func emojiPrefix(for logLevel: LogLevel) -> String {
    let prefixes: [LogLevel: String] = [
        .debug: "🐛",
        .info: "📘", // ℹ️
        .warning: "⚠️",
        .error: "❌",
        .critical: "🔥"
    ]

    return prefixes[logLevel] ?? "❓"
}

// Note: due to the OS_ACTIVITY_MODE env variable (in product>scheme), i am not using as logger as it just doesn't log
// anything w that enabled.
// The env variable is set because otherwise i get an ungodly amount of random logs.
//let logger = Logger()

public func log(_ message: Any, _ logLevel: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
    
    let parsedFile = file.split(separator: "/").last?.replacing(".swift", with: "").description ?? "Unk"
    let parsedFunc = function.split(separator: "(").first?.description ?? "Unk"
    
    let prefix = emojiPrefix(for: logLevel)
    
    print("[\(prefix)|\(parsedFile):\(line)@\(parsedFunc)] \(message)")

//    switch logLevel {
//    case .debug:
//        logger.debug("[\(parsedFile):\(line)@\(parsedFunc)] \(message)")
//    case .info:
//        logger.info("[\(parsedFile):\(line)@\(parsedFunc)] \(message)")
//    case .warning:
//        logger.warning("[\(parsedFile):\(line)@\(parsedFunc)] \(message)")
//    case .error:
//        logger.error("[\(parsedFile):\(line)@\(parsedFunc)] \(message)")
//    case .critical:
//        logger.critical("[\(parsedFile):\(line)@\(parsedFunc)] \(message)")
//    }
}

public func debugLog(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
    log(message, .debug, file: file, function: function, line: line)
}

public func warn(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
    log(message, .warning, file: file, function: function, line: line)
}

public func errorr(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
    log(message, .error, file: file, function: function, line: line)
}

public func critical(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
    log(message, .critical, file: file, function: function, line: line)
}

public func info(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
    log(message, file: file, function: function, line: line)
}

