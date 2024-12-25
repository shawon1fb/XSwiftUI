//
//  AppLogger.swift
//  XSwiftUI
//
//  Created by Shahanul Haque on 12/25/24.
//
import Foundation
import OSLog

extension Bundle {
    public static var appBundleIdentifier: String {
        return Bundle.main.bundleIdentifier ?? "com.example.XSwiftUI"
    }
}

public enum AppLogger {
    private static let queue = DispatchQueue(label: "com.logger.queue")
    
    public static let app = Logger(subsystem: Bundle.appBundleIdentifier, category: "App")
    public static let network = Logger(subsystem: Bundle.appBundleIdentifier, category: "Network")
    public static let user = Logger(subsystem: Bundle.appBundleIdentifier, category: "User")
    
    public enum Level {
        case debug
        case info
        case warning
        case error
        case fault
        
        fileprivate var osLogType: OSLogType {
            switch self {
            case .debug: return .debug
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            case .fault: return .fault
            }
        }
    }
    
    public struct Configuration {
        public let subsystem: String
        public let includeSourceLocation: Bool
        public let defaultPrivacy: OSLogPrivacy
        
        public init(
            subsystem: String = Bundle.appBundleIdentifier,
            includeSourceLocation: Bool = true,
            defaultPrivacy: OSLogPrivacy = .public
        ) {
            self.subsystem = subsystem
            self.includeSourceLocation = includeSourceLocation
            self.defaultPrivacy = defaultPrivacy
        }
    }
    
    nonisolated(unsafe) private static var configuration = Configuration()
    
    public static func configure(_ newConfiguration: Configuration) {
        queue.sync {
            configuration = newConfiguration
        }
    }
    
    public static func log(
        _ message: String,
        level: Level = .info,
        logger: Logger = app,
        isPrivate: Bool = false,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        queue.sync {
            let config = configuration
            let metadata = config.includeSourceLocation
                ? "[\(file.components(separatedBy: "/").last ?? "")] \(function) line \(line):"
                : ""
            
            let fullMessage = metadata.isEmpty ? message : "\(metadata) \(message)"
            
            if isPrivate {
                logger.log(level: level.osLogType, "\(fullMessage, privacy: .private)")
            } else {
                logger.log(level: level.osLogType, "\(fullMessage, privacy: .public)")
            }
        }
    }
    
    public static func logSensitive(
        _ message: String,
        sensitiveData: String,
        level: Level = .info,
        logger: Logger = app,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        queue.sync {
            let config = configuration
            let metadata = config.includeSourceLocation
                ? "[\(file.components(separatedBy: "/").last ?? "")] \(function) line \(line):"
                : ""
            
            let fullMessage = metadata.isEmpty
                ? "\(message): \(sensitiveData)"
                : "\(metadata) \(message): \(sensitiveData)"
            
            logger.log(level: level.osLogType, "\(fullMessage, privacy: .sensitive)")
        }
    }
    
    public static func debug(
        _ message: String,
        logger: Logger = app,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .debug, logger: logger, file: file, function: function, line: line)
    }
    
    public static func info(
        _ message: String,
        logger: Logger = app,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .info, logger: logger, file: file, function: function, line: line)
    }
    
    public static func warning(
        _ message: String,
        logger: Logger = app,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .warning, logger: logger, file: file, function: function, line: line)
    }
    
    public static func error(
        _ message: String,
        logger: Logger = app,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .error, logger: logger, file: file, function: function, line: line)
    }
    
    public static func fault(
        _ message: String,
        logger: Logger = app,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .fault, logger: logger, file: file, function: function, line: line)
    }
}
