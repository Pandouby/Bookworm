import SwiftUI

struct SettingsView: View {
    @AppStorage("isDiscoveryActive") var isDiscoveryActive: Bool = false
    @AppStorage("PreferredLanguage") var preferredLanguage: String = "eng"
    
    @State private var selectedGenre1: String = Genre.nonClassifiable.rawValue
    @State private var selectedGenre2: String = Genre.nonClassifiable.rawValue
    @State private var selectedGenre3: String = Genre.nonClassifiable.rawValue
    
    let languages = [
        ("English", "eng"),
        ("German", "ger"),
        ("French", "fre"),
        ("Italian", "ita"),
        ("Spanish", "spa")
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Discovery Preferences")) {
                    Picker("Genre 1", selection: $selectedGenre1) {
                        ForEach(Genre.allCases) { genre in
                            Text(genre.rawValue).tag(genre.rawValue)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    
                    Picker("Genre 2", selection: $selectedGenre2) {
                        ForEach(Genre.allCases) { genre in
                            Text(genre.rawValue).tag(genre.rawValue)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    
                    Picker("Genre 3", selection: $selectedGenre3) {
                        ForEach(Genre.allCases) { genre in
                            Text(genre.rawValue).tag(genre.rawValue)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    
                    Picker("Preferred Language", selection: $preferredLanguage) {
                        ForEach(languages, id: \.1) { name, code in
                            Text(name).tag(code)
                        }
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        isDiscoveryActive = false
                    } label: {
                        Text("Reset Discovery Setup")
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                loadGenres()
            }
            // Sync changes back to UserDefaults
            .onChange(of: selectedGenre1) { _, _ in saveGenres() }
            .onChange(of: selectedGenre2) { _, _ in saveGenres() }
            .onChange(of: selectedGenre3) { _, _ in saveGenres() }
        }
    }
    
    private func loadGenres() {
        if let genres = UserDefaults.standard.array(forKey: "FavoriteGenres") as? [String] {
            if genres.count >= 1 { selectedGenre1 = genres[0] }
            if genres.count >= 2 { selectedGenre2 = genres[1] }
            if genres.count >= 3 { selectedGenre3 = genres[2] }
        }
    }
    
    private func saveGenres() {
        let genres = [selectedGenre1, selectedGenre2, selectedGenre3]
        UserDefaults.standard.set(genres, forKey: "FavoriteGenres")
    }
}

#Preview {
    SettingsView()
}
