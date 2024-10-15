//
//  Book.swift
//  Bookworm
//
//  Created by Silvan Dubach on 09.10.2024.
//

import Foundation
import SwiftData

enum Genre: String, Codable {
    case physics,
    philosophy,
    fiction,
    utopia,
    novella,
    novel,
    comedy,
    compsci,
    selfhelp,
    tale,
    biography,
    nonFiction,
    scienceFiction,
    satire,
    distopia
}

enum Status: String, Codable {
    case toDo,
    onPause,
    inProgress,
    done
}

@Model
final class Book {
    var title: String
    var author: String
    var pages: Int
    var genre: Genre
    
    var rating: Int?
    var status: Status
    var started: Date?
    var finished: Date?
    var notes: String?
    
    init(title: String, author: String, pages: Int, genre: Genre) {
        self.title = title
        self.author = author
        self.pages = pages
        self.genre = genre
        self.status = Status.toDo
    }
}
