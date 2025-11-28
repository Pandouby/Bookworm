import GRDB
import GRDBQuery

struct Edition: Codable, FetchableRecord, PersistableRecord, TableRecord {
    static let databaseTableName = "Editions"
    
    var editionKey: String
    var workKey: String?
    var physicalFormat: String?
    var editionTitle: String?
    var editionDescription: String?
    var numberOfPages: Int?
    var isbn13: String?
    var isbn10: String?
    var publishDate: String?
    var oclcNumber: String?
    var revision: Int?
    var cover: String?
    
    enum Columns: String, ColumnExpression {
        case editionKey = "edition_key"
        case workKey = "work_key"
        case physicalFormat = "physical_format"
        case editionTitle = "edition_title"
        case editionDescription = "edition_description"
        case numberOfPages = "number_of_pages"
        case isbn13 = "isbn_13"
        case isbn10 = "isbn_10"
        case publishDate = "publish_date"
        case oclcNumber = "oclc_number"
        case revision
        case cover
    }
    
    enum CodingKeys: String, CodingKey {
        case editionKey = "edition_key"
        case workKey = "work_key"
        case physicalFormat = "physical_format"
        case editionTitle = "edition_title"
        case editionDescription = "edition_description"
        case numberOfPages = "number_of_pages"
        case isbn13 = "isbn_13"
        case isbn10 = "isbn_10"
        case publishDate = "publish_date"
        case oclcNumber = "oclc_number"
        case revision
        case cover
    }
}

extension Edition {
    static let work = belongsTo(Work.self)
    static let userBook = hasOne(UserBookDetails.self)
    static let editionLanguages = hasMany(EditionLanguage.self)
    static let languages = hasMany(Language.self, through: editionLanguages, using: EditionLanguage.language)
    static let editionPublishers = hasMany(EditionPublisher.self)
    static let publishers = hasMany(Publisher.self, through: editionPublishers, using: EditionPublisher.publisher)
}

struct EditionListResponse: Codable {
    let entries: [EditionResponse]
}

struct EditionResponse: Codable {
    var title: String
    var key: String
    var number_of_pages: Int?
    var isbn_13: [String]?
    var isbn_10: [String]?
    var publish_date: String?
    var languages: [LanguageResponse]?
    var covers: [Int]?
    var coverLink: String?
    var publishers: [String]?
}

extension Edition {
    /// Fetch all editions
    static func allEditions() -> QueryInterfaceRequest<Edition> {
        Edition.order(Columns.editionTitle.asc)
    }
    
    /// Fetch editions belonging to a work
    static func editions(forWorkKey key: String) -> QueryInterfaceRequest<Edition> {
        Edition.filter(Columns.workKey == key)
            .including(optional: Edition.languages)   // eager loading
            .including(optional: Edition.publishers)
            .including(optional: Edition.userBook)
    }
    
    /// Fetch a single edition by key
    static func edition(withKey key: String) -> QueryInterfaceRequest<Edition> {
        Edition.filter(Columns.editionKey == key)
            .including(optional: Edition.languages)
            .including(optional: Edition.publishers)
            .including(optional: Edition.userBook)
    }
}
