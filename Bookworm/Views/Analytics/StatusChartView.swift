//
//  StatusChartView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 25.10.2024.
//

import Charts
import Foundation
import SwiftUI
import GRDB
import GRDBQuery

struct StatusChartView: View {
    @Query(AllCompleteBooksQuery(statuses: [.toDo, .inProgress, .onPause, .done])) var completeBooks: [CompleteBookData]
    
    @State private var chartEntries: [StatusChartEntry] = []
    @State private var selectedAngle: Int?
    @State private var selectedStatus: StatusChartEntry?

    private var titleView: some View {
        VStack(spacing: 2) {
            Text(selectedStatus?.status.rawValue ?? "Total")
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
            
            Text(
                (selectedStatus?.count.formatted() ?? completeBooks.count.formatted())
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

    private func colorForStatus(_ status: Status) -> Color {
        Color(status.rawValue.replacingOccurrences(of: " ", with: "_"))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Books by Status")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)
            
            ZStack {
                Chart(chartEntries) { entry in
                    let isSelected = entry.status == selectedStatus?.status

                    SectorMark(
                        angle: .value("Count", entry.isAnimated ? entry.count : 0),
                        innerRadius: .ratio(0.65),
                        outerRadius: .ratio(isSelected ? 1.0 : 0.92),
                        angularInset: 2.0
                    )
                    .cornerRadius(6)
                    .foregroundStyle(colorForStatus(entry.status).gradient)
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
                            getSelectedStatus(value: newValue)
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
                            .fill(colorForStatus(entry.status).gradient)
                            .frame(width: 10, height: 10)
                        
                        Text(entry.status.rawValue)
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(entry.count)")
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.interactiveSpring()) {
                            if selectedStatus?.id == entry.id {
                                selectedStatus = nil
                            } else {
                                selectedStatus = entry
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
            withAnimation { selectedStatus = nil }
        }
    }

    private func calculateChartEntries() {
        var statusDict: [Status: Int] = [:]
        for book in completeBooks {
            statusDict[book.userDetails.status, default: 0] += 1
        }

        let newEntries = statusDict.map {
            StatusChartEntry(status: $0.key, count: $0.value, isAnimated: false)
        }
        .sorted(by: { $0.count > $1.count })

        self.chartEntries = newEntries
        animateChart()
    }

    private func getSelectedStatus(value: Int) {
        var cumulativeTotal = 0
        selectedStatus = chartEntries.first { entry in
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

struct StatusChartEntry: Equatable, Identifiable {
    var id: UUID = UUID()
    var status: Status
    var count: Int
    var isAnimated: Bool
}

#Preview {
    let dbQueue = AppDatabase.preview()
    DatabaseRepository.dbQueue = dbQueue
    
    return StatusChartView()
        .databaseContext(.readWrite { dbQueue })
}
