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
            .sorted()
    }

    @State private var isShowingScanner = false
    @State private var scannedCode: String?
    @State private var showBookNotFoundAlert = false
    @State private var selectedLanguages = ["eng"]

    @State private var isBookSearchShowing = false

    @State var searchResults: [CompleteBookDataViewModel] = []
    @State var searchQuery: String = ""

    var isSearching: Bool {
        return !searchQuery.isEmpty
    }

    var body: some View {        
        List {
            ForEach(isSearching ? searchResults: ownedBooks) { book in
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
            .onDelete(
                perform: isSearching ? deleteSearchItems : deleteItems
            )
            // Auto navigate to newly added books
            /*.navigationDestination(
                 isPresented: Binding(
                 get: { selectedBook != nil },  // Navigate if a book is selected
                 set: { if !$0 { selectedBook = nil } }  // Clear selection after navigating
                 )
                 ) {
                 if let book = selectedBook {
                 BookDetailsView(book: book)
                 }
                 }
                 */
        }
        .toolbar {
            ToolbarItem {
                Button("Scan new Book", systemImage: "barcode.viewfinder") {
                    isShowingScanner = true
                }
            }
            ToolbarItem {
                Button(action: addItem) {
                    Label("Add Book", systemImage: "plus")
                }
            }
        }
        // Turns of the opaque background of the toolbar when content scrolls below it
        //.toolbarBackground(.hidden, for: .navigationBar)
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
                searchResults.remove(at: index)
            }
        }
    }
    
    private func handleScan(result: Result<ScanResult, ScanError>) async {
        isShowingScanner = false

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
        /*
         // Google Book Api
        guard let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=isbn:\(isbn)"
        )
         */
        
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
    let preview = Preview()
    preview.addExamples(Book.sampleBooks)

    return OwnedBooksView()
        .modelContainer(preview.container)
}
