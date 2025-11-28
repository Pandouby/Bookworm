//
//  Genre.swift
//  Bookworm
//
//  Created by Silvan Dubach on 28.10.2024.
//
import GRDB

enum Genre: String, Codable, CaseIterable, Identifiable {
    case nonClassifiable = "Non-Classifiable"
    case architecture = "Architecture"
    case art = "Art"
    case biographyAutobiography = "Biography & Autobiography"
    case businessEconomics = "Business & Economics"
    case comics = "Comics"
    case computers = "Computers"
    case cooking = "Cooking"
    case craftsHobbies = "Crafts & Hobbies"
    case design = "Design"
    case drama = "Drama"
    case education = "Education"
    case fiction = "Fiction"
    case nonfiction = "Nonfiction"
    case gamesActivities = "Games & Activities"
    case healthFitness = "Health & Fitness"
    case history = "History"
    case humor = "Humor"
    case juvenile = "Juvenile"
    case languageArtsDisciplines = "Language Arts & Disciplines"
    case law = "Law"
    case literaryCriticism = "Literary Criticism"
    case mathematics = "Mathematics"
    case medical = "Medical"
    case performingArts = "Performing Arts"
    case music = "Music"
    case nature = "Nature"
    case philosophy = "Philosophy"
    case photography = "Photography"
    case poetry = "Poetry"
    case politicalScience = "Political Science"
    case psychology = "Psychology"
    case religion = "Religion"
    case science = "Science"
    case selfHelp = "Self-Help"
    case socialScience = "Social Science"
    case sportsRecreation = "Sports & Recreation"
    case technologyEngineering = "Technology & Engineering"
    case travel = "Travel"
    var id: Self { self }
}

struct GenreRecord: Codable, FetchableRecord, PersistableRecord, TableRecord {
    static let databaseTableName = "Genres"
    
    var genreId: String
    var genreName: String
    
    enum Columns: String, ColumnExpression {
        case genreId = "genre_id"
        case genreName = "genre_name"
    }
    
    enum CodingKeys: String, CodingKey {
        case genreId = "genre_id"
        case genreName = "genre_name"
    }
}

extension GenreRecord {
    static let workGenres = hasMany(WorkGenre.self)
    static let works = hasMany(Work.self, through: workGenres, using: WorkGenre.work)
}
