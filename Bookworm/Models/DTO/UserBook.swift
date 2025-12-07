import GRDB
import Foundation

struct UserBookDetails: Codable, FetchableRecord, PersistableRecord, TableRecord {
    static let databaseTableName = "UserBookDetails"
    
    var editionKey: String
    var addedDate: Date
    var userRating: Double
    var status: Status
    var startDate: Date
    var endDate: Date
    var notes: String
    
    enum Columns: String, ColumnExpression {
        case editionKey = "edition_key"
        case addedDate = "added_date"
        case userRating = "user_rating"
        case status = "status"
        case startDate = "start_date"
        case endDate = "end_date"
        case notes = "notes"
    }
    
    enum CodingKeys: String, CodingKey {
        case editionKey = "edition_key"
        case addedDate = "added_date"
        case userRating = "user_rating"
        case status = "status"
        case startDate = "start_date"
        case endDate = "end_date"
        case notes = "notes"
    }
}

extension UserBookDetails {
    static let edition = belongsTo(Edition.self)
}

extension UserBookDetails {
    /// Useful for rebuilding a modified record
    func copy(
        editionKey: String? = nil,
        addedDate: Date? = nil,
        userRating: Double? = nil,
        status: Status? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        notes: String? = nil
    ) -> UserBookDetails {
        UserBookDetails(
            editionKey: editionKey ?? self.editionKey,
            addedDate: addedDate ?? self.addedDate,
            userRating: userRating ?? self.userRating,
            status: status ?? self.status,
            startDate: startDate ?? self.startDate,
            endDate: endDate ?? self.endDate,
            notes: notes ?? self.notes
        )
    }
}
