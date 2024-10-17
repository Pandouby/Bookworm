//
//  BookDetailsView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 15.10.2024.
//

import AVFoundation
import Foundation
import SwiftData
import SwiftUI

struct BookDetailsView: View {
  
    @Bindable var book: Book

    var body: some View {

        VStack {
            Form {
                Section {
                    NavigationLink(
                        destination: EditFieldView(
                            fieldName: "Title", inputValue: $book.title)
                    ) {
                        HStack {
                            Text("Title")
                            Spacer()
                            Text(book.title)
                        }
                    }

                    NavigationLink(
                        destination: EditFieldView(
                            fieldName: "Author", inputValue: $book.author)
                    ) {
                        HStack {
                            Text("Author")
                            Spacer()
                            Text(book.author)
                        }
                    }

                    Picker("Genre", selection: $book.genre) {
                        ForEach(Genre.allCases) { genre in
                            Text(genre.rawValue)
                        }
                    }
                    .pickerStyle(.navigationLink)

                    TextField("Pages", value: $book.pages, format: .number)
                        .keyboardType(.asciiCapableNumberPad)
                }

                Section {
                    Picker("Status", selection: $book.status) {
                        ForEach(Status.allCases) { status in
                            HStack {
                                Text(status.rawValue)
                                StatusIcon(status: status)
                            }
                        }
                    }
                    .pickerStyle(.menu)

                    RatingView($book.rating, maxRating: 5).padding(5)

                    DatePicker(
                        "Started",
                        selection: $book.started, displayedComponents: .date
                    ).onSubmit {
                        // Handle submission for Started
                    }

                    DatePicker(
                        "Finished",
                        selection: $book.finished, displayedComponents: .date
                    ).onSubmit {
                        // Handle submission for Finished
                    }

                    VStack(alignment: .leading) {
                        Text("Notes")
                        TextEditor(text: $book.notes)
                            .frame(height: 200)  // Set a height for better visibility
                            .padding()
                            .background(Color(UIColor.systemGray5))  // Background for TextEditor
                            .cornerRadius(10)  // Rounded corners for aesthetics
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Book.self, configurations: config)

        let excample = Book(
            isbn: "1234", title: "Test", author: "Test", pages: 123,
            genre: Genre.fiction)

        return BookDetailsView(book: excample).modelContainer(container)
    } catch {
        fatalError("Failed to create model container")
    }
}
