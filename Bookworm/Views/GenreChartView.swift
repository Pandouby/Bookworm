//
//  ChartView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 25.10.2024.
//

import Charts
import Foundation
import SwiftData
import SwiftUI

struct GenreChartView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var books: [Book]
    @State private var chartEntries: [ChartEntry] = []

    @State private var selectedAngle: Int?
    @State private var selectedGenre: ChartEntry?

    init() {
        let filter = #Predicate<Book> { book in
            book.statusOrder != 0  // Filters out all books with the status "want to read"
        }

        _books = Query(filter: filter)
    }

    private var titleView: some View {
        VStack {
            Text(selectedGenre?.genre.rawValue ?? "Genres")
                .font(.title)
            Text(
                (selectedGenre?.count.formatted() ?? books.count.formatted())
                    + " books"
            )
            .font(.callout)
        }
        .frame(maxWidth: 150, maxHeight: 150)
    }

    private func colorForGenre(_ genre: Genre) -> Color {
        Color(genre.rawValue.replacingOccurrences(of: " ", with: "_"))
    }

    var body: some View {
        VStack(alignment: .center) {
            Chart(chartEntries) { entry in
                let isSelected = entry.genre == selectedGenre?.genre

                SectorMark(
                    angle: .value(
                        "Count", entry.isAnimated ? entry.count : 0),
                    innerRadius: .ratio(0.618),
                    outerRadius: .ratio(isSelected ? 1 : 0.9),
                    angularInset: isSelected ? 3 : 2
                )
                .cornerRadius(5)
                .foregroundStyle(colorForGenre(entry.genre))
                .opacity(isSelected ? 1 : 0.8)
            }
            .scaledToFit()
            .chartAngleSelection(value: $selectedAngle)
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    if let anchor = chartProxy.plotFrame {
                        let frame = geometry[anchor]
                        titleView
                            .position(x: frame.midX, y: frame.midY)
                    }
                }
            }
            .onChange(
                of: selectedAngle,
                { oldValue, newValue in
                    if let newValue {
                        withAnimation {
                            getSelectedGenre(value: newValue)
                        }
                    }
                }
            )
            .padding()
            .frame(maxWidth: .infinity)
            
            LazyVGrid(
                columns: [
                    GridItem(
                        .adaptive(minimum: 100, maximum: .infinity))
                ],
                alignment: .leading
            ) {

                ForEach(chartEntries) { entry in
                    HStack(alignment: .top) {
                        Image(systemName: "circle.fill")
                            .foregroundStyle(colorForGenre(entry.genre))
                        Text(entry.genre.rawValue)
                    }
                    .frame(maxHeight: 15)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            calculateChartEntries()
        }
        .onChange(
            of: chartEntries,
            {
                animateChart()
            }
        )
        .contentShape(Rectangle())
        .onTapGesture {
            selectedGenre = nil
        }
    }

    private func calculateChartEntries() {
        var genreDict: [Genre: Int] = [:]

        for book in books {
            genreDict[book.genre, default: 0] += 1
        }

        self.chartEntries =
            genreDict
            .map {
                ChartEntry(genre: $0.key, count: $0.value, isAnimated: false)
            }
            .sorted(by: { $0.genre.rawValue < $1.genre.rawValue })
        //.sorted(by: { $0.count > $1.count })

        selectedGenre = nil
        animateChart()
    }

    private func getSelectedGenre(value: Int) {
        var cumulativeTotal = 0
        _ = chartEntries.first { entry in
            cumulativeTotal += entry.count
            if value <= cumulativeTotal {
                selectedGenre = entry
                return true
            }
            return false
        }
    }

    private func animateChart() {
        $chartEntries.enumerated().forEach { index, entry in
            let delay = Double(index) * 0.05
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.smooth) {
                    entry.wrappedValue.isAnimated = true
                }
            }
        }

    }
}

struct ChartEntry: Equatable, Identifiable {
    var id: UUID = UUID()
    var genre: Genre
    var count: Int
    var isAnimated: Bool
}

#Preview {
    let preview = Preview()
    preview.addExamples(Book.sampleBooks)

    return GenreChartView()
        .modelContainer(preview.container)
}
