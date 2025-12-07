//
//  Status.swift
//  Bookworm
//
//  Created by Silvan Dubach on 28.10.2024.
//

import GRDB

enum Status: String, Codable, CaseIterable, Identifiable, DatabaseValueConvertible {
    case wantToRead = "Want to Read"
    case toDo = "To Do"
    case onPause = "On Pause"
    case inProgress = "In Progress"
    case done = "Done"
    
    var sortOrder: Int {
        switch self {
        case .wantToRead: return 0
        case .toDo: return 1
        case .onPause: return 2
        case .inProgress: return 3
        case .done: return 4
        }
    }
    
    var id: Self { self }
}
