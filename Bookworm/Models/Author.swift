import GRDB

struct Author: Codable, FetchableRecord, PersistableRecord, TableRecord {
    static let databaseTableName = "Authors"
    
    var authorKey: String
    var authorName: String
    var birthDate: String?
    var deathDate: String?
    var wikipedia: String?
    
    enum Columns: String, ColumnExpression {
        case authorKey = "author_key"
        case authorName = "author_name"
        case birthDate = "birth_date"
        case deathDate = "death_date"
        case wikipedia
    }
}

extension Author {
    static let authorWorks = hasMany(AuthorWork.self)
    static let works = hasMany(Work.self, through: authorWorks, using: AuthorWork.work)
}

struct AuthorResponse: Codable {
    let name: String
}
