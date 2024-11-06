import Foundation
import SwiftData
//
//  Untitled.swift
//  Bookworm
//
//  Created by Silvan Dubach on 21.10.2024.
//
import SwiftUI

struct BooksView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [
        SortDescriptor(\Book.statusOrder),
        SortDescriptor(\Book.finishedDate, order: .reverse),
        SortDescriptor(\Book.dateAdded, order: .reverse),
        SortDescriptor(\Book.title),
    ])
    private var books: [Book]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 15) {
                VStack(alignment: .leading) {
                    Text(
                        "\(dateStringFormatter(date: Date(), formattingString: "EEEE, MMMM dd", isUppercase: true))"
                    )
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
                                Image(systemName: "books.vertical.fill")
                                    .foregroundColor(.white)
                                    .opacity(0.6)

                                Text("Owned Books")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .bold()
                                    .padding(.top, 5)

                                Text(
                                    "\(books.filter { $0.status != .wantToRead }.count) items"
                                )
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

                                Text("Want to read")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .bold()
                                    .padding(.top, 5)

                                Text(
                                    "\(books.filter { $0.status == .wantToRead }.count) items"
                                )
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

                let currentBook = books.filter {
                    $0.status == Status.inProgress
                }.first

                NavigationLink(
                    destination: currentBook.map { BookDetailsView(book: $0) }
                ) {
                    ZStack(alignment: .topLeading) {
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

                        VStack(alignment: .leading) {
                            Image(systemName: "book.fill")
                                .foregroundColor(.white)
                                .opacity(0.6)

                            Text("Currenlty reading")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .bold()
                                .padding(.top, 5)

                            if let currentBook = currentBook {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading) {

                                        Text("\(currentBook.title)")
                                            .foregroundStyle(.white)
                                            .bold()

                                        Text("By \(currentBook.author)")
                                            .foregroundStyle(.white)
                                            .opacity(0.8)

                                        Text(
                                            "Started at \(dateStringFormatter(date: currentBook.startedDate, formattingString: "MMMM dd"))"
                                        )
                                        .foregroundStyle(.white)
                                        .opacity(0.8)

                                        Spacer()
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing) {
                                        Text("\(currentBook.genre.rawValue)")
                                            .foregroundStyle(.white)
                                            .opacity(0.8)

                                        Text("\(currentBook.pageCount) pages")
                                            .foregroundStyle(.white)
                                            .opacity(0.8)
                                        Spacer()
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            } else {
                                Text("No book in progress")
                                    .foregroundStyle(.white)
                                    .opacity(0.8)
                                Spacer()
                            }
                        }
                        .padding()
                    }
                    .frame(height: 200)
                    .shadow(color: .widgetShadow, radius: 10)
                }

                Spacer()
            }
            .frame(
                maxWidth: .infinity, maxHeight: .infinity,
                alignment: .topLeading
            )
            .padding()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Book.self, configurations: config)

    for i in 1..<10 {
        let book = Book(
            isbn: "1234", title: "Test", author: "Test", pages: 123,
            genre: Genre.fiction,
            bookDescription:
                "A test book to check if the layouting is working properly. This book has no content and is fake."
        )
        container.mainContext.insert(book)
    }

    return BooksView()
        .modelContainer(container)
}
