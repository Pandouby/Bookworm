//
//  AnalyticsView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 29.10.2024.
//

import SwiftUI

struct AnalyticsView: View {
    @State private var selectedView: ChartType = .pagesChart
    
    enum ChartType: String, CaseIterable, Identifiable {
        case pagesChart = "Pages"
        case genreChart = "Genres"
        case statusChart = "Statuses"
        
        var id: String { rawValue }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Select Chart", selection: $selectedView) {
                        ForEach(ChartType.allCases) { chart in
                            Text(chart.rawValue).tag(chart)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    if selectedView == .pagesChart {
                        PagesAnalytics()
                    } else if selectedView == .genreChart {
                        GenreChartView()
                    } else {
                        StatusChartView()
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Analytics")
        }
    }
}

#Preview {
    let dbQueue = AppDatabase.preview()
    DatabaseRepository.dbQueue = dbQueue
    
    return AnalyticsView()
        .databaseContext(.readWrite { dbQueue })
}
