//
//  AnalyticsView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 29.10.2024.
//

import SwiftUI

struct AnalyticsView: View {
    @State private var selectedView: ChartType = .genreChart
    
    enum ChartType: String, CaseIterable, Identifiable {
        case genreChart = "Genres"
        case statusChart = "Statuses"
        
        var id: String { rawValue }
    }
    
    var body: some View {
        VStack {
            List {
                Picker("Select Chart", selection: $selectedView) {
                    ForEach(ChartType.allCases) { chart in
                        Text(chart.rawValue).tag(chart)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .listRowBackground(Color.clear)
                
                Section {
                    if selectedView == .genreChart {
                        GenreChartView()
                    } else {
                        StatusChartView()
                    }
                }
            }
            .scrollDisabled(true)
        }
    }
}

#Preview {
    let preview = Preview()
    preview.addExamples(Book.sampleBooks)
    
    return AnalyticsView()
        .modelContainer(preview.container)
}
