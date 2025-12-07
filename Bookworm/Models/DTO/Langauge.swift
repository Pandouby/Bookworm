import GRDB

struct Language: Codable, FetchableRecord, PersistableRecord, TableRecord {
    static let databaseTableName = "Languages"
    
    var languageId: String
    var printName: String
    var invertedName: String?
    
    enum Columns: String, ColumnExpression {
        case languageId = "language_id"
        case printName = "print_name"
        case invertedName = "inverted_name"
    }
    
    enum CodingKeys: String, CodingKey {
        case languageId = "language_id"
        case printName = "print_name"
        case invertedName = "inverted_name"
    }
}

extension Language {
    static let workLanguages = hasMany(WorkLanguage.self)
    static let works = hasMany(Work.self, through: workLanguages, using: WorkLanguage.work)
    
    static let editionLanguages = hasMany(EditionLanguage.self)
    static let editions = hasMany(Edition.self, through: editionLanguages, using: EditionLanguage.edition)
}

struct LanguageResponse: Codable {
    let key: String
}
