import GRDB
import GRDBQuery

struct Work: Codable, FetchableRecord, PersistableRecord, TableRecord, Identifiable {
    static let databaseTableName = "Works"
    
    var workKey: String
    var workTitle: String
    var subtitle: String?
    var workDescription: String?
    var firstPublishYear: Int?
    
    var id: String { workKey }
    
    enum Columns: String, ColumnExpression {
        case workKey = "work_key"
        case workTitle = "work_title"
        case subtitle
        case workDescription = "work_description"
        case firstPublishYear = "first_publish_year"
    }
    
    enum CodingKeys: String, CodingKey {
        case workKey = "work_key"
        case workTitle = "work_title"
        case subtitle
        case workDescription = "work_description"
        case firstPublishYear = "first_publish_year"
    }
}

extension Work {
    static let editions = hasMany(Edition.self)
    static let ratings = hasMany(Rating.self)
    
    static let authorWorks = hasMany(AuthorWork.self)
    static let authors = hasMany(Author.self, through: authorWorks, using: AuthorWork.author)
    
    static let workLanguages = hasMany(WorkLanguage.self)
    static let languages = hasMany(Language.self, through: workLanguages, using: WorkLanguage.language)
    
    static let workGenres = hasMany(WorkGenre.self)
    static let genres = hasMany(GenreRecord.self, through: workGenres, using: WorkGenre.genre)
}

extension Work {
    func copy(
        workKey: String? = nil,
        workTitle: String? = nil,
        subtitle: String? = nil,
        workDescription: String? = nil,
        firstPublishYear: Int? = nil
    ) -> Work {
        Work(
            workKey: workKey ?? self.workKey,
            workTitle: workTitle ?? self.workTitle,
            subtitle: subtitle ?? self.subtitle,
            workDescription: workDescription ?? self.workDescription,
            firstPublishYear: firstPublishYear ?? self.firstPublishYear
        )
    }
}

struct WorkResponse: Codable {
    let workKey: String
    let workTitle: String
    var description: String?
    let editionKeys: [String]?
    let authorKeys: [String]?
    let languages: [String]?
    let firstPublishYear: Int?
    let subjects: [String]?
    
    enum CodingKeys: String, CodingKey {
        case workKey = "key"
        case workTitle = "title"
        case description
        case editionKeys = "edition_key"
        case authorKeys = "author_key"
        case languages = "language"
        case firstPublishYear = "first_publish_year"
        case subjects = "subject"
    }
}

struct DetailWorkResponse: Codable {
    let workKey: String
    let workTitle: String
    let description: String?
    let authors: [AuthorWorkResponse]?
    let subjects: [String]?
    let languages: [String]?
    let firstPublishYear: Int?
    
    enum CodingKeys: String, CodingKey {
        case workKey = "key"
        case workTitle = "title"
        case description
        case authors
        case subjects
        case languages = "language"
        case firstPublishYear = "first_publish_year"
    }
}



extension Work {
    /// Fetch all works
    static func allWorks() -> QueryInterfaceRequest<Work> {
        Work.order(Columns.workTitle.asc)
    }
    
    /// Fetch a single work with full details + relations
    static func work(withKey key: String) -> QueryInterfaceRequest<Work> {
        Work
            .filter(Columns.workKey == key)
            .including(all: Work.editions
                .including(optional: Edition.publishers)
                .including(optional: Edition.languages)
                .including(optional: Edition.userBookDetail)
            )
            .including(all: Work.authors)
            .including(all: Work.languages)
            .including(all: Work.genres)
            .including(all: Work.ratings)
    }
}

struct AllWorksQuery: ValueObservationQueryable {
    static var defaultValue: [Work] { [] }
    
    func fetch(_ db: Database) throws -> [Work] {
        try Work.fetchAll(db)
    }
}

struct WorkKeyElement: Codable {
        let key: String
}
