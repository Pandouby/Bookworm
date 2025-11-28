//
//  BookwormApp.swift
//  Bookworm
//
//  Created by Silvan Dubach on 09.10.2024.
//

import SwiftUI
import SwiftData
import GRDB
import GRDBQuery

@main
struct BookwormApp: App {
    
    /// Initialize your GRDB database
    let appDatabase = AppDatabase.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.databaseContext, appDatabase.dbQueue)
        }
        // Keep your SwiftData model container
        .modelContainer(for: Book.self)
    }
}
