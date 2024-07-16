//
//  MenuBarContentView.swift
//  Dpad
//
//  Created by Paul Kim on 10/11/22.
//

import SwiftUI

struct MenuBarContentView: View {
    
    @EnvironmentObject var appState: AppState
    
    

    var body: some View {
        MenuStreamListSection(title: "Favorites", streams: appState.streams.favorites)
        MenuStreamListSection(title: "Live", streams: appState.streams.notFavorites)

//        Section("Other") {
//            Toggle("Toggle", isOn: .constant(true))
//            Stepper("Stepper", onIncrement: nil, onDecrement: nil)
//            Slider(value: .constant(0.5))
//            Link("Link", destination: URL(string: "www.google.com")!)
//            Button("Button") { }
//            Label("Label", image: "chevron.up")
//            List {
//                Text("Button")
//                Text("Button")
//            }
//        }
//        ScrollView {
//            StreamList()
//            Divider()
//            Text("Following")
//                .contextMenu {
//
//                }
//            ChannelList()
//            Divider()
//            Button("Refresh") {
//                appState.execute(.fetchStreams)
//            }
//            .frame(alignment: .leading)
//        }
//        .frame(alignment: .leading)
//        .buttonStyle(.borderless)
//        .frame(height: 800)
//        .padding(10)
    }
}

struct MenuStreamListSection: View {
    
    @EnvironmentObject var appState: AppState
    var title: String
    var streams: [Stream]
    
    var body: some View {
        Section(title) {
            ForEach(streams, id: \.channel.id) { stream in
                Button {
                    appState.execute(.playStream(stream))
                } label: {
                    Text("\(stream.channel.name) (\(stream.viewerCount ?? 0))")
                        .foregroundColor(appState.isPlaying(channel: stream.channel) ? .red : .primary)
//                    if appState.isFavorited(channel: stream.channel) {
//                        Image(systemName: "star.fill")
//                    }
                }
            }
        }
    }
}


//struct StreamList: View {
//    
//    @EnvironmentObject var appState: AppState
//    
//    var body: some View {
//        ForEach(appState.streams, id: \.url) { stream in
//            HStack {
//                Button {
//                    appState.execute(.playStream(stream))
//                } label: {
//                    HStack {
//                        Text(stream.displayName)
//                            .foregroundColor(appState.isPlaying(channel: stream.channel) ? .red : .white)
//                        if appState.isFavorited(channel: stream.channel) {
//                            Image(systemName: "star.fill")
//                                .foregroundColor(.yellow)
//                        }
//                        Spacer()
//                    }
//                }
////                .buttonStyle(.borderless)
//                .contextMenu {
//                    Button {
//                        if appState.isFavorited(channel: stream.channel) {
//                            appState.execute(.unfavoriteChannel(stream.channel))
//                        } else {
//                            appState.execute(.favoriteChannel(stream.channel))
//                        }
//                    } label: {
//                        if appState.isFavorited(channel: stream.channel) {
//                            Text("Unfavorite")
//                        } else {
//                            Text("Favorite")
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//}
//
//struct ChannelList: View {
//    
//    @EnvironmentObject var appState: AppState
//    
//    var body: some View {
//        ForEach(appState.offlineChannels, id: \.id) { channel in
//            HStack {
//                Button {
//
//                } label: {
//                    HStack {
//                        Text(channel.name)
//                        if appState.isFavorited(channel: channel) {
//                            Image(systemName: "star.fill")
//                                .foregroundColor(.yellow)
//                        }
//                        
//                        Spacer()
//                    }
//                }
//                .buttonStyle(.borderless)
//                .contextMenu {
//                    Button {
//                        if appState.isFavorited(channel: channel) {
//                            appState.execute(.unfavoriteChannel(channel))
//                        } else {
//                            appState.execute(.favoriteChannel(channel))
//                        }
//                    } label: {
//                        if appState.isFavorited(channel: channel) {
//                            Text("Unfavorite")
//                        } else {
//                            Text("Favorite")
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//}
//
