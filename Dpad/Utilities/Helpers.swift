//
//  Helpers.swift
//  Dpad
//
//  Created by Paul Kim on 10/15/22.
//

import Foundation
import Combine

extension Channel {
    
    var isFavorited: Bool {
        return UserPreferences.shared.favoriteChannels.contains { $0.id == id }
    }
    
}

extension Array where Element == Stream {
    
    var favorites: [Stream] {
        filter { $0.channel.isFavorited }
    }
    
    var notFavorites: [Stream] {
        filter { !$0.channel.isFavorited }
    }
    
}

extension Int {
    
    var abbreviated: String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        let number = self
        
        switch self {
        case 0...999:
            return "\(number)"
        case 1000...999999:
            let shortNum = NSNumber(value: Double(number) / 1000)
            return formatter.string(from: shortNum)!.appending("K")
        default:
            let shortNum = NSNumber(value: Double(number) / 1000000)
            return formatter.string(from: shortNum)!.appending("M")
        }
    }
    
}

extension Array where Element == DataProvider {
    /*
    var userPublisher: AnyPublisher<TwitchUser?, Never> {
        let publishers = map { $0.userPublisher }
        return Publishers.MergeMany(publishers)
//            .collect()
            .eraseToAnyPublisher()
    }
    
    var streamsPublisher: AnyPublisher<[Stream], Never> {
        let publishers = map { $0.streamsPublisher }
        return Publishers.MergeMany(publishers)
//            .collect()
//            .collect()
            .print()
            .eraseToAnyPublisher()
//            .collect()
//            .eraseToAnyPublisher()
    }
    
    var channelsPublisher: AnyPublisher<[Channel], Never> {
        let publishers = map { $0.channelsPublisher }
        return Publishers.MergeMany(publishers)
//            .collect()
            .eraseToAnyPublisher()
    }
    
    func fetchUser() async throws {
        try await self.asyncForEach {
            try await $0.fetchUser()
        }
    }
    
    func fetchStreams(userID: String) async throws {
//        try await self.asyncForEach {
//            try await $0.fetchStreamsTest()
//        }
    }
    
    func fetchChannels(userID: String) async throws {
//        try await self.asyncForEach {
//            try await $0.fetchChannelsTest()
//        }
    }
    
    func fetchChannel(url: URL) async throws -> Channel? {
        return nil
//        var channels = [Channel]()
//        try await self.asyncForEach {
//            if let channel = try await $0.fetchChannel(url: url) {
//                channels.append(channel)
//            }
//        }
//        return channels.first
    }
    */
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
