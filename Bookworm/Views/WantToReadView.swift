//
//  WantToReadView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 18.10.2024.
//

import AVFoundation
import CodeScanner
import Foundation
import SwiftData
import SwiftUI

struct WantToReadView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<Book> { book in
            books.filter { $0.status == .wantToRead }
        },
        sort: [
            SortDescriptor(\Book.dateAdded, order: .reverse),
            SortDescriptor(\Book.title),
        ])
    private var wantToReadList: [Book]

    @State private var isBookSearchShowing = false

    @State var searchResults: [Book] = []
    @State var searchQuery: String = ""

    var isSearching: Bool {
        return !searchQuery.isEmpty
    }

    var body: some View {
        List {
            ForEach(isSearching ? searchResults : wantToReadList) { book in
                NavigationLink(destination: BookDetailsView(book: book)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(book.title).font(.headline)
                            book.author.isEmpty
                                ? Text(" ") : Text(book.author)
                        }

                        StatusIcon(status: book.status)
                            .padding(.leading, 10)
                    }
                }
                .swipeActions(edge: .leading) {
                    Button("Add to Owned") {
                        book.status = Status.inProgress
                        book.statusOrder = book.status.sortOrder
                    }
                    .tint(.blue)
                }
            }
            .onDelete(
                perform: isSearching ? deleteSearchItems : deleteItems
            )
        }
        .toolbar {
            ToolbarItem {
                Button(action: addItem) {
                    Label("Add Book", systemImage: "plus")
                }
            }
        }
        .searchable(
            text: $searchQuery,
            placement: .automatic,
            prompt: "Title or Author"
        )
        .textInputAutocapitalization(.never)
        .onChange(of: searchQuery) {
            self.fetchSearchResults(for: searchQuery)
        }
        .sheet(isPresented: $isBookSearchShowing) {
            BookSearchView()
        }
        .toolbarBackground(.hidden, for: .tabBar)
    }

    private func addItem() {
        withAnimation {
            isBookSearchShowing = true
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(wantToReadList[index])
            }
        }
    }

    private func deleteSearchItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(searchResults[index])
                searchResults.remove(at: index)
            }
        }
    }

    private func fetchSearchResults(for query: String) {
        let searchQuery = query.lowercased()

        searchResults = wantToReadList.filter { book in
            book.title.lowercased().contains(searchQuery)
                || book.author.lowercased().contains(searchQuery)
        }
    }
}

#Preview {
    let preview = Preview()
    preview.addExamples(Book.sampleBooks)

    return OwnedBooksView()
        .modelContainer(preview.container)
}
