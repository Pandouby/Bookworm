//
//  OwnedBooksView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 18.10.2024.
//

import AVFoundation
import Foundation
import CodeScanner
import SwiftUI
import GRDBQuery
import GRDB

struct OwnedBooksView: View {
    @Query(AllCompleteBooksQuery(statuses: [.toDo, .inProgress, .onPause, .done])) var completeBooks: [CompleteBookData]
    
    var ownedBooks: [CompleteBookDataViewModel] {
        completeBooks
            .map { .init(from: $0) }
            .filter { book in
                let matchesFavorite = !filterFavoritesOnly || book.isFavorite
                let matchesStatus = selectedStatusFilter == nil || book.status == selectedStatusFilter
                let matchesGenre = selectedGenreFilter == nil || book.genre == selectedGenreFilter
                
                return matchesFavorite && matchesStatus && matchesGenre
            }
            .sorted()
    }

    @State private var isShowingScanner = false
    @State private var scannedCode: String?
    @State private var showBookNotFoundAlert = false
    @State private var selectedLanguages = ["eng"]
    
    // Filter State
    @State private var filterFavoritesOnly = false
    @State private var selectedStatusFilter: Status? = nil
    @State private var selectedGenreFilter: Genre? = nil
    
    @State private var showFavoriteDeleteDialog = false
    @State private var favoriteBookToDelete: CompleteBookDataViewModel?
    @State private var favoriteOffsetsToDelete: IndexSet?

    @State private var isBookSearchShowing = false

    @State var searchResults: [CompleteBookDataViewModel] = []
    @State var searchQuery: String = ""

    var isSearching: Bool {
        return !searchQuery.isEmpty
    }
    
    var isFiltering: Bool {
        filterFavoritesOnly || selectedStatusFilter != nil || selectedGenreFilter != nil
    }

    var body: some View {        
        List {
            if isFiltering {
                Section {
                    Button(action: {
                        withAnimation {
                            filterFavoritesOnly = false
                            selectedStatusFilter = nil
                            selectedGenreFilter = nil
                        }
                    }) {
                        Label("Clear all filters", systemImage: "xmark.circle")
                            .foregroundColor(.accentColor)
                    }
                }
            }
            
            ForEach(isSearching ? searchResults: ownedBooks) { book in
                NavigationLink(destination: BookDetailsView(book: book)) {
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(book.workTitle).font(.headline)
                                
                                if book.isFavorite {
                                    Image(systemName: "heart.fill")
                                        .foregroundStyle(.red)
                                }
                            }
                            
                            Text(book.authorName)
                        }

                        StatusIcon(status: book.status)
                            .padding(.leading, 10)
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button("Done") {
                        book.status = Status.done
                        Task {
                            try DatabaseRepository.saveCompleteBook(book.asRecord)
                        }
                    }
                    .tint(.done)
                }
                .swipeActions(edge: .leading) {
                    Button("Reading") {
                        book.status = Status.inProgress
                        Task {
                            try DatabaseRepository.saveCompleteBook(book.asRecord)
                        }
                    }
                    .tint(.inProgress)
                }
            }
            .onDelete { offsets in
                handleDelete(offsets: offsets)
            }
        }
        .confirmationDialog(
            "Delete Favorite Book?",
            isPresented: $showFavoriteDeleteDialog,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let offsets = favoriteOffsetsToDelete {
                    if isSearching {
                        deleteSearchItems(offsets: offsets)
                    } else {
                        deleteItems(offsets: offsets)
                    }
                }
                
                favoriteBookToDelete = nil
                favoriteOffsetsToDelete = nil
            }
            
            Button("Cancel", role: .cancel) {
                favoriteBookToDelete = nil
                favoriteOffsetsToDelete = nil
            }
        } message: {
            Text("This book is marked as favorite. Are you sure you want to delete it?")
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu {
                    Toggle(isOn: $filterFavoritesOnly) {
                        Label("Favorites Only", systemImage: "heart.fill")
                    }
                    
                    Divider()
                    
                    Menu {
                        Button("All") { selectedStatusFilter = nil }
                        ForEach(Status.allCases.filter { $0 != .wantToRead }) { status in
                            Button {
                                selectedStatusFilter = status
                            } label: {
                                HStack {
                                    Text(status.rawValue)
                                    if selectedStatusFilter == status {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Label("Filter by Status", systemImage: "checklist")
                    }
                    
                    Menu {
                        Button("All") { selectedGenreFilter = nil }
                        ForEach(Genre.allCases) { genre in
                            Button {
                                selectedGenreFilter = genre
                            } label: {
                                HStack {
                                    Text(genre.rawValue)
                                    if selectedGenreFilter == genre {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Label("Filter by Genre", systemImage: "books.vertical")
                    }
                    
                } label: {
                    Image(systemName: isFiltering ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        .foregroundColor(isFiltering ? .accentColor : .primary)
                }

                Button("Scan new Book", systemImage: "barcode.viewfinder") {
                    isShowingScanner = true
                }
                
                Button(action: addItem) {
                    Label("Add Book", systemImage: "plus")
                }
            }
        }
        .alert(isPresented: $showBookNotFoundAlert) {
            Alert(
                title: Text("Book could not be found"),
                message: Text("Please enter the book details manualy")
            )
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
        .sheet(isPresented: $isShowingScanner) {
            CodeScannerView(
                codeTypes: [.ean13],
                scanMode: .once,
                showViewfinder: true,
                simulatedData: "9781784162122",
                videoCaptureDevice: AVCaptureDevice.zoomedCameraForQRCode(
                    withMinimumCodeSize: 15),
                completion: { result in
                    Task {
                        await handleScan(result: result)
                    }
                }
            )
            .ignoresSafeArea()
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
    
    private func handleDelete(offsets: IndexSet) {
        let booksArray = isSearching ? searchResults : ownedBooks
        
        guard let index = offsets.first else { return }
        let book = booksArray[index]
        
        if book.isFavorite {
            // Show confirmation popup
            favoriteBookToDelete = book
            favoriteOffsetsToDelete = offsets
            showFavoriteDeleteDialog = true
        } else {
            // Delete immediately
            if isSearching {
                deleteSearchItems(offsets: offsets)
            } else {
                deleteItems(offsets: offsets)
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                print("Delete item at: \(index)")
                print(ownedBooks[index].workTitle)
                Task {
                    try DatabaseRepository.deleteCompleteBook(ownedBooks[index].asRecord)
                }
            }
        }
    }

    private func deleteSearchItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                print("delete search item at: \(index)")
                let itemToDelete: CompleteBookDataViewModel = searchResults[index]
                searchResults.remove(at: index)
                Task {
                    try DatabaseRepository.deleteCompleteBook(itemToDelete.asRecord)
                }
            }
        }
    }
    
    private func handleScan(result: Result<ScanResult, ScanError>) async {
        isShowingScanner = false
        
        print("ISBN----------------")
        print(result)

        switch result {
        case .success(let result):
            
        await getCompleteBookDataByIsbn(isbn: result.string)
    
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }

    private func fetchSearchResults(for query: String) {
        let searchQuery = query.lowercased()  // Make the query case-insensitive

        searchResults = ownedBooks.filter { book in
            book.workTitle.lowercased().contains(searchQuery)
                || book.authorName.lowercased().contains(searchQuery)
        }
    }

    public func getCompleteBookDataByIsbn(isbn: String) async {
        guard let url = URL(string: "https://openlibrary.org/isbn/\(isbn).json")
        else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let edition = try JSONDecoder().decode(EditionResponse.self, from: data)
            
            if let fullSearchResult = await fetchCompleteBookDataByEdition(for: edition, languages: selectedLanguages) {
                print(fullSearchResult)
                await saveFullSearchResultToDB(book: fullSearchResult, status: Status.toDo)
            } else {
                print("Failed to fetch complete book data for edition: \(edition)")
                showBookNotFoundAlert = true
            }
            
        } catch let error {
            print("Failed to parse Json: \(error)")
            showBookNotFoundAlert = true
        }
    }
}

#Preview {
    let dbQueue = AppDatabase.preview()
    DatabaseRepository.dbQueue = dbQueue
    
    return NavigationStack {
        OwnedBooksView()
            .databaseContext(.readWrite { dbQueue })
    }
}
