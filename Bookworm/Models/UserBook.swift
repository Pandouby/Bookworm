import GRDB
import Foundation

struct UserBooks: Codable, FetchableRecord, PersistableRecord, TableRecord {
    static let databaseTableName = "UserBooks"
    
    var editionKey: String
    var userRating: Double
    var status: Status
    var startDate: Date
    var endDate: Date
    var notes: String
    
    enum Columns: String, ColumnExpression {
        case editionKey = "edition_key"
        case userRating = "user_rating"
        case status = "status"
        case startDate = "start_date"
        case endDate = "end_date"
        case notes = "notes"
    }
    
    enum CodingKeys: String, CodingKey {
        case editionKey = "edition_key"
        case userRating = "user_rating"
        case status = "status"
        case startDate = "start_date"
        case endDate = "end_date"
        case notes = "notes"
    }
}

extension UserBooks {
    static let edition = belongsTo(Edition.self)
}

struct UserBook {
    let work: Work
    let edition: Edition
    let authors: [Author]
    let genres: [Genre]
}
