//
//  ThumbnailSearchService.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 14.4.2022.
//

import Foundation

struct Urls: Hashable, Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
    let small_s3: String
}

struct RandomPhotoResult: Hashable, Codable {
    let width: Int
    let height: Int
    let blur_hash: String
    let urls: Urls
}

enum ThumbnailSearchService {
    static func fetchRandomPhoto(query: String) async throws -> RandomPhotoResult? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.unsplash.com"
        components.path = "/photos/random"
        let apiKey = Bundle.main.infoDictionary?["UNSPLASH_CLIENT_KEY"] as? String

        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "client_id", value: apiKey)
        ]

        guard let string = components.string else { return nil }
        guard let url = URL(string: string) else { return nil }

        let (data, _) = try await URLSession.shared.data(from: url)

        let result = try JSONDecoder().decode(RandomPhotoResult.self, from: data)

        return result
    }
}
