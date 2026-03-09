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
    @Bindable var book: CompleteBookDataViewModel

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
                VStack(spacing: 0) {
                    Form {
                        Section {
                            NavigationLink(
                                destination: EditFieldView(
                                    fieldName: "Title", inputValue: $book.workTitle)
                            ) {
                                HStack {
                                    Text("Title")
                                    Spacer()
                                    Text(book.workTitle)
                                }
                            }
                            .onChange(of: book.workTitle) {
                                saveData(book: book)
                            }

                            NavigationLink(
                                destination: EditFieldView(
                                    fieldName: "Author", inputValue: $book.authorName)
                            ) {
                                HStack {
                                    Text("Author")
                                    Spacer()
                                    Text(book.authorName)
                                }
                            }
                            .onChange(of: book.authorName) {
                                saveData(book: book)
                            }

                            Picker("Genre", selection: $book.genre) {
                                ForEach(Genre.allCases) { genre in
                                    Text(genre.rawValue)
                                }
                            }
                            .pickerStyle(.navigationLink)
                            .onChange(of: book.genre) {
                                print(book.genre)
                                saveData(book: book)
                            }

                            TextField("Pages", value: $book.pageCount, format: .number)
                                .keyboardType(.asciiCapableNumberPad)
                                .onChange(of: book.pageCount) {
                                    saveData(book: book)
                                }
                        }

                        Section {
                            Picker("Status", selection: $book.status) {
                                ForEach(Status.allCases) { status in
                                    HStack {
                                        Text(status.rawValue)
                                        StatusIcon(status: status)
                                    }
                                }
                            }
                            .pickerStyle(.menu)
                            .onChange(of: book.status) {
                                saveData(book: book)
                            }

                            RatingView($book.userRating, maxRating: 5).padding(5)
                                .onChange(of: book.userRating) {
                                    saveData(book: book)
                                }

                            LabeledContent {
                                DatePicker(
                                    "Started",
                                    selection: $book.startDate, displayedComponents: .date
                                )
                                .labelsHidden()
                            } label: {
                                Text("Started")
                            }
                            .onChange(of: book.startDate) {
                                saveData(book: book)
                            }
                            
                            LabeledContent {
                                DatePicker(
                                    "Finished",
                                    selection: $book.endDate, displayedComponents: .date
                                )
                                .labelsHidden()
                            } label: {
                                Text("Finished")
                            }
                            .onChange(of: book.endDate) {
                                saveData(book: book)
                            }

                            VStack(alignment: .leading) {
                                Text("Notes")
                                TextEditor(text: $book.notes)
                                    .frame(height: 200)  // Set a height for better visibility
                                    .padding()
                                    .background(Color(UIColor.systemGray5))  // Background for TextEditor
                                    .cornerRadius(10)  // Rounded corners for aesthetics
                            }
                            .onChange(of: book.notes) {
                                saveData(book: book)
                            }
                        }
                    }
                    .scrollDisabled(true)
                    .frame(height: 850)
                    .padding(.top, -35)
                }
                .background(Color(UIColor.systemGroupedBackground))
                .clipShape(RoundedCorner(radius: 30, corners: [.topLeft, .topRight]))
                .zIndex(1)
            }
        }
        .scrollIndicators(.hidden)
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
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
