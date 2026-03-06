//
//  GenreChartView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 25.10.2024.
//

import Charts
import Foundation
import SwiftUI
import GRDB
import GRDBQuery

struct GenreChartView: View {
    @Query(AllCompleteBooksQuery(statuses: [.toDo, .inProgress, .onPause, .done])) var completeBooks: [CompleteBookData]
    
    @State private var chartEntries: [ChartEntry] = []
    @State private var selectedAngle: Int?
    @State private var selectedGenre: ChartEntry?

    private var titleView: some View {
        VStack(spacing: 2) {
            Text(selectedGenre?.genre.rawValue ?? "Total")
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
            
            Text(
                (selectedGenre?.count.formatted() ?? completeBooks.count.formatted())
            )
            .font(.system(.title2, design: .rounded, weight: .bold))
            .foregroundColor(.primary)
            
            Text("books")
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(width: 100, height: 100)
        .contentShape(Rectangle())
    }

    private func colorForGenre(_ genre: Genre) -> Color {
        Color(genre.rawValue.replacingOccurrences(of: " ", with: "_"))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Books by Genre")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)
            
            ZStack {
                Chart(chartEntries) { entry in
                    let isSelected = entry.genre == selectedGenre?.genre

                    SectorMark(
                        angle: .value("Count", entry.isAnimated ? entry.count : 0),
                        innerRadius: .ratio(0.65),
                        outerRadius: .ratio(isSelected ? 1.0 : 0.92),
                        angularInset: 2.0
                    )
                    .cornerRadius(6)
                    .foregroundStyle(colorForGenre(entry.genre).gradient)
                    .opacity(isSelected ? 1 : 0.85)
                }
                .frame(height: 260)
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
                .onChange(of: selectedAngle) { _, newValue in
                    if let newValue {
                        withAnimation(.interactiveSpring()) {
                            getSelectedGenre(value: newValue)
                        }
                    }
                }
            }
            .padding(.vertical, 10)
            
            Divider()
                .padding(.horizontal)
            
            // Refined Legend
            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                alignment: .leading,
                spacing: 12
            ) {
                ForEach(chartEntries) { entry in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(colorForGenre(entry.genre).gradient)
                            .frame(width: 10, height: 10)
                        
                        Text(entry.genre.rawValue)
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text("\(entry.count)")
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.interactiveSpring()) {
                            if selectedGenre?.id == entry.id {
                                selectedGenre = nil
                            } else {
                                selectedGenre = entry
                            }
                        }
                    }
                }
            }
            .padding([.horizontal, .bottom])
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .padding()
        .onAppear {
            calculateChartEntries()
        }
        .onChange(of: completeBooks) { _, _ in
            calculateChartEntries()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation { selectedGenre = nil }
        }
    }

    private func calculateChartEntries() {
        var genreDict: [Genre: Int] = [:]
        for book in completeBooks {
            if let firstGenre = book.genres.first {
                genreDict[firstGenre, default: 0] += 1
            } else {
                genreDict[.nonClassifiable, default: 0] += 1
            }
        }

        let newEntries = genreDict.map {
            ChartEntry(genre: $0.key, count: $0.value, isAnimated: false)
        }
        .sorted(by: { $0.count > $1.count })

        self.chartEntries = newEntries
        animateChart()
    }

    private func getSelectedGenre(value: Int) {
        var cumulativeTotal = 0
        selectedGenre = chartEntries.first { entry in
            cumulativeTotal += entry.count
            return value <= cumulativeTotal
        }
    }

    private func animateChart() {
        for index in chartEntries.indices {
            let delay = Double(index) * 0.05
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.smooth) {
                    chartEntries[index].isAnimated = true
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
    let dbQueue = AppDatabase.preview()
    DatabaseRepository.dbQueue = dbQueue
    
    return GenreChartView()
        .databaseContext(.readWrite { dbQueue })
}
