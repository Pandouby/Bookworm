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
        
        dbQueue = try! DatabaseQueue(path: path)
        try! migrator.migrate(dbQueue)
    }
    
    
    var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
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
            }
        }
        
        let statusValues = Status.allCases.map { "'\($0.rawValue)'" }.joined(separator: ", ")
        
        migrator.registerMigration("createUserBooks") { db in
            try db.create(table: "UserBooks") { t in
                t.column("edition_key", .text).primaryKey()
                    .references("Editions", onDelete: .cascade)
                t.column("user_rating", .real)
                t.column("status", .text)
                t.column("start_date", .text)
                t.column("end_date", .text)
                t.column("notes", .text)
                
                // Auto-generated CHECK constraint
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
                t.column("rating_id", .integer).primaryKey(autoincrement: true)
                t.column("work_key", .text)
                    .notNull()
                    .indexed()
                    .references("Works", onDelete: .cascade)
                t.column("rating", .integer).notNull()
                t.column("rating_date", .text).notNull()
                
                // rating 1–5 constraint
                t.check(sql: "rating >= 1 AND rating <= 5")
            }
        }
        
        // Indexes
        migrator.registerMigration("createIndexes") { db in
            try db.create(index: "idx_work_title", on: "Works", columns: ["work_title"])
            try db.create(index: "idx_author_name", on: "Authors", columns: ["author_name"])
            try db.create(index: "idx_edition_work", on: "Editions", columns: ["work_key"])
            try db.create(index: "idx_rating_edition", on: "Ratings", columns: ["edition_key"])
            try db.create(index: "idx_rating_date", on: "Ratings", columns: ["rating_date"])
        }
        
        return migrator
    }
    
}
