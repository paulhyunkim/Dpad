//
//  Clock.swift
//  Dpad
//
//  Created by Paul Kim on 10/17/22.
//

import SwiftUI

private struct TimerKey: EnvironmentKey {
    static let defaultValue: Clock = Clock()
}

extension EnvironmentValues {
    var clock: Clock {
        get { self[TimerKey.self] }
        set { self[TimerKey.self] = newValue }
    }
}

class Clock: ObservableObject {
    
    @Published var time: Date = .now
    
    let dateFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .brief
        formatter.zeroFormattingBehavior = .dropLeading
        return formatter
    }()
    
    init() {
        Timer.TimerPublisher(interval: 60, runLoop: .main, mode: .default)
            .autoconnect()
//            .compactMap { clock in
//                let formatter = DateComponentsFormatter()
//                formatter.allowedUnits = [.hour, .minute, .second]
//                formatter.zeroFormattingBehavior = .pad
//                if let startTime = streamPlayer.stream.startTime {
//                    let uptime = Date.now.timeIntervalSince(startTime)
//                    return formatter.string(from: uptime)
//                } else {
//                    return nil
//                }
//            }
//            .removeDuplicates()
////            .print()
//            .sink { uptimeString in
//                self.uptime = uptimeString
//            }
//            .store(in: &cancellables)
            .assign(to: &$time)
    }
    
    func uptime(for startedAt: Date?) -> String? {
        guard let startedAt else {
            return nil
        }
        let uptimeInterval = time.timeIntervalSince(startedAt)
        return dateFormatter.string(from: uptimeInterval)
    }
    
}
