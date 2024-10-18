//
//  Book.swift
//  Bookworm
//
//  Created by Silvan Dubach on 09.10.2024.
//

import Foundation
import SwiftData

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

enum Status: String, Codable, CaseIterable, Identifiable {
    case toDo = "To Do"
    case onPause = "On Pause"
    case inProgress = "In Progress"
    case done = "Done"
    
    var sortOrder: Int {
        switch self {
        case .toDo: return 0
        case .onPause: return 1
        case .inProgress: return 2
        case .done: return 3
        }
    }
    
    var id: Self { self }
}

@Model
class Book {
    var isbn: String
    var title: String
    var author: String
    var pages: Int
    var genre: Genre
    
    var dateAdded: Date = Date()
    var publishedDate: String?
    var publisher: String?
    var statusOrder: Int = Status.toDo.sortOrder
    var rating: Double = 2.5
    var status: Status = Status.toDo
    var startedDate: Date = Date()
    var finishedDate: Date = Date()
    var notes: String = ""
    
    init(
        isbn: String, title: String, author: String, pages: Int, genre: Genre,
        rating: Double = 2.5, started: Date = Date(), finished: Date = Date(),
        notes: String = "", publishedDate: String? = nil, publisher: String? = nil
    ) {
        self.isbn = isbn
        self.title = title
        self.author = author
        self.pages = pages
        self.genre = genre
        self.publishedDate = publishedDate
        self.publisher = publisher
    }
}
struct BookResponse: Codable {
    let items: [BookItem]?
    let totalItems: Int
}

struct BookItem: Codable {
    let volumeInfo: VolumeInfo?
}

struct VolumeInfo: Codable {
    let industryIdentifiers: [BookIdentifier]?
    let title: String?
    let authors: [String]?
    let pageCount: Int?
    let categories: [String]?
    let publishedDate: String?
    let publisher: String?
}

struct BookIdentifier: Codable {
    let type: String
    let identifier: String
}
