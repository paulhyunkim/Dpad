//
//  StreamPlayer.swift
//  Dpad
//
//  Created by Paul Kim on 10/12/22.
//

import SwiftUI
import AVKit
import Combine
import AppKit


class StreamPlayer: ObservableObject, Identifiable {
    
    @Published private(set) var player: AVPlayer?
//    var player: AVPlayer
    var stream: Stream
//    var webView: WebView
    
    var id: String {
        return stream.channel.id
    }
    
    private(set) var maxVolume: Double = 1
    @Published var isMuted: Bool = false
    @Published var volume: Double = 1

    // var absoluteVolume
    // var normalizedVolume
    
    var cancellables = Set<AnyCancellable>()
    
    @ViewBuilder var view: some View {
        PlayerView(
            player: Binding(
                get: { self.player },
                set: { self.player = $0 }
            )
        )
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }

    init(stream: Stream, streamURL: URL) {
        self.stream = stream
        let playerItem = AVPlayerItem(url: streamURL)
//        playerItem.automaticallyPreservesTimeOffsetFromLive = true
//        playerItem.configuredTimeOffsetFromLive = CMTime(seconds: 1, preferredTimescale: 1)
//        playerItem.preferredForwardBufferDuration = 1
        
        let player = AVPlayer(playerItem: playerItem)

//        player.automaticallyWaitsToMinimizeStalling = false
        
//        self.player.automaticallyWaitsToMinimizeStalling = false
        self.player = player
//        player.automaticallyWaitsToMinimizeStalling = playerItem.isPlaybackBufferEmpty
        
        $isMuted
            .receive(on: DispatchQueue.main)
//            .print()
            .sink { isMuted in
                player.isMuted = isMuted
            }
            .store(in: &cancellables)
        
        $volume
            .removeDuplicates()
//            .print()
            .receive(on: DispatchQueue.main)
        
            .sink {
                player.volume = Float($0)
//                print("Player Volume: \(Float($0))")
            }
            .store(in: &cancellables)
    }
    
}

// MARK: - PlayerView

/// View representable for PlayerUIView
fileprivate struct PlayerView: NSViewRepresentable {
    
    @Binding var player: AVPlayer?
    
    func makeNSView(context: Context) -> PlayerUIView {
        return PlayerUIView(player: player)
    }

    func updateNSView(_ playerView: PlayerUIView, context: NSViewRepresentableContext<PlayerView>) {
        playerView.playerLayer.player = player
    }

}


// MARK: - PlayerUIView

/// A custom UIView that draws an AVPlayer layer for the purpose of removing player control elements.
fileprivate class PlayerUIView: NSView {
    
    let playerLayer = AVPlayerLayer()

    init(player: AVPlayer?) {
        super.init(frame: .zero)
        playerLayer.player = player
        
        // set the appropriate gravity to fill the view with the video, either .resizeAspectFill or .resize
        playerLayer.videoGravity = .resizeAspectFill
//        print(layer)
//        layer?.addSublayer(playerLayer)
        layer = playerLayer
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()
//        print(bounds)
        playerLayer.frame = bounds
    }
    
}



extension Array where Element == StreamPlayer {
    
    func muteAll() {
        forEach { $0.isMuted = true }
    }
    
}
