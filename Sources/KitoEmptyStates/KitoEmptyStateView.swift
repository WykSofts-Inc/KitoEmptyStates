//
//  KitoEmptyStateView.swift
//  KitoEmptyStates
//
//  Created by Wycliff on 5/12/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import UIKit
import KitoCore

public enum KitoEmptyStateActionRole: Sendable {
    case primary, secondary, destructive
}

public struct KitoEmptyStateAction: Identifiable {
    public let id = UUID()
    public var title: String
    public var handler: () -> Void
    public var role: KitoEmptyStateActionRole

    public init(title: String, role: KitoEmptyStateActionRole = .primary, handler: @escaping () -> Void) {
        self.title = title
        self.handler = handler
        self.role = role
    }
}

/// A themed empty/error/no-connection view: media (SF Symbol, image, GIF,
/// SVG, Lottie, or looping video), an optional title, an optional message,
/// and any number of action buttons, laid out horizontally or vertically.
/// Charts (`KitoCharts`), lists, and search results all reach for the same
/// shape — this is the one place it's built.
public struct KitoEmptyStateView: View {
    @Environment(\.kitoTheme) private var theme

    let media: KitoEmptyStateMedia
    let title: String?
    let message: String?
    let actions: [KitoEmptyStateAction]
    let actionsAxis: Axis
    let mediaSize: CGSize

    /// The fully general initializer — every piece is independently optional
    /// so a caller can show just an icon, just a message, or the full
    /// media+title+message+multi-action combination.
    public init(
        media: KitoEmptyStateMedia = .none,
        title: String? = nil,
        message: String? = nil,
        actions: [KitoEmptyStateAction] = [],
        actionsAxis: Axis = .vertical,
        mediaSize: CGSize = CGSize(width: 160, height: 160)
    ) {
        self.media = media
        self.title = title
        self.message = message
        self.actions = actions
        self.actionsAxis = actionsAxis
        self.mediaSize = mediaSize
    }

    /// Source-compatible with the original SF-Symbol-only API.
    public init(systemImage: String, title: String, message: String? = nil, action: KitoEmptyStateAction? = nil) {
        self.init(media: .systemImage(systemImage), title: title, message: message, actions: action.map { [$0] } ?? [])
    }

    public var body: some View {
        VStack(spacing: theme.spacing.md) {
            mediaView
            if let title {
                Text(title)
                    .font(theme.typography.titleMedium)
                    .foregroundStyle(theme.colors.onBackground)
                    .multilineTextAlignment(.center)
            }
            if let message {
                Text(message)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.onBackground.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            if !actions.isEmpty {
                actionsStack
                    .padding(.top, theme.spacing.xs)
            }
        }
        .padding(theme.spacing.xl)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var mediaView: some View {
        switch media {
        case .none:
            EmptyView()
        case .systemImage(let name):
            ZStack {
                Circle()
                    .fill(theme.colors.primary.opacity(0.12))
                    .frame(width: 88, height: 88)
                Image(systemName: name)
                    .font(.system(size: 34))
                    .foregroundStyle(theme.colors.primary.opacity(0.8))
            }
            .kitoGlow(theme.colors.primary, radius: 16, intensity: 0.18)
        case .image(let name):
            Image(name)
                .resizable()
                .scaledToFit()
                .frame(width: mediaSize.width, height: mediaSize.height)
        case .remoteImage(let source):
            KitoRemoteImageView(source: source)
                .frame(width: mediaSize.width, height: mediaSize.height)
        case .gif(let source):
            KitoGIFView(source: source)
                .frame(width: mediaSize.width, height: mediaSize.height)
        case .svg(let source):
            KitoSVGView(source: source)
                .frame(width: mediaSize.width, height: mediaSize.height)
        case .lottie(let source, let loop):
            KitoLottieView(source: source, loop: loop)
                .frame(width: mediaSize.width, height: mediaSize.height)
        case .video(let url, let loop, let muted):
            KitoLoopingVideoView(url: url, loop: loop, muted: muted)
                .frame(width: mediaSize.width, height: mediaSize.height)
        }
    }

    @ViewBuilder
    private var actionsStack: some View {
        if actionsAxis == .horizontal {
            HStack(spacing: theme.spacing.sm) {
                ForEach(actions) { actionButton($0) }
            }
        } else {
            VStack(spacing: theme.spacing.sm) {
                ForEach(actions) { actionButton($0) }
            }
        }
    }

    private func actionButton(_ action: KitoEmptyStateAction) -> some View {
        Button(action.title, action: action.handler)
            .font(theme.typography.button)
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.sm)
            .frame(maxWidth: actionsAxis == .vertical ? .infinity : nil)
            .background(background(for: action.role), in: Capsule())
            .foregroundStyle(foreground(for: action.role))
    }

    private func background(for role: KitoEmptyStateActionRole) -> Color {
        switch role {
        case .primary: return theme.colors.primary
        case .secondary: return theme.colors.surfaceMuted
        case .destructive: return theme.colors.danger
        }
    }

    private func foreground(for role: KitoEmptyStateActionRole) -> Color {
        switch role {
        case .primary: return theme.colors.onPrimary
        case .secondary: return theme.colors.onBackground
        case .destructive: return .white
        }
    }
}

private struct KitoRemoteImageView: View {
    let source: KitoMediaSource
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image).resizable().scaledToFit()
            } else {
                Color.clear
            }
        }
        .task(id: source) {
            if let data = await source.loadData() {
                image = UIImage(data: data)
            }
        }
    }
}

public extension KitoEmptyStateView {
    static func noData(title: String = "Nothing here yet", message: String? = nil) -> KitoEmptyStateView {
        KitoEmptyStateView(media: .systemImage("tray"), title: title, message: message)
    }

    static func noResults(query: String) -> KitoEmptyStateView {
        KitoEmptyStateView(
            media: .systemImage("magnifyingglass"),
            title: "No results for \"\(query)\"",
            message: "Try a different search term."
        )
    }

    static func noConnection(retry: @escaping () -> Void) -> KitoEmptyStateView {
        KitoEmptyStateView(
            media: .systemImage("wifi.slash"),
            title: "You're offline",
            message: "Check your connection and try again.",
            actions: [KitoEmptyStateAction(title: "Retry", handler: retry)]
        )
    }

    static func error(message: String, retry: @escaping () -> Void) -> KitoEmptyStateView {
        KitoEmptyStateView(
            media: .systemImage("exclamationmark.triangle"),
            title: "Something went wrong",
            message: message,
            actions: [KitoEmptyStateAction(title: "Try again", handler: retry)]
        )
    }
}
