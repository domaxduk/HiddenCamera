//
//  DecodeHelper.swift
//  HiddenCamera
//
//  Created by Tra Le on 12/2/25.
//

import Foundation

class DecodeHelper {
    static func decode<T: Decodable>(urlString: String, type: T.Type) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw error
        }
    }
}
