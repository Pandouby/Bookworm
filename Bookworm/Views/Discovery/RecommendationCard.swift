//
//  RecommendationCard.swift
//  Bookworm
//
//  Created by Silvan Dubach on 04.11.2024.
//

import SwiftUI
import GRDB

struct RecommendationCard: View {
    var book: CompleteBookData
    var onSwipeLeft: () -> Void
    var onSwipeRight: () -> Void
    
    @State private var offset = CGSize.zero
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Card Background
            RoundedRectangle(cornerRadius: 30)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 10)
            
            // Content Container with Fixed Top Padding
            VStack(spacing: 0) {
                // Fixed top spacer to keep padding constant at the very top of the card
                Spacer().frame(height: 16)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Book Cover
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemGray6))
                            
                            if let cover = book.edition.cover, let url = URL(string: cover) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 400)
                                .clipped()
                            } else {
                                Image(systemName: "book.closed.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.gray.opacity(0.4))
                            }
                        }
                        .frame(height: 400)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        VStack(alignment: .leading, spacing: 16) {
                            // Book Info
                            VStack(alignment: .leading, spacing: 6) {
                                Text(book.edition.editionTitle ?? book.work.workTitle)
                                    .font(.system(.title, design: .rounded, weight: .bold))
                                    .foregroundColor(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Text("by \(book.authors.first?.authorName ?? "Unknown Author")")
                                    .font(.system(.headline, design: .rounded, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            // Metadata Tags
                            HStack(spacing: 12) {
                                if let pages = book.edition.numberOfPages, pages > 0 {
                                    Label("\(pages) pages", systemImage: "book.pages")
                                        .font(.system(.caption, design: .rounded, weight: .semibold))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.secondary.opacity(0.1))
                                        .clipShape(Capsule())
                                }
                                
                                if let year = book.work.firstPublishYear {
                                    Label("\(String(year))", systemImage: "calendar")
                                        .font(.system(.caption, design: .rounded, weight: .semibold))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.secondary.opacity(0.1))
                                        .clipShape(Capsule())
                                }
                            }
                            .foregroundColor(.secondary)
                            
                            Divider()
                            
                            // Description
                            if let description = book.work.workDescription {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("About this book")
                                        .font(.system(.headline, design: .rounded, weight: .bold))
                                    
                                    Text(description)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundColor(.secondary)
                                        .lineSpacing(4)
                                }
                            }
                            
                            // Explicit spacing at the bottom for the buttons overlay
                            Spacer(minLength: 140)
                        }
                        .padding(.horizontal, 8)
                        .padding(.top, 24)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20)) // Matches image radius exactly
            }
            .padding(.horizontal, 16) // Narrow the whole column to match image width
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            // Bottom Action Buttons Overlay
            ZStack(alignment: .bottom) {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.secondarySystemBackground).opacity(0),
                        Color(.secondarySystemBackground).opacity(0.9),
                        Color(.secondarySystemBackground)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 160)
                .allowsHitTesting(false)
                
                HStack(spacing: 48) {
                    Button(action: {
                        withAnimation(.interpolatingSpring(stiffness: 150, damping: 15)) {
                            offset.width = -800
                            onSwipeLeft()
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.red)
                            .frame(width: 64, height: 64)
                            .background(
                                Circle()
                                    .fill(Color(.secondarySystemBackground))
                                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                            )
                    }
                    
                    Button(action: {
                        withAnimation(.interpolatingSpring(stiffness: 150, damping: 15)) {
                            offset.width = 800
                            onSwipeRight()
                        }
                    }) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.green)
                            .frame(width: 64, height: 64)
                            .background(
                                Circle()
                                    .fill(Color(.secondarySystemBackground))
                                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                            )
                    }
                }
                .padding(.bottom, 32)
            }
            .allowsHitTesting(true)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            // Visual Swipe Indicators (STAMP style) - Back over the image
            ZStack {
                if offset.width > 20 {
                    stamp(text: "WANT", color: .green, rotation: -15)
                        .padding(.leading, 40)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(Double(min(offset.width / 100, 1)))
                } else if offset.width < -20 {
                    stamp(text: "NOPE", color: .red, rotation: 15)
                        .padding(.trailing, 40)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .opacity(Double(min(-offset.width / 100, 1)))
                }
            }
            .frame(height: 400) // Match cover image height
            .padding(.top, 16) // Account for fixed top spacer
            .allowsHitTesting(false)
        }
        .offset(x: offset.width, y: offset.height * 0.2)
        .rotationEffect(.degrees(Double(offset.width / 15)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    // Only start swiping if the movement is predominantly horizontal
                    if abs(gesture.translation.width) > abs(gesture.translation.height) || abs(offset.width) > 0 {
                        offset = gesture.translation
                    }
                }
                .onEnded { _ in
                    if offset.width > 140 {
                        withAnimation(.spring()) {
                            offset.width = 1000
                            onSwipeRight()
                        }
                    } else if offset.width < -140 {
                        withAnimation(.spring()) {
                            offset.width = -1000
                            onSwipeLeft()
                        }
                    } else {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            offset = .zero
                        }
                    }
                }
        )
        .padding(.horizontal, 16)
        .frame(maxHeight: .infinity)
    }
    
    private func stamp(text: String, color: Color, rotation: Double) -> some View {
        Text(text)
            .font(.system(size: 42, weight: .black, design: .rounded))
            .foregroundColor(color)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color, lineWidth: 6)
            )
            .rotationEffect(.degrees(rotation))
    }
}

#Preview {
    let dbQueue = AppDatabase.preview()
    DatabaseRepository.dbQueue = dbQueue
    
    let books = try! dbQueue.read { db in
        try DatabaseRepository.queryAllUserBookDetails(db: db)
    }

    return RecommendationCard(
        book: books[0],
        onSwipeLeft: { print("Left") },
        onSwipeRight: { print("Right") }
    )
    .databaseContext(.readWrite { dbQueue })
}
