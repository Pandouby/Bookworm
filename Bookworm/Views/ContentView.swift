//
//  ContentView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 09.10.2024.
//

import SwiftUI
import GRDB

struct ContentView: View {
    @State private var tabIndex = 1

    var body: some View {
        TabView(selection: $tabIndex) {
            BooksView()
                .tag(1)
            
            DiscoveryView()
                .tag(2)
            
            AnalyticsView()
                .tag(3)
            
            Text("Settings tab")
                .tag(4)
        }
        .overlay(alignment: .bottom) {
            CustomTabView(tabIndex: $tabIndex)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    let dbQueue = AppDatabase.preview()
    DatabaseRepository.dbQueue = dbQueue
    
    return ContentView()
        .databaseContext(.readWrite { dbQueue })
}
