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
    var status: Status
    var addedDate: Date
    var startDate: Date
    var endDate: Date
    var notes: String
    
    init(from data: CompleteBookData) {
        self.originalWork = data.work
        self.originalEdition = data.edition
        self.originalAuthors = data.authors
        self.originalGenres = data.genres
        self.originalUserBookDetails = data.userDetails
        
        // Copy fields into observable state
        self.workTitle = data.work.workTitle
        self.authorName = data.authors.first?.authorName ?? "Unknown Author"
        self.genre = data.genres.first ?? .nonClassifiable
        self.pageCount = data.edition.numberOfPages ?? 0
        self.userRating = data.userDetails.userRating
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
    
    /// Convert everything back into a complete record structure
    var asRecord: CompleteBookData {
        CompleteBookData(
            work: workEdited,
            edition: originalEdition,
            authors: originalAuthors,
            genres: genresEdited,
            userDetails: userDetailsEdited
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
        lhs.status == rhs.status &&
        lhs.addedDate == rhs.addedDate &&
        lhs.startDate == rhs.startDate &&
        lhs.endDate == rhs.endDate &&
        lhs.notes == rhs.notes
    }
    
    static func < (lhs: CompleteBookDataViewModel, rhs: CompleteBookDataViewModel) -> Bool {
        if lhs.addedDate != rhs.addedDate { return lhs.addedDate > rhs.addedDate }
        if lhs.endDate != rhs.endDate { return lhs.endDate > rhs.endDate }
        if lhs.status.sortOrder != rhs.status.sortOrder { return lhs.status.sortOrder < rhs.status.sortOrder }
        return lhs.workTitle < rhs.workTitle
    }
}

