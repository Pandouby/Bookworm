//
//  APIResponse.swift
//  Bookworm
//
//  Created by Silvan Dubach on 22.11.2025.
//

struct SearchResponse: Codable {
    let numFound: Int
    let docs: [WorkResponse]
}

struct WorkResponse: Codable {
    let workKey: String
    let workTitle: String
    let description: String?
    let editionKeys: [String]?
    let authorKeys: [String]?
    let languages: [String]?
    let firstPublishYear: Int?
    let subjects: [String]?
    
    enum CodingKeys: String, CodingKey {
        case workKey = "key"
        case workTitle = "title"
        case description
        case editionKeys = "edition_key"
        case authorKeys = "author_key"
        case languages = "language"
        case firstPublishYear = "first_publish_year"
        case subjects = "subject"
    }
}
