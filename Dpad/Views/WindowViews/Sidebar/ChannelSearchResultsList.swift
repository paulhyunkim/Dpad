//
//  ChannelSearchResultsList.swift
//  Dpad
//
//  Created by Paul Kim on 10/15/22.
//

import SwiftUI

struct ChannelSearchResultsList: View {
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ChannelSearchResultsList_Previews: PreviewProvider {
    static var previews: some View {
        ChannelSearchResultsList()
    }
}


//struct ChannelList: View {
//    
//    
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            if !appState.playingStreams.isEmpty {
//                    LiveChannelsSection(title: "Playing", streams: appState.playingStreams)
//                    Divider()
//                .padding(.bottom, 16)
//            }
//
//            HStack {
//                Text("Live")
//                Circle()
//                    .frame(width: 5, height: 5)
//                    .foregroundColor(.red)
//            }
//            ForEach(appState.notPlayingStreams, id: \.url) { stream in
//                Button {
//                    appState.execute(.playStream(stream))
//                } label: {
//                    LiveChannelListItem(stream: stream)
//                        .padding(.horizontal, 10)
//                        .padding(.vertical, 5)
//                }
////                        .help(stream.title ?? "")
//                .buttonStyle(.borderless)
//            }
//            
//            OfflineChannelsSection(title: "Offline", channels: appState.offlineChannels)
//        }
//    }
//}
//
//struct LiveChannelsSection/*<Title: View>*/: View {
//    
//    @EnvironmentObject var appState: AppState
////    @ViewBuilder var title: Title
//    var title: String
//    var streams: [Stream]
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
////            HStack {
//                Text(title)
////                Image(systemName: "play.fill")
////            }
//            ForEach(streams, id: \.url) { stream in
//                Button {
//                    if appState.isPlaying(stream: stream) {
//                        appState.execute(.focusStream(stream))
//                    } else {
//                        appState.execute(.playStream(stream))
//                    }
//                } label: {
//                    LiveChannelItem(stream: stream)
//                        .padding(.horizontal, 10)
//                        .padding(.vertical, 5)
//                }
//                //                        .help(stream.title ?? "")
//                .buttonStyle(.borderless)
//            }
//        }
//    }
//    
//}
//
//struct OfflineChannelsSection: View {
//    
//    @EnvironmentObject var appState: AppState
//    var title: String
//    var channels: [Channel]
//    
//    var body: some View {
//        
//        VStack(alignment: .leading, spacing: 0) {
//            Text(title)
//            ForEach(channels, id: \.id) { channel in
//                OfflineChannelListItem(channel: channel)
//                    .padding(.horizontal, 10)
//                    .padding(.vertical, 5)
//            }
//        }
//    }
//    
//}
//
//struct LiveChannelItem: View {
//    
//    @EnvironmentObject var appState: AppState
//    var stream: Stream
//    @State var onHover: Bool = false
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            HStack(spacing: 4) {
//                if appState.isPlaying(stream: stream) {
//                    Circle()
//                        .frame(width: 5, height: 5)
//                        .foregroundColor(.red)
//                }
//                if stream.channel.isFavorited {
//                    Image(systemName: "star.fill")
//                        .foregroundColor(.yellow)
//                }
//                Text(stream.channel.name)
//                    .font(.headline)
//                Spacer()
//                Text(stream.viewerCount.abbreviated)
//                    .font(.subheadline)
//            }
//            .foregroundColor(.primary)
//            .padding(.bottom, 2)
//            
//            Group {
//                if let gameName = stream.gameName {
//                    Text(gameName)
//                        .font(.callout)
//                        .bold()
//                        .lineLimit(1)
//                        .truncationMode(.tail)
//                        .padding(.bottom, 2)
//                }
//                
//                if let title = stream.title {
//                    Text(title)
//                        .font(.caption)
//                        .italic()
//                        .lineLimit(1)
//                        .truncationMode(.tail)
//                }
//            }
//            .padding(.trailing, 5)
//            .foregroundColor(.secondary)
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
////        .onTapGesture {
////            appState.execute(.playStream(stream))
////        }
////        .opacity(onHover ? 1 : 0.5)
//        .contextMenu {
//            Button {
//                if stream.channel.isFavorited {
//                    appState.execute(.unfavoriteChannel(stream.channel))
//                } else {
//                    appState.execute(.favoriteChannel(stream.channel))
//                }
//            } label: {
//                if stream.channel.isFavorited {
//                    Text("Unfavorite")
//                } else {
//                    Text("Favorite")
//                }
//            }
//        }
//        .animation(.interactiveSpring(), value: onHover)
//        .onHover { onHover in
//            self.onHover = onHover
//        }
//    }
//    
//}
//
//struct ChannelListItem: View {
//    
//    @EnvironmentObject var appState: AppState
//    var channel: Channel
//    @State var onHover: Bool = false
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            HStack(spacing: 4) {
//                if channel.isFavorited {
//                    Image(systemName: "star.fill")
//                        .foregroundColor(.yellow)
//                }
//                Text(channel.name)
//                    .font(.body)
//            }
//            .foregroundColor(.secondary)
//            .padding(.bottom, 2)
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
////        .onTapGesture {
////            appState.execute(.playStream(stream))
////        }
////        .opacity(onHover ? 1 : 0.5)
//        .contextMenu {
//            Button {
//                if channel.isFavorited {
//                    appState.execute(.unfavoriteChannel(channel))
//                } else {
//                    appState.execute(.favoriteChannel(channel))
//                }
//            } label: {
//                if channel.isFavorited {
//                    Text("Unfavorite")
//                } else {
//                    Text("Favorite")
//                }
//            }
//        }
//        .animation(.interactiveSpring(), value: onHover)
//        .onHover { onHover in
//            self.onHover = onHover
//        }
//    }
//}
//
//struct ChannelsList_Previews: PreviewProvider {
//    static var previews: some View {
//        ChannelsList()
//    }
//}
