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
                .tabItem {
                    Label("Owned books", systemImage: "book.closed")
                }
                .tag(1)
            
            DiscoveryView()
                .tabItem {
                    Label("Discovery", systemImage: "magnifyingglass")
                }
                .tag(2)
            
            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.xaxis")
                }
                .tag(3)
            
            Text("Settings tab")
                .tabItem {
                    Label("Settings", systemImage: "slider.horizontal.2.square")
                }
                .tag(4)
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
