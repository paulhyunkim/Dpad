//
//  Shell.swift
//  Dpad
//
//  Created by Paul Kim on 10/12/22.
//

import Foundation

struct ShellService {
    
    static func execute(_ command: String) throws-> String {
        let process = Process()
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        process.arguments = ["-c", command]
        process.launchPath = "/bin/zsh"
        process.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            return output
        } else {
            throw ShellServiceError.couldNotDecodeOutput
        }
    }
    
}
