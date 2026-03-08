//
//  Untitled.swift
//  Bookworm
//
//  Created by Silvan Dubach on 15.10.2024.
//

import AVFoundation
import SwiftUI

struct RatingView: View {
    init(_ rating: Binding<Double>, maxRating: Int = 5) {
        _rating = rating
        self.maxRating = maxRating
        // Initialize local display rating with the starting value
        _displayRating = State(initialValue: rating.wrappedValue)
    }

    let maxRating: Int
    @Binding var rating: Double
    
    // Local state to track visual changes during drag
    @State private var displayRating: Double
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    @State private var starSize: CGSize = .zero
    @State private var controlSize: CGSize = .zero
    @GestureState private var dragging: Bool = false

    var body: some View {
        ZStack {
            HStack(spacing: 30) {
                ForEach(0..<Int(displayRating), id: \.self) { idx in
                    fullStar
                }

                if displayRating != floor(displayRating) {
                    halfStar
                }

                ForEach(0..<Int(Double(maxRating) - displayRating), id: \.self) {
                    idx in
                    emptyStar
                }
            }
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: ControlSizeKey.self, value: proxy.size)
                }
            )
            .onPreferenceChange(StarSizeKey.self) { size in
                starSize = size
            }
            .onPreferenceChange(ControlSizeKey.self) { size in
                controlSize = size
            }

            Color.clear
                .frame(width: controlSize.width, height: controlSize.height)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { value in
                            // Prepare generator for upcoming feedback
                            feedbackGenerator.prepare()
                            
                            let newRating = calculateRating(at: value.location)
                            if newRating != displayRating {
                                displayRating = newRating
                            }
                        }
                        .onEnded { value in
                            // Commit the final rating to the binding only when finger is lifted
                            rating = displayRating
                        }
                )
        }
        .onChange(of: displayRating) { _, _ in
            feedbackGenerator.impactOccurred()
        }
        .onChange(of: rating) { _, newValue in
            // Keep display in sync if rating is changed from outside (e.g. initial load)
            if newValue != displayRating {
                displayRating = newValue
            }
        }
    }

    private var fullStar: some View {
        Image(systemName: "star.fill")
            .star(size: starSize)
            .foregroundColor(.accentColor)
    }

    private var halfStar: some View {
        Image(systemName: "star.leadinghalf.fill")
            .star(size: starSize)
            .foregroundColor(.accentColor)
    }

    private var emptyStar: some View {
        Image(systemName: "star")
            .star(size: starSize)
            .foregroundColor(.accentColor)
    }

    private func calculateRating(at position: CGPoint) -> Double {
        let x = position.x
        let width = controlSize.width
        
        // Map x position directly to 0...maxRating
        let relativeX = max(0, min(x, width))
        let normalized = Double(relativeX / width)
        let rawRating = normalized * Double(maxRating)
        
        // Snapping to 0.5 increments
        let snappedRating = (rawRating * 2).rounded() / 2
        
        return min(Double(maxRating), max(0, snappedRating))
    }
}

extension Image {
    fileprivate func star(size: CGSize) -> some View {
        return
            self
            .font(.title)
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: StarSizeKey.self, value: proxy.size)
                }
            )
            .frame(width: size.width, height: size.height)
    }
}

private protocol SizeKey: PreferenceKey {}
extension SizeKey {
    fileprivate static var defaultValue: CGSize { .zero }
    fileprivate static func reduce(value: inout CGSize, nextValue: () -> CGSize)
    {
        let next = nextValue()
        value = CGSize(
            width: max(value.width, next.width),
            height: max(value.height, next.height))
    }
}

private struct StarSizeKey: SizeKey {}
private struct ControlSizeKey: SizeKey {}
