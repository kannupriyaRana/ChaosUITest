//
//  LogFile.swift
//  AtpUITests
//
//  Created by Kannupriya on 26/05/22.
//  Copyright © 2022 Microsoft. All rights reserved.
//

import Foundation

class LogFileHandler {

    static let filePath = "/Users/runner/work/1/s/chaosInputsLogFile.txt"
    static let fileURL = URL(string:filePath)!

    static func appendLogsIntoFile(_ content : String) {
        if let handle = try? FileHandle(forWritingTo: fileURL) {
            handle.seekToEndOfFile()
            handle.write(content.data(using: .utf8)!)
            handle.closeFile()
        }
    }

    static func createFileToStoreInputEvents() {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
            } catch {
                print(error)
            }
        }
        FileManager.default.createFile(atPath: fileURL.path, contents: nil)
    }
}
