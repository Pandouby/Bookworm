import SwiftUI
import GRDBQuery
import GRDB

struct BooksView: View {
    @Query(AllCompleteBooksQuery()) private var completeBooks: [CompleteBookData]

    var body: some View {
        let currentBook = completeBooks.first { $0.userDetails.status == .inProgress }
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
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
                                    "\(completeBooks.filter { $0.userDetails.status != .wantToRead }.count) items"
                                )
                                .foregroundStyle(.white)
                                .opacity(0.8)

                                Spacer()
                            }
                            .padding()
                        }
                        .frame(maxWidth: .infinity)
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
                                    "\(completeBooks.filter { $0.userDetails.status == .wantToRead }.count) items"
                                )
                                .foregroundStyle(.white)
                                .opacity(0.8)

                                Spacer()
                            }
                            .padding()

                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .shadow(color: .widgetShadow, radius: 10)
                    }
                }

                let currentBook = completeBooks.filter {
                    $0.userDetails.status == Status.inProgress
                }.first

                NavigationLink(
                    destination: currentBook.map { BookDetailsView(book: CompleteBookDataViewModel(from: $0)) }
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

                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "book.fill")
                                    .foregroundColor(.white)
                                    .opacity(0.6)

                                Text("Currently reading")
                                    .font(.system(.title3, design: .rounded, weight: .bold))
                                    .foregroundStyle(.white)
                            }

                            if let currentBook = currentBook {
                                HStack(alignment: .top, spacing: 16) {
                                    // Cover Image or Placeholder
                                    if let cover = currentBook.edition.cover, let url = URL(string: cover) {
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        } placeholder: {
                                            Color.white.opacity(0.1)
                                        }
                                        .frame(width: 94, height: 140)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                                    } else {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white.opacity(0.15))
                                            Image(systemName: "book.closed.fill")
                                                .font(.system(size: 30))
                                                .foregroundColor(.white.opacity(0.4))
                                        }
                                        .frame(width: 94, height: 140)
                                    }

                                    // Book Details
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(currentBook.edition.editionTitle ?? currentBook.work.workTitle)
                                            .font(.system(.headline, design: .rounded))
                                            .foregroundStyle(.white)
                                            .lineLimit(2)
                                            .truncationMode(.tail)
                                            .multilineTextAlignment(.leading)
                                            .fixedSize(horizontal: false, vertical: true)

                                        Text("By \(currentBook.authors.first?.authorName ?? "Unknown Author")")
                                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                                            .foregroundStyle(.white)
                                            .opacity(0.8)
                                            .lineLimit(1)
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Started: \(currentBook.userDetails.startDate.formattedLocale())")
                                                Text("\(currentBook.edition.numberOfPages ?? 0) pages")
                                            }
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundStyle(.white)
                                            .opacity(0.7)
                                            
                                            // Genre Pill at the bottom
                                            if let firstGenre = currentBook.genres.first {
                                                Text(firstGenre.rawValue)
                                                    .font(.system(.caption2, design: .rounded, weight: .bold))
                                                    .foregroundStyle(.white)
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 4)
                                                    .background(Capsule().fill(Color.white.opacity(0.2)))
                                            }
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.bottom, 5)
                            } else {
                                HStack {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.15))
                                        Image(systemName: "book.closed.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(.white.opacity(0.4))
                                    }
                                    .frame(width: 94, height: 140)
                                    
                                    Text("No book in progress")
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundStyle(.white)
                                        .opacity(0.8)
                                        .padding(.leading, 8)
                                    
                                    Spacer()
                                }
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
    let dbQueue = AppDatabase.preview()
    DatabaseRepository.dbQueue = dbQueue
    
    return BooksView()
        .databaseContext(.readWrite { dbQueue })
}
