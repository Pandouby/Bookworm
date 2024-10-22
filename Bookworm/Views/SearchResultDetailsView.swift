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
        VStack(alignment: .leading) {
            Text(searchResult.title)
                .font(.title)
            Text("By \(searchResult.author)")
                .font(.title3)
                .opacity(0.8)
            
            HStack(alignment: .top) {
                Text("\(searchResult.pageCount) pages")
                
                Spacer()
                
                Text(searchResult.genre.rawValue) 
            }
            .frame(maxWidth: .infinity)

            Text("\"\(searchResult.bookDescription)\"")
                .padding(.top, 5)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .toolbar {
            ToolbarItem {
                Button("Add book", systemImage: "plus") {
                    addBook()
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    func addBook() {
        modelContext.insert(searchResult)
        dismiss()
    }
}



#Preview {
    let example = Book(
        isbn: "12345678", title: "To Kill a Mockingbird", author: "Harper Lee",
        pages: 309,
        genre: Genre.fiction,
        bookDescription:
            "Shoot all the bluejays you want, if you can hit 'em, but remember it's a sin to kill a mockingbird."
    )

    return SearchResultDetailsView(searchResult: example)
}
