import GRDB

struct WorkGenre: Codable, FetchableRecord, PersistableRecord, TableRecord {
    static let databaseTableName = "works_genres"
    
    var workKey: String
    var genreId: String
    
    enum Columns: String, ColumnExpression {
        case workKey = "work_key"
        case genreId = "genre_id"
    }
    
    enum CodingKeys: String, CodingKey {
        case workKey = "work_key"
        case genreId = "genre_id"
    }
}

extension WorkGenre {
    static let work = belongsTo(Work.self)
    static let genre = belongsTo(GenreRecord.self)
}
