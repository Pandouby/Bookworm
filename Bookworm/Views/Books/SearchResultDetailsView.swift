import SwiftUI

struct SearchResultDetailsView: View {
    var searchResult: FullSearchResult
    let addBookAction: (FullSearchResult, Status) -> Void
    @Environment(\.dismiss) var dismiss

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
                            
                            AsyncImage(
                                url: URL(
                                    string: searchResult.edition?.coverLink ?? ""
                                )
                            ) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                        .frame(minHeight: 250)
                        .shadow(color: .widgetShadow, radius: 5)
                        
                    } else {
                        HStack {
                            searchResultDetailWidget
                        }
                    }
                }
                
                if(searchResult.work.description != "") {
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
                        
                        ScrollView {
                            Text("\"\(searchResult.work.description ?? "")\"")
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 250)
                        .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: 250)
                    .shadow(color: .widgetShadow, radius: 5)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
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

            VStack(alignment: .leading, spacing: 10) {
                    
                if(searchResult.edition?.number_of_pages != nil) {
                    Text("\(searchResult.edition?.number_of_pages ?? 0) ")
                        .bold()
                        .foregroundStyle(.white)
                    + Text("Pages")
                        .foregroundStyle(.white)
                }
                        
                if(searchResult.genre != nil) {
                    Text("Genre")
                        .foregroundStyle(.white)
                    Text(searchResult.genre?.rawValue ?? Genre.nonClassifiable.rawValue)
                        .foregroundStyle(.white)
                        .bold()
                }

                if(searchResult.edition?.publish_date != "") {
                    Text("Published\n")
                        .foregroundStyle(.white)
                    + Text("\(searchResult.edition?.publish_date ?? "")")
                        .foregroundStyle(.white)
                        .bold()
                }
                
                if(searchResult.edition?.publishers?.first != "") {
                    Text("Published by ")
                        .foregroundStyle(.white)
                    + Text("\(searchResult.edition?.publishers?.first ?? "")")
                        .foregroundStyle(.white)
                        .bold()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .shadow(color: .widgetShadow, radius: 5)
        .toolbar {
            ToolbarItem {
                Button(action: {
                    addBookAction(searchResult, .toDo)
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
        description: "This is a sample book description that explains what the book is about.",
        editionKeys: ["/books/OL67890M"],
        authorKeys: ["/authors/OL12345A"],
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
    })
}


