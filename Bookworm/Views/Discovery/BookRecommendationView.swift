//
//  BookRecommendationView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 05.11.2024.
//

import Foundation
import SwiftUI
import GRDB

struct BookRecommendationView: View {
    var readBooks: [CompleteBookData]

    @State private var averageGenreRating: [Genre: Double] = [:]
    @State private var recommendations: [CompleteBookData] = []
    
    private var favoriteGenres: [Genre] = []

    init(readBooks: [CompleteBookData]) {
        self.readBooks = readBooks

        if let genreStrings = UserDefaults.standard.array(
            forKey: "FavoriteGenres") as? [String]
        {
            favoriteGenres = genreStrings.compactMap { Genre(rawValue: $0) }
        }
    }

    var body: some View {
        ZStack {
            if recommendations.isEmpty {
                emptyState
            } else {
                ForEach(recommendations.reversed()) { book in
                    RecommendationCard(
                        book: book,
                        onSwipeLeft: {
                            handleSwipe(book: book, isRight: false)
                        },
                        onSwipeRight: {
                            handleSwipe(book: book, isRight: true)
                        },
                        onSwipeUp: {
                            handleSwipeUp(book: book)
                        }
                    )
                    .zIndex(Double(recommendations.firstIndex(where: { $0.id == book.id }) ?? 0))
                }
            }
        }
        .padding()
        .onAppear {
            GenreRecommendationCalculation()
            generateMockRecommendations()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "books.vertical.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No more recommendations")
                .font(.title2)
                .bold()
            
            Button("Reset Mock Recommendations") {
                generateMockRecommendations()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func handleSwipeUp(book: CompleteBookData) {
        // Remove book from stack
        withAnimation {
            recommendations.removeAll { $0.id == book.id }
        }
        
        // Save as Done
        var bookToSave = book
        bookToSave = CompleteBookData(
            work: book.work,
            edition: book.edition,
            authors: book.authors,
            genres: book.genres,
            userDetails: UserBookDetails(
                editionKey: book.edition.editionKey,
                addedDate: Date(),
                userRating: 5.0, // Default 5 for finished books via swipe up? Or keeping it consistent with 1.0
                isFavorite: false,
                status: .done,
                startDate: Date().addingTimeInterval(-86400), // Default 1 day ago
                endDate: Date(),
                notes: "Quick added as Done"
            )
        )
        
        Task {
            do {
                try DatabaseRepository.saveCompleteBook(bookToSave)
            } catch {
                print("Error saving recommended book as done: \(error)")
            }
        }
    }

    private func handleSwipe(book: CompleteBookData, isRight: Bool) {
        // Remove book from stack
        withAnimation {
            recommendations.removeAll { $0.id == book.id }
        }
        
        if isRight {
            // Save as Want to Read
            var bookToSave = book
            bookToSave = CompleteBookData(
                work: book.work,
                edition: book.edition,
                authors: book.authors,
                genres: book.genres,
                userDetails: UserBookDetails(
                    editionKey: book.edition.editionKey,
                    addedDate: Date(),
                    userRating: 1.0,
                    isFavorite: false,
                    status: .wantToRead,
                    startDate: Date(),
                    endDate: Date(),
                    notes: "Recommended"
                )
            )
            
            Task {
                do {
                    try DatabaseRepository.saveCompleteBook(bookToSave)
                } catch {
                    print("Error saving recommended book: \(error)")
                }
            }
        }
    }

    private func GenreRecommendationCalculation() {
        let genreRatings = Dictionary(grouping: readBooks, by: { $0.genres.first ?? .nonClassifiable })
            .mapValues { booksInGenre in
                let totalRating = booksInGenre.reduce(0.0) { $0 + $1.userDetails.userRating }
                return totalRating / Double(booksInGenre.count)
            }

        let sortedGenreRatings = genreRatings.sorted { (first, second) in
            if favoriteGenres.contains(first.key) { return true }
            if favoriteGenres.contains(second.key) { return false }
            return first.value > second.value
        }

        averageGenreRating = Dictionary(uniqueKeysWithValues: sortedGenreRatings)
    }

    private func generateMockRecommendations() {
        // Mock data for frontend development
        let mockBooks = [
            CompleteBookData(
                work: Work(workKey: "M1", workTitle: "Project Hail Mary", subtitle: nil, workDescription: "Ryland Grace is the sole survivor on a desperate, last-chance mission—and if he fails, humanity and the earth itself will perish.\n\nExcept that right now, he doesn’t know that. He can’t even remember his own name, let alone the nature of his assignment or how to complete it.\n\nAll he knows is that he’s been asleep for a very, very long time. And he’s just been awakened to find himself millions of miles from home, with nothing but two corpses for company.", firstPublishYear: 2021),
                edition: Edition(editionKey: "ME1", workKey: "M1", editionTitle: "Project Hail Mary", numberOfPages: 476, isbn13: "9780593135204", cover: "https://covers.openlibrary.org/b/id/10574235-L.jpg"),
                authors: [Author(authorKey: "MA1", authorName: "Andy Weir")],
                genres: [.fiction, .science],
                userDetails: UserBookDetails(editionKey: "ME1", addedDate: Date(), userRating: 1.0, isFavorite: false, status: .wantToRead, startDate: Date(), endDate: Date(), notes: "")
            ),
            CompleteBookData(
                work: Work(workKey: "M2", workTitle: "Foundation", subtitle: nil, workDescription: "For twelve thousand years the Galactic Empire has ruled supreme. Now it is dying. But only Hari Seldon, creator of the revolutionary science of psychohistory, can see into the future—to a dark age of ignorance, barbarism, and warfare that will last thirty thousand years.\n\nTo preserve knowledge and save mankind, Seldon gathers the best minds in the Empire—both scientists and scholars—and brings them to a bleak planet at the edge of the galaxy to serve as a beacon of hope for future generations. He calls his sanctuary the Foundation.", firstPublishYear: 1951),
                edition: Edition(editionKey: "ME2", workKey: "M2", editionTitle: "Foundation", numberOfPages: 255, isbn13: "9780553293357", cover: "https://covers.openlibrary.org/b/id/10121345-L.jpg"),
                authors: [Author(authorKey: "MA2", authorName: "Isaac Asimov")],
                genres: [.fiction, .science],
                userDetails: UserBookDetails(editionKey: "ME2", addedDate: Date(), userRating: 1.0, isFavorite: false, status: .wantToRead, startDate: Date(), endDate: Date(), notes: "")
            ),
            CompleteBookData(
                work: Work(workKey: "M3", workTitle: "The Adventures of Sherlock Holmes", subtitle: nil, workDescription: "The Adventures of Sherlock Holmes is a collection of twelve short stories by Arthur Conan Doyle, first published on 14 October 1892. It contains the earliest short stories featuring the consulting detective Sherlock Holmes, which had been published in twelve monthly issues of The Strand Magazine from July 1891 to June 1892.", firstPublishYear: 1892),
                edition: Edition(editionKey: "ME3", workKey: "M3", editionTitle: "The Adventures of Sherlock Holmes", numberOfPages: 307, isbn13: "9780140620351", cover: "https://covers.openlibrary.org/b/id/12836262-L.jpg"),
                authors: [Author(authorKey: "MA3", authorName: "Arthur Conan Doyle")],
                genres: [.fiction],
                userDetails: UserBookDetails(editionKey: "ME3", addedDate: Date(), userRating: 1.0, isFavorite: false, status: .wantToRead, startDate: Date(), endDate: Date(), notes: "")
            ),
            CompleteBookData(
                work: Work(workKey: "M4", workTitle: "Pride and Prejudice", subtitle: nil, workDescription: "Since its immediate success in 1813, Pride and Prejudice has remained one of the most popular novels in the English language. Jane Austen called this brilliant work \"her own darling child\" and its vivacious heroine, Elizabeth Bennet, \"as delightful a creature as ever appeared in print.\"\n\nThe romantic clash between the opinionated Elizabeth and her proud beau, Mr. Darcy, is a splendid performance of civilized sparring.", firstPublishYear: 1813),
                edition: Edition(editionKey: "ME4", workKey: "M4", editionTitle: "Pride and Prejudice", numberOfPages: 432, isbn13: "9780141439518", cover: "https://covers.openlibrary.org/b/id/12818817-L.jpg"),
                authors: [Author(authorKey: "MA4", authorName: "Jane Austen")],
                genres: [.fiction],
                userDetails: UserBookDetails(editionKey: "ME4", addedDate: Date(), userRating: 1.0, isFavorite: false, status: .wantToRead, startDate: Date(), endDate: Date(), notes: "")
            )
        ]
        
        recommendations = mockBooks
    }
}

private func RecommendationSearch() {

}

#Preview {
    let dbQueue = AppDatabase.preview()
    DatabaseRepository.dbQueue = dbQueue
    
    let books = try! dbQueue.read { db in
        try DatabaseRepository.queryAllUserBookDetails(db: db)
    }

    return BookRecommendationView(readBooks: books)
        .databaseContext(.readWrite { dbQueue })
}
