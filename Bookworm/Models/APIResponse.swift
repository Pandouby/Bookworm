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
    let work: WorkResponse
    let edition: EditionResponse?
    let authors: [AuthorResponse]?
    let genre: Genre?
    let publisher: [String]?
    let languages: [String]?
    
    var id: String { work.workKey }
}
