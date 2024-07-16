//
//  ChannelList.swift
//  Dpad
//
//  Created by Paul Kim on 10/15/22.
//

import SwiftUI
//import YoutubeKit

struct ChannelList: View {
    
    @EnvironmentObject var appState: AppState
    @State var searchTerm: String = ""
    
    var body: some View {
        List {
            if !appState.streamsPlaying.isEmpty {
                LiveChannelListSection(streams: appState.streamsPlaying) {
                    HStack {
                        Image(systemName: "play.fill")
                            .foregroundColor(.accentColor)
                            .frame(width: 20)
                        Text("Playing")
                    }
                }
            }

            if !appState.notPlayingStreams.isEmpty {
                LiveChannelListSection(streams: appState.notPlayingStreams) {
                    HStack {
                        Image(systemName: "person.wave.2.fill")
                            .foregroundColor(.red)
                            .frame(width: 20)
                        Text("Live")
                            .foregroundColor(.secondary)
                    }
                }
//                .background(.red)
            }

            if !appState.offlineChannels.isEmpty {
                OfflineChannelListSection(channels: appState.offlineChannels) {
                    HStack {
                        Image(systemName: "antenna.radiowaves.left.and.right.slash")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        Text("Offline")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
//        .listSectionSeparator(.visible)
//        .listSectionSeparatorTint(.green)
        .listStyle(.sidebar)
        .scrollIndicators(.hidden)
        .searchable(text: $searchTerm, placement: .sidebar, prompt: "Search")
//        .refreshable {
//            appState.execute(.fetchStreams)
//        }
        .animation(.default, value: appState.streamsPlaying.map { $0.url })
    }
}



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

//struct ChannelsList_Previews: PreviewProvider {
//    static var previews: some View {
//        ChannelList()
//            .environmentObject(AppState.mockState())
//    }
//}
