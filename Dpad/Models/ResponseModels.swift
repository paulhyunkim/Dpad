//
//  ResponseModels.swift
//  Dpad
//
//  Created by Paul Kim on 10/12/22.
//

import Foundation

struct GetTwitchStreamsSuccess: Codable {
    
    var data: [TwitchStreamItem]
    
}

struct GetTwitchStreamsResponse: Codable {
    
    var data: [Data]
    
    struct Data: Codable {
        var id: String
        var user_id: String
        var user_login: String
        var user_name: String
        var game_id: String
        var game_name: String
        var type: String
        var title: String
        var viewer_count: Int
        var started_at: Date
        var language: String
        var thumbnail_url: String
        var tag_ids: [String]
        var is_mature: Bool
    }
    
//    {
//      "data": [
//        {
//          "id": "41375541868",
//          "user_id": "459331509",
//          "user_login": "auronplay",
//          "user_name": "auronplay",
//          "game_id": "494131",
//          "game_name": "Little Nightmares",
//          "type": "live",
//          "title": "hablamos y le damos a Little Nightmares 1",
//          "viewer_count": 78365,
//          "started_at": "2021-03-10T15:04:21Z",
//          "language": "es",
//          "thumbnail_url": "https://static-cdn.jtvnw.net/previews-ttv/live_user_auronplay-{width}x{height}.jpg",
//          "tag_ids": [
//            "d4bb9c58-2141-4881-bcdc-3fe0505457d1"
//          ],
//          "is_mature": false
//        },
//        ...
//      ],
//      "pagination": {
//        "cursor": "eyJiIjp7IkN1cnNvciI6ImV5SnpJam8zT0RNMk5TNDBORFF4TlRjMU1UY3hOU3dpWkNJNlptRnNjMlVzSW5RaU9uUnlkV1Y5In0sImEiOnsiQ3Vyc29yIjoiZXlKeklqb3hOVGs0TkM0MU56RXhNekExTVRZNU1ESXNJbVFpT21aaGJITmxMQ0owSWpwMGNuVmxmUT09In19"
//      }
//    }
}

struct TwitchStreamItem: Codable {
    var user_name: String
    var user_id: String
    var viewer_count: Int
    var game_name: String?
    var title: String?
    var user_login: String
    var started_at: Date?
}

struct GetTwitchChannel: Codable {
    
    var to_id: String // id
    var to_name: String // title
    var to_login: String // username
    
}

struct GetTwitchChannelsResponse: Codable {
    
    var data: [Data]
    
    struct Data: Codable {
        var broadcaster_id: String
        var broadcaster_login: String
        var broadcaster_name: String
        var broadcaster_language: String
        var game_id: String
        var game_name: String
        var title: String
        var delay: Int
    }
    
//    {
//      "data": [
//        {
//          "broadcaster_id": "141981764",
//          "broadcaster_login": "twitchdev",
//          "broadcaster_name": "TwitchDev",
//          "broadcaster_language": "en",
//          "game_id": "509670",
//          "game_name": "Science & Technology",
//          "title": "TwitchDev Monthly Update // May 6, 2021",
//          "delay": 0
//        }
//      ]
//    }
}

struct GetTwitchFollowsSuccess: Codable {
    
    var total: Int
    var data: [GetTwitchChannel]
    var pagination: Pagination
    
    struct Pagination: Codable {
        var cursor: String?
    }
                        
}

struct GetTwitchUsersResponse: Codable {
    
    var data: [Data]
    
    struct Data: Codable {
        var id: String
        var login: String
        var display_name: String
        var profile_image_url: URL?
    }
    
//    {
//          "id": "160504245",
//          "login": "39daph",
//          "display_name": "39daph",
//          "type": "",
//          "broadcaster_type": "partner",
//          "description": "streams every dayish at 11pm pst ish",
//          "profile_image_url": "https://static-cdn.jtvnw.net/jtv_user_pictures/3a4c876e-1c4b-46ba-bf77-91e282202879-profile_image-300x300.jpeg",
//          "offline_image_url": "https://static-cdn.jtvnw.net/jtv_user_pictures/3e11bfe3-2a8c-47a0-bb41-843548ab22f6-channel_offline_image-1920x1080.jpeg",
//          "view_count": 32543232,
//          "created_at": "2017-06-17T12:43:43Z"
//        },
}

struct GetYouTubeVideoSuccess: Codable {

    var items: [Item]
    
    struct Item: Codable {
        
        var id: String
        var snippet: Snippet
        var liveStreamingDetails: LiveStreamingDetails?
        
        struct Snippet: Codable {
            var title: String
            var publishedAt: Date
            var channelId: String
            var description: String
            var channelTitle: String
            var liveBroadcastContent: String
        }
        
        struct LiveStreamingDetails: Codable {
            var actualStartTime: Date?
            var scheduledStartTime: Date?
            var concurrentViewers: String?
            var activeLiveChatId: String?
        }

    }

}

struct GetYouTubeChannelSuccess: Codable {

    var items: [Item]
    
    struct Item: Codable {
        
        var id: String
        var snippet: Snippet
        
        struct Snippet: Codable {
            var title: String
            var description: String
            var customUrl: String
            var thumbnails: Thumbnails
            
            struct Thumbnails: Codable {
                var `default`: DefaultThumbnail
                
                struct DefaultThumbnail: Codable {
                    var url: URL?
                }
            }
        }

    }

}

struct YouTubeScrapedVideoDetail: Codable {
    
    var isLive: Bool
    var author: String
    var channelId: String
    var title: String
    var videoId: String
    var viewCount: String
    
}

