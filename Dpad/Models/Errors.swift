//
//  Errors.swift
//  Dpad
//
//  Created by Paul Kim on 10/15/22.
//

import Foundation

enum DataServiceError: Error {
    case invalidURL
}

enum ShellServiceError: Error {
    case couldNotDecodeOutput
}

enum StreamlinkServiceError: Error {
    case invalidStreamURL
    case outputIsNotAURL(String)
}

enum YouTubeError: Error {
    case emptyVideosResponseItems
    case emptyChannelsResponseItems
}
