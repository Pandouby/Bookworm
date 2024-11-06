//
//  BookRecommendationView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 05.11.2024.
//

import Foundation
import SwiftUI

struct BookRecommendationView: View {
    var readBooks: [Book]

    @State private var averageGenreRating: [Genre: Double] = [:]

    private var favoriteGenres: [Genre] = []

    init(readBooks: [Book]) {
        self.readBooks = readBooks

        if let genreStrings = UserDefaults.standard.array(
            forKey: "FavoriteGenres") as? [String]
        {
            favoriteGenres = genreStrings.compactMap { Genre(rawValue: $0) }
        }

        GenreRecommendationCalculation()
    }

    var body: some View {
        VStack {
            Button(action: { print(averageGenreRating) }) {
                Text("test")
            }
        }
    }

    private func GenreRecommendationCalculation() {
        let genreRatings = Dictionary(grouping: readBooks, by: { $0.genre })
            .mapValues { booksInGenre in
                let totalRating = booksInGenre.reduce(0) { $0 + $1.rating }
                return totalRating / Double(booksInGenre.count)
            }

        let sortedGenreRatings = genreRatings.sorted { (first, second) in
            if favoriteGenres.contains(first.key) { return true }
            if favoriteGenres.contains(second.key) { return false }
            return first.value > second.value
        }

        averageGenreRating = Dictionary(
            uniqueKeysWithValues: sortedGenreRatings)
    }

}

private func RecommendationSearch() {

}

#Preview {
    let preview = Preview()
    preview.addExamples(Book.sampleBooks)

    return BookRecommendationView(readBooks: Book.sampleBooks)
        .modelContainer(preview.container)
}
