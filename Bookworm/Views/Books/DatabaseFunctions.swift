//
//  DatabaseFunctions.swift
//  Bookworm
//
//  Created by Silvan Dubach on 05.12.2025.
//
import SwiftUI

@MainActor
func saveFullSearchResultToDB(book: FullSearchResult, status: Status) async {
    do {
        var work = Work(
            workKey: book.work.workKey,
            workTitle: book.work.workTitle,
            subtitle: nil,
            workDescription: book.work.description,
            firstPublishYear: book.work.firstPublishYear
        )
        try DatabaseRepository.save(&work)
        
        guard let editionData = book.edition else {
            print("Edition missing, cannot save")
            return
        }
        
        var edition = Edition(
            editionKey: editionData.key,
            workKey: book.work.workKey,
            editionTitle: editionData.title,
            editionDescription: book.work.description,
            numberOfPages: editionData.number_of_pages,
            isbn13: editionData.isbn_13?.first,
            isbn10: editionData.isbn_10?.first,
            publishDate: editionData.publish_date,
            cover: editionData.covers?.first != nil
            ? "https://covers.openlibrary.org/b/id/\(editionData.covers!.first!)-L.jpg"
            : nil
        )
        
        try DatabaseRepository.save(&edition)
        
        
        guard let authorData = book.authors?.first else { return }
        var author = Author(
            authorKey: authorData.authorKey,
            authorName: authorData.authorName,
            birthDate: authorData.birthDate,
            deathDate: authorData.deathDate,
            wikipedia: authorData.wikipedia
        )
        try DatabaseRepository.save(&author)
        try DatabaseRepository.addAuthor(key: author.authorKey, toWork: work.workKey)
        
        var userBook = UserBookDetails(
            editionKey: book.edition?.key ?? "",
            addedDate: Date(),
            userRating: 2.5,
            status: status,
            startDate: Date(),
            endDate: Date(),
            notes: ""
        )
        try DatabaseRepository.save(&userBook)
        
        if let genreKey = book.genre?.rawValue {
            var genreRecord = GenreRecord(genreId: genreKey, genreName: genreKey)
            try DatabaseRepository.save(&genreRecord)
            try DatabaseRepository.addGenre(key: genreKey, toWork: work.workKey)
        }
        
    } catch {
        print("Error saving book: \(error)")
    }
    }

func addEmptyBook() {
    @Environment(\.dismiss) var dismiss
    
    print("Adding empty book...")
    let bookId = "/works/" + UUID().uuidString
    var work = Work(workKey: bookId, workTitle: "New Book", subtitle: nil, workDescription: nil, firstPublishYear: nil)
    let editionKey = UUID().uuidString
    var edition = Edition(editionKey: editionKey, workKey: bookId, physicalFormat: nil, editionTitle: "New Book", editionDescription: nil, numberOfPages: 0, isbn13: nil, isbn10: nil, publishDate: nil, oclcNumber: nil, revision: nil, cover: nil)
    var userBook = UserBookDetails(editionKey: editionKey, addedDate: Date(), userRating: 2.5, status: .toDo, startDate: Date(), endDate: Date(), notes: "")
    
    Task {
        do {
            try DatabaseRepository.save(&work)
            try DatabaseRepository.save(&edition)
            try DatabaseRepository.save(&userBook)
        } catch {
            print("Error saving empty book: \(error)")
        }
    }
    dismiss()
}
