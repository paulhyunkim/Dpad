//
//  Channel.swift
//  Dpad
//
//  Created by Paul Kim on 10/10/22.
//

import Foundation

protocol Channel {
    var id: String { get }
    var name: String { get }
    var userLogin: String { get }
    var imageURL: URL? { get }
    
    func toCacheType() -> CacheChannel
}

struct CacheChannel: Channel, Codable {
    
    var id: String
    var name: String
    // TODO: - do we need this? can we just construct a channel URL from id/login?
    var userLogin: String
    var imageURL: URL?
    var platform: Platform
    
    enum Platform: Codable {
        case twitch
        case youTube
    }
    
    func toCacheType() -> CacheChannel {
        return self
    }
    
}

struct TwitchChannel: Channel, Codable, Hashable {
    
    var id: String
    var name: String
    var userLogin: String
    var imageURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case id = "to_id"
        case name = "to_name"
        case userLogin = "to_login"
    }
    
    init(userData: GetTwitchUsersResponse.Data, channelData: GetTwitchChannelsResponse.Data) {
        self.id = channelData.broadcaster_id
        self.name = channelData.broadcaster_name
        self.userLogin = channelData.broadcaster_login
        self.imageURL = userData.profile_image_url
    }
    
    init(responseItem: GetTwitchUsersResponse.Data) {
        self.id = responseItem.id
        self.name = responseItem.display_name
        self.userLogin = responseItem.login
        self.imageURL = responseItem.profile_image_url
    }
    
    init(responseItem: GetTwitchChannel) {
        self.id = responseItem.to_id
        self.name = responseItem.to_name
        self.userLogin = responseItem.to_login
        // TODO: - from GET USERS
//        self.imageURL = responseItem.
    }
    
    init(cachedChannel: Channel) {
        self.id = cachedChannel.id
        self.name = cachedChannel.name
        self.userLogin = cachedChannel.userLogin
        self.imageURL = cachedChannel.imageURL
    }
    
    func toCacheType() -> CacheChannel {
        CacheChannel(id: id, name: name, userLogin: userLogin, imageURL: imageURL, platform: .twitch)
    }
    
}

struct YouTubeChannel: Channel, Codable {
    var id: String
    var name: String
    var userLogin: String
    var imageURL: URL?
    
    init(id: String, name: String, userLogin: String) {
        self.id = id
        self.name = name
        self.userLogin = userLogin
    }
    
    init(cachedChannel: Channel) {
        self.id = cachedChannel.id
        self.name = cachedChannel.name
        self.userLogin = cachedChannel.userLogin
        self.imageURL = cachedChannel.imageURL
    }
    
    init(responseItem: GetYouTubeChannelSuccess.Item) {
        self.id = responseItem.id
        self.name = responseItem.snippet.title
        self.userLogin = responseItem.snippet.customUrl
        self.imageURL = responseItem.snippet.thumbnails.default.url
    }

    func toCacheType() -> CacheChannel {
        CacheChannel(id: id, name: name, userLogin: userLogin, imageURL: imageURL, platform: .youTube)
    }

}

//extension Array where Element: Channel {
//    func removing(streams: [Stream]) -> Self {
//        let streamChannels = streams.map { $0.channel }
//        return filter { channel in
//            !streamChannels.contains { streamChannel in
//                streamChannel.id == channel.id
//            }
//        }
//    }
//}
