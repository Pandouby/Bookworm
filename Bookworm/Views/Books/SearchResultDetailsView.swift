import SwiftUI

struct SearchResultDetailsView: View {
    @State var searchResult: FullSearchResult
    let addBookAction: (FullSearchResult, Status) -> Void
    var isWantToReadView: Bool = false
    @Environment(\.dismiss) var dismiss
    
    @State private var isLoadingDetails = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                
                VStack {
                    Text(searchResult.work.workTitle)
                        .font(.title)
                    
                    if let author = searchResult.authors?.first {
                        Text("By \(author.authorName)")
                            .font(.title3)
                            .opacity(0.8)
                            .frame(maxWidth: .infinity)
                    }
                }

                
                HStack(spacing: 15) {
                    
                    if searchResult.edition?.coverLink != "" {
                        
                        VStack {
                            searchResultDetailWidget
                        }
                        
                        ZStack {
                            Rectangle()
                                .fill(.widget)
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 24)
                                )
                            
                            if let coverLink = searchResult.edition?.coverLink, !coverLink.isEmpty {
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
                let originalCoverLink = searchResult.edition?.coverLink
                isLoadingDetails = true
                if var fullDetails = await fetchCompleteBookDataByWork(for: searchResult.work, languages: ["eng"]) {
                    // Preserve the cover link from search results if the detail fetch doesn't find one
                    if (fullDetails.edition?.coverLink == nil || fullDetails.edition?.coverLink?.isEmpty == true) && originalCoverLink != nil {
                        var updatedEdition = fullDetails.edition
                        updatedEdition?.coverLink = originalCoverLink
                        
                        fullDetails = FullSearchResult(
                            work: fullDetails.work,
                            edition: updatedEdition,
                            authors: fullDetails.authors,
                            genre: fullDetails.genre,
                            publisher: fullDetails.publisher,
                            languages: fullDetails.languages
                        )
                    }
                    
                    withAnimation {
                        self.searchResult = fullDetails
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
                    
                    if let publisher = searchResult.edition?.publishers?.first, !publisher.isEmpty {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "building.2")
                            Text(publisher)
                        }
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .lineLimit(2)
                    }
                }
                .foregroundStyle(.white)
                
                Spacer(minLength: 8)
                
                // Genre Pill at the bottom
                if let genre = searchResult.genre {
                    Text(genre.rawValue)
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.white.opacity(0.2)))
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


