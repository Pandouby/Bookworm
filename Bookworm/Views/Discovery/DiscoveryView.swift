//
//  DiscoveryView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 04.11.2024.
//

import SwiftUI
import GRDB
import GRDBQuery

struct DiscoveryView: View {
    @Query(AllCompleteBooksQuery(statuses: [.done])) private var books: [CompleteBookData]
    @AppStorage("isDiscoveryActive") var isDiscoveryActive: Bool = false
    
    var body: some View {
        if isDiscoveryActive {
            BookRecommendationView(readBooks: books)
        } else {
            // Text("Discovery Setup")
            DiscoverySetupView(books: books)
        }
    }
}

#Preview {
    let dbQueue = AppDatabase.preview()
    DatabaseRepository.dbQueue = dbQueue
    
    return DiscoveryView()
        .databaseContext(.readWrite { dbQueue })
}

