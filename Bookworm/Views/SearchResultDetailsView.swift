//
//  SearchResultDetailsView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 20.10.2024.
//

import SwiftData
import SwiftUI

struct SearchResultDetailsView: View {
    var searchResult: Book
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                
                VStack {
                    Text(searchResult.title)
                        .font(.title)
                    
                    Text("By \(searchResult.author)")
                        .font(.title3)
                        .opacity(0.8)
                }
                .frame(maxWidth: .infinity)
                
                HStack(spacing: 15) {
                    
                    if searchResult.imageLink != "" {
                        
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
                                    string: searchResult.imageLink ?? ""
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
                
                if(searchResult.bookDescription != "") {
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
                            Text("\"\(searchResult.bookDescription)\"")
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
            .toolbar {
                ToolbarItem {
                    Button("Add book", systemImage: "plus") {
                        addBook()
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    func addBook() {
        modelContext.insert(searchResult)
        dismiss()
    }

    @ViewBuilder
    private var searchResultDetailWidget: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(.widget)
                .clipShape(
                    RoundedRectangle(cornerRadius: 24)
                )

            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading ) {
                    Text("\(searchResult.pageCount) ")
                        .bold()
                        .foregroundStyle(.white)
                    + Text("Pages")
                        .foregroundStyle(.white)
                    
                    Text(searchResult.genre.rawValue)
                        .foregroundStyle(.white)
                        .bold()
                }

                if(searchResult.publishedDate != "") {
                    Text("Published ")
                        .foregroundStyle(.white)
                    + Text("\(searchResult.publishedDate ?? "")")
                        .foregroundStyle(.white)
                        .bold()
                }
                
                if(searchResult.publisher != "") {
                    Text("Published by ")
                        .foregroundStyle(.white)
                    + Text("\(searchResult.publisher ?? "")")
                        .foregroundStyle(.white)
                        .bold()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .shadow(color: .widgetShadow, radius: 5)
    }
}
#Preview {
    let example = Book(
        isbn: "12345678", title: "To Kill a Mockingbird", author: "Harper Lee",
        pages: 309,
        genre: Genre.fiction,
        imageLink: "placeholderBookCover",
        bookDescription:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi. Nulla quis sem at nibh elementum imperdiet. Duis sagittis ipsum. Praesent mauris. Fusce nec tellus sed augue semper porta. Mauris massa. Vestibulum lacinia arcu eget nulla. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Curabitur sodales ligula in libero. Sed dignissim lacinia nunc. Curabitur tortor. Pellentesque nibh. Aenean quam. In scelerisque sem at dolor. Maecenas mattis. Sed convallis tristique sem. Proin ut ligula vel nunc egestas porttitor."
    )

    return SearchResultDetailsView(searchResult: example)
}
