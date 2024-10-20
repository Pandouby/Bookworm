//
//  SearchResultDetailsView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 20.10.2024.
//

import SwiftData
import SwiftUI

struct SearchResultDetailsView: View {
    var searchResult: Book

    var body: some View {
        VStack(alignment: .leading) {
            Text(searchResult.title).font(.headline)
            Text(searchResult.author).font(.subheadline)

            Text(searchResult.bookDescription)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        let container = try ModelContainer(
            for: Book.self, configurations: config)

        let excample = Book(
            isbn: "1234", title: "Test", author: "Test", pages: 123,
            genre: Genre.fiction, bookDescription: "A test book to check if the layouting is working properly. This book has no content and is fake.")

        return SearchResultDetailsView(searchResult: excample).modelContainer(
            container)
    } catch {
        fatalError("Failed to create model container")
    }
}
