//
//  CCTVCountryViewModel.swift
//  HiddenCamera
//
//  Created by Tra Le on 11/2/25.
//

import UIKit
import RxSwift

struct CCTVCountryViewModelInput: InputOutputViewModel {
    var back = PublishSubject<()>()
    var didSelectItem = PublishSubject<CCTV>()
}

struct CCTVCountryViewModelOutput: InputOutputViewModel {

}

struct CCTVCountryViewModelRouting: RoutingOutput {
    var stop = PublishSubject<()>()
    var routeToDetail = PublishSubject<(cctv: CCTV, info: CCTVInfoFetcher.Result?)>()
}

final class CCTVCountryViewModel: BaseViewModel<CCTVCountryViewModelInput, CCTVCountryViewModelOutput, CCTVCountryViewModelRouting> {
    @Published var infos = [String: CCTVInfoFetcher.Result]()
    private var tasks = [URLSessionDataTask]()
    
    let country: CCTVCountry
    
    init(country: CCTVCountry) {
        self.country = country
        super.init()
        getInfo()
    }
    
    override func configInput() {
        super.configInput()
        
        input.back.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            
            for task in tasks {
                task.cancel()
            }
            
            self.tasks.removeAll()
            self.routing.stop.onNext(())
        }).disposed(by: self.disposeBag)
        
        input.didSelectItem.subscribe(onNext: { cctv in
            AdsInterstitial.shared.tryToPresent { [weak self] in
                guard let self else { return }
                self.routing.routeToDetail.onNext((cctv, infos[cctv.name]))
            }
        }).disposed(by: self.disposeBag)
    }
    
    private func getInfo() {
        for cctv in country.items {
            let task = CCTVInfoFetcher.getM3u8Link(from: cctv.path, completion: { [weak self] result, error in
                guard let self else { return }
                if let result {
                    DispatchQueue.main.async {
                        self.infos[cctv.name] = result
                    }
                }
                
                if let error {
                    print("[GET INFO CCTV] \(error)")
                }
            })
            
            if task != nil {
                self.tasks.append(task!)
                task?.resume()
            }
        }
    }
    
    var title: String {
        return country.name
    }
    
    var items: [CCTV] {
        return country.items
    }
}

struct CCTVInfoFetcher {
    enum Error {
        case noData
        case wrongLink
    }
    
    struct Result: Codable {
        var imagePath: String?
        var views: String?
        var link: String?
    }
   
    static func getM3u8Link(from urlString: String, completion: @escaping (Result?, Error?) -> Void) -> URLSessionDataTask? {
        guard let url = URL(string: urlString), !urlString.isEmpty else {
            completion(nil, Error.wrongLink)
            return nil
        }
        
        var result = Result()
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil,
                  let htmlContent = String(data: data, encoding: .utf8) else {
                completion(nil, Error.noData)
                return
            }
            
            // Extract m3u8 link
            if let hlsManifestUrl = extractFirstMatch(from: htmlContent, pattern: #""hlsManifestUrl":"(https:[^"]+)""#)?.replacingOccurrences(of: "\\u0026", with: "&") {
                result.link = hlsManifestUrl
            }
            
            // Extract view count
            if let viewCount = extractFirstMatch(from: htmlContent, pattern: #""originalViewCount":(\d+)"#) {
                result.views = viewCount
            } else {
                result.views = String(Int.random(in: 1005...9999))
            }
            
            // Extract thumbnail
            if let videoPath = extractFirstMatch(from: htmlContent, pattern: #"https:\/\/i\.ytimg\.com\/.*?(vi\/[\w\-]+)\/maxresdefault\.jpg"#) {
                result.imagePath = "https://i.ytimg.com/\(videoPath)/hqdefault.jpg"
            }
            
            completion(result, nil)
        }
        
        return task
    }
    
    static func getInfoLink(from urlString: String, completion: @escaping ([String: String]) -> Void) {
        var result: [String: String] = [:]
        guard let url = URL(string: urlString), !urlString.isEmpty else {
            completion(result)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil,
                  let htmlContent = String(data: data, encoding: .utf8) else {
                completion(result)
                return
            }
            
            // Extract view count
            if let viewCount = extractFirstMatch(from: htmlContent, pattern: #""originalViewCount":"(\d+)""#) {
                result["view_count"] = viewCount
            } else {
                result["view_count"] = String(Int.random(in: 1005...9999))
            }
            
            // Extract thumbnail (high resolution)
            if let thumbnail = extractFirstMatch(from: htmlContent, pattern: #"https:\/\/i\.ytimg\.com\/.*?\/([\w\-]+)\/maxresdefault\.jpg"#) {
                result["thumbnail"] = thumbnail
            } else if let thumbnail = extractFirstMatch(from: htmlContent, pattern: #"https:\/\/i\.ytimg\.com\/.*?\/([\w\-]+)\/hqdefault\.jpg"#) {
                result["thumbnail"] = thumbnail
            }
            
            completion(result)
        }
        task.resume()
    }
    
    private static func extractFirstMatch(from text: String, pattern: String) -> String? {
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        if let match = regex?.firstMatch(in: text, options: [], range: range) {
            if let matchRange = Range(match.range(at: 1), in: text) {
                return String(text[matchRange])
            }
        }
        
        return nil
    }
}

