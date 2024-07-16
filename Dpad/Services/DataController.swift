//
//  DataController.swift
//  Dpad
//
//  Created by Paul Kim on 12/5/22.
//

import Foundation
import Combine

class DataController {
    
    var twitchDataProvider: TwitchDataProvider
    var youTubeDataProvider: YouTubeDataService

    @Published var channels: [Channel] = []
    @Published var streams: [Stream] = []
    
    @Published var playingStreams: [Stream] = []
    
    var cancellables = Set<AnyCancellable>()
    
    init() {
        twitchDataProvider = TwitchDataProvider()
        youTubeDataProvider = YouTubeDataService()
        
        Publishers.CombineLatest(youTubeDataProvider.$channels, twitchDataProvider.$channels)
//            .receive(on: DispatchQueue.main)
            .map { $0 + $1 }
            .map { $0.sorted { $0.name.lowercased() < $1.name.lowercased() } }
            .assign(to: &$channels)
        
        Publishers.CombineLatest(youTubeDataProvider.$streams, twitchDataProvider.$streams)
//            .receive(on: DispatchQueue.main)
            .map { $0 + $1 }
            .map { $0.sorted { $0.viewerCount > $1.viewerCount } }
            .assign(to: &$streams)
        
        setupRefreshScheduleSubscription()
    }
    
    private var streamsSubject = CurrentValueSubject<[Stream], Never>([])
    private var channelsSubject = CurrentValueSubject<[Channel], Never>([])
    
    var justWentLivePublisher: AnyPublisher<[Stream], Never> {
        $streams
            .scan([]) { (initial, next) in
                return next
                    .filter { newStream in
                        let isAddition = !self.streams.contains { oldStream in
                            oldStream.channel.id == newStream.channel.id
                        }

                        guard let startTime = newStream.startTime else {
                            return false
                        }
                        let didJustStart = Date.now.timeIntervalSince(startTime) < 3 * 60
                        return isAddition && didJustStart
                    }
            }
            .eraseToAnyPublisher()
    }
    
    var justEndedPublisher: AnyPublisher<[Stream], Never> {
        $streams
            .scan([]) { (initial, next) in
                return initial
                    .filter { oldStream in
                        !next.contains { newStream in
                            oldStream.channel.id == newStream.channel.id
                        }
                    }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchChannels() {
        Task {
            do {
                try await youTubeDataProvider.fetchChannels()
            } catch {
                print("Fetch youtube channels error:", error)
            }
        }
        Task {
            try await twitchDataProvider.fetchChannels()
        }
    }
    
    func fetchStreams() {
        Task {
            do {
                try await youTubeDataProvider.fetchStreams()
            } catch {
                print("Fetch youtube streams error:", error)
            }
        }
        Task {
            try await twitchDataProvider.fetchStreams()
        }
//        Task {
//            do {
//                let youTubeStreams = try await youTubeDataProvider.fetchStreams()
//                let twitchStreams = try await twitchDataProvider.fetchStreams()
//                let streams = youTubeStreams + twitchStreams
//                await MainActor.run {
//                    self.streams = streams.sorted(by: { lhs, rhs in lhs.viewerCount > rhs.viewerCount })
//                }
//            } catch {
//                print(error)
//            }
//        }
    }
    
    func addChannel(for url: URL) {
        Task {
            do {
                if url.host()?.contains("twitch") == true {
                    try await twitchDataProvider.addChannel(from: url)
                } else if url.host()?.contains("youtube") == true {
                    try await youTubeDataProvider.addChannel(from: url)
                }
                let channels: [Channel] = youTubeDataProvider.cachedChannels + twitchDataProvider.cachedChannels
                await MainActor.run {
                    self.channels = channels.sorted(by: { lhs, rhs in lhs.name.lowercased() < rhs.name.lowercased() })
                }
            } catch {
                print(error)
            }
            
        }
        fetchStreams()
    }
    
    private func setupRefreshScheduleSubscription() {
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .prepend(Date())
            .sink { _ in
                self.fetchStreams()
            }
            .store(in: &cancellables)
        
        Timer.publish(every: 60 * 60 * 1, on: .main, in: .common)
            .autoconnect()
            .prepend(Date())
            .sink { _ in
                self.fetchChannels()
            }
            .store(in: &cancellables)
    }
    
}
