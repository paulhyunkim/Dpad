//
//  StreamlinkService.swift
//  Dpad
//
//  Created by Paul Kim on 10/15/22.
//

import Foundation

struct StreamlinkService {
    
    func url(for stream: Stream, quality: StreamQuality) async throws -> URL {
        guard let url = stream.url else {
            throw StreamlinkServiceError.invalidStreamURL
        }
        
        let qualityArg = stream.streamlinkQualityArg(quality)
        
        return try await withCheckedThrowingContinuation { continuation in
            let command = "\(UserPreferences.shared.streamlinkPath) --twitch-low-latency --twitch-disable-ads '--twitch-api-header=Authorization=OAuth k3ajhglzuzcxzvd68sis4mzv00vy3b' \"\(url.absoluteString)\" \(qualityArg) --stream-url"
            print(command)
            Task {
                do {
                    let output = try ShellService.execute(command).trimmingCharacters(in: .whitespacesAndNewlines)
                    if let url = URL(string: output) {
                        continuation.resume(returning: url)
                    } else {
                        continuation.resume(throwing: StreamlinkServiceError.outputIsNotAURL(output))
                    }
                }
            }
        }
    }
    
}

