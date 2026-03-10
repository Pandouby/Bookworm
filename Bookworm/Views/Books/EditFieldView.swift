//
//  EditFieldView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 17.10.2024.
//

import SwiftUI

struct EditFieldView: View {
    var fieldName: String
    @Binding var inputValue: String
    @FocusState private var isFocused: Bool
    
    // Local state to hold the value while editing
    @State private var tempValue: String = ""

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 12) {
                Text(fieldName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                TextEditor(text: $tempValue)
                    .focused($isFocused)
                    .frame(minHeight: 125) // Approx 5 lines of text
                    .padding(8)
                    .scrollContentBackground(.hidden)
                    .background(Color(UIColor { traitCollection in
                        return traitCollection.userInterfaceStyle == .dark 
                            ? .systemGray5 
                            : .systemGray6 
                    }))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
            .padding(.top)
        }
        .navigationTitle("Edit \(fieldName)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            tempValue = inputValue
            isFocused = true
        }
        .onDisappear {
            updateValue()
        }
    }
    
    private func updateValue() {
        let trimmed = tempValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            inputValue = trimmed
        }
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
                .buttonStyle(.plain) // Prevents the button from capturing taps intended for the text field
            }
        }
    }
}

#Preview {
    @Previewable @State var inputValue = "Sample Text"
    
    return EditFieldView(fieldName: "Test view", inputValue: $inputValue)
}
