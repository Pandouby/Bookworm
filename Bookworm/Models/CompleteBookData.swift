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
        let allBooks = try DatabaseRepository.queryAllUserBookDetails(db: db)
        
        print("🔍 AllCompleteBooksQuery fetched \(allBooks.count) total books from DB")
        for book in allBooks {
            print("  - Book: \(book.work.workTitle), Status: \(book.userDetails.status.rawValue)")
        }

        // no filter -> return all
        if statuses.isEmpty {
            return allBooks
        }
        
        let filtered = allBooks.filter { statuses.contains($0.userDetails.status) }
        print("🔍 AllCompleteBooksQuery returning \(filtered.count) books after filtering for: \(statuses.map { $0.rawValue })")
        return filtered
    }
}


