//
//  CompleteBookData.swift
//  Bookworm
//
//  Created by Silvan Dubach on 28.11.2025.
//
import GRDB
import GRDBQuery

struct CompleteBookData: Codable, FetchableRecord, PersistableRecord, Identifiable{
    let work: Work
    let edition: Edition
    let authors: [Author]
    let genres: [Genre]
    let userDetails: UserBookDetails
    
    var id: String { work.workKey }
}

struct AllCompleteBooksQuery: ValueObservationQueryable {
    static var defaultValue: [CompleteBookData] { [] }
    
    func fetch(_ db: Database) throws -> [CompleteBookData] {
        try CompleteBookData.fetchAll(db)
    }
}
