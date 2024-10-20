//
//  CustomTabView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 18.10.2024.
//

import SwiftUI

struct CustomTabView: View {
    @Binding var tabIndex: Int
    
    let tabBarItems: [(iconName: String, name: String)] = [
        ("house.fill", "Home"),
        ("magnifyingglass", "Search"),
        ("person.fill", "Settings")
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
                ForEach(0..<3) { index in
                    Button {
                        if (tabIndex == index + 1) {
                            
                        } else {
                            tabIndex = index + 1
                        }
                    } label: {
                        VStack() {
                            Image(systemName: tabBarItems[index].iconName)
                                .font(.system(size: index + 1 == tabIndex ? 30 : 20))
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

struct CustomTabViewPreview: PreviewProvider {
    static var previews: some View {
        CustomTabView(tabIndex: .constant(1))
    }
}


