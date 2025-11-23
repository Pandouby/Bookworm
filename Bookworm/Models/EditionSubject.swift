import GRDB

struct EditionSubject: Codable, FetchableRecord, PersistableRecord, TableRecord {
    static let databaseTableName = "Editions_subjects"
    
    var editionKey: String
    var subjectId: String
}
