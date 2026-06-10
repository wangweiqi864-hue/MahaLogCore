//
//  MahaLog.swift
//  Pods
//
//  Created by mahaLive on 2024/2/21.
//

import Foundation
import SwiftyBeaver

public class MahaLog{

    private static let share = MahaLog()
    
    private let log = SwiftyBeaver.self
    private let console = ConsoleDestination()
    private let file = FileDestination()
    
    private var logPathDir = "/Maha/logs/"
    
    private init() {config()}
    
    private func config() {
        
        let doucmentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        logPathDir = doucmentDir + logPathDir + "log"
        
//        logPathDir = dir.appending(logPathDir)
        
        // 默认swiftybeaver.log文件日志
        file.logFileAmount = 4
        file.logFileURL = URL(fileURLWithPath:logPathDir)
        file.format = "$D YYYY:MM:dd HH:mm:ss$d $L: $M"
        
        // Xcode控制台日志
        console.format = "$D YYYY:MM:dd HH:mm:ss$d $L: $M"

        //添加配置到SwiftyBeaver
        log.addDestination(console)
        log.addDestination(file)
    }
    
    public static func recordDebug<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line) {
        autoreleasepool {
            let fileName = (file as NSString).lastPathComponent
            let msg = "flie=\(fileName)::\(message)"
            self.share.log.debug(msg)
        }
    }
    
    
    public static func recordInfo<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line) {
        autoreleasepool {
            let fileName = (file as NSString).lastPathComponent
            let msg = "flie=\(fileName)::\(message)"
            self.share.log.info(msg)
        }
    }

    
    public static func recordError<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line) {
        autoreleasepool {
            let fileName = (file as NSString).lastPathComponent
            let msg = "flie=\(fileName)::\(message)"
            self.share.log.error(msg)
        }
    }
    
    // 打印的debu
    public static func record<T>(_ message: T, file: String = #file) {
        autoreleasepool {
            let fileName = (file as NSString).lastPathComponent
            let msg = "flie=\(fileName)::\(message)"
            self.share.log.debug(msg)
        }
    }
    
}
