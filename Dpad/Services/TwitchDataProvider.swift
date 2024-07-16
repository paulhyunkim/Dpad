//
//  TwitchDataProvider.swift
//  Dpad
//
//  Created by Paul Kim on 10/14/22.
//

import SwiftUI
import Combine

class TwitchDataProvider: DataProvider {
    
    @AppStorage(Constant.Twitch.channels) var cachedChannels: [TwitchChannel] = []
//    @AppStorage(Constant.Twitch.user) var cachedUser: TwitchUser = TwitchUser(id: "", userName: "", clientID: "", expiresIn: -1)
//    TwitchUser(id: "", userName: "", clientID: "", expiresIn: 0)
    
    var user: TwitchUser? = nil
    
    @Published var channels: [Channel] = []
    @Published var streams: [Stream] = []
    
    let streamlinkService = StreamlinkService()
    
    init() {
//        channels = cachedChannels
        
        Task {
//            if cachedUser.id.isEmpty {
                try await fetchUser()
//            }
//            self.user = user
        }
    }
    
    func fetchChannels() async throws -> [Channel] {
        let ids = cachedChannels.map { $0.id }
        let usersData: [GetTwitchUsersResponse.Data] = try await fetchUsers(ids: ids)
        let channelsData: [GetTwitchChannelsResponse.Data] = try await fetchChannels(ids: ids)
        
        let channels: [TwitchChannel] = channelsData
            .compactMap { channelData in
                guard let userData = usersData.first(where: { $0.id == channelData.broadcaster_id }) else {
                    return nil
                }
                return TwitchChannel(userData: userData, channelData: channelData)
            }
        DispatchQueue.main.async {
            self.channels = channels
        }
        updateChannelsCache(with: channels)
        return channels
    }
    
    func fetchStreams() async throws -> [Stream] {
        let ids = cachedChannels.map { $0.id }
        let streamsData: [GetTwitchStreamsResponse.Data] = try await fetchStreams(ids: ids)
        
        let streams: [TwitchStream] = streamsData
            .compactMap { streamData in
                guard let channel = cachedChannels.first(where: { $0.id == streamData.user_id }) else {
                    return nil
                }
                return TwitchStream(streamData: streamData, channel: channel)
            }
        DispatchQueue.main.async {
            self.streams = streams
        }
        return streams
    }
    
//    func fetchFollowedStreams() async throws -> [Stream] {
//        guard let userID = user?.id else {
//            throw DataServiceError.invalidURL
//        }
//        var urlComponents = URLComponents(url: Constant.Twitch.followedApiURL, resolvingAgainstBaseURL: false)
//        urlComponents?.queryItems = [URLQueryItem(name: "user_id", value: userID)]
//
//        guard let requestURL = urlComponents?.url else {
//            throw DataServiceError.invalidURL
//        }
//
//        var urlRequest = URLRequest(url: requestURL)
//        urlRequest.setValue("Bearer \(UserPreferences.shared.twitchAccessToken)", forHTTPHeaderField: "Authorization")
//        urlRequest.setValue(UserPreferences.shared.twitchClientID, forHTTPHeaderField: "Client-ID")
//
//        let (data, _) = try await URLSession.shared.data(for: urlRequest)
//        let decoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .iso8601
//        let streamsData = try decoder.decode(GetTwitchStreamsSuccess.self, from: data).data
//
//        let streams: [TwitchStream] = streamsData.compactMap { data -> TwitchStream? in
//            guard let channel = UserPreferences.shared.channels.first(where: { $0.id == data.user_id }) else {
//                return nil
//            }
//
//            return TwitchStream(item: data, channel: channel)
//        }
//
//        return streams
//    }
    
    func addChannel(from url: URL) async throws {
//    https://www.twitch.tv/ironmouse
        guard url.host()?.contains("twitch") == true else {
            throw DataServiceError.invalidURL
        }
        
        let path = url.pathComponents[1]
        
        guard let userData = try await fetchUser(username: path) else {
            throw DataServiceError.invalidURL
        }
        
//        let channelData = try await fetchChannel(login: path) else {
//            throw DataServiceError.invalidURL
//        }
        
        guard let channelData: GetTwitchChannelsResponse.Data = try await fetchChannels(ids: [userData.id]).data.first else {
            throw DataServiceError.invalidURL
        }
        
        let channel = TwitchChannel(userData: userData, channelData: channelData)
        updateChannelsCache(with: [channel])
    }
    
    private func fetchUser() async throws {
        var urlRequest = URLRequest(url: Constant.Twitch.oauthValidateURL)
        urlRequest.setValue("Bearer \(UserPreferences.shared.twitchAccessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserPreferences.shared.twitchClientID, forHTTPHeaderField: "Client-ID")

        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        let decoder = JSONDecoder()
        let user = try decoder.decode(TwitchUser.self, from: data)
        self.user = user
    }
    
    func refreshChannels() {
        
    }
    
    func addChannel(url: URL) {
    
    }
    
}


extension TwitchDataProvider {
    
    func fetchChannel(url: URL) async -> Channel? {
        guard url.host()?.contains("twitch") == true,
              let login = url.pathComponents.dropFirst().first else {
            print(DataServiceError.invalidURL)
            return nil
        }
        return try await fetchChannel(login: login)
    }
    
    private func updateChannelsCache(with channels: [TwitchChannel]) {
        channels.forEach { channel in
            if let index = cachedChannels.firstIndex(where: { $0.id == channel.id }) {
//                print(channel)
//                print(cachedChannels[index])
                cachedChannels[index] = channel
            } else {
                cachedChannels.append(channel)
            }
        }
        print(cachedChannels)
    }
    
    private func fetchUser(username: String) async throws -> GetTwitchUsersResponse.Data? {
        let decoder = JSONDecoder()
        let queryItem = URLQueryItem(name: "login", value: username)
        
        var urlComponents = URLComponents(url: Constant.Twitch.usersURL, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [queryItem]
        guard let requestURL = urlComponents?.url else {
            throw DataServiceError.invalidURL
        }
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.setValue("Bearer \(UserPreferences.shared.twitchAccessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserPreferences.shared.twitchClientID, forHTTPHeaderField: "Client-ID")
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        let success = try decoder.decode(GetTwitchUsersResponse.self, from: data)
        return success.data.first
    }
    
    private func fetchUsers(ids: [String]) async throws -> [GetTwitchUsersResponse.Data] {
        let chunkedIDs = ids.chunked(into: 100)
        
        let responses = try await withThrowingTaskGroup(of: GetTwitchUsersResponse.self) { group in
            var responses = [GetTwitchUsersResponse]()
            
            chunkedIDs.forEach { ids in
                group.addTask {
                    return try await self.fetchUsers(ids: ids)
                }
            }
            
            for try await response in group {
                responses.append(response)
            }
            
            let usersData = responses
                .map { response in
                    response.data
                }
                .flatMap { $0 }
            return usersData
        }
        return responses
    }
    
    private func fetchUsers(ids: [String]) async throws -> GetTwitchUsersResponse {
        guard ids.count <= 100 else {
            throw DataServiceError.invalidURL
        }
        
        let decoder = JSONDecoder()
        let queryItems = ids.map { URLQueryItem(name: "id", value: $0) }
        
        var urlComponents = URLComponents(url: Constant.Twitch.usersURL, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = queryItems
        guard let requestURL = urlComponents?.url else {
            throw DataServiceError.invalidURL
        }
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.setValue("Bearer \(UserPreferences.shared.twitchAccessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserPreferences.shared.twitchClientID, forHTTPHeaderField: "Client-ID")
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        let success = try decoder.decode(GetTwitchUsersResponse.self, from: data)
        return success
    }
    
//    private func fetchChannels(ids: [String]) async throws -> [TwitchChannel] {
//        let chunkedQueryItems = ids.map { URLQueryItem(name: "id", value: $0) }.chunked(into: 100)
//
//        let decoder = JSONDecoder()
//
//        let channels = try await withThrowingTaskGroup(of: [TwitchChannel].self) { group in
//            var channels = [TwitchChannel]()
//
//            chunkedQueryItems.forEach { queryItems in
//                group.addTask {
//                    var urlComponents = URLComponents(url: Constant.Twitch.usersURL, resolvingAgainstBaseURL: false)
//                    urlComponents?.queryItems = queryItems
//                    guard let requestURL = urlComponents?.url else {
//                        throw DataServiceError.invalidURL
//                    }
//                    var urlRequest = URLRequest(url: requestURL)
//                    urlRequest.setValue("Bearer \(UserPreferences.shared.twitchAccessToken)", forHTTPHeaderField: "Authorization")
//                    urlRequest.setValue(UserPreferences.shared.twitchClientID, forHTTPHeaderField: "Client-ID")
//
//                    let (data, _) = try await URLSession.shared.data(for: urlRequest)
//                    let success = try decoder.decode(GetTwitchUsersResponse.self, from: data)
////                    return success.data.map { TwitchChannel(responseItem: $0) }
//                }
//            }
//
//            for try await channel in group {
//                channels.append(contentsOf: channel)
//            }
//            return channels
//        }
//        return channels
////        let sortedChannels = channels.sorted { $0.name.lowercased() < $1.name.lowercased() }
//    }
    
    private func fetchChannels(ids: [String]) async throws -> GetTwitchChannelsResponse {
        guard ids.count <= 100 else {
            throw DataServiceError.invalidURL
        }
        
        let decoder = JSONDecoder()
        let queryItems = ids.map { URLQueryItem(name: "broadcaster_id", value: $0) }
        
        var urlComponents = URLComponents(url: Constant.Twitch.channelsURL, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = queryItems
        guard let requestURL = urlComponents?.url else {
            throw DataServiceError.invalidURL
        }
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.setValue("Bearer \(UserPreferences.shared.twitchAccessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserPreferences.shared.twitchClientID, forHTTPHeaderField: "Client-ID")
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        let success = try decoder.decode(GetTwitchChannelsResponse.self, from: data)
        return success
    }
    
    private func fetchChannels(ids: [String]) async throws -> [GetTwitchChannelsResponse.Data] {
        let chunkedIDs = ids.chunked(into: 100)
        
        let responses = try await withThrowingTaskGroup(of: GetTwitchChannelsResponse.self) { group in
            var responses = [GetTwitchChannelsResponse]()
            
            chunkedIDs.forEach { ids in
                group.addTask {
                    return try await self.fetchChannels(ids: ids)
                }
            }
            
            for try await response in group {
                responses.append(response)
            }
            
            let channelsData = responses
                .map { response in
                    response.data
                }
                .flatMap { $0 }
            return channelsData
        }
        return responses
    }
    
    func fetchChannel(login: String) async -> TwitchChannel? {
//        let chunkedQueryItems = ids.map { URLQueryItem(name: "login", value: $0) }.chunked(into: 100)
        
        let decoder = JSONDecoder()
        
        var urlComponents = URLComponents(url: Constant.Twitch.usersURL, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [URLQueryItem(name: "login", value: login)]
        guard let requestURL = urlComponents?.url else {
            return nil
        }
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.setValue("Bearer \(UserPreferences.shared.twitchAccessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserPreferences.shared.twitchClientID, forHTTPHeaderField: "Client-ID")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            let success = try decoder.decode(GetTwitchUsersResponse.self, from: data)
            let channels = success.data.map { TwitchChannel(responseItem: $0) }
            return channels.first
        } catch {
            return nil
        }
        
//        let sortedChannels = channels.sorted { $0.name.lowercased() < $1.name.lowercased() }
    }
    
    private func fetchStreams(ids: [String]) async throws -> [GetTwitchStreamsResponse.Data] {
        let chunkedIDs = ids.chunked(into: 100)
        
        let responses = try await withThrowingTaskGroup(of: GetTwitchStreamsResponse.self) { group in
            var responses = [GetTwitchStreamsResponse]()
            
            chunkedIDs.forEach { ids in
                group.addTask {
                    return try await self.fetchStreams(ids: ids)
                }
            }
            
            for try await response in group {
                responses.append(response)
            }
            
            let streamsData = responses
                .map { response in
                    response.data
                }
                .flatMap { $0 }
            return streamsData
        }
        return responses
    }
    
    private func fetchStreams(ids: [String]) async throws -> GetTwitchStreamsResponse {
        guard ids.count <= 100 else {
            throw DataServiceError.invalidURL
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let userIDQueryItems = ids.map { URLQueryItem(name: "user_id", value: $0) }
        let typeQueryItem = URLQueryItem(name: "type", value: "live")
        let queryItems = userIDQueryItems + [typeQueryItem]
        
        
        var urlComponents = URLComponents(url: Constant.Twitch.streamsURL, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = queryItems
        guard let requestURL = urlComponents?.url else {
            throw DataServiceError.invalidURL
        }
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.setValue("Bearer \(UserPreferences.shared.twitchAccessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserPreferences.shared.twitchClientID, forHTTPHeaderField: "Client-ID")
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        let success = try decoder.decode(GetTwitchStreamsResponse.self, from: data)
        return success
    }
    
    func fetchFollowedChannels(userID: String) async throws {
        let baseURLComponents = URLComponents(url: Constant.Twitch.allFollowedURL, resolvingAgainstBaseURL: false)
        let baseQueryItems = [URLQueryItem(name: "from_id", value: userID), URLQueryItem(name: "first", value: "100")]
        
        let decoder = JSONDecoder()
        
        var cursor: String?
        var channels = [TwitchChannel]()
        
        repeat {
            var urlComponents = baseURLComponents
            urlComponents?.queryItems = baseQueryItems + [URLQueryItem(name: "after", value: cursor)]
            
            guard let requestURL = urlComponents?.url else {
                throw DataServiceError.invalidURL
            }
            var urlRequest = URLRequest(url: requestURL)
            urlRequest.setValue("Bearer \(UserPreferences.shared.twitchAccessToken)", forHTTPHeaderField: "Authorization")
            urlRequest.setValue(UserPreferences.shared.twitchClientID, forHTTPHeaderField: "Client-ID")
            
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            let success = try decoder.decode(GetTwitchFollowsSuccess.self, from: data)
            channels.append(contentsOf: success.data.map { TwitchChannel(responseItem: $0) })
            cursor = success.pagination.cursor
        } while cursor != nil
        
        
        let sortedChannels = channels.sorted { $0.name.lowercased() < $1.name.lowercased() }
        
//        channelsSubject.send(sortedChannels)
    }
    
}
