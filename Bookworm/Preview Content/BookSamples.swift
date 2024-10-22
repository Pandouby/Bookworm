//
//  BookSamples.swift
//  Bookworm
//
//  Created by Silvan Dubach on 22.10.2024.
//

extension Book {
    static var sampleBooks: [Book] {
        [
            Book(
                isbn: "1234", title: "Test1", author: "Test1", pages: 123,
                genre: Genre.fiction,
                bookDescription:
                    "A test book to check if the layouting is working properly. This book has no content and is fake."
            ),
            Book(
                isbn: "4321", title: "Test2", author: "Test2", pages: 123,
                genre: Genre.fiction,
                bookDescription:
                    "A test book to check if the layouting is working properly. This book has no content and is fake."
            ),
            Book(
                isbn: "7123", title: "Test3", author: "Test3", pages: 123,
                genre: Genre.fiction,
                bookDescription:
                    "A test book to check if the layouting is working properly. This book has no content and is fake."
            )
        ]
    }
}
