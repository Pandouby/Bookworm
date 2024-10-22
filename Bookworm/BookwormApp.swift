//
//  BookwormApp.swift
//  Bookworm
//
//  Created by Silvan Dubach on 09.10.2024.
//

import SwiftUI
import SwiftData

@main
struct BookwormApp: App {
    
    /*
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Book.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false) // Settin isStoredInMemoryOnly to false breaks the preview for some reason i havent figured out yet. With it set to true SwiftData dosnt work so there is no books being displayed

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
     */

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Book.self)
    }
}
