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

    private struct PendingLog {
        let message: String
        let level: Level
        let byteCount: Int
    }

    private static let shared = MahaLog()

    private let logger = SwiftyBeaver.self
    private let console = ConsoleDestination()
    private let file = FileDestination()
    private let pendingLock = NSLock()
    private let writeQueue = DispatchQueue(label: "com.maha.log.write", qos: .utility)
    private var pendingLogs: [PendingLog] = []
    private var pendingBytes = 0
    private var isDrainScheduled = false
    private var droppedLogCount = 0

    private static let logFormat = "$D YYYY:MM:dd HH:mm:ss$d $L: $M"
    private static let logFileAmount = 4
    private static let logDirectoryComponents = ["Maha", "logs"]
    private static let logFileName = "log"
    private static let filePrefix = "flie="
    private static let maximumPendingLogCount = 256
    private static let maximumPendingLogBytes = 512 * 1024
    private static let maximumMessageCharacterCount = 16 * 1024

    private init() { configureLogger() }

    private func configureLogger() {

        file.logFileAmount = Self.logFileAmount
        file.logFileURL = buildLogFileURL()
        file.format = Self.logFormat

        console.format = Self.logFormat

        // MahaLog owns the bounded asynchronous queue. Synchronous destinations
        // prevent SwiftyBeaver from creating a second pair of unbounded queues.
        file.asynchronously = false
        console.asynchronously = false

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
        let body = message as? String ?? String(describing: message)
        guard body.count > maximumMessageCharacterCount else {
            return "\(filePrefix)\(fileName)::\(body)"
        }
        let truncatedBody = String(body.prefix(maximumMessageCharacterCount))
        return "\(filePrefix)\(fileName)::\(truncatedBody) [truncated]"
    }

    private func hasCapacityForNewLog() -> Bool {
        pendingLock.lock()
        defer { pendingLock.unlock() }
        guard pendingLogs.count < Self.maximumPendingLogCount,
              pendingBytes < Self.maximumPendingLogBytes else {
            droppedLogCount += 1
            return false
        }
        return true
    }

    private func enqueue<T>(_ message: T, level: Level, file: String) {
        let content = Self.formatLogMessage(message, file: file)
        let entry = PendingLog(
            message: content,
            level: level,
            byteCount: content.utf8.count + file.utf8.count
        )

        pendingLock.lock()
        guard pendingLogs.count < Self.maximumPendingLogCount,
              pendingBytes + entry.byteCount <= Self.maximumPendingLogBytes else {
            droppedLogCount += 1
            pendingLock.unlock()
            return
        }
        pendingLogs.append(entry)
        pendingBytes += entry.byteCount
        let shouldScheduleDrain = isDrainScheduled == false
        isDrainScheduled = true
        pendingLock.unlock()

        if shouldScheduleDrain {
            writeQueue.async { [weak self] in
                self?.drainPendingLogs()
            }
        }
    }

    private func drainPendingLogs() {
        while let next = dequeuePendingLog() {
            autoreleasepool {
                if next.droppedCount > 0 {
                    write(
                        message: "\(Self.filePrefix)MahaLog.swift::[MahaLog] dropped \(next.droppedCount) logs because the pending write buffer was full",
                        level: .info
                    )
                }
                write(message: next.entry.message, level: next.entry.level)
            }
        }
    }

    private func dequeuePendingLog() -> (entry: PendingLog, droppedCount: Int)? {
        pendingLock.lock()
        defer { pendingLock.unlock() }
        guard pendingLogs.isEmpty == false else {
            isDrainScheduled = false
            return nil
        }
        let entry = pendingLogs.removeFirst()
        pendingBytes -= entry.byteCount
        let droppedCount = droppedLogCount
        droppedLogCount = 0
        return (entry, droppedCount)
    }

    private func write(message: String, level: Level) {
        switch level {
        case .debug:
            logger.debug(message)
        case .info:
            logger.info(message)
        case .error:
            logger.error(message)
        }
    }

    public static func record<T>(
        _ message: @autoclosure () -> T,
        level: Level = .debug,
        file: String = #file
    ) {
        let log = shared
        guard log.hasCapacityForNewLog() else { return }
        log.enqueue(message(), level: level, file: file)
    }
}
