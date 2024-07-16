//
//  MockDataProvider.swift
//  Dpad
//
//  Created by Paul Kim on 10/14/22.
//

import SwiftUI
import Combine

//class MockTwitchDataProvider: DataProvider, ObservableObject {
//    
//    func fetchChannel(url: URL) async -> Channel? {
//        return nil
//    }
//    
//    var userPublisher: AnyPublisher<TwitchUser?, Never> {
//        userSubject.eraseToAnyPublisher()
//    }
//    
//    var streamsPublisher: AnyPublisher<[Stream], Never> {
//        streamsSubject.eraseToAnyPublisher()
//    }
//    
//    var channelsPublisher: AnyPublisher<[Channel], Never> {
//        channelsSubject.eraseToAnyPublisher()
//    }
//
//    private var userSubject = CurrentValueSubject<TwitchUser?, Never>(nil)
//    private var streamsSubject = CurrentValueSubject<[Stream], Never>([])
//    private var channelsSubject = CurrentValueSubject<[Channel], Never>([])
//    
//    func fetchUser() async throws {
//        let url = Bundle.main.url(forResource: "user", withExtension: "json")!
//        let data = try Data(contentsOf: url)
//        let decoder = JSONDecoder()
//        let user = try decoder.decode(TwitchUser.self, from: data)
//        userSubject.send(user)
//    }
//    
//    func fetchStreams(userID: String) async throws {
//        let url = Bundle.main.url(forResource: "streams", withExtension: "json")!
//        let data = try! Data(contentsOf: url)
//        let decoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .iso8601
//        let streams = try! decoder.decode(GetTwitchStreamsSuccess.self, from: data).data
//        streamsSubject.send([])
//    }
//    
//    func fetchChannels(userID: String) async throws {
//        let url = Bundle.main.url(forResource: "channels", withExtension: "json")!
//        let data = try! Data(contentsOf: url)
//        let decoder = JSONDecoder()
//        let channels = try! decoder.decode(GetTwitchFollowsSuccess.self, from: data).data
//        channelsSubject.send([])
//    }
//    
//}
