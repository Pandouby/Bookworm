//
//  BookSearchView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 17.10.2024.
//

import SwiftData
import SwiftUI

struct BookSearchView: View {
    var isWantToReadView: Bool? = false
    @State var searchResults: [Book] = []
    @Environment(\.modelContext) private var modelContext
    @State var searchQuery: String = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            if searchResults.isEmpty {
                VStack {
                    Spacer()
                    Text("Cant find your book")
                    Button("Add book manually") {
                        addEmptyBook()
                    }
                }
            }
            List {
                ForEach(searchResults) { book in
                    NavigationLink(
                        destination: SearchResultDetailsView(searchResult: book)
                    ) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(truncatedTitle(book.title, length: 18))
                                    .font(.headline)
                                book.author.isEmpty
                                    ? Text(" ")
                                    : Text(
                                        truncatedTitle(book.author, length: 20))

                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(
                                    truncatedTitle(
                                        book.genre.rawValue, length: 20))
                                book.pageCount > 0
                                    ? Text("p. \(book.pageCount)") : Text("")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        /*
                         .onTapGesture {
                         modelContext.insert(book)
                         print("addded: \(book.title)")
                         dismiss()
                         }
                         */
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button("Owned") {
                                modelContext.insert(book)
                                print("Add: \(book.title)")
                                dismiss()
                            }
                            .tint(.blue)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button("Want to read") {
                                // Add functionallity to add to want to read list
                                print("Want to read: \(book.title)")
                                print(book.bookDescription)
                                dismiss()
                            }
                            .tint(.blue)
                        }
                    }
                }
            }
            .searchable(
                text: $searchQuery,
                placement: .automatic,
                prompt: "Search for books"
            )
            .textInputAutocapitalization(.never)
            .onChange(of: searchQuery) {
                if !searchQuery.isEmpty {
                    self.fetchBooks(for: searchQuery)
                }
            }
            .toolbar {
                ToolbarItem {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func fetchBooks(for query: String) {
        let url = URL(
            string:
                "https://www.googleapis.com/books/v1/volumes?q=intitle:\(query)|inauthor:\(query)&printType=books&orderBy=relevance&maxResult=10"
        )!

        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            guard let data = data else { return }
            //print(String(data: data, encoding: .utf8)!)
            do {
                let jsonData = try JSONDecoder().decode(
                    BookResponse.self, from: data)

                let receivedBooks = jsonData.items?.prefix(10)
                DispatchQueue.main.async {  // Update UI on the main thread
                    searchResults = []  // Clear previous results
                    receivedBooks?.forEach { book in
                        let bookData = book.volumeInfo

                        let isbn =
                            bookData?.industryIdentifiers?.count ?? 0 > 1
                            ? bookData?.industryIdentifiers?[1].identifier : ""
                        let title = bookData?.title ?? "N/A"
                        let authors =
                            bookData?.authors?.first ?? "Unknown Author"
                        let pageCount = bookData?.pageCount ?? 0
                        let genre =
                            bookData?.categories?.first ?? "Non-Classifiable"
                        let publisher = bookData?.publisher ?? ""
                        let publishedDate = bookData?.publishedDate
                        let imageLink = bookData?.imageLinks?.thumbnail.replacingOccurrences(of: "http://", with: "https://")
                        let bookDescription = bookData?.description

                        let newBook = Book(
                            isbn: isbn ?? "",
                            title: title,
                            author: authors,
                            pages: pageCount,
                            genre: Genre(rawValue: genre)
                                ?? Genre.nonClassifiable,
                            imageLink: imageLink,
                            publishedDate: publishedDate,
                            publisher: publisher,
                            bookDescription: bookDescription ?? "",
                            status: isWantToReadView ?? false ? .wantToRead : .toDo
                        )
                        
                        newBook.statusOrder = newBook.status.sortOrder

                        searchResults.append(newBook)
                    }
                }

            } catch let error {
                print("Failed to parse JSON: \(error)")
            }
        }

        task.resume()
    }

    private func addEmptyBook() {
        let emptyBook = Book(
            isbn: "", title: "New Book", author: "Unknown", pages: 0,
            genre: Genre.nonClassifiable)
        modelContext.insert(emptyBook)
        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Book.self, configurations: config)

    for i in 1..<10 {
        let book = Book(
            isbn: "1234", title: "Test", author: "Test", pages: 123,
            genre: Genre.fiction,
            bookDescription:
                "A test book to check if the layouting is working properly. This book has no content and is fake."
        )
        container.mainContext.insert(book)
    }

    return BookSearchView()
        .modelContainer(container)
}
