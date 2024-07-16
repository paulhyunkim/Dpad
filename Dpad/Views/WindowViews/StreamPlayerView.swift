//
//  StreamPlayerView.swift
//  Dpad
//
//  Created by Paul Kim on 10/12/22.
//

import SwiftUI
import AVKit

struct StreamPlayerView: View {
    
    @ObservedObject var streamPlayer: StreamPlayer
    @EnvironmentObject var appState: AppState
    @State var showingVolumeOverlay: Bool = false
    @Environment(\.clock) var clock
    @Environment(\.openURL) var openURL
    @State var hovering = false
    
    @State var eventMonitor: Any?
    
    var style: Style
    
    enum Style {
        case primary
        case secondary
        case windowed
    }
    
    @Environment(\.openWindow) var openWindow
    
    var body: some View {
        switch style {
        case .primary:
            primaryView
        case .secondary:
            primaryView
        case .windowed:
            windowedView
        }
    }
    
    @ViewBuilder var primaryView: some View {
        VStack(spacing: 0) {
            streamPlayer.view
                .overlay(alignment: .topLeading) {
                    volumeOverlay
                        .opacity(showingVolumeOverlay ? 1 : 0)
                        .animation(showingVolumeOverlay ? nil : .default.delay(1), value: showingVolumeOverlay)
                }
                .overlay(alignment: .bottomLeading) {
                    HStack {
                        VStack(alignment: .leading) {
                            if let uptime {
                                Text(uptime)
                                    .font(.title3)
                            }
                            muteButtonImage
                            Text(streamPlayer.stream.channel.name)
                            Text(streamPlayer.stream.title ?? "")
                            Text(streamPlayer.stream.gameName ?? "")
                        }
                        Spacer()
                        Text("Something here")
                    }
                    .opacity(hovering ? 1 : 0)
                    .animation(hovering ? nil : .default, value: hovering)
                }
        
                .contentShape(Rectangle())
                .contextMenu {
                    Button {
                        appState.execute(.closeStream(streamPlayer.stream))
                    } label: {
                        Label("Close Stream", systemImage: "xmark")
                    }
                    
                    Button {
                        
                    } label: {
                        Label("Add to Favorites", systemImage: "heart")
                    }
                    Button {
                        if let url = streamPlayer.stream.url {
                            openURL(url)
                        }
                    } label: {
                        Text("Open Stream in Browser")
                    }
                    Button {
                        if let url = streamPlayer.stream.chatURL {
                            openURL(url)
                        }
                    } label: {
                        Text("Open Chat in Browser")
                    }
                }
                .onTapGesture(count: 2, perform: {
                    appState.execute(.focusStream(streamPlayer.stream))
                })
                .onHover { onHover in
                    self.hovering = onHover
                    volumeGesture(isActive: onHover)
                }
                .aspectRatio(aspectRatio, contentMode: .fit)
        }
    }
    
    @ViewBuilder var windowedView: some View {
        streamPlayer.view
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 5) {
                    Spacer()
                    Text(streamPlayer.stream.displayName)
                        .font(.headline)
                }
                .frame(maxWidth: 100)
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .background(.thickMaterial)
                .cornerRadius(10)
                .padding(.leading, 10)
                .padding(.top, 10)
                
                volumeOverlay
                    .opacity(showingVolumeOverlay ? 1 : 0)
                    .animation(showingVolumeOverlay ? nil : .default.delay(1), value: showingVolumeOverlay)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                print("VIDEO TAPPED")
                openWindow(id: "Player", value: streamPlayer.id)
            }
            .onHover { onHover in
                volumeGesture(isActive: onHover)
            }
            .aspectRatio(aspectRatio, contentMode: .fit)
    }
    
    var muteButtonImage: Image {
        switch streamPlayer.isMuted || streamPlayer.volume == 0 {
        case true:
            return Image(systemName: "speaker.slash.fill")
        case false:
            return Image(systemName: "speaker.wave.2.fill")
        }
    }
    
    var uptime: String? {
        return clock.uptime(for: streamPlayer.stream.startTime)
    }
    
    @ViewBuilder var controlsView: some View {
        HStack(spacing: 0) {
            Button {
                appState.execute(.focusStream(streamPlayer.stream))
            } label: {
                Image(systemName: "chevron.up")
                    .frame(width: 20, height: 20)
            }
            
            Button {
                appState.execute(.closeStream(streamPlayer.stream))
            } label: {
                Image(systemName: "xmark")
                    .frame(width: 20, height: 20)
            }
        }
    }
    
    @ViewBuilder var volumeOverlay: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Volume: \(Int(streamPlayer.volume * 100))")
                .font(.headline)
            
            // make component
            Rectangle()
                .frame(maxWidth: .infinity)
                .frame(height: 4)
                .foregroundColor(.secondary)
                .overlay(alignment: .leading) {
                    GeometryReader { geometry in
                        Rectangle()
                            .frame(width: streamPlayer.volume * geometry.size.width, height: 4)
                            .foregroundColor(.accentColor)
                    }
                }
        }
        .frame(maxWidth: 100)
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(.thickMaterial)
        .cornerRadius(10)
        .padding(.leading, 10)
        .padding(.top, 10)
    }
    
    var aspectRatio: CGFloat {
        return 16.0 / 9.0
    }
    
    func volumeGesture(isActive: Bool) {
        if isActive {
            self.eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.scrollWheel]) { event in
                switch event.phase {
                case .began:
                    showingVolumeOverlay = true
                    return event
                case .changed:
                    let currentVolume = streamPlayer.volume
                    let newVolume = currentVolume + (-event.scrollingDeltaY / 500)
                    
                    if newVolume > 1 {
                        streamPlayer.volume = 1
                    } else if newVolume < 0 {
                        streamPlayer.volume = 0
                    } else {
                        streamPlayer.volume = newVolume
                    }
                    return event
                case .ended:
                    showingVolumeOverlay = false
                    return event
                default:
                    return event
                }
            }
            
        } else if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
            self.eventMonitor = nil
        }
    }
    
}

//struct VideoPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        StreamPlayerView()
//    }
//}

