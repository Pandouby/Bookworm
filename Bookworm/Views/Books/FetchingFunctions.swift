//
//  FetchingFunctions.swift
//  Bookworm
//
//  Created by Silvan Dubach on 03.12.2025.
//

import SwiftUI

// MARK: - FETCH COMPLETE BOOK

func fetchCompleteBookDataByWork(for work: WorkResponse, languages: [String]) async -> FullSearchResult? {
    guard let workKey = work.workKey.split(separator: "/").last else { return nil }
    let authorKey = work.authorKeys?.first
    print("Author-Key -----------------")
    print(authorKey!)
    
    let workURL = URL(string: "https://openlibrary.org/works/\(workKey).json")!
    let editionURL = URL(string: "https://openlibrary.org/works/\(workKey)/editions.json")!
    
    do {
        async let workData = URLSession.shared.data(from: workURL)
        async let editionData = URLSession.shared.data(from: editionURL)
        
        let (workRaw, _) = try await workData
        let (editionRaw, _) = try await editionData
        
        print("Work------------")
        print(work)
        
        let workDetails = try JSONDecoder().decode(DetailWorkResponse.self, from: workRaw)
        print("Work-Details------------")
        print(workDetails)
        
        // Find out error here
        let editionListResponse = try JSONDecoder().decode(EditionListResponse.self, from: editionRaw)
        print("Edition------------")
        print(editionListResponse)
        
        let authorResponse: AuthorResponse
        
        if let authorKey, !authorKey.isEmpty,
           let authorURL = URL(string: "https://openlibrary.org/authors/\(authorKey).json") {
            
            async let authorData = URLSession.shared.data(from: authorURL)
            let (authorRaw, _) = try await authorData
            authorResponse = try JSONDecoder().decode(AuthorResponse.self, from: authorRaw)
            
        } else {
            print("⚠️ No author key available for this book!")
            authorResponse = AuthorResponse(authorKey: "", authorName: "Unknown Author")
        }
        
        print("Author------------")
        print(authorResponse)
        
        let editions = editionListResponse.entries
        
        var bestEdition = editions.first { edition in
            let hasISBN = !(edition.isbn_13?.isEmpty ?? true) || !(edition.isbn_10?.isEmpty ?? true)
            let hasPageCount = edition.number_of_pages != nil
            
            var matchesLanguage: Bool
            
            if let lang = languages.first {
                matchesLanguage = edition.languages?.contains {
                    $0.key == "/languages/\(lang)"
                } ?? false
            } else {
                matchesLanguage = false
            }
            
            return hasISBN && hasPageCount && matchesLanguage
        } ?? editions.first
        
        let imageLink: String?
        if let coverId = bestEdition?.covers?.first {
            imageLink = "https://covers.openlibrary.org/b/id/\(coverId)-L.jpg"
        } else { imageLink = nil }
        
        bestEdition?.coverLink = imageLink
        
        print("-------------------------")
        print(bestEdition!)
        
        if var edition = bestEdition {
            edition.isbn_13 = [edition.isbn_13?.first ?? ""]
            edition.isbn_10 = [edition.isbn_10?.first ?? ""]
            edition.number_of_pages = edition.number_of_pages ?? 0
            bestEdition = edition
        }
        
        let fullWork = WorkResponse(workKey: work.workKey, workTitle: work.workTitle, description: workDetails.description, editionKeys: work.editionKeys, authorKeys: work.authorKeys, languages: work.languages, firstPublishYear: work.firstPublishYear, subjects: work.subjects)
        
        //print("-----------------------------------")
        //print(fullWork, bestEdition!, authorResponse)
        
        return createBook(from: fullWork, edition: bestEdition, authors: [authorResponse])
        
    } catch {
        print("---------------------")
        print("Fetch error: ", error)
        return (nil)
    }
    }

func fetchCompleteBookDataByEdition(for edition: EditionResponse, languages: [String]) async -> FullSearchResult? {
    var edition = edition
    guard let workKey = edition.works?.first?.key.split(separator: "/").last else { return nil }
    
    let workURL = URL(string: "https://openlibrary.org/works/\(workKey).json")!
    
    do {
        async let workData = URLSession.shared.data(from: workURL)
        
        let (workRaw, _) = try await workData
        
        let workDetails = try JSONDecoder().decode(DetailWorkResponse.self, from: workRaw)
        print("Work-Details------------")
        print(workDetails)
        
        let authorKey = workDetails.authors?.first?.author.key.split(separator: "/").last ?? ""
        print("Author-Key -----------------")
        print(authorKey)
        let authorURL = URL(string: "https://openlibrary.org/authors/\(authorKey).json")!
        
        let authorResponse: AuthorResponse
        
        async let authorData = URLSession.shared.data(from: authorURL)
        let (authorRaw, _) = try await authorData
        do {
            authorResponse = try JSONDecoder().decode(AuthorResponse.self, from: authorRaw)
        } catch {
            print("⚠️ No author key available for this book!")
            authorResponse = AuthorResponse(authorKey: "", authorName: "Unknown Author")
        }
        
        print("Author------------")
        print(authorResponse)
        
        let imageLink: String?
        if let coverId = edition.covers?.first {
            imageLink = "https://covers.openlibrary.org/b/id/\(coverId)-L.jpg"
        } else { imageLink = nil }
        
        edition.coverLink = imageLink
        
        print("Edition------------")
        print(edition)
        
        let authorKeys = workDetails.authors?.map { $0.author.key } ?? []
        
        print("Author-Keys-----------")
        print(authorKeys)
        
        let fullWork = WorkResponse(workKey: workDetails.workKey, workTitle: workDetails.workTitle, description: workDetails.description, editionKeys: [edition.key], authorKeys: authorKeys, languages: workDetails.languages, firstPublishYear: workDetails.firstPublishYear, subjects: workDetails.subjects)
        
        //print("-----------------------------------")
        //print(fullWork, bestEdition!, authorResponse)
        
        return createBook(from: fullWork, edition: edition, authors: [authorResponse])
        
    } catch {
        print("---------------------")
        print("Fetch error: ", error)
        return (nil)
    }
}


// MARK: - BOOK CREATION

func createBook(from work: WorkResponse, edition: EditionResponse?, authors: [AuthorResponse]?) -> FullSearchResult {
    print("---CREATE BOOK---")
    let genre: Genre = work.subjects?
        .compactMap { Genre(rawValue: $0) }
        .first ?? .nonClassifiable
    
    let newBook = FullSearchResult(
        work: work, edition: edition, authors: authors, genre: genre, publisher: edition?.publishers, languages: work.languages
    )
    
    return newBook
}
