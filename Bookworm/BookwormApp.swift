//
//  BookwormApp.swift
//  Bookworm
//
//  Created by Silvan Dubach on 09.10.2024.
//

import SwiftUI
import GRDB
import GRDBQuery

@main
struct BookwormApp: App {
    
    /// Initialize your GRDB database
    let appDatabase = AppDatabase.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .databaseContext(.readWrite{appDatabase.dbQueue})
    }
}
