//
//  CompleteBookData.swift
//  Bookworm
//
//  Created by Silvan Dubach on 28.11.2025.
//
import GRDB
import GRDBQuery

struct CompleteBookData: Codable, FetchableRecord, PersistableRecord, Identifiable, Equatable {
    let work: Work
    let edition: Edition
    let authors: [Author]
    let genres: [Genre]
    let userDetails: UserBookDetails
    
    var id: String { work.workKey }
    
    static func == (lhs: CompleteBookData, rhs: CompleteBookData) -> Bool {
        return lhs.work.workKey == rhs.work.workKey &&
               lhs.userDetails.status == rhs.userDetails.status &&
               lhs.userDetails.userRating == rhs.userDetails.userRating &&
               lhs.userDetails.isFavorite == rhs.userDetails.isFavorite
    }
}

struct AllCompleteBooksQuery: ValueObservationQueryable {
    static var defaultValue: [CompleteBookData] { [] }

    var statuses: [Status] = []
    
    func fetch(_ db: Database) throws -> [CompleteBookData] {
        //let allBooks = try CompleteBookData.fetchAll(db)
        let allBooks = try DatabaseRepository.queryAllUserBookDetails(db: db)
        
        // no filter -> return all
        if statuses.isEmpty {
            return allBooks
        }
        
        return allBooks.filter { statuses.contains($0.userDetails.status) }
    }
}


