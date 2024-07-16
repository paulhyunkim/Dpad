//
//  YouTubeDataService.swift
//  Dpad
//
//  Created by Paul Kim on 12/4/22.
//

import SwiftUI
import Combine
import SwiftSoup
import Sextant

class YouTubeDataService: DataProvider {

    @AppStorage(Constant.YouTube.channels) var cachedChannels: [YouTubeChannel] = []
    
    @Published var channels: [Channel] = []
    @Published var streams: [Stream] = []
    
    let streamlink = YoutubeStreamlinkService()
    
    init() {
    }
    
    @discardableResult
    func fetchChannels() async throws -> [Channel] {
        let channelsResponse = try await fetchYouTubeChannels(ids: cachedChannels.map { $0.id } )
        let channels = channelsResponse.items.map { YouTubeChannel(responseItem: $0) }
        DispatchQueue.main.async {
            self.channels = channels
        }
        updateChannelsCache(with: channels)
        return channels
    }
    
    @discardableResult
    func fetchStreams() async throws -> [Stream] {
//        do {
            let liveVideoData = try await scrapeLiveVideoData(channels: cachedChannels)
            let response = try await fetchYouTubeVideos(ids: liveVideoData.map { $0.videoID })
            let streams: [Stream] = response.items.compactMap { item in
                guard let channel = cachedChannels.first(where: { $0.id == item.snippet.channelId }),
                      let videoData = liveVideoData.first(where: { $0.videoID == item.id }) else {
                    return nil
                }
                // TODO: - maybe set last broadcast time to sort channels list against
    //            item.liveStreamingDetails?.actualStartTime
                return YouTubeStream(responseItem: item, channel: channel, gameName: videoData.gameName)
            }
            DispatchQueue.main.async {
                self.streams = streams
            }
            return streams
//        } catch {
//            print(error)
//        }
//        return []
    }
    
//    @discardableResult
//    func fetchStreams() async throws -> [Stream] {
//        for cachedChannel in cachedChannels {
//            try await streamlink.isLive(for: cachedChannel)
//        }
//        
//        // get array of live channels
//        
//    }
    
    func addChannel(from url: URL) async throws {
        guard url.host()?.contains("youtube") == true,
              let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems,
              let videoID = queryItems.first(where: { $0.name == "v" })?.value else {
            throw DataServiceError.invalidURL
        }
        
        guard let videoResponseItem = try await fetchYouTubeVideos(ids: [videoID]).items.first else {
            throw YouTubeError.emptyVideosResponseItems
        }
        
        guard let channelResponseItem = try await fetchYouTubeChannels(ids: [videoResponseItem.snippet.channelId]).items.first else {
            throw YouTubeError.emptyChannelsResponseItems
        }
        
        let channel = YouTubeChannel(responseItem: channelResponseItem)
        updateChannelsCache(with: [channel])
    }
    
}


extension YouTubeDataService {
    
    private func fetchYouTubeVideos(videosData: [ScrapedLiveVideoData]) async throws -> GetYouTubeVideoSuccess {
        let part = "snippet,liveStreamingDetails"
        
        var urlComponents = URLComponents(url: Constant.YouTube.getVideosURL, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [
            URLQueryItem(name: "part", value: part),
            URLQueryItem(name: "id", value: videosData.map({ $0.videoID }).joined(separator: ",")),
            URLQueryItem(name: "key", value: UserPreferences.shared.youtubeAPIKey)
        ]
        
        guard let requestURL = urlComponents?.url else {
            throw DataServiceError.invalidURL
        }
        let urlRequest = URLRequest(url: requestURL)
        
        return try await withCheckedThrowingContinuation { continuation in
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                guard let data else {
                    continuation.resume(throwing: DataServiceError.invalidURL)
                    return
                }
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                do {
                    let response = try decoder.decode(GetYouTubeVideoSuccess.self, from: data)
                    continuation.resume(returning: response)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            task.resume()
        }
    }
    
    private func fetchYouTubeVideos(ids: [String]) async throws -> GetYouTubeVideoSuccess {
        let part = "snippet,liveStreamingDetails"
        
        var urlComponents = URLComponents(url: Constant.YouTube.getVideosURL, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [
            URLQueryItem(name: "part", value: part),
            URLQueryItem(name: "id", value: ids.joined(separator: ",")),
            URLQueryItem(name: "key", value: UserPreferences.shared.youtubeAPIKey)
        ]
        
        guard let requestURL = urlComponents?.url else {
            throw DataServiceError.invalidURL
        }
        let urlRequest = URLRequest(url: requestURL)
        
        return try await withCheckedThrowingContinuation { continuation in
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                guard let data else {
                    continuation.resume(throwing: DataServiceError.invalidURL)
                    return
                }
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                do {
                    let response = try decoder.decode(GetYouTubeVideoSuccess.self, from: data)
                    continuation.resume(returning: response)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            task.resume()
        }
    }
    
    private func fetchYouTubeChannels(ids: [String]) async throws -> GetYouTubeChannelSuccess {
        let chunkSize = 50

        // Split the ids array into chunks of 50
        let idChunks = ids.chunked(into: chunkSize)
        
        // Initialize an array to hold the combined results
        var combinedResults = GetYouTubeChannelSuccess(items: [])

        for chunk in idChunks {
            let result = try await fetchChannelsChunk(ids: chunk)
            combinedResults.items.append(contentsOf: result.items)
        }

        return combinedResults
    }
    
    private func fetchChannelsChunk(ids: [String]) async throws -> GetYouTubeChannelSuccess {
        let part = "snippet"
        
        var urlComponents = URLComponents(url: Constant.YouTube.getChannelsURL, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [
            URLQueryItem(name: "part", value: part),
            URLQueryItem(name: "id", value: ids.joined(separator: ",")),
            URLQueryItem(name: "key", value: UserPreferences.shared.youtubeAPIKey)
        ]
        
        guard let requestURL = urlComponents?.url else {
            throw DataServiceError.invalidURL
        }
        let urlRequest = URLRequest(url: requestURL)
        
        return try await withCheckedThrowingContinuation { continuation in
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                guard let data else {
                    continuation.resume(throwing: DataServiceError.invalidURL)
                    return
                }
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                do {
                    let response = try decoder.decode(GetYouTubeChannelSuccess.self, from: data)
                    continuation.resume(returning: response)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            task.resume()
        }
    }
    
    private func updateChannelsCache(with channels: [YouTubeChannel]) {
        channels.forEach { channel in
            if let index = cachedChannels.firstIndex(where: { $0.id == channel.id }) {
                cachedChannels[index] = channel
            } else {
                cachedChannels.append(channel)
            }
        }
    }
    
    private func convertStringToDictionary(text: String) -> [String: AnyObject]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    
    private func scrapeLiveVideoData(channels: [YouTubeChannel]) async throws -> [ScrapedLiveVideoData] {
        return try await withThrowingTaskGroup(
            of: ScrapedLiveVideoData?.self,
            returning: [ScrapedLiveVideoData].self) { taskGroup in
                var liveVideoData: [ScrapedLiveVideoData?] = []
                channels.forEach { channel in
                    taskGroup.addTask {
                        do {
                            let videoID = try await self.scrapeLiveVideoID(channel: channel)
                            let gameName = try await self.scrapeLiveVideoGameName(channel: channel)
                            return YouTubeDataService.ScrapedLiveVideoData(videoID: videoID, gameName: gameName)
                        } catch {
                            return nil
                        }
                    }
                }
                for try await data in taskGroup {
                    liveVideoData.append(data)
                }
                return liveVideoData.compactMap { $0 }
            }
    }
    
    struct ScrapedLiveVideoData {
        var videoID: String
        var gameName: String?
    }
    
    private func scrapeLiveVideoID(channel: YouTubeChannel) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
        
            guard let requestURL = URL(string: "https://www.youtube.com/\(channel.userLogin)") else {
//            guard let requestURL = URL(string: "https://www.youtube.com/watch?v=aHbiwZbmkuQ") else {
                continuation.resume(throwing: DataServiceError.invalidURL)
                return
            }
            var urlRequest = URLRequest(url: requestURL)
            urlRequest.setValue("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/121.0.0.0 Safari/537.36 [ip:13.233.135.97]", forHTTPHeaderField: "User-Agent")
            
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                guard let data,
                      let html = String(data: data, encoding: .ascii) else {
                    continuation.resume(throwing: DataServiceError.invalidURL)
                    return
                }
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                do {
                    let document = try SwiftSoup.parse(html)
                    let initialDataRegex = try Regex("var ytInitialData = (.*);")

                    guard let initialDataScript = try document.select("script")
                        .first(where: { $0.data().contains("var ytInitialData = ") }) else {
                        continuation.resume(throwing: DataServiceError.invalidURL)
                        return
                    }

                    let escapedData = Entities.escape(initialDataScript.data(), OutputSettings().encoder(String.Encoding.ascii).escapeMode(Entities.EscapeMode.base))
                    guard let initialDataRegexMatch = escapedData.firstMatch(of: initialDataRegex),
                          let initialDataSubstring = initialDataRegexMatch.output.last?.substring else {
                        continuation.resume(throwing: DataServiceError.invalidURL)
                        return
                    }

                    let initialDataString = String(initialDataSubstring)
                    let initialData = initialDataString.data(using: .utf8)!
                    
//                    guard let isLive = initialData.query(values: "$..channelFeaturedContentRenderer..videoRenderer.thumbnailOverlays[?(@.thumbnailOverlayTimeStatusRenderer.style=='LIVE')]"),
//                          isLive.count > 0,
//                          let results = initialData.query(values: "$..channelFeaturedContentRenderer..videoRenderer.thumbnailOverlays[?(@.thumbnailOverlayTimeStatusRenderer.style=='LIVE')]")?.first
//                          as? String else {
//                        continuation.resume(throwing: DataServiceError.invalidURL)
//                        return
//                    }
                    
                    guard let videoRenderers = initialData.query(values: "$..videoRenderer") else {
                        continuation.resume(throwing: DataServiceError.invalidURL)
                        return
                    }
                    let liveStyles: JsonArray = videoRenderers
                        .filter {
                            if let matches = $0.query(values: "$..thumbnailOverlayTimeStatusRenderer[?(@.style=='LIVE')]"),
                               matches.count > 0 {
                                return true
                            } else {
                                return false
                            }
                        }
//                        .compactMap {
//                            if let matches = $0.query(values: "$..thumbnailOverlayTimeStatusRenderer[?(@.style=='LIVE')]"),
//                               matches.count > 0 {
//                                return $0
//                            } else {
//                                return nil
//                            }
//                        }
                    guard let videoID = liveStyles.first?.query(values: "$..videoId")?.first as? String else {
                        continuation.resume(throwing: DataServiceError.invalidURL)
                        return
                    }

//                    guard let videoRenderers.query(values: "$..thumbnailOverlayTimeStatusRenderer[?(@.style=='LIVE')]")?.count > 0
                    
//                    "$..thumbnailOverlayTimeStatusRenderer[?(@.style=='LIVE')]"
                    
//                    print("\(channel.userLogin) is live with videoID \(results)")
//                    let gameName = initialData.query(values: "$..richMetadataRenderer[?(@.style=='RICH_METADATA_RENDERER_STYLE_BOX_ART')].title.simpleText")?.first as? String
//                    let videoData = YouTubeDataService.ScrapedLiveVideoData(videoID: results, gameName: gameName)
                    
                    continuation.resume(returning: videoID)

//                    if let results = initialData.query(values: "$..richMetadataRenderer[?(@.style=='RICH_METADATA_RENDERER_STYLE_BOX_ART')].title.simpleText") {
//                        print(results)
//                    }
                    
//                    if let results = dict.query(values: "$..viewCountFactoidRenderer[?(@.viewCountType=='VIEW_COUNT_FACTOID_TYPE_CONCURRENT_VIEWERS')].factoid.factoidRenderer.value.simpleText") {
//                        print(results)
//                    }
                } catch {
                    continuation.resume(throwing: DataServiceError.invalidURL)
                }
            }
            task.resume()
        }
    }
    
    private func scrapeLiveVideoGameName(videoID: String) async throws -> String? {
        return try await withCheckedThrowingContinuation { continuation in
            guard let requestURL = URL(string: "https://www.youtube.com/watch?v=\(videoID)") else {
                continuation.resume(throwing: DataServiceError.invalidURL)
                return
            }
            let urlRequest = URLRequest(url: requestURL)
            
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                guard let data,
                      let html = String(data: data, encoding: .utf8) else {
                    continuation.resume(throwing: DataServiceError.invalidURL)
                    return
                }
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                do {
                    let document = try SwiftSoup.parse(html)
                    let initialDataRegex = try Regex("var ytInitialData = (.*);")

                    guard let initialDataScript = try document.select("script")
                        .first(where: { $0.data().contains("var ytInitialData = ") }) else {
                        continuation.resume(returning: nil)
                        return
                    }

                    let escapedData = Entities.escape(initialDataScript.data(), OutputSettings().encoder(String.Encoding.utf8).escapeMode(Entities.EscapeMode.base))
                    guard let initialDataRegexMatch = escapedData.firstMatch(of: initialDataRegex),
                          let initialDataSubstring = initialDataRegexMatch.output.last?.substring else {
                        continuation.resume(returning: nil)
                        return
                    }

                    let initialDataString = String(initialDataSubstring)
                    let initialData = initialDataString.data(using: .utf8)!
                    
                    guard let gameName = initialData.query(values: "$..richMetadataRenderer[?(@.style=='RICH_METADATA_RENDERER_STYLE_BOX_ART')].title.simpleText")?.first as? String else {
                        continuation.resume(returning: "Just Chatting")
                        return
                    }
                    
                    continuation.resume(returning: gameName)
                } catch {
                    continuation.resume(returning: nil)
                }
            }
            task.resume()
        }
    }
    
    private func scrapeLiveVideoGameName(channel: Channel) async throws -> String? {
        return try await withCheckedThrowingContinuation { continuation in
            guard let requestURL = URL(string: "https://www.youtube.com/\(channel.userLogin)/live") else {
                continuation.resume(throwing: DataServiceError.invalidURL)
                return
            }
            let urlRequest = URLRequest(url: requestURL)
            
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                guard let data,
                      let html = String(data: data, encoding: .utf8) else {
                    continuation.resume(throwing: DataServiceError.invalidURL)
                    return
                }
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                do {
                    let document = try SwiftSoup.parse(html)
                    let initialDataRegex = try Regex("var ytInitialData = (.*);")

                    guard let initialDataScript = try document.select("script")
                        .first(where: { $0.data().contains("var ytInitialData = ") }) else {
                        continuation.resume(returning: nil)
                        return
                    }

                    let escapedData = Entities.escape(initialDataScript.data(), OutputSettings().encoder(String.Encoding.utf8).escapeMode(Entities.EscapeMode.base))
                    guard let initialDataRegexMatch = escapedData.firstMatch(of: initialDataRegex),
                          let initialDataSubstring = initialDataRegexMatch.output.last?.substring else {
                        continuation.resume(returning: nil)
                        return
                    }

                    let initialDataString = String(initialDataSubstring)
                    let initialData = initialDataString.data(using: .utf8)!
                    
                    guard let gameName = initialData.query(values: "$..richMetadataRenderer[?(@.style=='RICH_METADATA_RENDERER_STYLE_BOX_ART')].title.simpleText")?.first as? String else {
                        continuation.resume(returning: "Just Chatting")
                        return
                    }
                    
                    continuation.resume(returning: gameName)
                } catch {
                    continuation.resume(returning: nil)
                }
            }
            task.resume()
        }
    }
    
    func fetchChannel(id: String) async throws -> YouTubeChannel {
        var urlComponents = URLComponents(url: Constant.YouTube.getChannelsURL, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "id", value: id),
            URLQueryItem(name: "key", value: "AIzaSyDEmoilv9NLdpxpQaEgHRF3bXWyessnYoI")
        ]
        
        guard let requestURL = urlComponents?.url else {
            throw DataServiceError.invalidURL
        }

        let urlRequest = URLRequest(url: requestURL)
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let response = try? decoder.decode(GetYouTubeChannelSuccess.self, from: data),
              let item = response.items.first else {
            throw DataServiceError.invalidURL
        }
        return YouTubeChannel(responseItem: item)
    }
    
}


struct YoutubeStreamlinkService {
    
    func isLive(for channel: Channel) async throws -> Bool {
//        guard let url = stream.url else {
//            throw StreamlinkServiceError.invalidStreamURL
//        }
//        
//        let qualityArg = stream.streamlinkQualityArg(quality)
        return false
        
        return try await withCheckedThrowingContinuation { continuation in
            let command = "\(UserPreferences.shared.streamlinkPath) \"https://www.youtube.com/\(channel.userLogin)\""
            print(command)
            Task {
                do {
                    let output = try ShellService.execute(command).trimmingCharacters(in: .whitespacesAndNewlines)
                    print(output)
                    if output.contains("[error]") {
                        continuation.resume(returning: false)
                    } else {
                        continuation.resume(returning: true)
                    }
//                    if let url = URL(string: output) {
//                        continuation.resume(returning: true)
//                    } else {
//                        continuation.resume(throwing: StreamlinkServiceError.outputIsNotAURL(output))
//                    }
                }
            }
        }
    }
    
    func url(for channel: Channel, quality: StreamQuality) async throws -> URL {
//        guard let url = stream.url else {
//            throw StreamlinkServiceError.invalidStreamURL
//        }
        
        let url = "https://www.youtube.com/\(channel.userLogin)"
        
//        let qualityArg = stream.streamlinkQualityArg(quality)
        
        return try await withCheckedThrowingContinuation { continuation in
            let command = "\(UserPreferences.shared.streamlinkPath) \"\(url)\" --stream-url"
            print(command)
            Task {
                do {
                    let output = try ShellService.execute(command).trimmingCharacters(in: .whitespacesAndNewlines)
                    if let url = URL(string: output) {
                        continuation.resume(returning: url)
                    } else {
                        continuation.resume(throwing: StreamlinkServiceError.outputIsNotAURL(output))
                    }
                }
            }
        }
    }
    
}
