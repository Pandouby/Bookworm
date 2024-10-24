//
//  Untitled.swift
//  Bookworm
//
//  Created by Silvan Dubach on 15.10.2024.
//

import AVFoundation
import SwiftData
import SwiftUI

struct RatingView: View {
    init(_ rating: Binding<Double>, maxRating: Int = 5) {
        _rating = rating
        self.maxRating = maxRating
    }

    let maxRating: Int
    @Binding var rating: Double
    @State private var starSize: CGSize = .zero
    @State private var controlSize: CGSize = .zero
    @GestureState private var dragging: Bool = false

    var body: some View {
        ZStack {
            HStack(spacing: 30) {
                Spacer()
                ForEach(0..<Int(rating), id: \.self) { idx in
                    fullStar
                }

                if rating != floor(rating) {
                    halfStar
                }

                ForEach(0..<Int(Double(maxRating) - rating), id: \.self) {
                    idx in
                    emptyStar
                }
                Spacer()
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
                            rating = rating(at: value.location)
                        }
                )
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

    private func rating(at position: CGPoint) -> Double {
        let singleStarWidth = starSize.width
        let totalPaddingWidth =
            controlSize.width - CGFloat(maxRating) * singleStarWidth
        let singlePaddingWidth = totalPaddingWidth / (CGFloat(maxRating) - 1)
        let starWithSpaceWidth = Double(singleStarWidth + singlePaddingWidth)
        let x = Double(position.x)

        let starIdx = Int(x / starWithSpaceWidth)
        let starPercent =
            x.truncatingRemainder(dividingBy: starWithSpaceWidth)
            / Double(singleStarWidth) * 100

        let rating: Double
        if starPercent < 25 {
            rating = Double(starIdx)
        } else if starPercent <= 75 {
            rating = Double(starIdx) + 0.5
        } else {
            rating = Double(starIdx) + 1
        }

        return min(Double(maxRating), max(0, rating))
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
