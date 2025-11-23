import SwiftData
import SwiftUI

struct BookSearchView: View {
    var isWantToReadView: Bool? = false
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var searchQuery = ""
    @State private var searchResults: [Book] = []
    @State private var isLoading = false

    @State private var currentTask: Task<Void, Never>? = nil
    
    private let debounceDelay = 0.4
    
    var body: some View {
        NavigationStack {
            if isLoading {
                ProgressView("Searching...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            } else if searchResults.isEmpty && !searchQuery.isEmpty {
                VStack {
                    Spacer()
                    Text("No books found for \"\(searchQuery)\"")
                    Button("Add book manually") { addEmptyBook() }
                    Spacer()
                }
            } else {
                List {
                    ForEach(searchResults) { book in
                        NavigationLink(
                            destination: SearchResultDetailsView(searchResult: book)
                        ) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(truncatedTitle(title: book.title, length: 18))
                                        .font(.headline)
                                    book.author.isEmpty
                                    ? Text(" ")
                                    : Text(truncatedTitle(title: book.author, length: 20))
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text(truncatedTitle(title: book.genre.rawValue, length: 20))
                                    book.pageCount > 0 ? Text("p. \(book.pageCount)") : Text("")
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
        .searchable(text: $searchQuery, prompt: "Search for books")
        .textInputAutocapitalization(.never)
        
        // 🟦 Trigger debounced search + cancel previous tasks
        .onChange(of: searchQuery) { newValue in
            handleSearchQueryChanged(newValue)
        }
        
        .toolbar {
            ToolbarItem { Button("Close") { dismiss() } }
        }
    }
    
    // MARK: - SEARCH HANDLER
    
    /// Called every time the searchQuery changes.
    private func handleSearchQueryChanged(_ query: String) {
        // Cancel ongoing API call
        currentTask?.cancel()
        
        // Clear results when empty
        if query.isEmpty || query.count < 3 {
            searchResults = []
            return
        }
        
        // Start new task (replaces Combine debounce)
        currentTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(debounceDelay * 1_000_000_000))
            
            if Task.isCancelled { return }
            
            await runSearch(query)
        }
    }
    
    // MARK: - RUN SEARCH
    
    @MainActor
    private func runSearch(_ query: String) async {
        isLoading = true
        
        await withTaskCancellationHandler {
            // Cancel ongoing network work if task is cancelled
            isLoading = false
        } operation: {
            await fetchWorks(for: query)
            isLoading = false
        }
    }
    
    // MARK: - FETCH WORKS (unchanged except async wrapper)
    
    private func fetchWorks(for query: String) async {
        let worksLimit = 10
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        guard let url = URL(string:
                                "https://openlibrary.org/search.json?title=\(encoded)&fields=key,title,subtitle,edition_key,author_key,subject,language,first_publish_year&sort=editions&limit=\(worksLimit)"
        ) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
            let works = searchResponse.docs
            
            var books: [Book] = []
            
            try await withThrowingTaskGroup(of: Book?.self) { group in
                for work in works {
                    group.addTask { await self.fetchCompleteBookData(for: work) }
                }
                
                for try await result in group {
                    if let book = result { books.append(book) }
                }
            }
            
            await MainActor.run {
                self.searchResults = books
            }
            
        } catch {
            print("Search error: \(error)")
        }
    }
    
    // MARK: - FETCH COMPLETE BOOK
    
    private func fetchCompleteBookData(for work: WorkResponse) async -> Book? {
        guard let workKey = work.workKey.split(separator: "/").last else { return nil }
        
        let workURL = URL(string: "https://openlibrary.org/works/\(workKey).json")!
        let editionURL = URL(string: "https://openlibrary.org/works/\(workKey)/editions.json")!
        
        var authorName = "Unknown Author"
        let authorKey = work.authorKeys?.first
        
        do {
            async let workData = URLSession.shared.data(from: workURL)
            async let editionData = URLSession.shared.data(from: editionURL)
            
            async let authorData: (Data, URLResponse)? =
            authorKey != nil
            ? try? URLSession.shared.data(from: URL(string: "https://openlibrary.org/authors/\(authorKey!).json")!)
            : nil
            
            let (workRaw, _) = try await workData
            let (editionRaw, _) = try await editionData
            
            let fullWork = try JSONDecoder().decode(WorkResponse.self, from: workRaw)
            let editionResp = try JSONDecoder().decode(EditionListResponse.self, from: editionRaw)
            
            if let authorTuple = try await authorData {
                let auth = try? JSONDecoder().decode(AuthorResponse.self, from: authorTuple.0)
                authorName = auth?.name ?? "Unknown Author"
            }
            
            let editions = editionResp.entries
            let bestEdition =
            editions.first { $0.isbn_13?.isEmpty == false && $0.number_of_pages != nil }
            ?? editions.first
            
            return createBook(from: fullWork, edition: bestEdition, authorName: authorName)
            
        } catch {
            return nil
        }
    }
    
    // MARK: - BOOK CREATION (unchanged)
    
    private func createBook(from work: WorkResponse, edition: EditionResponse?, authorName: String) -> Book {
        let isbn = edition?.isbn_13?.first ?? edition?.isbn_10?.first ?? ""
        let title = work.workTitle
        let pageCount = edition?.number_of_pages ?? 0
        
        let genre: Genre = work.subjects?
            .compactMap { Genre(rawValue: $0) }
            .first ?? .nonClassifiable
        
        let imageLink: String?
        if let coverId = edition?.covers?.first {
            imageLink = "https://covers.openlibrary.org/b/id/\(coverId)-L.jpg"
        } else { imageLink = nil }
        
        let newBook = Book(
            isbn: isbn,
            title: title,
            author: authorName,
            pages: pageCount,
            genre: genre,
            imageLink: imageLink,
            publishedDate: edition?.publish_date,
            publisher: edition?.publishers?.first,
            bookDescription: work.description ?? "",
            status: isWantToReadView ?? false ? .wantToRead : .toDo
        )
        
        newBook.statusOrder = newBook.status.sortOrder
        return newBook
    }
    
    private func addEmptyBook() {
        let emptyBook = Book(isbn: "", title: "New Book", author: "Unknown", pages: 0, genre: .nonClassifiable)
        modelContext.insert(emptyBook)
        dismiss()
    }
}

// Helper
func truncatedTitle(title: String, length: Int) -> String {
    title.count > length ? String(title.prefix(length)) + "..." : title
}
