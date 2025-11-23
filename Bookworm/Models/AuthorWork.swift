import GRDB

struct AuthorWork: Codable, FetchableRecord, PersistableRecord, TableRecord {
    static let databaseTableName = "Authors_Works"
    
    var authorKey: String
    var workKey: String
    
    static let author = belongsTo(Author.self)
    static let work = belongsTo(Work.self)
}

