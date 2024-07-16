//
//  AppState.swift
//  Dpad
//
//  Created by Paul Kim on 10/10/22.
//

import SwiftUI
import AVKit
import Combine
import UserNotifications

enum StreamsLayout {
    case symmetricGrid
    case focusedGrid
}

extension Sequence {
    func asyncForEach(
        _ operation: (Element) async throws -> Void
    ) async rethrows {
        for element in self {
            try await operation(element)
        }
    }
}

struct StreamViewModel {
    var stream: Stream
    var player: StreamPlayer
}

class AppState: ObservableObject {
    
    @Published private(set) var user: TwitchUser?
    @Published private(set) var streams: [Stream] = []
    @Published private(set) var channels: [Channel] = []
    @Published private(set) var streamPlayers: [StreamPlayer] = []
    
    @Published private(set) var justWentLiveStreams: [Stream] = []
    @Published private(set) var justEndedStreams: [Stream] = []
    @Published private(set) var allMuted: Bool = false
    @Published private(set) var showChat: Bool = true
    
    @Published private(set) var streamsPlaying: [Stream] = []
    
    // When new streams comes on
    var autoPlayMode: AutoPlayMode = .enabled(autoFocus: .enabled)
    var autoFocusMode: AutoFocusMode = .enabled
    
    // Notifications
    // TODO: - not implemented yet
    var areNotificationsEnabled: Bool = false

    // Master Volume
    var masterVolume: Double = 1 { willSet { sendVolumeUpdate(newValue) } }
    private var masterVolumeChangeSubject = PassthroughSubject<VolumeChange, Never>()
    
    private func sendVolumeUpdate(_ newVolume: Double) {
        let volumeChange = VolumeChange(from: masterVolume, to: newVolume)
        masterVolumeChangeSubject.send(volumeChange)
    }
    
//    var masterVolumeChangePublisher: AnyPublisher<VolumeChange, Never> {
//        masterVolumeChangeSubject
//            .eraseToAnyPublisher()
//    }
    
    enum AutoPlayMode {
        case enabled(autoFocus: AutoFocusMode)
        case disabled
    }
    
    enum NewStreamPlayMode {
        // auto play and focused and not muted
        // auto play and not focused and not muted
        // auto play and not focused and muted
        // not auto pla
    }
    
    enum AutoFocusMode {
        case enabled
        case disabled
    }
    
    struct VolumeChange {
        var from: Double
        var to: Double
    }

    @Published var streamsLayout: StreamsLayout = .focusedGrid
    
//    var dataServices: [DataProvider]
    var streamlinkService: StreamlinkService
    var cancellables = Set<AnyCancellable>()
    
    var dataController: DataController
    
    enum Action {
        case addChannel(URL)
        case fetchUser
        case fetchChannels
        case fetchStreams
        case playStream(Stream)
        case closeStream(Stream)
        case focusStream(Stream)
        case favoriteChannel(Channel)
        case unfavoriteChannel(Channel)
        case requestNotificationPermission
        case toggleChat
    }
    
    init(dataServices: [DataProvider]) {
        self.streamlinkService = StreamlinkService()
        
        self.dataController = DataController()
        
//        setupSubscriptions()
//        execute(.fetchUser)
//        execute(.fetchChannels)
        requestNotificationPermission()
        
        dataController.$channels
            .assign(to: &$channels)
        
        dataController.$streams
            .assign(to: &$streams)
        
        dataController.justWentLivePublisher
            .receive(on: DispatchQueue.main)
            .print("justWentLive")
            .sink { streams in
                streams.forEach {
                    let content = UNMutableNotificationContent()
                    content.title = "\($0.channel.name) went live!"
                    content.subtitle = $0.title ?? "Click to watch"
                    content.sound = UNNotificationSound.default

                    // show this notification five seconds from now
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

                    // choose a random identifier
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                    // add our notification request
                    UNUserNotificationCenter.current().add(request)
                    
//                    self.execute(.playStream($0))
                }
            }
            .store(in: &cancellables)
        
        dataController.justEndedPublisher
            .receive(on: DispatchQueue.main)
            .print("justEnded")
            .sink { streams in
                streams
                    .filter { self.isPlaying(stream: $0) }
                    .forEach { self.execute(.closeStream($0)) }
            }
            .store(in: &cancellables)
    }
    
    func execute(_ action: Action) {
        switch action {
        case .addChannel(let url):
            dataController.addChannel(for: url)
        case .fetchUser:
            return
        case .fetchChannels:
            dataController.fetchChannels()
        case .fetchStreams:
            dataController.fetchStreams()
        case .playStream(let stream):
            playStream(stream)
        case .closeStream(let stream):
            closeStream(stream)
        case .focusStream(let stream):
            focusStream(stream)
        case .favoriteChannel(let channel):
            favoriteChannel(channel)
        case .unfavoriteChannel(let channel):
            unfavoriteChannel(channel)
        case .requestNotificationPermission:
            requestNotificationPermission()
        case .toggleChat:
            showChat.toggle()
        }
    }
    
    var offlineChannels: [Channel] {
        let streamChannels = streams.map { $0.channel }
        return channels.filter { channel in
            !streamChannels.contains { streamChannel in
                streamChannel.id == channel.id
            }
        }
    }
    
    var playingStreams: [Stream] {
        return streams
            .filter { isPlaying(stream: $0) }
    }
    
    var notPlayingStreams: [Stream] {
        return streams
            .filter { !isPlaying(stream: $0) }
    }
    
    func isPlaying(channel: Channel) -> Bool {
        return streamPlayers.contains(where: { channel.id == $0.stream.channel.id })
    }
    
    func isPlaying(stream: Stream) -> Bool {
        return streamPlayers.contains(where: { stream.channel.id == $0.stream.channel.id })
    }

}


// MARK: - Actions

extension AppState {
    
    /*
    private func addChannel(url: URL) {
        Task {
            do {
                guard let channel = try await dataServices.fetchChannel(url: url) else {
                    return
                }
                UserPreferences.shared.channels.append(channel.toCacheType())
                try await fetchChannels()
                try await fetchStreams()
            } catch {
                print(error)
            }
        }
    }
    
    private func fetchUser() async throws {
        try await dataServices.fetchUser()
    }
    
    private func fetchStreams() async throws {
//        guard let userID = user?.id else {
//            return
//        }
    
        try await dataServices.fetchStreams(userID: "userID")
    }
    
    private func fetchChannels() async throws {
//        guard let userID = user?.id else {
//            return
//        }
        
        try await dataServices.fetchChannels(userID: "userID")
    }
     */
    
    private func playStream(_ stream: Stream, quality: StreamQuality = UserPreferences.shared.defaultQuality) {
        streamsPlaying.append(stream)
        guard !streamPlayers.contains(where: { $0.stream.url == stream.url }) else {
            return
        }
        Task.detached {
            do {
                let streamURL = try await self.streamlinkService.url(for: stream, quality: quality)
                let streamPlayer = StreamPlayer(stream: stream, streamURL: streamURL)
                await MainActor.run {
                    switch self.autoFocusMode {
                    case .enabled:
                        self.streamPlayers.insert(streamPlayer, at: 0)
                        streamPlayer.isMuted = false
                    case .disabled:
                        self.streamPlayers.append(streamPlayer)
                        streamPlayer.isMuted = true
                    }
//                    self.streamPlayers.append(streamPlayer)
                    streamPlayer.volume = self.masterVolume
                    streamPlayer.play()
                }
            } catch {
                print(error)
            }
        }
    }
    
    private func closeStream(_ stream: Stream) {
        guard let index = streamsPlaying.firstIndex(where: { $0.url == stream.url }) else {
            return
        }
        streamsPlaying.remove(at: index)
        
        guard let index = streamPlayers.firstIndex(where: { $0.stream.url == stream.url }) else {
            return
        }
        streamPlayers.remove(at: index)
    }
    
    private func focusStream(_ stream: Stream) {
        guard let index = streamPlayers.firstIndex(where: { $0.stream.url == stream.url }) else {
            return
        }
        streamPlayers.swapAt(index, 0)
    }
    
    private func favoriteChannel(_ channel: Channel) {
//        guard !UserPreferences.shared.favoriteChannels.contains(where: { favoriteChannel in
//            return favoriteChannel.id == channel.id
//        }) else {
//            return
//        }
//        let favoriteChannel = FavoriteChannel(channel: channel)
//        UserPreferences.shared.channel.append(favoriteChannel)
    }
    
    private func unfavoriteChannel(_ channel: Channel) {
//        guard let index = UserPreferences.shared.favoriteChannels.firstIndex(where: { $0.id == channel.id }) else {
//            return
//        }
//        UserPreferences.shared.favoriteChannels.remove(at: index)
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound],
            completionHandler: { success, error in
                if success {
                    print("All set!")
//                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
//                        let content = UNMutableNotificationContent()
//                        content.title = "Feed the cat"
//                        content.subtitle = "It looks hungry"
//                        content.sound = UNNotificationSound.default
//
//                        // show this notification five seconds from now
//                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//
//                        // choose a random identifier
//                        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//
//                        // add our notification request
//                        UNUserNotificationCenter.current().add(request)
//                    }
                } else if let error {
                    print(error.localizedDescription)
                }
            }
        )
    }
    
}

// MARK: - Subscriptions

extension AppState {
    
    private func setupSubscriptions() {
//        setupDataControllerSubscriptions()
//        setupAutoPlayFavoritesSubscription()
//        setupAutoCloseEndedSubscription()
//        setupAutoRefreshOnUserUpdateSubscription()
//        setupMasterVolumeSubscription()
//        setupRefreshScheduleSubscription()
    }
    
    private func setupDataControllerSubscriptions() {
//        $channels
//            .map { $0.map { $0.toCacheType() } }
//            .sink { UserPreferences.shared.channels = $0 }
//            .store(in: &cancellables)
        
//        dataServices.userPublisher
//            .receive(on: DispatchQueue.main)
////            .print()
//            .assign(to: &$user)
        
//        dataServices.forEach {
//            $0.channelsPublisher
//                .receive(on: DispatchQueue.main)
//                .print()
//                .sink { _ in
//
//                }
//                .store(in: &cancellables)
//        }
        
//        dataServices.forEach {
//            $0.streamsPublisher
//                .receive(on: DispatchQueue.main)
//                .print()
//                .sink { _ in
//
//                }
//                .store(in: &cancellables)
//        }
        
        
        $channels
            .receive(on: DispatchQueue.main)
            .sink { _ in
//                self.channels = $0
            }
            .store(in: &cancellables)
    
        $streams
            .receive(on: DispatchQueue.main)
            .print("streamsPublisher")
            .sink { streams in
                let newStreams = streams
                    .filter { newStream in
                        !self.streams.contains { oldStream in
                            oldStream.channel.id == newStream.channel.id
                        }
                    }
                let endedStreams = self.streams
                    .filter { oldStream in
                        !streams.contains { newStream in
                            oldStream.channel.id == newStream.channel.id
                        }
                    }
                self.streams = streams
                self.justWentLiveStreams = newStreams.filter { stream in
                    guard let startTime = stream.startTime else {
                        return false
                    }
                    return Date.now.timeIntervalSince(startTime) < 3 * 60
                }
                self.justEndedStreams = endedStreams
            }
            .store(in: &cancellables)
    }
    
    private func setupAutoPlayFavoritesSubscription() {
        $justWentLiveStreams
            .receive(on: DispatchQueue.main)
            .sink { streams in
                streams.favorites
                    .forEach {
                        print("sent notification")
                        let content = UNMutableNotificationContent()
                        content.title = "\($0.channel.name) went live!"
                        content.subtitle = $0.title ?? "Click to watch"
                        content.sound = UNNotificationSound.default

                        // show this notification five seconds from now
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

                        // choose a random identifier
                        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                        // add our notification request
                        UNUserNotificationCenter.current().add(request)
                        
                        self.execute(.playStream($0))
                    }
            }
            .store(in: &cancellables)
    }
    
    private func setupAutoCloseEndedSubscription() {
        $justEndedStreams
            .sink { streams in
                streams
                    .filter { self.isPlaying(stream: $0) }
                    .forEach { self.execute(.closeStream($0)) }
            }
            .store(in: &cancellables)
    }
    
    private func setupAutoRefreshOnUserUpdateSubscription() {
        $user
            .receive(on: DispatchQueue.main)
            .sink { _ in
                Task {
                    try await self.dataController.fetchChannels()
                    try await self.dataController.fetchStreams()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupRefreshScheduleSubscription() {
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { _ in self.execute(.fetchStreams) }
            .store(in: &cancellables)
        
        Timer.publish(every: 60 * 60 * 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in self.execute(.fetchChannels) }
            .store(in: &cancellables)
    }
    
    private func setupMasterVolumeSubscription() {
        masterVolumeChangeSubject
            .receive(on: DispatchQueue.main)
//            .print()
            .sink { volumeChange in
//                print("masterVolume: \(self.masterVolume)")
                self.streamPlayers.forEach { player in
                    var newVolume = volumeChange.to / volumeChange.from * Double(player.volume)
//                    print("volume for \(player.stream.channel.name): \(min(newVolume, 1))")
                    // Helps reset the value to a baseline each time.
                    // The master and player volumes will start to diverge since their final values are a product
                    // of a series of micro calculations as the slider drags.
                    if newVolume > 0.99 {
                        newVolume = 1
                    }
                    player.volume = newVolume
                }
            }
            .store(in: &cancellables)
        
        $allMuted
            .receive(on: DispatchQueue.main)
            .sink { allMuted in
                self.streamPlayers.forEach { player in
                    player.isMuted = allMuted
                }
            }
            .store(in: &cancellables)
    }
    
}

extension AppState {
    
//    static func mockState() -> AppState {
//        return AppState(dataServices: [MockTwitchDataProvider()])
//    }
    
}

