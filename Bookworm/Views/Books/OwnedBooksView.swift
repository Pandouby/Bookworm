//
//  OwnedBooksView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 18.10.2024.
//

import AVFoundation
import Foundation
import SwiftData
import CodeScanner
import SwiftUI

struct OwnedBooksView: View {
    @Environment(\.modelContext) private var modelContext
    @Query() private var books: [Book]

    @State private var isShowingScanner = false
    @State private var scannedCode: String?
    @State private var showBookNotFoundAlert = false

    @State private var isBookSearchShowing = false

    @State var searchResults: [Book] = []
    @State var searchQuery: String = ""

    var isSearching: Bool {
        return !searchQuery.isEmpty
    }

    init() {
        let filter = #Predicate<Book> { book in
            book.statusOrder != 0
        }
        
        let sort: [SortDescriptor<Book>] = [
            SortDescriptor(\Book.statusOrder),
            SortDescriptor(\Book.finishedDate, order: .reverse),
            SortDescriptor(\Book.dateAdded, order: .reverse),
            SortDescriptor(\Book.title)
        ]
        
        _books = Query(filter: filter, sort: sort)
    }

    var body: some View {
        List {
            ForEach(isSearching ? searchResults : books) { book in
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
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button("Done") {
                        book.status = Status.done
                        book.statusOrder = book.status.sortOrder
                    }
                    .tint(.done)
                }
                .swipeActions(edge: .leading) {
                    Button("Reading") {
                        book.status = Status.inProgress
                        book.statusOrder = book.status.sortOrder
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
                completion: handleScan
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
                modelContext.delete(books[index])
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
    
    private func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false

        switch result {
        case .success(let result):
            getBookData(isbn: result.string)
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }

    private func fetchSearchResults(for query: String) {
        let searchQuery = query.lowercased()  // Make the query case-insensitive

        searchResults = books.filter { book in
            book.title.lowercased().contains(searchQuery)
                || book.author.lowercased().contains(searchQuery)
        }
    }

    private func getBookData(isbn: String) {
        let url = URL(
            string: "https://www.googleapis.com/books/v1/volumes?q=isbn:\(isbn)"
        )!

        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
            do {
                let jsonData = try JSONDecoder().decode(
                    BookResponse.self, from: data)

                if let bookData = jsonData.items?.first?.volumeInfo {
                    let title = bookData.title ?? "N/A"
                    let authors = bookData.authors?.first ?? "Unknown Author"
                    let pageCount = bookData.pageCount ?? 0
                    let genre = bookData.categories?.first ?? "Non-Classifiable"

                    print(bookData)

                    let newBook = Book(
                        isbn: isbn,
                        title: title,
                        author: authors,
                        pages: pageCount,
                        genre: Genre(rawValue: genre) ?? Genre.nonClassifiable
                    )

                    DispatchQueue.main.async {
                        modelContext.insert(newBook)
                    }
                } else {
                    print("No book data found for the given ISBN.")
                    showBookNotFoundAlert = true
                }

            } catch let error {
                print("Failed to parse Json: \(error)")
                showBookNotFoundAlert = true
            }
        }

        task.resume()
    }
}

#Preview {
    let preview = Preview()
    preview.addExamples(Book.sampleBooks)

    return OwnedBooksView()
        .modelContainer(preview.container)
}
