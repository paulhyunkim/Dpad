//
//  StreamDataServices.swift
//  Dpad
//
//  Created by Paul Kim on 12/3/22.
//

import Foundation
import Combine

protocol DataProvider {
    
//    var userPublisher: AnyPublisher<TwitchUser?, Never> { get }
//    var streamsPublisher: AnyPublisher<[Stream], Never> { get }
//    var channelsPublisher: AnyPublisher<[Channel], Never> { get }
    
    func fetchChannels() async throws -> [Channel]
    func fetchStreams() async throws -> [Stream]
    func addChannel(from url: URL) async throws

}

