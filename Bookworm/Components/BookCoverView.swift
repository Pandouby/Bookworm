//
//  BookCoverView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 06.03.2026.
//

import SwiftUI

struct BookCoverView: View {
    let coverURL: String?
    let editionKey: String
    
    @State private var localImage: UIImage? = nil
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if let image = localImage {
                Image(uiImage: image)
                    .resizable()
            } else if isLoading {
                ZStack {
                    Color(.systemGray5)
                    ProgressView()
                }
            } else {
                placeholder
            }
        }
        .onAppear {
            loadCover()
        }
    }
    
    private var placeholder: some View {
        ZStack {
            Color(.systemGray5)
            Image(systemName: "book.closed.fill")
                .foregroundColor(.secondary)
        }
    }
    
    private func loadCover() {
        guard let coverURL = coverURL, !coverURL.isEmpty else { return }
        
        // Use a safe filename based on editionKey
        let filename = getSafeFilename(editionKey)
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        
        // 1. Check if it exists locally
        if let data = try? Data(contentsOf: fileURL), let image = UIImage(data: data) {
            self.localImage = image
            return
        }
        
        // 2. If not, download it
        guard let url = URL(string: coverURL) else { return }
        
        isLoading = true
        URLSession.shared.dataTask(with: url) { data, response, error in
            defer { DispatchQueue.main.async { isLoading = false } }
            
            if let data = data, let image = UIImage(data: data) {
                // Save locally
                try? data.write(to: fileURL)
                
                DispatchQueue.main.async {
                    self.localImage = image
                }
            }
        }.resume()
    }
    
    private func getSafeFilename(_ key: String) -> String {
        // Remove slashes and special characters from OpenLibrary keys like "/books/OL123M"
        return key.replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_") + ".jpg"
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
