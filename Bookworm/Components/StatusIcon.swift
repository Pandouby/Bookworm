//
//  StatusIcon.swift
//  Bookworm
//
//  Created by Silvan Dubach on 16.10.2024.
//
import SwiftUI

struct StatusIcon: View {
    var status: Status
    var body: some View {
        switch status {
        case .wantToRead:
            statusWantToRead
        case .toDo:
            statusToDo
        case .onPause:
            statusOnPause
        case .inProgress:
            statusInProgress
        case .done:
            statusDone
        }
    }

    var iconSize: CGFloat = 30

    private var statusWantToRead: some View {
        Image(systemName: "cart")
            .foregroundColor(.wantToRead)
            .font(.system(size: iconSize))
    }

    private var statusToDo: some View {
        Image(systemName: "checklist.unchecked")
            .foregroundColor(.toDo)
            .font(.system(size: iconSize))
    }

    private var statusOnPause: some View {
        Image(systemName: "pause.fill")
            .foregroundColor(.onPause)
            .font(.system(size: iconSize))
    }

    private var statusInProgress: some View {
        Image(systemName: "checklist")
            .foregroundColor(.inProgress)
            .font(.system(size: iconSize))
    }

    private var statusDone: some View {
        Image(systemName: "checklist.checked")
            .foregroundColor(.done)
            .font(.system(size: iconSize))
    }
}
