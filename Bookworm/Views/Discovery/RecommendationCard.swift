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
    var onSwipeUp: () -> Void
    
    @State private var offset = CGSize.zero
    @State private var isDragging = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Card Background
            RoundedRectangle(cornerRadius: 30)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(isDragging ? 0.25 : 0.12), radius: isDragging ? 30 : 20, x: 0, y: isDragging ? 20 : 10)
            
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
                .scrollDisabled(isDragging)
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
                
                HStack(spacing: 32) {
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
                            offset.height = -1000
                            onSwipeUp()
                        }
                    }) {
                        Image(systemName: "books.vertical.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.blue)
                            .frame(width: 54, height: 54)
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
            .allowsHitTesting(!isDragging)
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
                } else if offset.height < -20 {
                    stamp(text: "READ", color: .blue, rotation: 0)
                        .frame(maxHeight: .infinity, alignment: .center)
                        .opacity(Double(min(-offset.height / 100, 1)))
                }
            }
            .frame(height: 400) // Match cover image height
            .padding(.top, 16) // Account for fixed top spacer
            .allowsHitTesting(false)
        }
        .offset(x: offset.width, y: offset.height)
        .rotationEffect(.degrees(Double(offset.width / 15)))
        .scaleEffect(isDragging ? 1.03 : 1.0)
        .gesture(
            LongPressGesture(minimumDuration: 0.3)
                .onEnded { _ in
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isDragging = true
                    }
                }
                .simultaneously(with:
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            if isDragging {
                                offset = gesture.translation
                            } else if abs(gesture.translation.width) > abs(gesture.translation.height) {
                                // Only allow immediate drag if it's horizontal
                                offset.width = gesture.translation.width
                            }
                        }
                        .onEnded { gesture in
                            let finalOffset = gesture.translation
                            let verticalSwipe = isDragging && finalOffset.height < -140
                            let horizontalSwipeRight = finalOffset.width > 140
                            let horizontalSwipeLeft = finalOffset.width < -140
                            
                            withAnimation(.spring()) {
                                if horizontalSwipeRight {
                                    offset.width = 1000
                                    onSwipeRight()
                                } else if horizontalSwipeLeft {
                                    offset.width = -1000
                                    onSwipeLeft()
                                } else if verticalSwipe {
                                    offset.height = -1000
                                    onSwipeUp()
                                } else {
                                    offset = .zero
                                }
                                isDragging = false
                            }
                        }
                )
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
        onSwipeRight: { print("Right") },
        onSwipeUp: { print("Up") }
    )
    .databaseContext(.readWrite { dbQueue })
}
