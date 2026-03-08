import SwiftUI

struct SearchResultDetailsView: View {
    let initialResult: FullSearchResult // Permanent record from the first call
    @State var searchResult: FullSearchResult // Stateful record for enrichment
    let addBookAction: (FullSearchResult, Status) -> Void
    var isWantToReadView: Bool = false
    @Environment(\.dismiss) var dismiss
    
    @State private var isLoadingDetails = false
    
    init(searchResult: FullSearchResult, addBookAction: @escaping (FullSearchResult, Status) -> Void, isWantToReadView: Bool = false) {
        self.initialResult = searchResult
        self._searchResult = State(initialValue: searchResult)
        self.addBookAction = addBookAction
        self.isWantToReadView = isWantToReadView
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                
                VStack {
                    Text(initialResult.work.workTitle) // Use initial
                        .font(.title)
                    
                    if let author = initialResult.authors?.first { // Use initial
                        Text("By \(author.authorName)")
                            .font(.title3)
                            .opacity(0.8)
                            .frame(maxWidth: .infinity)
                    }
                }

                
                HStack(spacing: 15) {
                    
                    if initialResult.edition?.coverLink != nil { // Use initial
                        
                        VStack {
                            searchResultDetailWidget
                        }
                        
                        ZStack {
                            Rectangle()
                                .fill(.widget)
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 24)
                                )
                            
                            // Always use initial cover to prevent flickering/changing
                            if let coverLink = initialResult.edition?.coverLink, !coverLink.isEmpty {
                                AsyncImage(
                                    url: URL(string: coverLink)
                                ) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                            } else {
                                // Placeholder for missing cover
                                ZStack {
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color.white.opacity(0.15))
                                    Image(systemName: "book.closed.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.white.opacity(0.4))
                                }
                            }
                        }
                        .frame(minHeight: 250)
                        .shadow(color: .widgetShadow, radius: 5)
                        
                    } else {
                        HStack {
                            searchResultDetailWidget
                        }
                    }
                }
                
                ZStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .customBlueAccent, .customBlue,
                                ]),
                                startPoint: .bottomTrailing,
                                endPoint: .topLeading
                            )
                        )
                        .clipShape(
                            RoundedRectangle(cornerRadius: 24)
                        )
                    
                    if isLoadingDetails {
                        ProgressView()
                            .tint(.white)
                            .padding()
                    } else if let descriptionText = searchResult.work.description?.text, !descriptionText.isEmpty {
                        ScrollView {
                            Text("\"\(descriptionText)\"")
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 250)
                        .padding()
                    } else {
                        Text("No description available")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                            .italic()
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 100, maxHeight: 250)
                .shadow(color: .widgetShadow, radius: 5)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .task {
            // Fetch full details (description, etc) on demand
            if searchResult.work.description == nil {
                isLoadingDetails = true
                if let fullDetails = await fetchCompleteBookDataByWork(for: searchResult.work, languages: ["eng"]) {
                    withAnimation {
                        // Enrichment: Merge initial data with deep details from the second call
                        let enriched = FullSearchResult(
                            work: WorkResponse(
                                workKey: initialResult.work.workKey,
                                workTitle: initialResult.work.workTitle,
                                description: fullDetails.work.description,
                                editionKeys: initialResult.work.editionKeys,
                                authorKeys: initialResult.work.authorKeys,
                                authorNames: initialResult.work.authorNames,
                                coverId: initialResult.work.coverId ?? fullDetails.work.coverId,
                                medianPageCount: initialResult.work.medianPageCount,
                                languages: initialResult.work.languages,
                                firstPublishYear: initialResult.work.firstPublishYear,
                                subjects: initialResult.work.subjects
                            ),
                            edition: EditionResponse(
                                title: initialResult.edition?.title ?? fullDetails.edition?.title ?? "",
                                key: initialResult.edition?.key ?? fullDetails.edition?.key ?? "",
                                number_of_pages: (initialResult.edition?.number_of_pages ?? 0) > 0 ? initialResult.edition?.number_of_pages : fullDetails.edition?.number_of_pages,
                                isbn_13: initialResult.edition?.isbn_13 ?? fullDetails.edition?.isbn_13,
                                isbn_10: initialResult.edition?.isbn_10 ?? fullDetails.edition?.isbn_10,
                                publish_date: initialResult.edition?.publish_date ?? fullDetails.edition?.publish_date, // Enriched date
                                coverLink: initialResult.edition?.coverLink ?? fullDetails.edition?.coverLink,
                                publishers: fullDetails.edition?.publishers
                            ),
                            authors: initialResult.authors,
                            genre: initialResult.genre,
                            publisher: fullDetails.edition?.publishers,
                            languages: initialResult.languages
                        )
                        self.searchResult = enriched
                    }
                }
                isLoadingDetails = false
            }
        }
    }

    @ViewBuilder
    private var searchResultDetailWidget: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .customRed, .customRedAccent,
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 24)
                )

            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 12) {
                    // Use searchResult (stateful) to show data as it loads
                    if let pages = searchResult.edition?.number_of_pages, pages > 0 {
                        HStack(spacing: 8) {
                            Image(systemName: "book.pages")
                            Text("\(pages) Pages")
                        }
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    }
                    
                    if let date = searchResult.edition?.publish_date, !date.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                            Text("Published: \(date)")
                        }
                        .font(.system(.caption, design: .rounded, weight: .medium))
                    }
                    
                    if let publisher = searchResult.publisher?.first ?? searchResult.edition?.publishers?.first, !publisher.isEmpty {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "building.2")
                            Text(publisher)
                        }
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .lineLimit(2)
                    }
                }
                .foregroundStyle(.white)
                
                // Genre Pill directly below the list
                if let genre = searchResult.genre {
                    Text(genre.rawValue)
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.white.opacity(0.2)))
                        .padding(.top, 4)
                }
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .shadow(color: .widgetShadow, radius: 5)
        .toolbar {
            ToolbarItem {
                Button(action: {
                    let status: Status = isWantToReadView ? .wantToRead : .toDo
                    // Save using the enriched result if we have it, otherwise initial
                    addBookAction(searchResult, status)
                    dismiss()
                }) {
                    Label("Add Book", systemImage: "plus")
                }
            }
        }
    }
}

#Preview {
    // Sample author
    let sampleAuthor = AuthorResponse(
        authorKey: "OL12345A",
        authorName: "Jane Doe",
        birthDate: "1970",
        deathDate: "2022"
    )
    
    // Sample edition
    let sampleEdition = EditionResponse(
        title: "Sample Book Edition",
        key: "/books/OL67890M",
        number_of_pages: 320,
        isbn_13: ["9781234567890"],
        isbn_10: ["1234567890"],
        publish_date: "2022",
        languages: [LanguageResponse(key: "/languages/eng")],
        covers: [123456],
        coverLink: "https://covers.openlibrary.org/b/id/123456-L.jpg",
        publishers: ["Sample Publisher"]
    )

    
    // Sample work
    let sampleWork = WorkResponse(
        workKey: "/works/OL11111W",
        workTitle: "Sample Book Title",
        description: .string("This is a sample book description that explains what the book is about."),
        editionKeys: ["/books/OL67890M"],
        authorKeys: ["/authors/OL12345A"],
        authorNames: ["Jane Doe"],
        coverId: 123456,
        medianPageCount: 320,
        languages: [],
        firstPublishYear: 2022,
        subjects: ["Fiction"]
    )
    
    // Full sample book
    let sampleBook = FullSearchResult(
        work: sampleWork,
        edition: sampleEdition,
        authors: [sampleAuthor],
        genre: .fiction,
        publisher: sampleEdition.publishers,
        languages: sampleWork.languages
    )
    
    SearchResultDetailsView(searchResult: sampleBook, addBookAction: { book, status in
        print("Mock addBookAction — book: \(book), status: \(status)")
    }, isWantToReadView: false)
    .databaseContext(.readWrite { AppDatabase.preview() })
}
