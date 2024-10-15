//
//  ContentView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 09.10.2024.
//

import SwiftUI
import SwiftData
import AVFoundation

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var books: [Book]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(books) { book in
                    NavigationLink {
                        BookDetailsView(book: book)
                    } label: {
                        Text(book.title)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {Button(action: scanNewBook) {
                    Label("Scan new Book", systemImage: "barcode.viewfinder")
                }}
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Book", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select a Book")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Book(title: "test", author: "test", pages: 220, genre: Genre.biography)
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(books[index])
            }
        }
    }
    
    private func scanNewBook() {
        withAnimation {
            
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Book.self, inMemory: true)
}
