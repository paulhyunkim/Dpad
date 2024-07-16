//
//  StreamsView.swift
//  Dpad
//
//  Created by Paul Kim on 10/15/22.
//

import SwiftUI

struct StreamsView: View {

    @EnvironmentObject var appState: AppState
    @StateObject var clock: Clock = Clock()
    
    var body: some View {
        Group {
            switch appState.streamsLayout {
            case .focusedGrid:
                NormalStreamsView()
            case .symmetricGrid:
                GridStreamsView()
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Slider(value: $appState.masterVolume, in: 0.0001...1, label: {
                    Text(volumeText)
                }, minimumValueLabel: {
                    Image(systemName: "speaker.fill")
                }, maximumValueLabel: {
                    Image(systemName: "speaker.wave.3.fill")
                }, onEditingChanged: { didChange in
                    
                })
                .frame(width: 120)
                .padding(.trailing, 10)
            }
        }
        .environmentObject(clock)
    }

    var volumeText: String {
        let volumeInt = Int(appState.masterVolume * 100)
        return "Volume: \(volumeInt)"
    }
    
}

struct StreamPlayersLayout {
    var primaryPlayer: StreamPlayer?
    var secondaryPlayers: [StreamPlayer]
}

struct GridLayout {
    // 2 dimensional matrix
    // build this matrix from streamplayers in the app state that pre-positions the players in the right layout
    var players: [[StreamPlayer]]
    
}


fileprivate struct NormalStreamsView: View {
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                VStack(spacing: 0) {
//                    if let stream = appState.streamsPlaying.first {
//                        StreamView(stream: stream, style: .primary)
//                            .frame(maxWidth: .infinity)
//                    }
//
//                    if !secondaryStreams.isEmpty {
//                        HStack(alignment: .top, spacing: 0) {
//                            ForEach(secondaryStreams, id: \.channel.id) { stream in
//                                StreamView(stream: stream, style: .primary)
//                            }
//                        }
//                        .frame(maxHeight: geometry.size.height * 0.25)
//                    }
                    
                     
                    //                Spacer()
                    if let streamPlayer = appState.streamPlayers.first {
                         StreamPlayerView(streamPlayer: streamPlayer, style: .primary)
                             .frame(maxWidth: .infinity)
                                             
//                        StreamView(stream: streamPlayer.stream, style: .primary)
//                            .frame(maxWidth: .infinity)
                    }
                    //
                    if !secondaryPlayers.isEmpty {
                        HStack(alignment: .top, spacing: 0) {
                            ForEach(secondaryPlayers, id: \.stream.channel.id) { player in
                                StreamPlayerView(streamPlayer: player, style: .secondary)
                                    
                            }
                        }
                        .frame(maxHeight: geometry.size.height * 0.25)
//                        .background(.blue)
                            
                        //                    Spacer()
                    }
                }
            }
            .animation(.interactiveSpring(), value: appState.streamPlayers.map { $0.stream.url })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        
    }

    var secondaryPlayers: [StreamPlayer] {
        return Array(appState.streamPlayers.dropFirst())
    }
    
    var secondaryStreams: [Stream] {
        return Array(appState.streamsPlaying.dropFirst())
    }
    
//    struct SecondaryPlayersView: View {
//        
//        var players: [StreamPlayer]
//        
//        var body: some View {
//            HStack(spacing: 0) {
//                ForEach(players, id: \.stream.channel.id) { player in
//                    StreamPlayerView(streamPlayer: player)
//                }
//            }
//        }
//        
//    }
}

fileprivate struct GridStreamsView: View {
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(appState.streamPlayers.reversed(), id: \.stream.channel.id) { player in
                StreamPlayerView(streamPlayer: player, style: .primary)
            }
        }
//        .frame(maxHeight: .infinity)
        
        
//        Grid(alignment: .center, horizontalSpacing: 0, verticalSpacing: 0) {
//            ForEach(1...gridDimension.rows, id: \.self) { row in
//                GridRow(alignment: .center) {
//                    HStack {
//                        ForEach(1...gridDimension.columns, id: \.self) { column in
//                            if let player = streamPlayer(row: row, column: column) {
//                                StreamPlayerView(streamPlayer: player)
//                            }
//
//                        }
//                    }
//                }
//            }
//        }

    }
    
    var columns: [GridItem] {
        switch appState.streamPlayers.count {
        case 1...2:
            return [GridItem(.flexible())]
        case 3...6:
            return Array(repeating: GridItem(.flexible()), count: 2)
        case 7...12:
            return Array(repeating: GridItem(.flexible()), count: 3)
        default:
            return Array(repeating: GridItem(.flexible()), count: 4)
        }
    }
    
    var gridDimension: StreamPlayersGrid {
        switch appState.streamPlayers.count {
        case 1: return StreamPlayersGrid(rows: 1, columns: 1)
        case 2: return StreamPlayersGrid(rows: 2, columns: 1) // <- this is the only exception. the player goes below. everything else increments linearly
        case 3: return StreamPlayersGrid(rows: 2, columns: 2)
        case 4: return StreamPlayersGrid(rows: 2, columns: 2)
        case 5: return StreamPlayersGrid(rows: 2, columns: 3)
        case 6: return StreamPlayersGrid(rows: 2, columns: 3)
        case 7: return StreamPlayersGrid(rows: 3, columns: 3)
        case 8: return StreamPlayersGrid(rows: 3, columns: 3)
        case 9: return StreamPlayersGrid(rows: 3, columns: 3)
        default: return StreamPlayersGrid(rows: 100, columns: 100)
        }
    }
    
    func streamPlayer(row: Int, column: Int) -> StreamPlayer? {
        let playerIndex = gridDimension.playerIndexForCoordinate(row: row, column: column)
        if (playerIndex + 1) >= appState.streamPlayers.count {
            return nil
        } else {
            return appState.streamPlayers[playerIndex]
        }
    }
    
}

struct StreamPlayersGrid {
    var rows: Int
    var columns: Int
    
    func playerIndexForCoordinate(row: Int, column: Int) -> Int {
        switch (row, column) {
        case (1, 1):
            return 0
        case (2, 1):
            if columns == 1 {
                return 1
            } else {
                return ((row - 1) * columns + column - 1)
            }
        default:
            return ((row - 1) * columns + column - 1)
        }
    }
}

struct StreamsView_Previews: PreviewProvider {
    static var previews: some View {
        StreamsView()
    }
}
