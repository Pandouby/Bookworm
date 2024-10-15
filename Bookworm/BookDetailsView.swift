//
//  BookDetailsView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 15.10.2024.
//

import SwiftUI
import SwiftData
import AVFoundation

struct BookDetailsView: View {
    var book: Book
    
    @State private var titleInputValue: String
    @State private var authorInputValue: String
    @State private var genreInputValue: String
    @State private var statusInputValue: String
    @State private var ratingInputValue: Int?
    @State private var pagesInputValue: Int
    @State private var startedInputValue: Date?
    @State private var finishedInputValue: Date?
    @State private var notesInputValue: String
    
    
    init(book: Book) {
        self.book = book
        _titleInputValue = State(initialValue: book.title)
        _authorInputValue = State(initialValue: book.author)
        _genreInputValue = State(initialValue: book.genre.rawValue.capitalized)
        _statusInputValue = State(initialValue: book.status.rawValue.capitalized)
        _ratingInputValue = State(initialValue: book.rating)
        _pagesInputValue = State(initialValue: book.pages)
        _startedInputValue = State(initialValue: book.started)
        _finishedInputValue = State(initialValue: book.finished)
        _notesInputValue = State(initialValue: book.notes ?? "")
    }
    
    var body: some View {
        
        VStack {
            Form {
                TextField("Title", text: $titleInputValue).onSubmit {
                    
                }
                
                TextField("Author", text: $authorInputValue).onSubmit {
                    
                }
                
                TextField("Genre", text: $genreInputValue).onSubmit {
                    
                }
                
                TextField("Status", text: $statusInputValue).onSubmit {
                    
                }
                
                TextField("Rating", value: $ratingInputValue, format: .number).onSubmit {
                    
                }
                
                
                TextField("Pages", value: $pagesInputValue, format: .number).onSubmit {
                    
                }
                
                // Using DatePicker instead of TextField for better UX
                DatePicker("Started", selection: Binding(
                    get: { startedInputValue ?? Date() }, // Default to current date if nil
                    set: { startedInputValue = $0 }
                ), displayedComponents: .date).onSubmit {
                    // Handle submission for Started
                }
                
                DatePicker("Finished", selection: Binding(
                    get: { finishedInputValue ?? Date() }, // Default to current date if nil
                    set: { finishedInputValue = $0 }
                ), displayedComponents: .date).onSubmit {
                    // Handle submission for Finished
                }
                
                // Use TextEditor for notes
                TextEditor(text: $notesInputValue)
                    .frame(height: 150) // Set a height for better visibility
                    .padding()
                    .background(Color(UIColor.systemGray6)) // Background for TextEditor
                    .cornerRadius(5) // Rounded corners for aesthetics
                    .onSubmit {
                        // Handle submission for Notes
                    }
            }
            
        }
    }
    
}

#Preview {
    BookDetailsView(book: Book(title: "test", author: "test", pages: 201, genre: Genre.comedy))
        .modelContainer(for: Book.self, inMemory: true)
}
