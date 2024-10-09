//
//  Item.swift
//  Bookworm
//
//  Created by Silvan Dubach on 09.10.2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
