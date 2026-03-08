import GRDB
import Foundation

struct AppDatabase {
    static let shared = AppDatabase()
    
    let dbQueue: DatabaseQueue
    
    init() {
        let path = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("app.sqlite")
            .path
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path)
        
        dbQueue = try! DatabaseQueue(path: path)
        
        // Ensure the repository is using the correct queue before any migrations or checks
        DatabaseRepository.dbQueue = dbQueue
        
        try! migrator.migrate(dbQueue)
        
        #if DEBUG
        // Populate with mock data if the database is empty to facilitate testing in the simulator.
        try? populateIfEmpty()
        #endif
    }
    
    private func populateIfEmpty() throws {
        // Use a write transaction to both check and populate
        try dbQueue.write { db in
            let count = try UserBookDetails.fetchCount(db)
            if count == 0 {
                try AppDatabase.createPreviewData(in: db)
            }
        }
    }
    
    var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        #if DEBUG
        // Debuging only delete After
        migrator.eraseDatabaseOnSchemaChange = true
        #endif
        
        migrator.registerMigration("createLanguages") { db in
            try db.create(table: "Languages") { t in
                t.column("language_id", .text).primaryKey()
                t.column("print_name", .text).notNull()
                t.column("inverted_name", .text)
            }
        }
        
        migrator.registerMigration("createAuthors") { db in
            try db.create(table: "Authors") { t in
                t.column("author_key", .text).primaryKey()
                t.column("author_name", .text).notNull()
                t.column("birth_date", .text)
                t.column("death_date", .text)
                t.column("wikipedia", .text)
            }
        }
        
        migrator.registerMigration("createWorks") { db in
            try db.create(table: "Works") { t in
                t.column("work_key", .text).primaryKey()
                t.column("work_title", .text).notNull()
                t.column("subtitle", .text)
                t.column("work_description", .text)
                t.column("first_publish_year", .integer)
                t.column("avg_rating", .real)
                t.column("rating_count", .integer)
            }
        }

        migrator.registerMigration("createPublishers") { db in
            try db.create(table: "Publishers") { t in
                t.column("publisher_id", .text).primaryKey()
                t.column("publisher_name", .text).notNull()
            }
        }
        
        migrator.registerMigration("createGenres") { db in
            try db.create(table: "Genres") { t in
                t.column("genre_id", .text).primaryKey()
                t.column("genre_name", .text).notNull()
            }
        }
        
        migrator.registerMigration("createEditions") { db in
            try db.create(table: "Editions") { t in
                t.column("edition_key", .text).primaryKey()
                t.column("work_key", .text)
                    .indexed()
                    .references("Works", onDelete: .cascade)
                t.column("physical_format", .text)
                t.column("edition_title", .text)
                t.column("edition_description", .text)
                t.column("number_of_pages", .integer)
                t.column("isbn_13", .text)
                t.column("isbn_10", .text)
                t.column("publish_date", .text)
                t.column("oclc_number", .text)
                t.column("revision", .integer)
                t.column("cover", .text)
            }
        }
        
        let statusValues = Status.allCases.map { "'\($0.rawValue)'" }.joined(separator: ", ")
        
        migrator.registerMigration("createUserBookDetails") { db in
            try db.create(table: "UserBookDetails") { t in
                t.column("edition_key", .text).primaryKey()
                    .references("Editions", onDelete: .cascade)
                t.column("added_date", .text)
                t.column("user_rating", .real)
                t.column("favorite", .boolean)
                    .defaults(to: false)
                t.column("status", .text)
                t.column("start_date", .text)
                t.column("end_date", .text)
                t.column("notes", .text)
                
                // Auto-generated CHECK constraint
                t.check(sql: "user_rating >= 1 AND user_rating <= 5")
                t.check(sql: "status IN (\(statusValues))")
            }
        }
        
        migrator.registerMigration("createWorksLanguages") { db in
            try db.create(table: "works_languages") { t in
                t.column("work_key", .text)
                    .references("Works", onDelete: .cascade)
                t.column("language_id", .text)
                    .references("Languages", onDelete: .cascade)
                t.primaryKey(["work_key", "language_id"])
            }
        }
        
        migrator.registerMigration("createEditionsLanguages") { db in
            try db.create(table: "editions_languages") { t in
                t.column("edition_key", .text)
                    .references("Editions", onDelete: .cascade)
                t.column("language_id", .text)
                    .references("Languages", onDelete: .cascade)
                t.primaryKey(["edition_key", "language_id"])
            }
        }
        
        migrator.registerMigration("createAuthorsWorks") { db in
            try db.create(table: "Authors_Works") { t in
                t.column("author_key", .text)
                    .references("Authors", onDelete: .cascade)
                t.column("work_key", .text)
                    .references("Works", onDelete: .cascade)
                t.primaryKey(["author_key", "work_key"])
            }
        }
        
        migrator.registerMigration("createEditionsPublishers") { db in
            try db.create(table: "editions_publishers") { t in
                t.column("edition_key", .text)
                    .references("Editions", onDelete: .cascade)
                t.column("publisher_id", .text)
                    .references("Publishers", onDelete: .cascade)
                t.primaryKey(["edition_key", "publisher_id"])
            }
        }
        
        migrator.registerMigration("createWorksGenres") { db in
            try db.create(table: "works_genres") { t in
                t.column("work_key", .text)
                    .references("Works", onDelete: .cascade)
                t.column("genre_id", .text)
                    .references("Genres", onDelete: .cascade)
                t.primaryKey(["work_key", "genre_id"])
            }
        }
        
        migrator.registerMigration("createRatings") { db in
            try db.create(table: "Ratings") { t in
                t.column("rating_id", .integer)
                t.column("work_key", .text)
                    .notNull()
                    .indexed()
                    .references("Works", onDelete: .cascade)
                t.column("rating", .integer).notNull()
                t.column("rating_date", .text).notNull()
                
                // rating 1–5 constraint
                t.check(sql: "rating >= 1 AND rating <= 5")
                
                // Composite primary key
                t.primaryKey(["rating_id", "work_key"])
            }
        }
        
        // Indexes
        migrator.registerMigration("createIndexes") { db in
            try db.create(index: "idx_work_title", on: "Works", columns: ["work_title"])
            try db.create(index: "idx_author_name", on: "Authors", columns: ["author_name"])
            try db.create(index: "idx_edition_work", on: "Editions", columns: ["work_key"])
            try db.create(index: "idx_rating_work", on: "Ratings", columns: ["work_key"])
            try db.create(index: "idx_rating_date", on: "Ratings", columns: ["rating_date"])
        }
        
        return migrator
    }
    
    // MARK: - Preview
    
    /// Creates a preview `DatabaseQueue` for SwiftUI previews.
    static func preview() -> DatabaseQueue {
        let config = Configuration()
        let dbQueue = try! DatabaseQueue(path: ":memory:", configuration: config)
        
        let appDatabase = AppDatabase.shared
        try! appDatabase.migrator.migrate(dbQueue)
        
        // Populate with sample data
        try! dbQueue.write { db in
            try createPreviewData(in: db)
        }
        
        return dbQueue
    }
    
    /// Populates the database with sample data.
    private static func createPreviewData(in db: Database) throws {
        let calendar = Calendar.current
        let today = Date()
        
        func date(_ daysAgo: Int) -> Date {
            calendar.date(byAdding: .day, value: -daysAgo, to: today)!
        }

        let sampleBooks = [
            CompleteBookData(
                work: Work(workKey: "W1", workTitle: "The Hobbit", subtitle: nil, workDescription: "A fantasy novel.", firstPublishYear: 1937),
                edition: Edition(editionKey: "E1", workKey: "W1", editionTitle: "The Hobbit", numberOfPages: 310, isbn13: "978-0-395-07122-1", cover: "https://covers.openlibrary.org/b/id/12818862-L.jpg"),
                authors: [Author(authorKey: "A1", authorName: "J.R.R. Tolkien")],
                genres: [.fiction, .juvenile],
                userDetails: UserBookDetails(editionKey: "E1", addedDate: date(40), userRating: 5, isFavorite: true, status: .done, startDate: date(40), endDate: date(30), notes: "A classic!")
            ),
            CompleteBookData(
                work: Work(workKey: "W2", workTitle: "Dune", subtitle: nil, workDescription: "A science fiction novel.", firstPublishYear: 1965),
                edition: Edition(editionKey: "E2", workKey: "W2", editionTitle: "Dune", numberOfPages: 412, isbn13: "978-0-441-01359-3", cover: "https://covers.openlibrary.org/b/id/10121345-L.jpg"),
                authors: [Author(authorKey: "A2", authorName: "Frank Herbert")],
                genres: [.fiction, .science],
                userDetails: UserBookDetails(editionKey: "E2", addedDate: date(25), userRating: 4, isFavorite: false, status: .done, startDate: date(25), endDate: date(15), notes: "Must read soon.")
            ),
            CompleteBookData(
                work: Work(workKey: "W3", workTitle: "The Great Gatsby", subtitle: nil, workDescription: "A classic American novel.", firstPublishYear: 1925),
                edition: Edition(editionKey: "E3", workKey: "W3", editionTitle: "The Great Gatsby", numberOfPages: 180, isbn13: "978-0-7432-7356-5", cover: "https://covers.openlibrary.org/b/id/12818817-L.jpg"),
                authors: [Author(authorKey: "A3", authorName: "F. Scott Fitzgerald")],
                genres: [.fiction],
                userDetails: UserBookDetails(editionKey: "E3", addedDate: date(60), userRating: 4.5, isFavorite: true, status: .done, startDate: date(60), endDate: date(55), notes: "Great read.")
            ),
            CompleteBookData(
                work: Work(workKey: "W4", workTitle: "The Shining", subtitle: nil, workDescription: "A horror novel.", firstPublishYear: 1977),
                edition: Edition(editionKey: "E4", workKey: "W4", editionTitle: "The Shining", numberOfPages: 447, isbn13: "978-0-307-74365-7", cover: "https://covers.openlibrary.org/b/id/12853785-L.jpg"),
                authors: [Author(authorKey: "A4", authorName: "Stephen King")],
                genres: [.fiction],
                userDetails: UserBookDetails(editionKey: "E4", addedDate: date(5), userRating: 3.5, isFavorite: false, status: .inProgress, startDate: date(5), endDate: today, notes: "Plan to read.")
            ),
            CompleteBookData(
                work: Work(workKey: "W5", workTitle: "1984", subtitle: nil, workDescription: "A dystopian social science fiction novel.", firstPublishYear: 1949),
                edition: Edition(editionKey: "E5", workKey: "W5", editionTitle: "1984", numberOfPages: 328, isbn13: "978-0-452-28423-4", cover: "https://covers.openlibrary.org/b/id/12818862-L.jpg"),
                authors: [Author(authorKey: "A5", authorName: "George Orwell")],
                genres: [.fiction, .politicalScience],
                userDetails: UserBookDetails(editionKey: "E5", addedDate: date(12), userRating: 5, isFavorite: true, status: .done, startDate: date(12), endDate: date(2), notes: "Powerful book.")
            ),
            CompleteBookData(
                work: Work(workKey: "W6", workTitle: "To Kill a Mockingbird", subtitle: nil, workDescription: "A novel about racial injustice.", firstPublishYear: 1960),
                edition: Edition(editionKey: "E6", workKey: "W6", editionTitle: "To Kill a Mockingbird", numberOfPages: 281, isbn13: "978-0-06-112008-4", cover: "https://covers.openlibrary.org/b/id/8267232-L.jpg"),
                authors: [Author(authorKey: "A6", authorName: "Harper Lee")],
                genres: [.fiction, .law, .socialScience],
                userDetails: UserBookDetails(editionKey: "E6", addedDate: date(100), userRating: 5, isFavorite: true, status: .done, startDate: date(100), endDate: date(90), notes: "Absolute masterpiece.")
            ),
            CompleteBookData(
                work: Work(workKey: "W7", workTitle: "Brave New World", subtitle: nil, workDescription: "A dystopian novel.", firstPublishYear: 1932),
                edition: Edition(editionKey: "E7", workKey: "W7", editionTitle: "Brave New World", numberOfPages: 268, isbn13: "978-0-06-085052-4", cover: "https://covers.openlibrary.org/b/id/12818862-L.jpg"),
                authors: [Author(authorKey: "A7", authorName: "Aldous Huxley")],
                genres: [.fiction, .science, .politicalScience, .socialScience],
                userDetails: UserBookDetails(editionKey: "E7", addedDate: date(15), userRating: 4, isFavorite: false, status: .done, startDate: date(15), endDate: date(8), notes: "Interesting perspective.")
            ),
            CompleteBookData(
                work: Work(workKey: "W11", workTitle: "Project Hail Mary", subtitle: nil, workDescription: "Survival story.", firstPublishYear: 2021),
                edition: Edition(editionKey: "E11", workKey: "W11", editionTitle: "Project Hail Mary", numberOfPages: 476, isbn13: "9780593135204", cover: "https://covers.openlibrary.org/b/id/10574235-L.jpg"),
                authors: [Author(authorKey: "A11", authorName: "Andy Weir")],
                genres: [.fiction, .science],
                userDetails: UserBookDetails(editionKey: "E11", addedDate: date(8), userRating: 5, isFavorite: true, status: .done, startDate: date(8), endDate: today, notes: "Amazing science!")
            ),
            CompleteBookData(
                work: Work(workKey: "W12", workTitle: "Atomic Habits", subtitle: nil, workDescription: "Self-help book.", firstPublishYear: 2018),
                edition: Edition(editionKey: "E12", workKey: "W12", editionTitle: "Atomic Habits", numberOfPages: 320, isbn13: "9780735211292", cover: "https://covers.openlibrary.org/b/id/12853785-L.jpg"),
                authors: [Author(authorKey: "A12", authorName: "James Clear")],
                genres: [.selfHelp, .psychology],
                userDetails: UserBookDetails(editionKey: "E12", addedDate: date(20), userRating: 4.5, isFavorite: false, status: .done, startDate: date(20), endDate: date(18), notes: "Quick but impactful.")
            ),
            CompleteBookData(
                work: Work(workKey: "W13", workTitle: "Deep Work", subtitle: nil, workDescription: "Focus rules.", firstPublishYear: 2016),
                edition: Edition(editionKey: "E13", workKey: "W13", editionTitle: "Deep Work", numberOfPages: 304, isbn13: "9781455586691", cover: "https://covers.openlibrary.org/b/id/8231991-L.jpg"),
                authors: [Author(authorKey: "A13", authorName: "Cal Newport")],
                genres: [.businessEconomics, .psychology],
                userDetails: UserBookDetails(editionKey: "E13", addedDate: date(35), userRating: 4, isFavorite: false, status: .done, startDate: date(35), endDate: date(28), notes: "Necessary for today.")
            ),
            CompleteBookData(
                work: Work(workKey: "W8", workTitle: "The Catcher in the Rye", subtitle: nil, workDescription: "A story of teenage rebellion.", firstPublishYear: 1951),
                edition: Edition(editionKey: "E8", workKey: "W8", editionTitle: "The Catcher in the Rye", numberOfPages: 234, isbn13: "978-0-316-76948-8", cover: "https://covers.openlibrary.org/b/id/8231991-L.jpg"),
                authors: [Author(authorKey: "A8", authorName: "J.D. Salinger")],
                genres: [.fiction, .juvenile, .psychology],
                userDetails: UserBookDetails(editionKey: "E8", addedDate: date(2), userRating: 3.5, isFavorite: false, status: .toDo, startDate: today, endDate: today, notes: "Classic coming-of-age.")
            ),
            CompleteBookData(
                work: Work(workKey: "W9", workTitle: "Harry Potter and the Philosopher's Stone", subtitle: nil, workDescription: "The first book in the Harry Potter series.", firstPublishYear: 1997),
                edition: Edition(editionKey: "E9", workKey: "W9", editionTitle: "Harry Potter and the Philosopher's Stone", numberOfPages: 223, isbn13: "978-0-7475-3269-9", cover: "https://covers.openlibrary.org/b/id/10521270-L.jpg"),
                authors: [Author(authorKey: "A9", authorName: "J.K. Rowling")],
                genres: [.fiction, .juvenile],
                userDetails: UserBookDetails(editionKey: "E9", addedDate: date(365), userRating: 5, isFavorite: true, status: .done, startDate: date(365), endDate: date(358), notes: "The magic starts here.")
            ),
            CompleteBookData(
                work: Work(workKey: "W10", workTitle: "A Brief History of Time", subtitle: nil, workDescription: "A popular-science book.", firstPublishYear: 1988),
                edition: Edition(editionKey: "E10", workKey: "W10", editionTitle: "A Brief History of Time", numberOfPages: 212, isbn13: "978-0-553-38016-3", cover: "https://covers.openlibrary.org/b/id/12853785-L.jpg"),
                authors: [Author(authorKey: "A10", authorName: "Stephen Hawking")],
                genres: [.science, .history, .philosophy],
                userDetails: UserBookDetails(editionKey: "E10", addedDate: today, userRating: 4.5, isFavorite: false, status: .wantToRead, startDate: today, endDate: today, notes: "Excited to learn.")
            )
        ]
        
        for book in sampleBooks {
            try DatabaseRepository.saveCompleteBook(book, in: db)
        }
    }
}
