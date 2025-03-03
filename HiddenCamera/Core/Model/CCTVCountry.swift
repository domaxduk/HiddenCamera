//
//  CCTVCountry.swift
//  HiddenCamera
//
//  Created by Tra Le on 11/2/25.
//

import Foundation

struct CCTVCountry: Codable {
    let name: String
    let imagePath: String
    let priority: Int
    let items: [CCTV]
    
    enum CodingKeys: String, CodingKey {
        case name = "country"
        case imagePath = "image_flag"
        case priority
        case items = "item"
    }
}

struct CCTV: Codable {
    let name: String
    let location: String
    let path: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case location
        case path = "link"
    }
}


