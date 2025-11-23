import GRDB

struct Rating: Codable, FetchableRecord, PersistableRecord, TableRecord {
    static let databaseTableName = "Ratings"
    
    var workKey: String
    var ratingId: Int64
    var rating: Int
    var ratingDate: String
    
    enum Columns: String, ColumnExpression {
        case workKey = "work_key"
        case ratingId = "rating_id"
        case rating
        case ratingDate = "rating_date"
    }
}

extension Rating {
    static let work = belongsTo(Work.self)
}
