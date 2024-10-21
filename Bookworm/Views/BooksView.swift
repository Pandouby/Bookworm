import Foundation
//
//  Untitled.swift
//  Bookworm
//
//  Created by Silvan Dubach on 21.10.2024.
//
import SwiftUI

struct BooksView: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 15) {
                VStack(alignment: .leading) {
                    Text("\(getCurrentDateString())")
                        .font(.subheadline)
                    Text("Your Books")
                        .font(.largeTitle)
                        .bold()
                }
                .padding(.top, 10)
                
                HStack(spacing: 15) {
                    NavigationLink(destination: OwnedBooksView()) {
                        ZStack(alignment: .topLeading) {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .customRed, .customRedAccent,
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            /*
                             .fill(
                             LinearGradient(
                             gradient: Gradient(colors: [
                             .customPurple, .customBlue, .customRed,
                             ]),
                             startPoint: .topLeading,
                             endPoint: .bottomTrailing)
                             )
                             */
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 24)
                                )
                            
                            VStack(alignment: .leading) {
                                Image(systemName: "book")
                                    .foregroundColor(.white)
                                    .opacity(0.6)
                                
                                Text("Owned Books").font(.callout)
                                    .foregroundStyle(.white)
                                    .bold()
                                    .padding(.top, 5)
                                
                                Text("test")
                                    .foregroundStyle(.white)
                                    .opacity(0.8)
                                
                                Spacer()
                            }
                            .padding()
                        }
                        .frame(height: 200)
                        .shadow(color: .widgetShadow, radius: 10)
                    }
                    
                    NavigationLink(destination: WantToReadView()) {
                        ZStack(alignment: .topLeading) {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .customPurpleAccent, .customPurple,
                                        ]),
                                        startPoint: .bottomLeading,
                                        endPoint: .trailing
                                    )
                                )
                            /*
                             .fill(
                             LinearGradient(
                             gradient: Gradient(colors: [
                             .customRed, .customBlue, .customPurple,
                             ]),
                             startPoint: .bottom,
                             endPoint: .topTrailing)
                             )
                             */
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 24)
                                )
                            
                            VStack(alignment: .leading) {
                                Image(systemName: "cart.fill")
                                    .foregroundColor(.white)
                                    .opacity(0.6)
                                
                                Text("Want to read").font(.callout)
                                    .foregroundStyle(.white)
                                    .bold()
                                    .padding(.top, 5)
                                
                                Text("test")
                                    .foregroundStyle(.white)
                                    .opacity(0.8)
                                
                                Spacer()
                            }
                            .padding()
                            
                        }
                        .frame(height: 200)
                        .shadow(color: .widgetShadow, radius: 10)
                    }
                }
                
                NavigationLink(destination: WantToReadView()) {
                    ZStack {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .customBlueAccent, .customBlue,
                                    ]),
                                    startPoint: .topTrailing,
                                    endPoint: .bottomLeading
                                )
                            )
                        /*
                         .fill(
                         LinearGradient(
                         gradient: Gradient(colors: [
                         .customRed, .customBlue, .customPurple,
                         ]),
                         startPoint: .top,
                         endPoint: .bottomLeading)
                         )
                         */
                            .clipShape(
                                RoundedRectangle(cornerRadius: 24)
                            )
                        
                    }
                    .frame(height: 200)
                    .shadow(color: .widgetShadow, radius: 10)
                }
                
                Spacer()
            }
            .frame(
                maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading
            )
            .padding()
        }
    }
}

func getCurrentDateString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMMM dd"
    return formatter.string(from: Date()).uppercased()
}

#Preview {
    BooksView()
}
