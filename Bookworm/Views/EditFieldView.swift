//
//  EditFieldView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 17.10.2024.
//

import SwiftData
import SwiftUI

struct EditFieldView: View {
    var fieldName: String
    @Binding var inputValue: String

    var body: some View {
        Form {
            TextField(fieldName, text: $inputValue)
                .modifier(TextFieldClearButton(inputValue: $inputValue))
                .multilineTextAlignment(.leading)
                .scrollDismissesKeyboard(.automatic)
            //.padding()

        }
        .navigationTitle("Edit \(fieldName)")
    }
}

struct TextFieldClearButton: ViewModifier {
    @Binding var inputValue: String

    func body(content: Content) -> some View {
        HStack {
            content

            if !inputValue.isEmpty {
                Button(
                    action: { self.inputValue = "" },
                    label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(UIColor.opaqueSeparator))
                    }
                )
            }
        }
    }
}
