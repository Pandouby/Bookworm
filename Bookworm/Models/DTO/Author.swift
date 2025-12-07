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
    
    enum CodingKeys: String, CodingKey {
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
    let authorKey: String
    let authorName: String
    let birthDate: String?
    let deathDate: String?
    let wikipedia: String?
    
    enum CodingKeys: String, CodingKey {
        case authorKey = "key"
        case authorName = "name"
        case birthDate = "birth_date"
        case deathDate = "death_date"
        case wikipedia
    }
    
    // Custom initializer
    init(authorKey: String,
         authorName: String,
         birthDate: String? = nil,
         deathDate: String? = nil,
         wikipedia: String? = nil
    ) {
        self.authorKey = authorKey
        self.authorName = authorName
        self.birthDate = birthDate
        self.deathDate = deathDate
        self.wikipedia = wikipedia
    }
}

struct AuthorWorkResponse: Codable {
    let author: AuthorKeyElement
}

struct AuthorKeyElement: Codable {
    let key: String
}
