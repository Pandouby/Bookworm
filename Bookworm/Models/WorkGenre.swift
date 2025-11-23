import GRDB

struct WorkGenre: Codable, FetchableRecord, PersistableRecord, TableRecord {
    static let databaseTableName = "works_genres"
    
    var workKey: String
    var genreId: String
}

extension WorkGenre {
    static let work = belongsTo(Work.self)
    static let genre = belongsTo(GenreRecord.self)
}