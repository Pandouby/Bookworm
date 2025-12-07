//
//  WantToReadView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 18.10.2024.
//

import AVFoundation
import Foundation
import SwiftUI
import GRDB
import GRDBQuery

struct WantToReadView: View {
    @Query(AllCompleteBooksQuery(statuses: [.wantToRead])) var completeBooks: [CompleteBookData]
    
    var wantToReadBooks: [CompleteBookDataViewModel] {
        completeBooks
            .map { CompleteBookDataViewModel(from: $0) }
            .sorted { $0.addedDate > $1.addedDate }
    }

    @State private var isBookSearchShowing = false

    @State var searchResults: [CompleteBookDataViewModel] = []
    @State var searchQuery: String = ""

    var isSearching: Bool {
        return !searchQuery.isEmpty
    }

    var body: some View {
        List {
            ForEach(isSearching ? searchResults : wantToReadBooks) { book in
                NavigationLink(destination: BookDetailsView(book: book)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(book.workTitle).font(.headline)
                            
                            Text(book.authorName)
                        }

                        StatusIcon(status: book.status)
                            .padding(.leading, 10)
                    }
                }
                .swipeActions(edge: .leading) {
                    Button("Add to Owned") {
                        book.status = Status.toDo
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
            BookSearchView(isWantToReadView: true)
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
                print("Delete item at: \(index)")
                print(wantToReadBooks[index].workTitle)
                Task {
                    try DatabaseRepository.deleteCompleteBook(wantToReadBooks[index].asRecord)
                }
            }
        }
    }

    private func deleteSearchItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                //modelContext.delete(searchResults[index])
                searchResults.remove(at: index)
            }
        }
    }

    private func fetchSearchResults(for query: String) {
        let searchQuery = query.lowercased()

        searchResults = wantToReadBooks.filter { book in
            book.workTitle.lowercased().contains(searchQuery)
            || ((book.authorName.lowercased().contains(searchQuery)) != false)
        }
    }
}

#Preview {
    let preview = Preview()
    preview.addExamples(Book.sampleBooks)

    return WantToReadView()
        .modelContainer(preview.container)
}
