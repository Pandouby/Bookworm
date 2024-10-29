//
//  test.swift
//  Bookworm
//
//  Created by Silvan Dubach on 29.10.2024.
//

//
//  AnalyticsView.swift
//  Bookworm
//
//  Created by Silvan Dubach on 25.10.2024.
//
/*
import Charts
import Foundation
import SwiftData
import SwiftUI

struct test: View {
    @State private var selectedChart: Chart = Chart.genreChart
    
    var body: some View {
        Picker("Chart", selection: $selectedChart) {
            ForEach(Chart.allCases) { chart in
                Text(chart.rawValue)
            }
        }
        .pickerStyle(.inline)
        
        if selectedChart == Chart.genreChart {
            GenreChartView()
        } else {
            StatusChartView()
        }
    }
}

enum Chart: String, Codable, CaseIterable, Identifiable {
    case statusChart = "statusChart"
    case genreChart = "genreChart"
    var id: Self { self }
}

#Preview {
    let preview = Preview()
    preview.addExamples(Book.sampleBooks)
    
    return test()
        .modelContainer(preview.container)
}
*/
