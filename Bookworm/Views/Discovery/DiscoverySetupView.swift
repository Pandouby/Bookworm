//
//  DiscoverySetupView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 04.11.2024.
//

/*

import SwiftUI

struct DiscoverySetupView: View {

    
    
    var books: [Book]
    @AppStorage("isDiscoveryActive") var isDiscoveryActive: Bool = false
    
    @AppStorage("FavoriteGenres") var favoriteGenres: [String] = [
        Genre.nonClassifiable.rawValue, Genre.nonClassifiable.rawValue, Genre.nonClassifiable.rawValue,
    ]
     

    private var enoughReadBooks: Bool

    init(books: [Book]) {
        self.books = books
        enoughReadBooks = books.count >= 10
    }

    var body: some View {
        VStack {
            NavigationStack {
                Form {
                    Section(header: Text("Favorite Genres")) {
                        Picker("1.", selection: $favoriteGenres[0]) {
                            ForEach(Genre.allCases) { genre in
                                Text(genre.rawValue)
                            }
                        }
                        .pickerStyle(.navigationLink)

                        Picker("2.", selection: $favoriteGenres[1]) {
                            ForEach(Genre.allCases) { genre in
                                Text(genre.rawValue)
                            }
                        }
                        .pickerStyle(.navigationLink)

                        Picker("3.", selection: $favoriteGenres[2]) {
                            ForEach(Genre.allCases) { genre in
                                Text(genre.rawValue)
                            }
                        }
                        .pickerStyle(.navigationLink)
                     
                    }

                    if !enoughReadBooks {
                        Section(header: Text("Book selection")) {
                            Text(
                                "You musst have at least 10 read books in your owned booklist."
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
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func submit() {
        print(favoriteGenres)

        if !favoriteGenres.contains(Genre.nonClassifiable.rawValue) {
            isDiscoveryActive = true
            UserDefaults.standard.set(
                [favoriteGenres[0], favoriteGenres[1], favoriteGenres[2]], forKey: "FavoriteGenres")
            print("Submited")
        } else {
            // Display an alert that are genres missing
            print("Please select 3 favorite genres")
        }
    }
     
}


 #Preview {
     let preview = Preview()
     preview.addExamples(Book.sampleBooks)
     
     return DiscoverySetupView(books: Book.sampleBooks)
     .modelContainer(preview.container)
 }
 
*/
