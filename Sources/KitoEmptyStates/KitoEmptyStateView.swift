//
//  KitoEmptyStateView.swift
//  KitoEmptyStates
//
//  Created by Wycliff on 5/12/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

public struct KitoEmptyStateAction {
    public var title: String
    public var handler: () -> Void

    public init(title: String, handler: @escaping () -> Void) {
        self.title = title
        self.handler = handler
    }
}

/// A themed empty/error/no-connection view: SF Symbol, title, message, and an
/// optional action button. Charts (`KitoCharts`), lists, and search results
/// all reach for the same shape — this is the one place it's built.
public struct KitoEmptyStateView: View {
    @Environment(\.kitoTheme) private var theme

    let systemImage: String
    let title: String
    let message: String?
    let action: KitoEmptyStateAction?

    public init(systemImage: String, title: String, message: String? = nil, action: KitoEmptyStateAction? = nil) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
        self.action = action
    }

    public var body: some View {
        VStack(spacing: theme.spacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 40))
                .foregroundStyle(theme.colors.onBackground.opacity(0.35))
            Text(title)
                .font(theme.typography.titleMedium)
                .foregroundStyle(theme.colors.onBackground)
            if let message {
                Text(message)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.onBackground.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            if let action {
                Button(action.title, action: action.handler)
                    .font(theme.typography.button)
                    .padding(.horizontal, theme.spacing.lg)
                    .padding(.vertical, theme.spacing.sm)
                    .background(theme.colors.primary, in: Capsule())
                    .foregroundStyle(theme.colors.onPrimary)
                    .padding(.top, theme.spacing.xs)
            }
        }
        .padding(theme.spacing.xl)
        .frame(maxWidth: .infinity)
    }
}

public extension KitoEmptyStateView {
    static func noData(title: String = "Nothing here yet", message: String? = nil) -> KitoEmptyStateView {
        KitoEmptyStateView(systemImage: "tray", title: title, message: message)
    }

    static func noResults(query: String) -> KitoEmptyStateView {
        KitoEmptyStateView(
            systemImage: "magnifyingglass",
            title: "No results for \"\(query)\"",
            message: "Try a different search term."
        )
    }

    static func noConnection(retry: @escaping () -> Void) -> KitoEmptyStateView {
        KitoEmptyStateView(
            systemImage: "wifi.slash",
            title: "You're offline",
            message: "Check your connection and try again.",
            action: KitoEmptyStateAction(title: "Retry", handler: retry)
        )
    }

    static func error(message: String, retry: @escaping () -> Void) -> KitoEmptyStateView {
        KitoEmptyStateView(
            systemImage: "exclamationmark.triangle",
            title: "Something went wrong",
            message: message,
            action: KitoEmptyStateAction(title: "Try again", handler: retry)
        )
    }
}
