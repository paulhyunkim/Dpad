//
//  UserPreferences.swift
//  Dpad
//
//  Created by Paul Kim on 10/15/22.
//

import SwiftUI

class UserPreferences: ObservableObject {
    
    static let shared = UserPreferences()
    
    @AppStorage(Constant.Storage.streamlinkPath) var streamlinkPath: String = "/opt/homebrew/bin/streamlink"
    @AppStorage(Constant.Storage.defaultQuality) var defaultQuality: StreamQuality = .best
    @AppStorage(Constant.Storage.twitchClientID) var twitchClientID: String = ""
    @AppStorage(Constant.Storage.twitchAccessToken) var twitchAccessToken: String = ""
    @AppStorage(Constant.Storage.youtubeAPIKey) var youtubeAPIKey: String = ""
    @AppStorage(Constant.Storage.favoriteChannels) var favoriteChannels: [FavoriteChannel] = []

    @AppStorage(Constant.Storage.channelListDisplayStyle) var channelListDisplayStyle: ChannelListDisplayStyle = .normal
    @AppStorage(Constant.Storage.enabledNotifications) var enabledNotifications: [NotificationsRule] = []
//    @AppStorage(Constant.Storage.playFavoritesOnLaunch) var playFavoritesOnLaunch: Bool
    @AppStorage(Constant.Storage.channels) var channels: [CacheChannel] = []
        
}
