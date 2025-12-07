import SwiftUI
import GRDBQuery
import GRDB

struct BooksView: View {
    @Query(AllCompleteBooksQuery()) private var completeBooks: [CompleteBookData]

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
                                    "\(completeBooks.filter { $0.userDetails.status != .wantToRead }.count) items"
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
                                    "\(completeBooks.filter { $0.userDetails.status == .wantToRead }.count) items"
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

                        VStack(alignment: .leading) {
                            Image(systemName: "book.fill")
                                .foregroundColor(.white)
                                .opacity(0.6)

                            Text("Currently reading")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .bold()
                                .padding(.top, 5)

                            if let currentBook = currentBook {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading) {

                                        Text(currentBook.edition.editionTitle ?? currentBook.work.workTitle)
                                            .foregroundStyle(.white)
                                            .bold()

                                        Text("By \(currentBook.authors.first?.authorName ?? "Unknown Author")")
                                            .foregroundStyle(.white)
                                            .opacity(0.8)

                                        Text(
                                            "Started at \(dateStringFormatter(date: currentBook.userDetails.startDate, formattingString: "MMMM dd"))"
                                        )
                                        .foregroundStyle(.white)
                                        .opacity(0.8)

                                        Spacer()
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing) {
                                        Text(currentBook.genres.first?.rawValue ?? "N/A")
                                            .foregroundStyle(.white)
                                            .opacity(0.8)

                                        Text("\(currentBook.edition.numberOfPages ?? 0) pages")
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
    let dbQueue = AppDatabase.preview()
    
    BooksView()
        .databaseContext(.readWrite { dbQueue })
}

