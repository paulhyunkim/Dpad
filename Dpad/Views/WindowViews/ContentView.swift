//
//  ContentView.swift
//  Dpad
//
//  Created by Paul Kim on 10/10/22.
//

import SwiftUI
import AVKit
import Combine
import WebKit
 
struct WebView: NSViewRepresentable {
 
    var url: URL?
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.1 Safari/605.1.15"
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        guard let url else {
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }
 
}


struct ContentView: View {
    
    @EnvironmentObject var appState: AppState
    @State var url: String = ""
    @State var volume: Double = 1
    @State var searchText: String = ""
    @State var chatURL: URL?
    
    @State var size: CGSize = .zero
    
    var hideChat: Bool {
        return (300 / size.width) > 0.25
    }
    
    var body: some View {
        NavigationSplitView {
            ChannelsSidebar()
                .navigationSplitViewColumnWidth(min: 250, ideal: 50, max: 500)
        } detail: {
            HStack(spacing: 0) {
                StreamsView()
                if appState.showChat {
                    ZStack {
                        ForEach(appState.streams, id: \.channel.id) { stream in
                            if let chatURL = stream.chatURL {
                                WebView(url: chatURL)
                                    .frame(width: chatURL == self.chatURL ? 300 : 0)
                            }
                        }
                    }
                    .transition(.move(edge: .trailing))
//                    WebView(url: chatURL)
//                        .frame(width: 300)
//                        .transition(.move(edge: .trailing))
                        
                }
            }
            .trackSize(size: $size)
            .animation(.default, value: appState.showChat)
        }
        
//
//        .onChange(of: size) { newValue in
//            if (300 / size.width) > 0.5 {
//
//            }
//        }
//        .navigationSplitViewStyle(.prominentDetail)
        .onReceive(appState.$streamPlayers) { players in
//            players.muteAll()
//            players.first?.isMuted = false
            self.chatURL = players.first?.stream.chatURL
        }
        .toolbar {
            TextField("Add Channel", text: $url)
                .frame(minWidth: 200, idealWidth: 250, maxWidth: 300)
                .onSubmit {
                    defer { self.url = "" }
                    guard let url = URL(string: url) else { return }
                    appState.execute(.addChannel(url))
                }
            TextField("Add YouTube ID", text: $url)
                .frame(minWidth: 200, idealWidth: 250, maxWidth: 300)
                .onSubmit {
                    defer { self.url = "" }
                    UserPreferences.shared.channels.append(CacheChannel(id: url, name: "", userLogin: "", platform: .youTube))
                    appState.execute(.fetchChannels)
                }
        }
        .searchable(text: $searchText, placement: .sidebar, prompt: Text("Filter"))
        .buttonStyle(.borderless)
    }
    
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//            .environmentObject(AppState.mockState())
//            .frame(width: 800, height: 500)
//    }
//}
