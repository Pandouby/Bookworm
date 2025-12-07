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
import GRDBQuery
import GRDB

struct BookDetailsView: View {
    @Bindable var book: CompleteBookDataViewModel

    var body: some View {
        VStack {
            Form {
                Section {
                    NavigationLink(
                        destination: EditFieldView(
                            fieldName: "Title", inputValue: $book.workTitle)
                    ) {
                        HStack {
                            Text("Title")
                            Spacer()
                            Text(book.workTitle)
                        }
                    }
                    .onChange(of: book.workTitle) {
                        saveData(book: book)
                    }

                    NavigationLink(
                        destination: EditFieldView(
                            fieldName: "Author", inputValue: $book.authorName)
                    ) {
                        HStack {
                            Text("Author")
                            Spacer()
                            Text(book.authorName)
                        }
                    }
                    .onChange(of: book.authorName) {
                        saveData(book: book)
                    }

                    Picker("Genre", selection: $book.genre) {
                        ForEach(Genre.allCases) { genre in
                            Text(genre.rawValue)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    .onChange(of: book.genre) {
                        print(book.genre)
                        saveData(book: book)
                    }

                    TextField("Pages", value: $book.pageCount, format: .number)
                        .keyboardType(.asciiCapableNumberPad)
                        .onChange(of: book.pageCount) {
                            saveData(book: book)
                        }
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
                    .onChange(of: book.status) {
                        saveData(book: book)
                    }

                    RatingView($book.userRating, maxRating: 5).padding(5)
                        .onChange(of: book.userRating) {
                            saveData(book: book)
                        }

                    DatePicker(
                        "Started",
                        selection: $book.startDate, displayedComponents: .date
                    ).onSubmit {
                        // Handle submission for Started
                    }
                    .onChange(of: book.startDate) {
                        saveData(book: book)
                    }
                    
                    DatePicker(
                        "Finished",
                        selection: $book.endDate, displayedComponents: .date
                    ).onSubmit {
                        // Handle submission for Finished
                    }
                    .onChange(of: book.endDate) {
                        saveData(book: book)
                    }

                    VStack(alignment: .leading) {
                        Text("Notes")
                        TextEditor(text: $book.notes)
                            .frame(height: 200)  // Set a height for better visibility
                            .padding()
                            .background(Color(UIColor.systemGray5))  // Background for TextEditor
                            .cornerRadius(10)  // Rounded corners for aesthetics
                    }
                    .onChange(of: book.notes) {
                        saveData(book: book)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private func saveData(book: CompleteBookDataViewModel) {
    print("Autosave on change")
    print(book.genre)
    print(book.genresEdited)
    print(book.asRecord)
    Task {
        try DatabaseRepository.saveCompleteBook(book.asRecord)
    }
}
