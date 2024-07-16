//
//  WindowGroupContentView.swift
//  Dpad
//
//  Created by Paul Kim on 10/19/22.
//

import SwiftUI

struct WindowGroupContentView: View {
    
    @EnvironmentObject var appState: AppState
    @State var streamPlayerID: StreamPlayer.ID?
    
    var body: some View {
        if let streamPlayer = appState.streamPlayers.first(where: { $0.id == streamPlayerID }) {
            StreamPlayerView(streamPlayer: streamPlayer, style: .windowed)
                .environmentObject(appState)
                .environmentObject(Clock())
//                .ignoresSafeArea()
        }
    }
    
}

//fileprivate struct SoloStreamPlayerView: View {
//    
//    var body: some View {
//        
//    }
//    
//}
//struct WindowGroupContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        WindowGroupContentView()
//    }
//}
