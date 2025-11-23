import GRDB

struct EditionPublisher: Codable, FetchableRecord, PersistableRecord, TableRecord {
    static let databaseTableName = "editions_publishers"
    
    var editionKey: String
    var publisherId: String
    
    static let edition = belongsTo(Edition.self)
    static let publisher = belongsTo(Publisher.self)
}
