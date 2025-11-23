import GRDB

struct Work: Codable, FetchableRecord, PersistableRecord, TableRecord {
    static let databaseTableName = "Works"
    
    var workKey: String
    var workTitle: String
    var subtitle: String?
    var workDescription: String?
    var firstPublishYear: Int?
    
    enum Columns: String, ColumnExpression {
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
