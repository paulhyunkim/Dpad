//
//  Stream.swift
//  Dpad
//
//  Created by Paul Kim on 10/12/22.
//

import Foundation

protocol Stream {

    var url: URL? { get }
    var channel: Channel { get }
    var viewerCount: Int { get }
    var startTime: Date? { get }
    var title: String? { get }
    var gameName: String? { get }
    func streamlinkQualityArg(_ quality: StreamQuality) -> String
    var chatURL: URL? { get }
    
}

extension Stream {
    var displayName: String {
        return ""
//        return "\(channel.title): \(viewerCount)"
    }
    
//    var id: String { channel.id }
}

struct TwitchStream: Stream {
//    static func == (lhs: TwitchStream, rhs: TwitchStream) -> Bool {
//        lhs.url == rhs.url
//    }
//
    
    var userName: String
    var userID: String
    var userLogin: String
    var viewerCount: Int
    var gameName: String?
    var title: String?
    var startTime: Date?
    var url: URL? {
        return URL(string: "https://www.twitch.tv/\(userLogin)")
    }
    var chatURL: URL? {
        return URL(string: "https://www.twitch.tv/popout/\(userLogin)/chat")
    }
    
    var channel: Channel
    
    init(item: TwitchStreamItem, channel: Channel) {
        self.userName = item.user_name
        self.userID = item.user_id
        self.viewerCount = item.viewer_count
        self.gameName = item.game_name
        self.title = item.title
        self.startTime = item.started_at
        self.userLogin = item.user_login
        self.channel = channel
    }
    
    init(streamData: GetTwitchStreamsResponse.Data, channel: Channel) {
        self.userName = streamData.user_name
        self.userID = streamData.user_id
        self.viewerCount = streamData.viewer_count
        self.gameName = streamData.game_name
        self.title = streamData.title
        self.startTime = streamData.started_at
        self.channel = channel
        self.userLogin = channel.userLogin
    }
    
    func streamlinkQualityArg(_ quality: StreamQuality) -> String {
        switch quality {
        case .worst: return "worst"
        case .p360:  return "360p"
        case .p480:  return "480p"
        case .p720:  return "720p60"
        case .p1080: return "1080p60"
        case .best:  return "best"
        }
    }
}

struct YouTubeStream: Stream {

//    static func == (lhs: YouTubeStream, rhs: YouTubeStream) -> Bool {
//        lhs.url == rhs.url
//    }
    
    var url: URL? {
        return URL(string: "https://www.youtube.com/watch?v=\(id)")
    }
    
    var viewerCount: Int
    var id: String
    var startTime: Date?
    var title: String?
    var gameName: String?
    
    var channel: Channel
    var chatURL: URL? {
        return URL(string: "https://www.youtube.com/live_chat?v=\(id)")
    }
    
//    init(videoDetails: YouTubeScrapedVideoDetail, channel: YouTubeChannel) {
//        self.id = videoDetails.videoId
//        self.viewerCount = Int(videoDetails.viewCount) ?? 0
//        self.channel = channel
//    }
    
    init(responseItem: GetYouTubeVideoSuccess.Item, channel: YouTubeChannel, gameName: String?) {
        self.id = responseItem.id
        self.title = responseItem.snippet.title
        self.startTime = responseItem.liveStreamingDetails?.actualStartTime
        self.viewerCount = Int(responseItem.liveStreamingDetails?.concurrentViewers ?? "0") ?? 0
        self.channel = channel
        self.gameName = gameName
    }
    
//    init(id: String, viewerCount: Int) {
//        self.id = id
//        self.viewerCount = viewerCount
//    }
    
    func streamlinkQualityArg(_ quality: StreamQuality) -> String {
        switch quality {
        case .worst: return "worst"
        case .p360:  return "360p"
        case .p480:  return "480p"
        case .p720:  return "720p"
        case .p1080: return "1080p"
        case .best:  return "best"
        }
    }
    
}

extension TwitchStream {
    func getChatURL() -> URL? {
        return URL(string: "https://www.twitch.tv/popout/\(userName)/chat")
    }

//    static func == (lhs: TwitchStream, rhs: TwitchStream) -> Bool {
//        return lhs.url == rhs.url
//    }
}

