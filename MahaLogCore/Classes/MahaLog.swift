//
//  MahaLog.swift
//  Pods
//
//  Created by mahaLive on 2024/2/21.
//

import Foundation
import SwiftyBeaver

public final class MahaLog {
    public enum Level {
        case debug
        case info
        case error
    }

    private static let shared = MahaLog()

    private let logger = SwiftyBeaver.self
    private let console = ConsoleDestination()
    private let file = FileDestination()

    private static let logFormat = "$D YYYY:MM:dd HH:mm:ss$d $L: $M"
    private static let logFileAmount = 4
    private static let logDirectoryComponents = ["Maha", "logs"]
    private static let logFileName = "log"
    private static let filePrefix = "flie="

    private init() { configureLogger() }

    private func configureLogger() {

        // 默认 swiftybeaver.log 文件日志
        file.logFileAmount = Self.logFileAmount
        file.logFileURL = buildLogFileURL()
        file.format = Self.logFormat

        // Xcode控制台日志
        console.format = Self.logFormat

        // 添加配置到 SwiftyBeaver
        logger.addDestination(console)
        logger.addDestination(file)
    }

    private func buildLogFileURL() -> URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: "")

        return Self.logDirectoryComponents.reduce(documentDirectory) { partialURL, component in
            partialURL.appendingPathComponent(component, isDirectory: true)
        }.appendingPathComponent(Self.logFileName, isDirectory: false)
    }

    private static func formatLogMessage<T>(_ message: T, file: String) -> String {
        let fileName = (file as NSString).lastPathComponent
        return "\(filePrefix)\(fileName)::\(message)"
    }

    private static func writeLog<T>(_ message: T, file: String, using output: (SwiftyBeaver.Type, String) -> Void) {
        autoreleasepool {
            output(shared.logger, formatLogMessage(message, file: file))
        }
    }

    public static func record<T>(_ message: T, level: Level = .debug, file: String = #file) {
        writeLog(message, file: file) { logger, content in
            switch level {
            case .debug:
                logger.debug(content)
            case .info:
                logger.info(content)
            case .error:
                logger.error(content)
            }
        }
    }
}
