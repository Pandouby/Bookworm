import GRDB

struct AuthorWork: Codable, FetchableRecord, PersistableRecord, TableRecord {
    static let databaseTableName = "Authors_Works"
    
    var authorKey: String
    var workKey: String
    
    enum Columns: String, ColumnExpression {
        case workKey = "work_key"
        case authorKey = "author_key"
    }
    
    enum CodingKeys: String, CodingKey {
        case workKey = "work_key"
        case authorKey = "author_key"
    }
    
    static let author = belongsTo(Author.self)
    static let work = belongsTo(Work.self)
}

