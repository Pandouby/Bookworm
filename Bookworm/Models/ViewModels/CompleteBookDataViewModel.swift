import SwiftUI

@Observable
final class CompleteBookDataViewModel: Identifiable  {
    // Non-editable database models
   
    // Keep original record so we can rebuild it
    private let originalWork: Work
    private let originalUserBookDetails: UserBookDetails
    private let originalEdition: Edition
    private let originalAuthors: [Author]
    private let originalGenres: [Genre]
    
    // Editable UI state (copied from UserBookDetails)
    var workTitle: String
    var authorName: String
    var genre: Genre
    var pageCount: Int
    var userRating: Double
    var isFavorite: Bool
    var status: Status
    var addedDate: Date
    var startDate: Date
    var endDate: Date
    var notes: String
    var cover: String?
    var editionKey: String
    
    init(from data: CompleteBookData) {
        self.originalWork = data.work
        self.originalEdition = data.edition
        self.originalAuthors = data.authors
        self.originalGenres = data.genres
        self.originalUserBookDetails = data.userDetails
        
        // Copy fields into observable state
        self.editionKey = data.edition.editionKey
        // Work
        self.workTitle = data.work.workTitle
        self.genre = data.genres.first ?? .nonClassifiable
        // Author
        self.authorName = data.authors.first?.authorName ?? "Unknown Author"
        // Edition
        self.pageCount = data.edition.numberOfPages ?? 0
        self.cover = data.edition.cover
        // UserBookDetails
        self.userRating = data.userDetails.userRating
        self.isFavorite = data.userDetails.isFavorite
        self.status = data.userDetails.status
        self.addedDate = data.userDetails.addedDate
        self.startDate = data.userDetails.startDate
        self.endDate = data.userDetails.endDate
        self.notes = data.userDetails.notes
    }
    
    /// Convert edited wrapper state back to a GRDB record
    var userDetailsEdited: UserBookDetails {
        originalUserBookDetails.copy(
            addedDate: addedDate,
            userRating: userRating,
            isFavorite: isFavorite,
            status: status,
            startDate: startDate,
            endDate: endDate,
            notes: notes
        )
    }
    
    var workEdited: Work {
        originalWork.copy(
            workTitle: workTitle
        )
    }
    
    var genresEdited: [Genre] {
        [genre]
    }
    
    var editionEdited: Edition {
        originalEdition.copy(
            numberOfPages: pageCount
        )
    }
    
    var authorsEdited: [Author] {
        if let first = originalAuthors.first {
            return [first.copy(authorName: authorName)]
        } else {
            // Fallback for books without any initial author data
            return [Author(authorKey: UUID().uuidString, authorName: authorName)]
        }
    }
    
    /// Convert everything back into a complete record structure
    var asRecord: CompleteBookData {
        CompleteBookData(
            work: workEdited,
            edition: editionEdited,
            authors: authorsEdited,
            genres: genresEdited,
            userDetails: userDetailsEdited
        )
    }
}

extension Author {
    func copy(authorName: String? = nil) -> Author {
        Author(
            authorKey: self.authorKey,
            authorName: authorName ?? self.authorName,
            birthDate: self.birthDate,
            deathDate: self.deathDate,
            wikipedia: self.wikipedia
        )
    }
}

extension CompleteBookDataViewModel: Comparable, Equatable {
    static func == (lhs: CompleteBookDataViewModel, rhs: CompleteBookDataViewModel) -> Bool {
        return lhs.id == rhs.id &&
        lhs.workTitle == rhs.workTitle &&
        lhs.authorName == rhs.authorName &&
        lhs.genre == rhs.genre &&
        lhs.pageCount == rhs.pageCount &&
        lhs.userRating == rhs.userRating &&
        lhs.isFavorite == rhs.isFavorite &&
        lhs.status == rhs.status &&
        lhs.addedDate == rhs.addedDate &&
        lhs.startDate == rhs.startDate &&
        lhs.endDate == rhs.endDate &&
        lhs.notes == rhs.notes
    }
    
    static func < (lhs: CompleteBookDataViewModel, rhs: CompleteBookDataViewModel) -> Bool {
        // 1. Sort by status order (To Do < Paused < In Progress < Done)
        if lhs.status.sortOrder != rhs.status.sortOrder {
            return lhs.status.sortOrder < rhs.status.sortOrder
        }
        
        // 2. Sort by date finished (most recent first)
        if lhs.endDate != rhs.endDate {
            return lhs.endDate > rhs.endDate
        }
        
        // 3. Sort by title alphabetically
        return lhs.workTitle < rhs.workTitle
    }
}

