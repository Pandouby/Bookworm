//
//  PagesAnalytics.swift
//  Bookworm
//
//  Created by Silvan Dubach on 30.10.2024.
//

import SwiftUI
import Charts
import GRDB
import GRDBQuery

struct PagesAnalytics: View {
    @Query(AllCompleteBooksQuery(statuses: [.done])) private var completedBooks: [CompleteBookData]
    
    @State private var timeRange: TimeRange = .month
    @State private var baseDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var selectedDate: Date?
    
    enum TimeRange: String, CaseIterable, Identifiable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        var id: String { rawValue }
    }
    
    struct PageEntry: Identifiable {
        let date: Date
        let pages: Double
        var id: Date { date }
    }
    
    private var chartData: [PageEntry] {
        var dailyPages: [Date: Double] = [:]
        let calendar = Calendar.current
        
        for book in completedBooks {
            let pages = Double(book.edition.numberOfPages ?? 0)
            let start = calendar.startOfDay(for: book.userDetails.startDate)
            let end = calendar.startOfDay(for: book.userDetails.endDate)
            
            let components = calendar.dateComponents([.day], from: start, to: end)
            let days = max(1, (components.day ?? 0) + 1)
            let pagesPerDay = pages / Double(days)
            
            for dayOffset in 0..<days {
                if let date = calendar.date(byAdding: .day, value: dayOffset, to: start) {
                    dailyPages[date, default: 0] += pagesPerDay
                }
            }
        }
        
        let range = currentRange
        
        if timeRange == .year {
            var monthlyPages: [Date: Double] = [:]
            for monthOffset in 0..<12 {
                if let date = calendar.date(byAdding: .month, value: monthOffset, to: range.start) {
                    let monthStart = calendar.dateInterval(of: .month, for: date)!.start
                    monthlyPages[monthStart] = 0.0
                }
            }
            for (date, pages) in dailyPages {
                if date >= range.start && date <= range.end {
                    let monthStart = calendar.dateInterval(of: .month, for: date)!.start
                    monthlyPages[monthStart, default: 0] += pages
                }
            }
            return monthlyPages.map { PageEntry(date: $0.key, pages: $0.value) }
                .sorted { $0.date < $1.date }
        } else {
            var filteredPages = dailyPages.filter { date, _ in
                date >= range.start && date <= range.end
            }
            var checkDate = range.start
            while checkDate <= range.end {
                let dayStart = calendar.startOfDay(for: checkDate)
                if filteredPages[dayStart] == nil {
                    filteredPages[dayStart] = 0.0
                }
                guard let nextDate = calendar.date(byAdding: .day, value: 1, to: checkDate) else { break }
                checkDate = nextDate
            }
            return filteredPages.map { PageEntry(date: $0.key, pages: $0.value) }
                .sorted { $0.date < $1.date }
        }
    }
    
    private var currentRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        var calendarWithMonday = calendar
        calendarWithMonday.firstWeekday = 2 // Monday
        
        switch timeRange {
        case .week:
            let startOfWeek = calendarWithMonday.dateInterval(of: .weekOfYear, for: baseDate)!.start
            let endOfWeek = calendarWithMonday.date(byAdding: .day, value: 6, to: startOfWeek)!
            return (startOfWeek, endOfWeek)
        case .month:
            let startOfMonth = calendar.dateInterval(of: .month, for: baseDate)!.start
            let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
            let lastDay = calendar.date(byAdding: .day, value: -1, to: endOfMonth)!
            return (startOfMonth, lastDay)
        case .year:
            let startOfYear = calendar.dateInterval(of: .year, for: baseDate)!.start
            let endOfYear = calendar.date(byAdding: .year, value: 1, to: startOfYear)!
            let lastDay = calendar.date(byAdding: .day, value: -1, to: endOfYear)!
            return (startOfYear, lastDay)
        }
    }
    
    private var dateLabel: String {
        let formatter = DateFormatter()
        let range = currentRange
        switch timeRange {
        case .week:
            formatter.dateFormat = "d. MMM"
            return "\(formatter.string(from: range.start)) - \(formatter.string(from: range.end))"
        case .month:
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: range.start)
        case .year:
            formatter.dateFormat = "yyyy"
            return formatter.string(from: range.start)
        }
    }
    
    private var totalPagesInRange: Int {
        Int(chartData.reduce(0.0) { $0 + $1.pages }.rounded())
    }
    
    private var selectedEntry: PageEntry? {
        guard let date = selectedDate else { return nil }
        let calendar = Calendar.current
        
        return chartData.first { entry in
            if timeRange == .year {
                return calendar.isDate(entry.date, equalTo: date, toGranularity: .month)
            } else {
                return calendar.isDate(entry.date, equalTo: date, toGranularity: .day)
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedEntry == nil ? "Pages Read" : formatSelectedDate(selectedEntry!.date))
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(selectedEntry == nil ? .secondary : .accentColor)
                        
                        if let entry = selectedEntry {
                            Text("\(Int(entry.pages.rounded()))")
                                .font(.system(.title, design: .rounded, weight: .bold))
                                .contentTransition(.numericText())
                        } else {
                            Text("\(totalPagesInRange)")
                                .font(.system(.title, design: .rounded, weight: .bold))
                                .transition(.opacity)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        Picker("Time Range", selection: $timeRange) {
                            ForEach(TimeRange.allCases) { range in
                                Text(range.rawValue).tag(range)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .onChange(of: timeRange) { _, _ in
                            selectedDate = nil
                        }
                        
                        if !isAtCurrentPeriod {
                            Button("Go to Today") {
                                withAnimation {
                                    baseDate = Calendar.current.startOfDay(for: Date())
                                    selectedDate = nil
                                }
                            }
                            .font(.system(.caption2, design: .rounded, weight: .bold))
                            .foregroundColor(.accentColor)
                        }
                    }
                }
                
                HStack {
                    Button(action: { 
                        withAnimation { 
                            moveBack() 
                            selectedDate = nil
                        } 
                    }) {
                        Image(systemName: "chevron.left")
                            .padding(8)
                            .background(Circle().fill(Color.secondary.opacity(0.1)))
                    }
                    
                    Spacer()
                    
                    Text(dateLabel)
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: { 
                        withAnimation { 
                            moveForward() 
                            selectedDate = nil
                        } 
                    }) {
                        Image(systemName: "chevron.right")
                            .padding(8)
                            .background(Circle().fill(Color.secondary.opacity(0.1)))
                    }
                    .disabled(isAtCurrentPeriod)
                }
            }
            .padding(.horizontal)
            
            // Chart Area
            Chart {
                ForEach(chartData) { entry in
                    BarMark(
                        x: .value("Date", entry.date, unit: timeRange == .year ? .month : .day),
                        y: .value("Pages", entry.pages)
                    )
                    .foregroundStyle(Color.accentColor.gradient)
                    .cornerRadius(timeRange == .year ? 2 : 4)
                    .opacity(selectedEntry == nil ? 1.0 : (entry.id == selectedEntry?.id ? 1.0 : 0.3))
                }
                
                if let entry = selectedEntry {
                    RuleMark(x: .value("Selected", entry.date, unit: timeRange == .year ? .month : .day))
                        .foregroundStyle(Color.accentColor.opacity(0.2))
                        .zIndex(-1)
                }
                
                if !chartData.isEmpty && selectedEntry == nil {
                    RuleMark(y: .value("Average", Double(totalPagesInRange) / Double(max(1, chartData.count))))
                        .foregroundStyle(.secondary)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                }
            }
            .frame(height: 240)
            .contentShape(Rectangle())
            .chartXSelection(value: $selectedDate)
            .simultaneousGesture(
                DragGesture(minimumDistance: 20)
                    .onEnded { value in
                        if abs(value.translation.width) > 80 {
                            if value.translation.width > 80 {
                                withAnimation { moveBack(); selectedDate = nil }
                            } else if value.translation.width < -80 {
                                if !isAtCurrentPeriod {
                                    withAnimation { moveForward(); selectedDate = nil }
                                }
                            }
                        }
                    }
            )
            .onTapGesture { location in
                // Tapping empty space clears selection
                withAnimation {
                    selectedDate = nil
                }
            }
            .chartXAxis {
                if timeRange == .week {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.weekday(.narrow))
                    }
                } else if timeRange == .month {
                    AxisMarks(values: .stride(by: .day, count: 7)) { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.day())
                    }
                } else {
                    AxisMarks(values: .stride(by: .month)) { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month(.narrow))
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .padding(.vertical, 20)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .padding()
    }
    
    private func formatSelectedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        if timeRange == .year {
            formatter.dateFormat = "MMMM yyyy"
        } else {
            formatter.dateStyle = .medium
        }
        return formatter.string(from: date)
    }
    
    private func isSamePeriod(_ d1: Date, _ d2: Date) -> Bool {
        let calendar = Calendar.current
        if timeRange == .year {
            return calendar.isDate(d1, equalTo: d2, toGranularity: .month)
        } else {
            return calendar.isDate(d1, equalTo: d2, toGranularity: .day)
        }
    }
    
    private var isAtCurrentPeriod: Bool {
        let calendar = Calendar.current
        switch timeRange {
        case .week:
            return calendar.isDate(baseDate, equalTo: Date(), toGranularity: .weekOfYear)
        case .month:
            return calendar.isDate(baseDate, equalTo: Date(), toGranularity: .month)
        case .year:
            return calendar.isDate(baseDate, equalTo: Date(), toGranularity: .year)
        }
    }
    
    private func moveBack() {
        let calendar = Calendar.current
        switch timeRange {
        case .week:
            baseDate = calendar.date(byAdding: .weekOfYear, value: -1, to: baseDate)!
        case .month:
            baseDate = calendar.date(byAdding: .month, value: -1, to: baseDate)!
        case .year:
            baseDate = calendar.date(byAdding: .year, value: -1, to: baseDate)!
        }
    }
    
    private func moveForward() {
        let calendar = Calendar.current
        let nextDate: Date
        switch timeRange {
        case .week:
            nextDate = calendar.date(byAdding: .weekOfYear, value: 1, to: baseDate)!
        case .month:
            nextDate = calendar.date(byAdding: .month, value: 1, to: baseDate)!
        case .year:
            nextDate = calendar.date(byAdding: .year, value: 1, to: baseDate)!
        }
        
        if nextDate <= Date() {
            baseDate = nextDate
        } else {
            baseDate = Date()
        }
    }
}

#Preview {
    let dbQueue = AppDatabase.preview()
    DatabaseRepository.dbQueue = dbQueue
    
    return PagesAnalytics()
        .databaseContext(.readWrite { dbQueue })
}
