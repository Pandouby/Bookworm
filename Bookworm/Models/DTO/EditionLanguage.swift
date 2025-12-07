import GRDB

struct EditionLanguage: Codable, FetchableRecord, PersistableRecord, TableRecord {
    static let databaseTableName = "editions_languages"
    
    var editionKey: String
    var languageId: String
    
    static let edition = belongsTo(Edition.self)
    static let language = belongsTo(Language.self)
}

