//
//  BookWidgetBundle.swift
//  BookWidget
//
//  Created by Silvan Dubach on 11.06.2025.
//

import WidgetKit
import SwiftUI

@main
struct BookWidgetBundle: WidgetBundle {
    var body: some Widget {
        BookWidget()
        BookWidgetControl()
        BookWidgetLiveActivity()
    }
}
