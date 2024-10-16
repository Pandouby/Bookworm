//
//  BookDetailsView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 15.10.2024.
//

import AVFoundation
import SwiftData
import SwiftUI
import Foundation

struct BookDetailsView: View {
    @Bindable var book: Book

    var body: some View {
            
            VStack {
                Form {
                   
                    TextField("Title", text: $book.title)
                    
                    TextField("Author", text: $book.author)
                
                    Picker("Genre", selection: $book.genre) {
                        ForEach(Genre.allCases) { genre in
                            Text(genre.rawValue)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    
                    Picker("Status", selection: $book.status) {
                        ForEach(Status.allCases) { status in
                            Text(status.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    RatingView($book.rating, maxRating: 5).padding(5)
                    
                    TextField("Pages", value: $book.pages, format: .number).keyboardType(.asciiCapableNumberPad)
                       
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
        
                    VStack(alignment: .leading){
                        Text("Notes")
                        TextEditor(text: $book.notes)
                            .frame(height: 200)  // Set a height for better visibility
                            .padding()
                            .background(Color(UIColor.systemGray6))  // Background for TextEditor
                            .cornerRadius(5)  // Rounded corners for aesthetics
                            .onSubmit {
                                // Handle submission for Notes
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
        let container = try ModelContainer(for: Book.self, configurations: config)
        
        let excample = Book(isbn: "1234", title: "Test", author: "Test", pages: 123, genre: Genre.fiction)
        
        return BookDetailsView(book: excample).modelContainer(container)
    } catch {
        fatalError("Failed to create model container")
    }
}
 

/*
#Preview {
    BookDetailsView(book: Book(isbn: "9781784162122", title: "test", author: "test", pages: 201, genre: Genre.comedy))
        .modelContainer(for: Book.self, inMemory: true)
}
*/
