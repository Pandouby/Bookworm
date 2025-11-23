import GRDB

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
}

extension Edition {
    static let work = belongsTo(Work.self)
    static let userBook = hasOne(UserBooks.self)
    static let editionLanguages = hasMany(EditionLanguage.self)
    static let languages = hasMany(Language.self, through: editionLanguages, using: EditionLanguage.language)
    static let editionPublishers = hasMany(EditionPublisher.self)
    static let publishers = hasMany(Publisher.self, through: editionPublishers, using: EditionPublisher.publisher)
}

struct EditionListResponse: Codable {
    let entries: [EditionResponse]
}

struct EditionResponse: Codable {
    let title: String?
    let key: String
    let number_of_pages: Int?
    let isbn_13: [String]?
    let isbn_10: [String]?
    let publish_date: String?
    let covers: [Int]?
    let publishers: [String]?
}

