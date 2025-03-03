//
//  Reel.swift
//  HiddenCamera
//
//  Created by Tra Le on 12/2/25.
//

import Foundation

struct Reel: Codable, Hashable {
    let id: UUID = UUID() 
    let title: String
    let path: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case path = "url"
    }
}
