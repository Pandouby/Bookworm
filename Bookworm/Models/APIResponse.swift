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

struct FullSearchResult: Codable, Identifiable {
    var work: WorkResponse
    var edition: EditionResponse?
    var authors: [AuthorResponse]?
    var genre: Genre?
    var publisher: [String]?
    var languages: [String]?
    
    var id: String { work.workKey }
}
