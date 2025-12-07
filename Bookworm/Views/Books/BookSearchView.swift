import SwiftUI

struct BookSearchView: View {
    var isWantToReadView: Bool? = false
    @Environment(\.dismiss) var dismiss

    @State private var searchQuery = ""
    @State private var searchResults: [FullSearchResult] = []
    @State private var isLoading = false
    @State private var selectedLanguages = ["eng"]

    @State private var currentTask: Task<Void, Never>?

    private let debounceDelay = 0.4

    var body: some View {
        NavigationStack {
            if isLoading {
                loadingView
            } else if searchResults.isEmpty && !searchQuery.isEmpty {
                noResultsView
            } else {
                resultsListView
            }
        }
        .searchable(text: $searchQuery, prompt: "Search for books")
        .textInputAutocapitalization(.never)
        .onChange(of: searchQuery) {
            handleSearchQueryChanged(searchQuery)
            print(searchQuery)
        }
        .toolbar {
            ToolbarItem { Button("Close") { dismiss() } }
        }
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        ProgressView("Searching...")
            .progressViewStyle(CircularProgressViewStyle())
            .scaleEffect(1.5)
    }
    
    private var noResultsView: some View {
        VStack {
            Spacer()
            Text("No books found for \"\(searchQuery)\"")
            Button("Add book manually") { addEmptyBook() }
            Spacer()
        }
    }
    
    private var resultsListView: some View {
        List {
            ForEach(searchResults) { book in
                NavigationLink(
                    destination: SearchResultDetailsView(searchResult: book, addBookAction: addBookToLibrary)
                ) {
                    BookRowView(book: book, addBookAction: addBookToLibrary)
                }
            }
        }
    }
    
    // MARK: - Row Subview
    
    struct BookRowView: View {
        let book: FullSearchResult
        let addBookAction: (FullSearchResult, Status) -> Void
        @Environment(\.dismiss) var dismiss
        
        var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(truncatedTitle(book.work.workTitle, length: 18))
                        .font(.headline)
                    if ((book.authors?.first) == nil) {
                        Text(truncatedTitle(book.authors?.first?.authorName ?? "", length: 20))
                    }
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(truncatedTitle(book.genre?.rawValue ?? Genre.nonClassifiable.rawValue, length: 20))
                    if let pages = book.edition?.number_of_pages, pages > 0 {
                        Text("p. \(pages)")
                    }
                }

            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button("Owned") {
                    addBookAction(book, .toDo)
                    dismiss()
                }
                .tint(.blue)
            }
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button("Want to read") {
                    addBookAction(book, .wantToRead)
                    dismiss()
                }
                .tint(.blue)
            }
        }
    }
   
    // MARK: - DATABASE

    private func addBookToLibrary(book: FullSearchResult, status: Status) {
        Task {
            do {
                print("save book")
                print(book.work.workTitle)
                await saveFullSearchResultToDB(book: book, status: status)
            }
        }
    }

    // MARK: - SEARCH HANDLER

    private func handleSearchQueryChanged(_ query: String) {
        currentTask?.cancel()

        if query.isEmpty || query.count < 3 {
            searchResults = []
            return
        }

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
        defer { isLoading = false }

        await fetchWorks(for: query)
    }

    // MARK: - FETCH WORKS

    private func fetchWorks(for query: String) async {
        let worksLimit = 10
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        guard let url = URL(string:
                                "https://openlibrary.org/search.json?title=\(encoded)&fields=key,title,subtitle,edition_key,author_key,subject,language,first_publish_year&sort=editions&limit=\(worksLimit)&langauge=\(selectedLanguages.first ?? "eng")")
        else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
            let works = searchResponse.docs

            var books: [FullSearchResult] = []

            try await withThrowingTaskGroup(of: FullSearchResult?.self) { group in
                for work in works {
                    group.addTask { await fetchCompleteBookDataByWork(for: work, languages: selectedLanguages) }
                    //print(work)
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
}

func saveCoverImage(_ image: UIImage, for id: String) throws -> URL {
    let data = image.jpegData(compressionQuality: 0.9)!
    let filename = "\(id).jpg"
    
    let url = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)
        .first!
        .appendingPathComponent(filename)
    
    try data.write(to: url)
    return url
}
   
