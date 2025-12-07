import GRDB

struct WorkLanguage: Codable, FetchableRecord, PersistableRecord, TableRecord {
    static let databaseTableName = "works_languages"
    
    var workKey: String
    var languageId: String
    
    static let work = belongsTo(Work.self)
    static let language = belongsTo(Language.self)
}

