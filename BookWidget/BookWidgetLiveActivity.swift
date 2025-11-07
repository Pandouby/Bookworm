//
//  BookWidgetLiveActivity.swift
//  BookWidget
//
//  Created by Silvan Dubach on 11.06.2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct BookWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct BookWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BookWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension BookWidgetAttributes {
    fileprivate static var preview: BookWidgetAttributes {
        BookWidgetAttributes(name: "World")
    }
}

extension BookWidgetAttributes.ContentState {
    fileprivate static var smiley: BookWidgetAttributes.ContentState {
        BookWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: BookWidgetAttributes.ContentState {
         BookWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: BookWidgetAttributes.preview) {
   BookWidgetLiveActivity()
} contentStates: {
    BookWidgetAttributes.ContentState.smiley
    BookWidgetAttributes.ContentState.starEyes
}
