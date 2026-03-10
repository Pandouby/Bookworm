//
//  BookDetailsView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 15.10.2024.
//

import AVFoundation
import Foundation
import SwiftUI
import GRDBQuery
import GRDB

struct BookDetailsView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var book: CompleteBookDataViewModel
    @State private var showingDeleteConfirmation = false

    @ViewBuilder
    private var headerView: some View {
        GeometryReader { proxy in
            let minY = proxy.frame(in: .global).minY
            
            // Layout constants
            let baseHeight = 360.0
            let baseWidth = 240.0
            
            // Logic for vertical compression
            let scrollProgress = max(0, 30 - minY)
            let currentHeight = max(0, baseHeight - scrollProgress)
            let opacity = max(0.0, currentHeight / baseHeight)
            
            ZStack(alignment: .top) {
                BookCoverView(coverURL: book.cover, editionKey: book.editionKey)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: baseWidth, height: currentHeight)
                    .clipShape(RoundedCorner(radius: 16, corners: [.topLeft, .topRight]))
                    .clipped() 
            }
            .frame(width: proxy.size.width)
            .opacity(opacity)
            .offset(y: minY < 30 ? (30 - minY) : 0)
        }
        .frame(height: 300)
        .offset(y: 40)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerView
                    .zIndex(0)
                
                // Main Content Card
                VStack(spacing: 20) {
                    Spacer(minLength: 15) // Extra space at the top of the card
                    
                    // First Section: Book Info
                    VStack(spacing: 0) {
                        if book.workTitle.count > 25 {
                            NavigationLink(
                                destination: EditFieldView(
                                    fieldName: "Title", inputValue: $book.workTitle)
                            ) {
                                HStack {
                                    Text("Title")
                                        .foregroundStyle(.primary)
                                        .frame(width: 80, alignment: .leading)
                                    Spacer()
                                    Text(book.workTitle)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.trailing)
                                        .lineLimit(1)
                                    Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
                                }
                                .padding()
                            }
                            .onChange(of: book.workTitle) { saveData(book: book) }
                        } else {
                            HStack {
                                Text("Title")
                                    .foregroundStyle(.primary)
                                    .frame(width: 80, alignment: .leading)
                                Spacer()
                                TextField("Title", text: $book.workTitle)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.trailing)
                                    .onChange(of: book.workTitle) { saveData(book: book) }
                            }
                            .padding()
                        }

                        Divider().padding(.leading)

                        if book.authorName.count > 25 {
                            NavigationLink(
                                destination: EditFieldView(
                                    fieldName: "Author", inputValue: $book.authorName)
                            ) {
                                HStack {
                                    Text("Author")
                                        .foregroundStyle(.primary)
                                        .frame(width: 80, alignment: .leading)
                                    Spacer()
                                    Text(book.authorName)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.trailing)
                                        .lineLimit(1)
                                    Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
                                }
                                .padding()
                            }
                            .onChange(of: book.authorName) { saveData(book: book) }
                        } else {
                            HStack {
                                Text("Author")
                                    .foregroundStyle(.primary)
                                    .frame(width: 80, alignment: .leading)
                                Spacer()
                                TextField("Author", text: $book.authorName)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.trailing)
                                    .onChange(of: book.authorName) { saveData(book: book) }
                            }
                            .padding()
                        }

                        Divider().padding(.leading)

                        HStack {
                            Text("Genre")
                                .foregroundStyle(.primary)
                                .frame(width: 80, alignment: .leading)
                            
                            Spacer()
                            
                            Picker("Genre", selection: $book.genre) {
                                ForEach(Genre.allCases) { genre in
                                    Text(genre.rawValue)
                                        .lineLimit(1)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                        }
                        .padding(.leading)
                        .frame(minHeight: 44)
                        .onChange(of: book.genre) { saveData(book: book) }

                        Divider().padding(.leading)

                        HStack {
                            Text("Pages")
                                .foregroundStyle(.primary)
                                .frame(width: 80, alignment: .leading)
                            Spacer()
                            TextField("Pages", value: $book.pageCount, format: .number)
                                .keyboardType(.asciiCapableNumberPad)
                                .multilineTextAlignment(.trailing)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .onChange(of: book.pageCount) { saveData(book: book) }
                    }
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Second Section: Reading Status
                    VStack(spacing: 0) {
                        HStack {
                            Text("Status")
                                .foregroundStyle(.primary)
                            Spacer()
                            Picker("Status", selection: $book.status) {
                                ForEach(Status.allCases) { status in
                                    HStack {
                                        Text(status.rawValue)
                                        StatusIcon(status: status)
                                    }
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        .padding()
                        .onChange(of: book.status) { saveData(book: book) }

                        Divider().padding(.leading)

                        RatingView($book.userRating, maxRating: 5)
                            .padding()
                            .onChange(of: book.userRating) { saveData(book: book) }

                        Divider().padding(.leading)

                        DatePicker("Started", selection: $book.startDate, displayedComponents: .date)
                            .foregroundStyle(.primary)
                            .padding()
                            .onChange(of: book.startDate) { saveData(book: book) }

                        Divider().padding(.leading)

                        DatePicker("Finished", selection: $book.endDate, displayedComponents: .date)
                            .foregroundStyle(.primary)
                            .padding()
                            .onChange(of: book.endDate) { saveData(book: book) }

                        Divider().padding(.leading)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .foregroundStyle(.primary)
                                .frame(width: 80, alignment: .leading)
                            TextEditor(text: $book.notes)
                                .frame(height: 150) // Approx 6 lines of text
                                .padding(8)
                                .scrollContentBackground(.hidden) 
                                .background(Color(UIColor { traitCollection in
                                    return traitCollection.userInterfaceStyle == .dark 
                                        ? .systemGray5 
                                        : .systemGray6 
                                }))
                                .cornerRadius(8)
                        }
                        .padding()
                        .onChange(of: book.notes) { saveData(book: book) }
                    }
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Delete Button Section
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "trash")
                            Text("Delete Book")
                            Spacer()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
                .padding(.top, -35)
                .background(Color(UIColor.systemGroupedBackground))
                .clipShape(RoundedCorner(radius: 30, corners: [.topLeft, .topRight]))
                .zIndex(1)
            }
        }
        .scrollIndicators(.hidden)
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .confirmationDialog("Are you sure you want to delete this book?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete Book", role: .destructive) {
                Task {
                    do {
                        try DatabaseRepository.deleteCompleteBook(book.asRecord)
                        dismiss()
                    } catch {
                        print("Failed to delete book: \(error)")
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .toolbar {
            ToolbarItem {
                Button {
                    withAnimation(.smooth) {
                        book.isFavorite.toggle()
                        saveData(book: book)
                    }
                } label: {
                    Image(systemName: book.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(book.isFavorite ? .red : .primary)
                        .symbolRenderingMode(.hierarchical)
                        .contentTransition(.symbolEffect(.replace))
                }
            }
        }
    }
}

// Helper for specific corner rounding
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

private func saveData(book: CompleteBookDataViewModel) {
    print("Autosave on change")
    print(book.genre)
    print(book.genresEdited)
    print(book.asRecord)
    Task {
        try DatabaseRepository.saveCompleteBook(book.asRecord)
    }
}

#Preview {
    let dbQueue = AppDatabase.preview()
    DatabaseRepository.dbQueue = dbQueue
    
    let sampleBook = CompleteBookDataViewModel.sampleCompleteBookDataViewModels[0]
    
    return NavigationStack {
        BookDetailsView(book: sampleBook)
            .databaseContext(.readWrite { dbQueue })
    }
}
