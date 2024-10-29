//
//  Book.swift
//  Bookworm
//
//  Created by Silvan Dubach on 09.10.2024.
//

import Foundation
import SwiftData

enum BookDestination: Hashable {
    case BookSearchView(Book)
    case OwnedBooksView(Book)
}

@Model
class Book {
    var isbn: String
    var title: String
    var author: String
    var pageCount: Int
    var genre: Genre
    var bookDescription: String = ""
    var publishedDate: String?
    var publisher: String?
    var imageLink: String?
    
    var dateAdded: Date = Date()
    var rating: Double = 2.5
    var status: Status = Status.toDo
    var statusOrder: Int = Status.toDo.sortOrder
    var startedDate: Date = Date()
    var finishedDate: Date = Date()
    var notes: String = ""
    
    init(
        isbn: String, title: String, author: String, pages: Int, genre: Genre,
        rating: Double = 2.5, started: Date = Date(), finished: Date = Date(), imageLink: String? = "",
        notes: String = "", publishedDate: String? = nil, publisher: String? = nil,
        bookDescription: String = "", status: Status? = Status.toDo
    ) {
        self.isbn = isbn
        self.title = title
        self.author = author
        self.pageCount = pages
        self.genre = genre
        self.publishedDate = publishedDate
        self.publisher = publisher
        self.bookDescription = bookDescription
        self.imageLink = imageLink
        self.status = status ?? Status.toDo
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
    let description: String?
    let imageLinks: ImageLink?
}

struct BookIdentifier: Codable {
    let type: String
    let identifier: String
}

struct ImageLink: Codable {
    let thumbnail: String
}
