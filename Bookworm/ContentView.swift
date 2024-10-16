//
//  ContentView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 09.10.2024.
//

import SwiftUI
import AVFoundation
import SwiftData
import CodeScanner

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var books: [Book]
    
    @State private var isShowingScanner = false
    @State private var scannedCode: String?
    @State private var showBookNotFoundAlert = false
    
    @State var searchResults: [Book] = []
    @State var searchQuery: String = ""
    
    var isSearching: Bool {
        return !searchQuery.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(isSearching ? searchResults : books) { book in
                    NavigationLink(value: book) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(book.title).font(.headline)
                                book.author.isEmpty ? Text(" ") : Text(book.author) 
                            }
                            
                            StatusIcon(status: book.status).padding(.leading, 10)
                        }
                    }
                }
                .onDelete(perform: isSearching ? deleteSearchItems : deleteItems )
            }
            .navigationDestination(for: Book.self, destination: BookDetailsView.init)
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
        }
        .sheet(isPresented: $isShowingScanner) {
            CodeScannerView(
                codeTypes: [.ean13],
                scanMode: .oncePerCode,
                showViewfinder: true,
                simulatedData: "9781784162122",
                videoCaptureDevice: AVCaptureDevice.zoomedCameraForQRCode(withMinimumCodeSize: 15),
                completion: handleScan
            )
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Book(
                isbn: "",
                title: "New Book",
                author: "",
                pages: 0,
                genre: Genre.nonClassifiable
            )
            
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
            book.title.lowercased().contains(searchQuery) ||
            book.author.lowercased().contains(searchQuery)
        }
    }

    struct BookResponse: Codable {
        let items: [BookItem]
        let totalItems: Int
    }
    
    struct BookItem: Codable {
        let volumeInfo: VolumeInfo
    }
    
    struct VolumeInfo: Codable {
        let title: String
        let authors: [String]
        let pageCount: Int
        let categories: [String]?
    }
    
    private func getBookData(isbn: String) {
        let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=isbn:\(isbn)")!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
            do {
                let jsonData = try JSONDecoder().decode(BookResponse.self, from: data)
                    
                if let bookData = jsonData.items.first?.volumeInfo {
                    let title = bookData.title
                    let authors = bookData.authors.first ?? "Unknown Author"
                    let pageCount = bookData.pageCount
                    let genre = bookData.categories?.first ?? "Non-Classifiable"
                    
                    print(bookData)
                    
                    let newBook = Book(
                        isbn: isbn,
                        title: title,
                        author: authors,
                        pages: pageCount,
                        genre: Genre(rawValue: genre) ?? Genre.nonClassifiable
                    )
                    
                    modelContext.insert(newBook)
                } else {
                    print("No book data found for the given ISBN.")
                }
                
            } catch let error {
                print("Failed to parse Json: \(error)")
                showBookNotFoundAlert = true
                addItem()
            }
        }
        
        task.resume()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Book.self, inMemory: true)
}
