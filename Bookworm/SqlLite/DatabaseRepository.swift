import GRDB
import Foundation

struct DatabaseRepository {
    private static var dbQueue: DatabaseQueue = AppDatabase.shared.dbQueue

    // MARK: - Generic CRUD

    /// Saves (inserts or updates) a record to the database.
    static func save<T: MutablePersistableRecord>(_ record: inout T) throws {
        try dbQueue.write { db in
            try record.save(db)
        }
    }

    /// Deletes a record from the database.
    static func delete<T: PersistableRecord>(_ record: T) throws {
        try dbQueue.write { db in
            _ = try record.delete(db)
        }
    }
    
    /// Deletes a record by its primary key.
    static func delete<T: TableRecord>(type: T.Type, key: any DatabaseValueConvertible) throws {
        try dbQueue.write { db in
            _ = try T.deleteOne(db, key: key)
        }
    }
    
    /// Deletes all records from a table.
    static func deleteAll<T: TableRecord>(type: T.Type) throws {
        try dbQueue.write { db in
            _ = try T.deleteAll(db)
        }
    }
    
    /// Delete a CompleteBookData and any related records that are no longer referenced
    static func deleteCompleteBook(_ completeBook: CompleteBookData) throws {
        try dbQueue.write { db in
            // 1. Delete the UserBookDetails record.
            try UserBookDetails.deleteOne(db, key: completeBook.userDetails.editionKey)
            
            // 2. Check if the Edition is now an orphan.
            let editionKey = completeBook.edition.editionKey
            let otherUserBooksForEditionRequest = UserBookDetails.filter(UserBookDetails.Columns.editionKey == editionKey)
            
            if try otherUserBooksForEditionRequest.fetchCount(db) == 0 {
                // This was the last user book for this edition. It's safe to delete the edition.
                try Edition.deleteOne(db, key: editionKey)
                
                // 3. Check if the Work is now an orphan.
                let workKey = completeBook.work.workKey
                let otherEditionsForWorkRequest = Edition.filter(Edition.Columns.workKey == workKey)
                
                if try otherEditionsForWorkRequest.fetchCount(db) == 0 {
                    // This was the last edition for this work. It's safe to delete the work
                    // and its many-to-many relationships.
                    try Work.deleteOne(db, key: workKey)
                    
                    // Delete associations from AuthorWork
                    try AuthorWork.filter(AuthorWork.Columns.workKey == workKey).deleteAll(db)
                    
                    // Delete associations from WorkGenre
                    try WorkGenre.filter(WorkGenre.Columns.workKey == workKey).deleteAll(db)
                    
                    // 4. Check if any Authors are now orphans.
                    for author in completeBook.authors {
                        let authorKey = author.authorKey
                        let otherWorksForAuthorRequest = AuthorWork.filter(AuthorWork.Columns.authorKey == authorKey)
                        if try otherWorksForAuthorRequest.fetchCount(db) == 0 {
                            try Author.deleteOne(db, key: authorKey)
                        }
                    }
                    
                    // 5. Check if any Genres are now orphans.
                    for genre in completeBook.genres {
                        let genreId = genre.rawValue
                        let otherWorksForGenreRequest = WorkGenre.filter(WorkGenre.Columns.genreId == genreId)
                        if try otherWorksForGenreRequest.fetchCount(db) == 0 {
                            try GenreRecord.deleteOne(db, key: genreId)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Read Operations

    /// Fetches a single record by its primary key.
    static func fetch<T: FetchableRecord & TableRecord>(type: T.Type, key: any DatabaseValueConvertible) throws -> T? {
        try dbQueue.read { db in
            try T.fetchOne(db, key: key)
        }
    }
    
    /// Fetches all records from a table.
    static func fetchAll<T: FetchableRecord & TableRecord>(type: T.Type) throws -> [T] {
        try dbQueue.read { db in
            try T.fetchAll(db)
        }
    }

    /// Fetches a single work with all its related authors, genres, languages, and editions.
    static func fetchWorkWithDetails(key: String) throws -> (Work, [Author], [GenreRecord], [Language], [Edition])? {
        try dbQueue.read { db in
            let request = Work.filter(key: key)
                .including(all: Work.authors)
                .including(all: Work.genres)
                .including(all: Work.languages)
                .including(all: Work.editions)

            if let row = try Row.fetchOne(db, request) {
                let work: Work = row[Work.databaseTableName]
                let authors: [Author] = row[Author.databaseTableName]
                let genres: [GenreRecord] = row[GenreRecord.databaseTableName]
                let languages: [Language] = row[Language.databaseTableName]
                let editions: [Edition] = row[Edition.databaseTableName]
                return (work, authors, genres, languages, editions)
            }
            return nil
        }
    }

    /// Fetches a single edition with its related work, publishers, and languages.
    static func fetchEditionWithDetails(key: String) throws -> (Edition, Work, [Publisher], [Language])? {
        try dbQueue.read { db in
            let request = Edition.filter(key: key)
                .including(required: Edition.work)
                .including(all: Edition.publishers)
                .including(all: Edition.languages)

            if let row = try Row.fetchOne(db, request) {
                let edition: Edition = row[Edition.databaseTableName]
                let work: Work = row[Work.databaseTableName]
                let publishers: [Publisher] = row[Publisher.databaseTableName]
                let languages: [Language] = row[Language.databaseTableName]
                return (edition, work, publishers, languages)
            }
            return nil
        }
    }

    /// Fetches all books in the user's library with all their details.
    static func fetchAllUserBookDetails() throws -> [CompleteBookData] {
        try dbQueue.read { db in
            
            let request = UserBookDetails
                .including(required: UserBookDetails.edition
                    .including(required: Edition.work
                        .including(all: Work.authors)
                        .including(all: Work.genres)
                    )
                )
            
            let rows = try Row.fetchAll(db, request)
            
            return try rows.map { row in
                let userDetails: UserBookDetails = try UserBookDetails(row: row)
                let edition: Edition = row["Edition"]
                let work: Work = row["Work"]
                let authors: [Author] = row[Author.databaseTableName]
                let genreRecords: [GenreRecord] = row[GenreRecord.databaseTableName]
                
                let genres = genreRecords.compactMap { Genre(rawValue: $0.genreName) }
                
                return CompleteBookData(
                    work: work,
                    edition: edition,
                    authors: authors,
                    genres: genres,
                    userDetails: userDetails
                )
            }
        }
    }
    
    /// Query the all books and there details for live update
    static func queryAllUserBookDetails(db: Database) throws -> [CompleteBookData] {
        let request = UserBookDetails
            .including(required: UserBookDetails.edition
                .including(required: Edition.work
                    .including(all: Work.authors)
                    .including(all: Work.genres)
                )
            )
        
        let rows = try Row.fetchAll(db, request)
        
        return try rows.map { row in
            let userDetails: UserBookDetails = try UserBookDetails(row: row)
            let edition: Edition = row["Edition"]
            let work: Work = row["Work"]
            let authors: [Author] = row[Author.databaseTableName]
            let genreRecords: [GenreRecord] = row[GenreRecord.databaseTableName]
            
            let genres = genreRecords.compactMap { Genre(rawValue: $0.genreName) }
            
            return CompleteBookData(
                work: work,
                edition: edition,
                authors: authors,
                genres: genres,
                userDetails: userDetails
            )
        }
    }
    
    /// Save a CompleteBookData object to the database
    static func saveCompleteBook(_ completeBook: CompleteBookData) throws {
        try dbQueue.write { db in
            // Save the work
            try completeBook.work.save(db)
            
            // Save all authors
            for author in completeBook.authors {
                try author.save(db)
                
                // Link author to work
                try AuthorWork(authorKey: author.authorKey, workKey: completeBook.work.workKey).save(db)
            }
            
            // Save all genres
            for genre in completeBook.genres {
                let genreRecord = GenreRecord(genreId: genre.rawValue, genreName: genre.rawValue)
                try genreRecord.save(db)
                
                // Link genre to work
                try WorkGenre(workKey: completeBook.work.workKey, genreId: genre.rawValue).save(db)
            }
            
            // Save the edition
            try completeBook.edition.save(db)
            
            // Save UserBookDetails
            try completeBook.userDetails.save(db)
            
            // Optional: handle edition publishers, languages, etc. here if needed
        }
    }

    // MARK: - Search
    
    static func searchWorks(title: String) throws -> [Work] {
        try dbQueue.read { db in
            try Work.filter(Work.Columns.workTitle.like("%\(title)%")).fetchAll(db)
        }
    }
    
    static func searchAuthors(name: String) throws -> [Author] {
        try dbQueue.read { db in
            try Author.filter(Author.Columns.authorName.like("%\(name)%")).fetchAll(db)
        }
    }

    // MARK: - Many-to-Many Relationship Management

    private static func link(pivot: inout some PersistableRecord) throws {
        try dbQueue.write { db in
            try pivot.save(db)
        }
    }
    
    static func addAuthor(key authorKey: String, toWork workKey: String) throws {
        var pivot = AuthorWork(authorKey: authorKey, workKey: workKey)
        try link(pivot: &pivot)
    }
    
    static func addGenre(key genreKey: String, toWork workKey: String) throws {
        var pivot = WorkGenre(workKey: workKey, genreId: genreKey)
        try link(pivot: &pivot)
    }
    
    static func addLanguage(key languageKey: String, toWork workKey: String) throws {
        var pivot = WorkLanguage(workKey: workKey, languageId: languageKey)
        try link(pivot: &pivot)
    }
    
    static func addPublisher(key publisherKey: String, toEdition editionKey: String) throws {
        var pivot = EditionPublisher(editionKey: editionKey, publisherId: publisherKey)
        try link(pivot: &pivot)
    }
    
    static func addLanguage(key languageKey: String, toEdition editionKey: String) throws {
        var pivot = EditionLanguage(editionKey: editionKey, languageId: languageKey)
        try link(pivot: &pivot)
    }
    
    // You can add remove functions similarly using .delete() on the pivot table records.
}
