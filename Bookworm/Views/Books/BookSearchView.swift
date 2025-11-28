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
                    Text(truncatedTitle(title: book.work.workTitle, length: 18))
                        .font(.headline)
                    if ((book.authors?.first) == nil) {
                        Text(truncatedTitle(title: book.authors?.first?.authorName ?? "", length: 20))
                    }
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(truncatedTitle(title: book.genre?.rawValue ?? Genre.nonClassifiable.rawValue, length: 20))
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
        Task<Void, Never> {
            await saveBookToDB(book: book, status: status)
        }
    }
    
    @MainActor
    private func saveBookToDB(book: FullSearchResult, status: Status) async {
        do {
            var work = Work(
                workKey: book.work.workKey,
                workTitle: book.work.workTitle,
                subtitle: nil,
                workDescription: book.work.description,
                firstPublishYear: book.work.firstPublishYear
            )
            try DatabaseRepository.save(&work)

            guard let editionData = book.edition else {
                print("Edition missing, cannot save")
                return
            }
            
            var edition = Edition(
                editionKey: editionData.key,
                workKey: book.work.workKey,
                editionTitle: editionData.title,
                editionDescription: book.work.description,
                numberOfPages: editionData.number_of_pages,
                isbn13: editionData.isbn_13?.first,
                isbn10: editionData.isbn_10?.first,
                publishDate: editionData.publish_date,
                cover: editionData.covers?.first != nil
                ? "https://covers.openlibrary.org/b/id/\(editionData.covers!.first!)-L.jpg"
                : nil
            )
            
            try DatabaseRepository.save(&edition)

            
            guard let authorData = book.authors?.first else { return }
            var author = Author(
                authorKey: authorData.authorKey,
                authorName: authorData.authorName,
                birthDate: authorData.birthDate,
                deathDate: authorData.deathDate,
                wikipedia: authorData.wikipedia
            )
            try DatabaseRepository.save(&author)
            try DatabaseRepository.addAuthor(key: author.authorKey, toWork: work.workKey)
            
            var userBook = UserBooks(
                editionKey: book.edition?.key ?? "",
                userRating: 2.5,
                status: status,
                startDate: Date(),
                endDate: Date(),
                notes: ""
            )
            try DatabaseRepository.save(&userBook)
            
            if let genreKey = book.genre?.rawValue {
                var genreRecord = GenreRecord(genreId: genreKey, genreName: genreKey)
                try DatabaseRepository.save(&genreRecord)
                try DatabaseRepository.addGenre(key: genreKey, toWork: work.workKey)
            }
            
        } catch {
            print("Error saving book: \(error)")
        }
    }


    private func addEmptyBook() {
        print("Adding empty book...")
        let bookId = "/works/" + UUID().uuidString
        var work = Work(workKey: bookId, workTitle: "New Book", subtitle: nil, workDescription: nil, firstPublishYear: nil)
        let editionKey = UUID().uuidString
        var edition = Edition(editionKey: editionKey, workKey: bookId, physicalFormat: nil, editionTitle: "New Book", editionDescription: nil, numberOfPages: 0, isbn13: nil, isbn10: nil, publishDate: nil, oclcNumber: nil, revision: nil, cover: nil)
        var userBook = UserBooks(editionKey: editionKey, userRating: 2.5, status: .toDo, startDate: Date(), endDate: Date(), notes: "")

        Task {
            do {
                try DatabaseRepository.save(&work)
                try DatabaseRepository.save(&edition)
                try DatabaseRepository.save(&userBook)
            } catch {
                print("Error saving empty book: \(error)")
            }
        }
        dismiss()
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
                    group.addTask { await self.fetchCompleteBookData(for: work) }
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

    // MARK: - FETCH COMPLETE BOOK

    private func fetchCompleteBookData(for work: WorkResponse) async -> FullSearchResult? {
        guard let workKey = work.workKey.split(separator: "/").last else { return nil }
        let authorKey = work.authorKeys?.first
        print("Author-Key -----------------")
        print(authorKey)

        let workURL = URL(string: "https://openlibrary.org/works/\(workKey).json")!
        let editionURL = URL(string: "https://openlibrary.org/works/\(workKey)/editions.json")!

        do {
            async let workData = URLSession.shared.data(from: workURL)
            async let editionData = URLSession.shared.data(from: editionURL)

            let (workRaw, _) = try await workData
            let (editionRaw, _) = try await editionData
            
            print("Work------------")
            print(work)
           
            let workDetails = try JSONDecoder().decode(DetailWorkResponse.self, from: workRaw)
            print("Work-Details------------")
            print(workDetails)
            
            // Find out error here
            let editionListResponse = try JSONDecoder().decode(EditionListResponse.self, from: editionRaw)
            print("Edition------------")
            print(editionListResponse)
            
            let authorResponse: AuthorResponse
            
            if let authorKey, !authorKey.isEmpty,
               let authorURL = URL(string: "https://openlibrary.org/authors/\(authorKey).json") {
                
                async let authorData = URLSession.shared.data(from: authorURL)
                let (authorRaw, _) = try await authorData
                authorResponse = try JSONDecoder().decode(AuthorResponse.self, from: authorRaw)
                
            } else {
                print("⚠️ No author key available for this book!")
                authorResponse = AuthorResponse(authorKey: "", authorName: "Unknown Author")
            }
        
            print("Author------------")
            print(authorResponse)
            
            let editions = editionListResponse.entries
            
            var bestEdition = editions.first { edition in
                let hasISBN = !(edition.isbn_13?.isEmpty ?? true) || !(edition.isbn_10?.isEmpty ?? true)
                let hasPageCount = edition.number_of_pages != nil
                
                var matchesLanguage: Bool
                
                if let lang = selectedLanguages.first {
                    matchesLanguage = edition.languages?.contains {
                        $0.key == "/languages/\(lang)"
                    } ?? false
                } else {
                    matchesLanguage = false
                }
                
                return hasISBN && hasPageCount && matchesLanguage
            } ?? editions.first
            
            let imageLink: String?
            if let coverId = bestEdition?.covers?.first {
                imageLink = "https://covers.openlibrary.org/b/id/\(coverId)-L.jpg"
            } else { imageLink = nil }
        
            bestEdition?.coverLink = imageLink
            
            print("-------------------------")
            print(bestEdition)
            
            if var edition = bestEdition {
                edition.isbn_13 = [edition.isbn_13?.first ?? ""]
                edition.isbn_10 = [edition.isbn_10?.first ?? ""]
                edition.number_of_pages = edition.number_of_pages ?? 0
                bestEdition = edition
            }
            
            let fullWork = WorkResponse(workKey: work.workKey, workTitle: work.workTitle, description: workDetails.description, editionKeys: work.editionKeys, authorKeys: work.authorKeys, languages: work.languages, firstPublishYear: work.firstPublishYear, subjects: work.subjects)
            
            //print("-----------------------------------")
            //print(fullWork, bestEdition!, authorResponse)

            return createBook(from: fullWork, edition: bestEdition, authors: [authorResponse])

        } catch {
            print("---------------------")
            print("Fetch error: ", error)
            return (nil)
        }
    }

    // MARK: - BOOK CREATION

    private func createBook(from work: WorkResponse, edition: EditionResponse?, authors: [AuthorResponse]?) -> FullSearchResult {
        print("---CREATE BOOK---")
        let genre: Genre = work.subjects?
            .compactMap { Genre(rawValue: $0) }
            .first ?? .nonClassifiable
        
        let newBook = FullSearchResult(
            work: work, edition: edition, authors: authors, genre: genre, publisher: edition?.publishers, languages: work.languages
        )

        return newBook
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

func truncatedTitle(title: String, length: Int) -> String {
    title.count > length ? String(title.prefix(length)) + "..." : title
}

   
