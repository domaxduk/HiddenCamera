//
//  Downloader.swift
//  HiddenCamera
//
//  Created by Tra Le on 12/2/25.
//

import Foundation
import SakuraExtension

class Downloader: NSObject, URLSessionTaskDelegate {
    static private let shared = Downloader()
    
    static func download(path: String) async throws -> Data {
        guard let url = URL(string: path) else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}

class ReelDownloader {
    static let folderURL = FileManager.documentURL()
    
    static func download(_ reel: Reel) async -> URL? {
        let localURL = reel.localURL
        if !reel.isExist {
            do {
                let data = try await Downloader.download(path: reel.path)
                print("get data success from \(reel.path)")
                try data.write(to: localURL)
            } catch {
                print(error)
                return nil
            }
        }
        
        return localURL
    }
}

extension Reel {
    var filename: String {
        return path.components(separatedBy: "/").last ?? ""
    }
    
    var localURL: URL {
        return ReelDownloader.folderURL.appendingPathComponent(filename)
    }
    
    var isExist: Bool {
        return FileManager.default.fileExists(atPath: localURL.path)
    }
}
