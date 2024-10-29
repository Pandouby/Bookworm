//
//  CustomTabView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 18.10.2024.
//

import SwiftUI

struct CustomTabView: View {
    @Binding var tabIndex: Int
    @Environment(\.dismiss) var dismiss
    
    let tabBarItems: [(iconName: String, name: String)] = [
        ("book.closed", "Owned books"),
        ("magnifyingglass", "Descovery"),
        ("chart.bar.xaxis", "Settings"),
        ("slider.horizontal.2.square", "Settings")
    ]
    
        
    var body: some View {
        ZStack {
            Capsule()
                .frame(height: 60)
                .cornerRadius(16)
                .foregroundColor(Color(.secondarySystemBackground))
                .shadow(radius: 2)
                .padding(.horizontal, 10)
            
            HStack {
                ForEach(0..<4) { index in
                    Button {
                        if (tabIndex == index + 1) {
                            dismiss()
                        } else {
                            tabIndex = index + 1
                        }
                    } label: {
                        VStack() {
                            Image(systemName: tabBarItems[index].iconName)
                                //.font(.system(size: index + 1 == tabIndex ? 30 : 25))
                                .font(.system(size: 30))
                                .foregroundColor(index + 1 == tabIndex ? Color.accentColor : Color.gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 80)
            .padding(.horizontal)
        }
    }
}

#Preview {
    CustomTabView(tabIndex: .constant(1))
}


