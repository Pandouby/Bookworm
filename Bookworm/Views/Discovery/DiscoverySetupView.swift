import SwiftUI
import GRDB

struct DiscoverySetupView: View {
    var books: [CompleteBookData]
    @AppStorage("isDiscoveryActive") var isDiscoveryActive: Bool = false
    
    @State private var selectedGenre1: String = Genre.nonClassifiable.rawValue
    @State private var selectedGenre2: String = Genre.nonClassifiable.rawValue
    @State private var selectedGenre3: String = Genre.nonClassifiable.rawValue

    private var enoughReadBooks: Bool

    init(books: [CompleteBookData]) {
        self.books = books
        enoughReadBooks = books.count >= 3 
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Favorite Genres")) {
                    Picker("1.", selection: $selectedGenre1) {
                        ForEach(Genre.allCases) { genre in
                            Text(genre.rawValue).tag(genre.rawValue)
                        }
                    }
                    .pickerStyle(.navigationLink)

                    Picker("2.", selection: $selectedGenre2) {
                        ForEach(Genre.allCases) { genre in
                            Text(genre.rawValue).tag(genre.rawValue)
                        }
                    }
                    .pickerStyle(.navigationLink)

                    Picker("3.", selection: $selectedGenre3) {
                        ForEach(Genre.allCases) { genre in
                            Text(genre.rawValue).tag(genre.rawValue)
                        }
                    }
                    .pickerStyle(.navigationLink)
                 
                }

                if !enoughReadBooks {
                    Section(header: Text("Book selection")) {
                        Text(
                            "You must have at least 3 read books in your owned booklist."
                        )
                        .font(.callout)
                        .opacity(0.7)
                    }
                }

                Button(action: submit) {
                    Text("Submit")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBlue))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .opacity(enoughReadBooks ? 1 : 0.4)
                }
                .disabled(!enoughReadBooks)
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)

            }
            .navigationTitle("Discovery Setup")
            .onAppear {
                loadFavoriteGenres()
            }
        }
    }

    private func loadFavoriteGenres() {
        if let genres = UserDefaults.standard.array(forKey: "FavoriteGenres") as? [String] {
            if genres.count >= 1 { selectedGenre1 = genres[0] }
            if genres.count >= 2 { selectedGenre2 = genres[1] }
            if genres.count >= 3 { selectedGenre3 = genres[2] }
        }
    }

    private func submit() {
        let favoriteGenres = [selectedGenre1, selectedGenre2, selectedGenre3]
        print(favoriteGenres)

        if !favoriteGenres.contains(Genre.nonClassifiable.rawValue) {
            isDiscoveryActive = true
            UserDefaults.standard.set(favoriteGenres, forKey: "FavoriteGenres")
            print("Submited")
        } else {
            // Display an alert that are genres missing
            print("Please select 3 favorite genres")
        }
    }
}

#Preview {
    let dbQueue = AppDatabase.preview()
    DatabaseRepository.dbQueue = dbQueue
    
    let books = try! dbQueue.read { db in
        try DatabaseRepository.queryAllUserBookDetails(db: db)
    }

    return DiscoverySetupView(books: books)
        .databaseContext(.readWrite { dbQueue })
}
