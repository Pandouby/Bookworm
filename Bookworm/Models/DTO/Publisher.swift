import GRDB

struct Publisher: Codable, FetchableRecord, PersistableRecord, TableRecord {
    static let databaseTableName = "Publishers"
    
    var publisherId: String
    var publisherName: String
    
    enum Columns: String, ColumnExpression {
        case publisherId = "publisher_id"
        case publisherName = "publisher_name"
    }
    
    enum CodingKeys: String, CodingKey {
        case publisherId = "publisher_id"
        case publisherName = "publisher_name"
    }
}

extension Publisher {
    static let editionPublishers = hasMany(EditionPublisher.self)
    static let editions = hasMany(Edition.self, through: editionPublishers, using: EditionPublisher.edition)
}

