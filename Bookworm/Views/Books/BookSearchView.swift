import SwiftUI

struct BookSearchView: View {
    var isWantToReadView: Bool? = false
    @Environment(\.dismiss) var dismiss

    @State private var searchQuery = ""
    @State private var searchResults: [FullSearchResult] = []
    @State private var isLoading = false
    @State private var isStreaming = false
    @State private var selectedLanguages = ["eng"]

    @State private var currentTask: Task<Void, Never>?

    private let debounceDelay = 0.4

    var body: some View {
        NavigationStack {
            ZStack {
                if !searchResults.isEmpty || isLoading || isStreaming {
                    resultsListView
                } else if !searchQuery.isEmpty && !isLoading && !isStreaming {
                    noResultsView
                }
            }
        }
        .searchable(text: $searchQuery, prompt: "Search by title or ISBN")
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
                    destination: SearchResultDetailsView(
                        searchResult: book, 
                        addBookAction: addBookToLibrary,
                        isWantToReadView: isWantToReadView ?? false
                    )
                ) {
                    BookRowView(book: book, addBookAction: addBookToLibrary)
                }
            }
            
            if isStreaming {
                HStack {
                    Spacer()
                    Image(systemName: "square.stack.3d.up")
                        .symbolEffect(.variableColor.iterative, options: .repeating.speed(3))
                        .font(.title2)
                        .padding()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
    }
    
    // MARK: - Row Subview
    
    struct BookRowView: View {
        let book: FullSearchResult
        let addBookAction: (FullSearchResult, Status) -> Void
        @Environment(\.dismiss) var dismiss
        
        var body: some View {
            HStack(spacing: 12) {
                // Book Cover
                if let coverLink = book.edition?.coverLink, !coverLink.isEmpty {
                    AsyncImage(url: URL(string: coverLink)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color(.systemGray5)
                    }
                    .frame(width: 45, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.systemGray5))
                        Image(systemName: "book.closed")
                            .font(.system(size: 20))
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 45, height: 70)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(book.work.workTitle)
                        .font(.system(.headline, design: .rounded))
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        Text(book.authors?.first?.authorName ?? "Unknown Author")
                        
                        if let pages = book.edition?.number_of_pages, pages > 0 {
                            Text("•")
                            Text("\(pages) pages")
                        }
                    }
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                }
                
                Spacer()
            }
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
            isLoading = false
            isStreaming = false
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
        isStreaming = false
        searchResults = []
        
        let cleanedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Regex for ISBN-10 or ISBN-13 (allows optional hyphens)
        let isbnRegex = "^(?:ISBN(?:-1[03])?:? )?(?=[0-9X]{10}$|(?=(?:[0-9]+[- ]){3})[- 0-9X]{13}$|97[89][0-9]{10}$|(?=(?:[0-9]+[- ]){4})[- 0-9]{17}$)(?:97[89][- ]?)?[0-9]{1,5}[- ]?[0-9]+[- ]?[0-9]+[- ]?[0-9X]$"
        
        let isIsbn = cleanedQuery.range(of: isbnRegex, options: .regularExpression) != nil
        
        if isIsbn {
            let pureNumbers = cleanedQuery.replacingOccurrences(of: "[^0-9X]", with: "", options: .regularExpression)
            await fetchByIsbn(pureNumbers)
        } else {
            await fetchWorks(for: cleanedQuery)
        }
    }

    // MARK: - FETCH BY ISBN
    
    private func fetchByIsbn(_ isbn: String) async {
        guard let url = URL(string: "https://openlibrary.org/isbn/\(isbn).json") else {
            await MainActor.run { isLoading = false }
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let edition = try JSONDecoder().decode(EditionResponse.self, from: data)
            
            await MainActor.run {
                self.isLoading = false
                self.isStreaming = true
            }
            
            if let result = await fetchCompleteBookDataByEdition(for: edition, languages: selectedLanguages) {
                await MainActor.run {
                    withAnimation(.smooth) {
                        self.searchResults = [result]
                        self.isStreaming = false
                    }
                }
            } else {
                await MainActor.run { self.isStreaming = false }
            }
        } catch {
            print("ISBN Search error: \(error)")
            await MainActor.run {
                self.isLoading = false
                self.isStreaming = false
            }
        }
    }

    // MARK: - FETCH WORKS

    private func fetchWorks(for query: String) async {
        let worksLimit = 10
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        guard let url = URL(string:
                                "https://openlibrary.org/search.json?title=\(encoded)&fields=key,title,subtitle,edition_key,author_key,subject,language,first_publish_year&sort=editions&limit=\(worksLimit)&langauge=\(selectedLanguages.first ?? "eng")")
        else { 
            await MainActor.run { isLoading = false }
            return 
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
            let works = searchResponse.docs

            // Done with the main fetch, start streaming details
            await MainActor.run {
                self.isLoading = false
                if !works.isEmpty {
                    self.isStreaming = true
                }
            }

            try await withThrowingTaskGroup(of: FullSearchResult?.self) { group in
                for work in works {
                    group.addTask { await fetchCompleteBookDataByWork(for: work, languages: selectedLanguages) }
                }

                for try await result in group {
                    if let book = result {
                        // Append results one by one as they arrive
                        await MainActor.run {
                            withAnimation(.smooth) {
                                self.searchResults.append(book)
                            }
                        }
                    }
                }
            }
            
            // All detail streaming finished
            await MainActor.run {
                self.isStreaming = false
            }

        } catch {
            print("Search error: \(error)")
            await MainActor.run { 
                self.isLoading = false
                self.isStreaming = false
            }
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

#Preview {
    let dbQueue = AppDatabase.preview()
    DatabaseRepository.dbQueue = dbQueue
    
    return BookSearchView()
        .databaseContext(.readWrite { dbQueue })
}
