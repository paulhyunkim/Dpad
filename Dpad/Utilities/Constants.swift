//
//  Constants.swift
//  Dpad
//
//  Created by Paul Kim on 10/10/22.
//

import Foundation

struct Constant {

    struct Twitch {
        static let oauthValidateURL = URL(string: "https://id.twitch.tv/oauth2/validate")!
        static let followedApiURL = URL(string: "https://api.twitch.tv/helix/streams/followed")!
        static let streamerDataURL = URL(string: "https://api.twitch.tv/helix/users")!
        static let allFollowedURL = URL(string: "https://api.twitch.tv/helix/users/follows")!
        static let usersURL = URL(string: "https://api.twitch.tv/helix/users")!
        static let channelsURL = URL(string: "https://api.twitch.tv/helix/channels")!
        static let streamsURL = URL(string: "https://api.twitch.tv/helix/streams")!
        static let channels = "\(bundleID).twitchChannels"
        static let user = "\(bundleID).twitchUser"
    }
    
    struct YouTube {
        static let getChannelsURL = URL(string: "https://youtube.googleapis.com/youtube/v3/channels")!
        static let getVideosURL = URL(string: "https://youtube.googleapis.com/youtube/v3/videos")!
        static let channels = "\(bundleID).youTubeChannels"
    }
    
    struct Storage {
        static let twitchClientID = "\(bundleID).twitchClientID"
        static let twitchAccessToken = "\(bundleID).twitchAccessToken"
        static let streamlinkPath = "\(bundleID).streamlinkPath"
        static let defaultQuality = "\(bundleID).defaultQuality"
        static let favoriteChannels = "\(bundleID).favoriteChannels"
        static let channelListDisplayStyle = "\(bundleID).channelListDisplayStyle"
        static let enabledNotifications = "\(bundleID).enabledNotifications"
        static let channels = "\(bundleID).channels"
        static let youtubeAPIKey = "\(bundleID).youtubeAPIKey"
    }
    
    static let bundleID = "com.paulkim.Dpad"
}

enum NotificationsRule: Int, Codable {
    case favoritesWentLive
    case favoritesWentOffline
}

//typealias EnabledNotifications = [NotificationsRule]

//extension EnabledNotifications: RawRepresentable {
    
//    init?(rawValue: String) {
//        self.
//    }
//
//
//    var rawValue: Self.RawValue { get }
    
//    public init?(rawValue: String) {
//        guard let data = rawValue.data(using: .utf8),
//            let result = try? JSONDecoder().decode(EnabledNotifications.self, from: data)
//        else {
//            return nil
//        }
//        self = result
//    }
//
//    public var rawValue: String {
//        guard let data = try? JSONEncoder().encode(self),
//            let result = String(data: data, encoding: .utf8)
//        else {
//            return "[]"
//        }
//        return result
//    }
//}

enum StreamQuality: String, CaseIterable {
    case worst
    case p360
    case p480
    case p720
    case p1080
    case best

    var text: String {
        switch self {
        case .worst:
            return "Worst"
        case .p360:
            return "360p"
        case .p480:
            return "480p"
        case .p720:
            return "720p"
        case .p1080:
            return "1080p"
        case .best:
            return "Best"
        }
    }
}

enum ChannelListDisplayStyle: String, CaseIterable {
    case compact
    case normal
}

//extension StreamQuality: RawRepresentable {
//    public init?(rawValue: String) {
//        guard let data = rawValue.data(using: .utf8),
//              let result = try? JSONDecoder().rawValue.decode(StreamQuality.self, from: data)
//        else {
//            return nil
//        }
//        self = result
//    }
//
//    public var rawValue: String {
//        guard let data = try? JSONEncoder().encode(self),
//            let result = String(data: data, encoding: .utf8)
//        else {
//            return "[]"
//        }
//        return result
//    }
//}
