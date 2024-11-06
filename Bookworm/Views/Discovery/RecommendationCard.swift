//
//  RecommendationCard.swift
//  Bookworm
//
//  Created by Silvan Dubach on 04.11.2024.
//

import SwiftUI

struct RecommendationCard: View {
    var book: Book
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    .white
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 24)
                )
                .shadow(color: .widgetShadow, radius: 10)
            
            VStack {
                VStack(alignment: .leading) {
                    ZStack {
                        Rectangle()
                            .fill(.widget)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 14)
                            )
                        
                        AsyncImage(
                            url: URL(
                                string: book.imageLink ?? ""
                            )
                        ) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .frame(maxHeight: 400)
                    
                    Text(book.title)
                        .font(.title)
                        .bold()
                    
                    Text("By \(book.author)")
                        .font(.callout)
                        .opacity(0.7)
                        .bold()
                }
                
                Spacer()
                
                HStack {
                    Image(systemName: "x.circle")
                        .frame(maxWidth: .infinity)
                        .font(.system(size: 30))
                        .foregroundColor(Color(.systemRed))
                    
                    Image(systemName: "checkmark")
                        .frame(maxWidth: .infinity)
                        .font(.system(size: 30))
                        .foregroundColor(Color(.systemGreen))
                }
            }
            .padding()
        }
        .padding()
        .frame(maxHeight: 600)
    }
}

#Preview {
    let preview = Preview()
    preview.addExamples(Book.sampleBooks)
    
    return RecommendationCard(book: Book.sampleBooks[9])
        .modelContainer(preview.container)
}
