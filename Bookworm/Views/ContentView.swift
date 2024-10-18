//
//  ContentView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 09.10.2024.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var tabIndex = 1

    var body: some View {
        TabView(selection: $tabIndex) {
            OwnedBooksView()
                .tag(1)
            
            Text("Second tab")
                .tag(2)
            
            Text("Third tab")
                .tag(3)
        }
        .overlay(alignment: .bottom) {
            CustomTabView(tabIndex: $tabIndex)
        }
    }
}
