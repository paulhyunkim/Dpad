//
//  DpadApp.swift
//  Dpad
//
//  Created by Paul Kim on 10/10/22.
//

import SwiftUI
import URLImage
import URLImageStore

@main
struct DpadApp: App {
    
//    @Environment(\.openWindow) var openWindow
    
    @Environment(\.scenePhase) private var scenePhase
//    @Environment(\.windowSize) private var
    @StateObject var appState = AppState(dataServices: [YouTubeDataService()])
    let urlImageService = URLImageService(fileStore: URLImageFileStore(),
                                          inMemoryStore: URLImageInMemoryStore())

    
    enum WindowType {
        case player
        case mainApp
    }
    
    var body: some Scene {
//        Window("Player", id: "Player") {
//            if let streamPlayer = appState.streamPlayers.first {
//                StreamPlayerView(streamPlayer: streamPlayer)
//            }
////            StreamPlayer(stream: appState.playingStreams.first, streamURL: <#T##URL#>)
//        }
        
        
    

        Window("Dpad", id: "Dpad") {
            ContentView()
                .environment(\.urlImageService, urlImageService)
                .environment(\.clock, Clock())
                .buttonStyle(.borderless)
                .environmentObject(appState)
                .toolbar {
                    ToolbarItemGroup {
                        Button(action: {
                            appState.execute(.toggleChat)
                        }, label: {
                            Image(systemName: "sidebar.right")
                        })
                        Spacer()
                        Button(action: {
                            if appState.streamsLayout == .focusedGrid {
                                appState.streamsLayout = .symmetricGrid
                            } else {
                                appState.streamsLayout = .focusedGrid
                            }
                        }, label: {
                            Image(systemName: "play.fill")
                            
                        })
                        
                        // TODO: - How to render hierarchical/multicolor SF Symbols
                        // https://www.hackingwithswift.com/articles/237/complete-guide-to-sf-symbols
                        // Can also adjust the variant through the `symbolVariant` modifier
                        // 􀥌 􀯝
                        // 􀌙 􁅒
                        
                        // AutoPlay
                        // 􁏴 play.display
                        // 􀼑 lock.display
                        // 􁏵 play.laptopcomputer
                        // 􀼓 lock.laptopcomputer
                        
                        // AutoFocus
                        // 􁇝 dot.viewfinder
                        // 􀥄 plus.viewfinder
                        // 􀎡 lock.fill
                        // 􀡝 lock.square.stack.fill

//                        Button {
//                            openWindow(id: "", value: appState.)
//                        } label: {
//                            Image(systemName: "plus.viewfinder")
//                        }
                        
                        // AirPlay
                        // 􀑡 airplayvideo
                        
                        // Settings
                        // 􀰲 sidebar.trailing
                        // 􀍟 gear
                        // 􀣋 gearshape
                        // 􀣌 gearshape.fill
                        
                        // Favorite
                        // 􀊵 heart.fill
                        // 􀋃 star.fill
                        
                        // Notifications
                        // 􀋚 bell.fill
                        // 􀋞 bell.slash.fill
                        
                        // Share
                        // 􀉣 link
                        // 􀈂 square.and.arrow.up
                        // 􀉑 arrowshape.turn.up.right.fill
                        // something for chat link or the above opens a menu of options: channel, chat, etc
                        // 􀌳 text.bubble.fill (maybe something like this?)
                        
                        // Channel list display mode
                        // 􀭞 square.fill.text.grid.1x2
                        // 􀋲 list.bullet
                        // 􀌇 line.3.horizontal
                        // 􀿒
                        // 􀌃 text.justify
                        // 􀵬 arrow.up.and.down.text.horizontal
                        
                        // Streams display mode
                        // 􀛧 rectangle.grid.2x2.fill
                        // 􀧌 rectangle.split.2x2
                        // 􀧍 rectangle.split.2x2.fill
                        // 􀏡 squares.below.rectangle
                        // 􁚬 squares.leading.rectangle
                        // 􀐷 rectangle.compress.vertical
                        // 􀐸 rectangle.expand.vertical
                        
                        // Stream display mode
                        // 􀾮 rectangle.tophalf.inset.filled
                        // 􀤳 rectangle.inset.filled
                        
                        // Stream action
                        // 􀆄 xmark
                        // 􀁡 xmark.circle.fill
                         
                        
                        Button(action: {
                            appState.execute(.fetchStreams)
                        }, label: {
                            Image(systemName: "pause.fill")
                        })
                        
                        Toggle(isOn: .constant(false)) {
                            Image(systemName: "arrow.clockwise")
                        }
                        Button {
//                            appState.execute(.focusStream(streamPlayer.stream))
                        } label: {
                            Image(systemName: "lock.fill")
                        }
                    }
                        
                        
       
//                    ToolbarItemGroup(placement: .primaryAction, content: {
//                        Button(action: {}, label: {
//                            Image(systemName: "square.stack.3d.down.forward.fill")
//                            Text(verbatim: "image_button")
//                        })
//                    })
//
//                    ToolbarItemGroup(placement: .destructiveAction, content: {
//                        Button(action: {}, label: {
//                            Text(verbatim: "button")
//                        })
//                    })
                }
//                .onOpenURL { url in
//                    let notification = Notification(name: OAuthSwift.didHandleCallbackURL, object: nil,
//                                                    userInfo: ["OAuthSwiftCallbackNotificationOptionsURLKey": url])
//                    NotificationCenter.default.post(notification)
                    
//                    if url.host == "oauth-callback" {
//                        OAuthSwift.handle(url: url)
//                    }
//                }
        }
        .windowStyle(.automatic)
        .windowToolbarStyle(.automatic)
        .commands {
            SidebarCommands()
            MenuCommands()
        }
//        .onChange(of: scenePhase) { scenePhase in
//            switch scenePhase {
//            case .active
//            }
//        }

        
        WindowGroup("Player", id: "Player", for: StreamPlayer.ID.self) { $streamPlayerID in
            WindowGroupContentView(streamPlayerID: streamPlayerID)
                .environmentObject(appState)
                .frame(width: 800, height: 500, alignment: .center)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.top)
        }
    
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unifiedCompact(showsTitle: false))
        
//        .wind
       
        
        Settings {
            SettingsView()
                .buttonStyle(.borderless)
                .environmentObject(appState)
        }
        
        MenuBarExtra {
//            Button("Nested #1") {}
//                .foregroundColor(.red)
//            HStack {
//                Text("Hello")
//                    .foregroundColor(.red)
//                Text("World")
//            }
//            Button("Nested #2") {}
//            Button("Nested #3") {}
//            Menu("asdf") {
//                Text("Nested")
//                    .contextMenu {
//                        Button("Nested #1") {}
//                    }
//            }
            MenuBarContentView()
                .buttonStyle(.borderless)
                .environmentObject(appState)
        } label: {
            Image(systemName: "dpad.fill")
        }
        .menuBarExtraStyle(.menu)
    }
}


struct MenuCommands: Commands {

    var body: some Commands {
        CommandMenu("Credentials") {
            Button(action: {
            }, label: {
                Text("Menu Button")
            })
        }
    }
}


struct SettingsView: View {
    
    @EnvironmentObject var appState: AppState
    @ObservedObject var userPreferences = UserPreferences.shared

    var body: some View {
        Form(content: {
            TextField("Twitch Client ID", text: userPreferences.$twitchClientID)
            TextField("Twitch Access Token", text: userPreferences.$twitchAccessToken)
            TextField("YouTube API Key", text: userPreferences.$youtubeAPIKey)
            TextField("Streamlink Location", text: userPreferences.$streamlinkPath)
            Picker("Default Quality", selection: userPreferences.$defaultQuality) {
                ForEach(StreamQuality.allCases, id: \.self) {
                    Text($0.text)
                        .tag($0)
                }
            }
            Picker("Channel List Display Style", selection: userPreferences.$channelListDisplayStyle) {
                ForEach(ChannelListDisplayStyle.allCases, id: \.self) {
                    Text($0.rawValue)
                        .tag($0)
                }
            }
            
        
        })
        .padding(20)
        .frame(width: 450)
    }
    
}
