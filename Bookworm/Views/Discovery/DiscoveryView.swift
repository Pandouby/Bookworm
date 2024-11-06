//
//  DiscoveryView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 04.11.2024.
//

import SwiftData
import SwiftUI

struct DiscoveryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query() private var books: [Book]
    @AppStorage("isDiscoveryActive") var isDiscoveryActive: Bool = false
    
    init() {
        let filter = #Predicate<Book> { book in
            book.statusOrder == 4
        }
        
        let sort: [SortDescriptor<Book>] = [
            SortDescriptor(\Book.rating)
        ]
        
        _books = Query(filter: filter, sort: sort)
    }
    
    
    var body: some View {
        if(isDiscoveryActive) {
            BookRecommendationView(readBooks: books)
        } else {
            DiscoverySetupView(books: books)
        }
    }
}

#Preview {
    let preview = Preview()
    preview.addExamples(Book.sampleBooks)
    
    return DiscoveryView()
        .modelContainer(preview.container)
}

