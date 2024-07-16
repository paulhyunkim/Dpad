//
//  StreamView.swift
//  Dpad
//
//  Created by Paul Kim on 12/13/22.
//

import SwiftUI

struct StreamView: View {
    
    @EnvironmentObject var appState: AppState
    @State var showingVolumeOverlay: Bool = false
    @Environment(\.clock) var clock
    @Environment(\.openURL) var openURL
    @State var hovering = false
    var stream: Stream
    
    @State var eventMonitor: Any?
    
    var style: Style
    
    enum Style {
        case primary
        case secondary
        case windowed
    }
    
    @Environment(\.openWindow) var openWindow
    
    var body: some View {
//        switch style {
//        case .primary:
            primaryView
//        case .secondary:
//            primaryView
//        case .windowed:
//            windowedView
//        }
    }
    
    @ViewBuilder var primaryView: some View {
        VStack(spacing: 0) {
            //            streamPlayer.view
            if let streamPlayer = appState.streamPlayers.first(where: { $0.stream.url == stream.url }) {
                streamPlayer.view
                    .aspectRatio(aspectRatio, contentMode: .fit)
//                    .overlay(alignment: .bottomLeading) {
//                        HStack {
//                            VStack(alignment: .leading) {
//                                Text(streamPlayer.stream.channel.name)
//                                Text(streamPlayer.stream.title ?? "")
//                                Text(streamPlayer.stream.gameName ?? "")
//                            }
//                            Spacer()
//                            Text("Something here")
//                        }
//                        .opacity(hovering ? 1 : 0)
//                        .animation(hovering ? nil : .default, value: hovering)
//                    }

//                    .contentShape(Rectangle())
//                    .onTapGesture(count: 2, perform: {
//                        appState.execute(.focusStream(stream))
//                    })
//                    .onHover { onHover in
//                        self.hovering = onHover
//                    }
//                    .aspectRatio(aspectRatio, contentMode: .fit)
            } else {
                EmptyView()
            }
                
        }
    }
    
    var aspectRatio: CGFloat {
        return 16.0 / 9.0
    }
    
}
