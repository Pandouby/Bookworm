//
//  PagesAnalytics.swift
//  Bookworm
//
//  Created by Silvan Dubach on 30.10.2024.
//

import SwiftUI
import Charts
import GRDB

struct PagesAnalytics: View {
    var body: some View {
        VStack {
            VStack(alignment: .center) {
                Text("Pages Analytics")
            }
        }
    }
}

#Preview {
    let dbQueue = AppDatabase.preview()
    DatabaseRepository.dbQueue = dbQueue
    
    return PagesAnalytics()
        .databaseContext(.readWrite { dbQueue })
}
