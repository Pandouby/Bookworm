//
//  CompleteBookDataSamples.swift
//  Bookworm
//
//  Created by Silvan Dubach on 25.02.2026.
//

import Foundation
import GRDB

extension CompleteBookDataViewModel {
    static var sampleCompleteBookDataViewModels: [CompleteBookDataViewModel] {
        // Sample Authors
        let author1 = Author(authorKey: "/authors/OL23919A", authorName: "Stephen King")
        let author2 = Author(authorKey: "/authors/OL1072979A", authorName: "J.K. Rowling")
        let author3 = Author(authorKey: "/authors/OL34336A", authorName: "Agatha Christie")

        // Sample Works
        let work1 = Work(workKey: "/works/OL45804W", workTitle: "It", subtitle: nil, workDescription: "A horror novel about an evil entity.", firstPublishYear: 1986)
        let work2 = Work(workKey: "/works/OL15447157W", workTitle: "Harry Potter and the Sorcerer's Stone", subtitle: nil, workDescription: "First book in the Harry Potter series.", firstPublishYear: 1997)
        let work3 = Work(workKey: "/works/OL15673197W", workTitle: "And Then There Were None", subtitle: nil, workDescription: "A classic mystery novel.", firstPublishYear: 1939)

        // Sample Editions
        let edition1 = Edition(editionKey: "/books/OL10000001M", workKey: work1.workKey, physicalFormat: "Paperback", editionTitle: "It", numberOfPages: 1138, isbn13: "9780451169518", isbn10: "0451169514", publishDate: "1986", cover: "https://covers.openlibrary.org/b/id/8259266-L.jpg")
        let edition2 = Edition(editionKey: "/books/OL10000002M", workKey: work2.workKey, physicalFormat: "Hardcover", editionTitle: "Harry Potter and the Sorcerer's Stone", numberOfPages: 309, isbn13: "9780590353403", isbn10: "0590353403", publishDate: "1997", cover: "https://covers.openlibrary.org/b/id/8267232-L.jpg")
        let edition3 = Edition(editionKey: "/books/OL10000003M", workKey: work3.workKey, physicalFormat: "Paperback", editionTitle: "And Then There Were None", numberOfPages: 264, isbn13: "9780062073488", isbn10: "0062073486", publishDate: "1939", cover: "https://covers.openlibrary.org/b/id/8750868-L.jpg")

        // Sample UserBookDetails
        let userDetails1 = UserBookDetails(editionKey: edition1.editionKey, addedDate: Date().addingTimeInterval(-86400 * 30), userRating: 4.5, isFavorite: true, status: .done, startDate: Date().addingTimeInterval(-86400 * 60), endDate: Date().addingTimeInterval(-86400 * 10), notes: "A truly terrifying masterpiece, kept me on the edge of my seat!")
        let userDetails2 = UserBookDetails(editionKey: edition2.editionKey, addedDate: Date().addingTimeInterval(-86400 * 15), userRating: 5.0, isFavorite: true, status: .inProgress, startDate: Date().addingTimeInterval(-86400 * 7), endDate: Date(), notes: "Re-reading this classic. Still magical!")
        let userDetails3 = UserBookDetails(editionKey: edition3.editionKey, addedDate: Date().addingTimeInterval(-86400 * 5), userRating: 3.8, isFavorite: false, status: .wantToRead, startDate: Date(), endDate: Date(), notes: "Heard great things about this mystery, planning to read it soon.")

        // Sample Genres
        let genre1 = Genre.fiction
        let genre2 = Genre.juvenile
        let genre3 = Genre.literaryCriticism

        // CompleteBookData
        let completeBookData1 = CompleteBookData(work: work1, edition: edition1, authors: [author1], genres: [genre1], userDetails: userDetails1)
        let completeBookData2 = CompleteBookData(work: work2, edition: edition2, authors: [author2], genres: [genre2], userDetails: userDetails2)
        let completeBookData3 = CompleteBookData(work: work3, edition: edition3, authors: [author3], genres: [genre3], userDetails: userDetails3)
        
        // CompleteBookDataViewModel
        return [
            CompleteBookDataViewModel(from: completeBookData1),
            CompleteBookDataViewModel(from: completeBookData2),
            CompleteBookDataViewModel(from: completeBookData3)
        ]
    }
}
