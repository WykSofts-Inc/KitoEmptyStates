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

/// How an empty state arranges itself.
public enum KitoEmptyStateLayout: Equatable, Sendable {
    /// Centred and stacked: media, title, message, actions. The default.
    case standard
    /// Media on the leading side, text and actions beside it — inside a card or a list section.
    case compact
    /// One quiet row with a small icon, the message and a text action, in a dashed outline —
    /// for an empty slot inside a form, e.g. "No payment methods yet · Add".
    case inline
    /// Fills the screen: a tinted backdrop, large media, and actions pinned to the bottom.
    case fullScreen
}

/// A themed empty/error/no-connection view: media (SF Symbol, image, GIF,
/// SVG, Lottie, or looping video), an optional title, an optional message,
/// and any number of action buttons, laid out horizontally or vertically, in one of
/// four `KitoEmptyStateLayout`s.
/// Charts (`KitoCharts`), lists, and search results all reach for the same
/// shape — this is the one place it's built.
public struct KitoEmptyStateView: View {
    @Environment(\.kitoTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let media: KitoEmptyStateMedia
    let title: String?
    let message: String?
    let actions: [KitoEmptyStateAction]
    let actionsAxis: Axis
    let mediaSize: CGSize
    let layout: KitoEmptyStateLayout

    @State private var appeared = false

    /// The fully general initializer — every piece is independently optional
    /// so a caller can show just an icon, just a message, or the full
    /// media+title+message+multi-action combination.
    public init(
        media: KitoEmptyStateMedia = .none,
        title: String? = nil,
        message: String? = nil,
        actions: [KitoEmptyStateAction] = [],
        actionsAxis: Axis = .vertical,
        mediaSize: CGSize = CGSize(width: 160, height: 160),
        layout: KitoEmptyStateLayout = .standard
    ) {
        self.media = media
        self.title = title
        self.message = message
        self.actions = actions
        self.actionsAxis = actionsAxis
        self.mediaSize = mediaSize
        self.layout = layout
    }

    /// Source-compatible with the original SF-Symbol-only API.
    public init(systemImage: String, title: String, message: String? = nil, action: KitoEmptyStateAction? = nil) {
        self.init(media: .systemImage(systemImage), title: title, message: message, actions: action.map { [$0] } ?? [])
    }

    public var body: some View {
        Group {
            switch layout {
            case .standard: standard
            case .compact: compact
            case .inline: inline
            case .fullScreen: fullScreen
            }
        }
        .onAppear {
            withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.55, dampingFraction: 0.85).delay(0.08)) { appeared = true }
        }
    }

    // MARK: Layouts

    private var standard: some View {
        VStack(spacing: theme.spacing.md) {
            mediaView(scale: 1)
            texts(alignment: .center)
            if !actions.isEmpty {
                actionsStack
                    .padding(.top, theme.spacing.xs)
                    .modifier(KitoEmptyStateEntrance(appeared: appeared, delay: 2, reduceMotion: reduceMotion))
            }
        }
        .padding(theme.spacing.xl)
        .frame(maxWidth: .infinity)
    }

    private var compact: some View {
        HStack(alignment: .center, spacing: theme.spacing.md) {
            mediaView(scale: 0.5)
                .frame(width: max(mediaSize.width * 0.5, 64))
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                texts(alignment: .leading)
                if !actions.isEmpty {
                    HStack(spacing: theme.spacing.xs) {
                        ForEach(actions) { actionButton($0, compact: true) }
                    }
                    .padding(.top, theme.spacing.xxs)
                    .modifier(KitoEmptyStateEntrance(appeared: appeared, delay: 2, reduceMotion: reduceMotion))
                }
            }
            Spacer(minLength: 0)
        }
        .padding(theme.spacing.md)
        .frame(maxWidth: .infinity)
    }

    private var inline: some View {
        HStack(spacing: theme.spacing.sm) {
            inlineIcon
            VStack(alignment: .leading, spacing: 2) {
                if let title {
                    Text(title).font(theme.typography.bodyEmphasized).foregroundStyle(theme.colors.onBackground)
                }
                if let message {
                    Text(message).font(theme.typography.caption).foregroundStyle(theme.colors.onBackground.opacity(0.6))
                }
            }
            Spacer(minLength: theme.spacing.xs)
            ForEach(actions) { action in
                Button(action: action.handler) {
                    Text(action.title).font(theme.typography.button)
                }
                .buttonStyle(.plain)
                .foregroundStyle(action.role == .destructive ? theme.colors.danger : theme.colors.primary)
            }
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm + 2)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: theme.radii.lg, style: .continuous)
                .fill(theme.colors.surfaceMuted.opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.lg, style: .continuous)
                .strokeBorder(theme.colors.border, style: StrokeStyle(lineWidth: 1.2, dash: [5, 4]))
        )
        .modifier(KitoEmptyStateEntrance(appeared: appeared, delay: 0, reduceMotion: reduceMotion))
    }

    private var fullScreen: some View {
        VStack(spacing: theme.spacing.md) {
            Spacer(minLength: theme.spacing.lg)
            mediaView(scale: 1.35)
            texts(alignment: .center)
                .padding(.horizontal, theme.spacing.md)
            Spacer(minLength: theme.spacing.lg)
            if !actions.isEmpty {
                VStack(spacing: theme.spacing.sm) {
                    ForEach(actions) { actionButton($0, fullWidth: true) }
                }
                .modifier(KitoEmptyStateEntrance(appeared: appeared, delay: 2, reduceMotion: reduceMotion))
            }
        }
        .padding(theme.spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(colors: [accent.opacity(0.14), theme.colors.background], startPoint: .top, endPoint: .center)
                .ignoresSafeArea()
        )
    }

    @ViewBuilder
    private func texts(alignment: HorizontalAlignment) -> some View {
        let textAlignment: TextAlignment = alignment == .leading ? .leading : .center
        VStack(alignment: alignment, spacing: theme.spacing.xs) {
            if let title {
                Text(title)
                    .font(layout == .fullScreen ? theme.typography.titleLarge : theme.typography.titleMedium)
                    .foregroundStyle(theme.colors.onBackground)
                    .multilineTextAlignment(textAlignment)
            }
            if let message {
                Text(message)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.onBackground.opacity(0.6))
                    .multilineTextAlignment(textAlignment)
            }
        }
        .modifier(KitoEmptyStateEntrance(appeared: appeared, delay: 1, reduceMotion: reduceMotion))
    }

    /// The media's lead colour, used to tint the full-screen backdrop and inline icon.
    private var accent: Color {
        if case .illustration(let illustration) = media, let first = illustration.colors.first { return first }
        return theme.colors.primary
    }

    @ViewBuilder
    private var inlineIcon: some View {
        switch media {
        case .systemImage(let name):
            inlineSymbol(name)
        case .illustration(let illustration):
            inlineSymbol(illustration.symbol)
        default:
            EmptyView()
        }
    }

    private func inlineSymbol(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(accent)
            .frame(width: 34, height: 34)
            .background(Circle().fill(accent.opacity(0.14)))
    }

    @ViewBuilder
    private func mediaView(scale: CGFloat) -> some View {
        let mediaSize = CGSize(width: self.mediaSize.width * scale, height: self.mediaSize.height * scale)
        switch media {
        case .none:
            EmptyView()
        case .systemImage(let name):
            ZStack {
                Circle()
                    .fill(theme.colors.primary.opacity(0.12))
                    .frame(width: 88 * max(scale, 0.64), height: 88 * max(scale, 0.64))
                Image(systemName: name)
                    .font(.system(size: 34 * max(scale, 0.64)))
                    .foregroundStyle(theme.colors.primary.opacity(0.8))
            }
            .kitoGlow(theme.colors.primary, radius: 16, intensity: 0.18)
        case .illustration(let illustration):
            KitoEmptyStateIllustrationView(illustration, size: min(mediaSize.width, mediaSize.height) * 1.15)
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
                ForEach(actions) { actionButton($0, fullWidth: true) }
            }
        }
    }

    private func actionButton(_ action: KitoEmptyStateAction, fullWidth: Bool = false, compact: Bool = false) -> some View {
        Button(action: action.handler) {
            Text(action.title)
                .font(compact ? theme.typography.label.weight(.semibold) : theme.typography.button)
                .padding(.horizontal, compact ? theme.spacing.md : theme.spacing.lg)
                .padding(.vertical, compact ? theme.spacing.xs + 1 : theme.spacing.sm + 2)
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .background(background(for: action.role), in: Capsule())
                .foregroundStyle(foreground(for: action.role))
                .contentShape(Capsule())
        }
        .buttonStyle(KitoEmptyStatePressStyle())
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

/// Slides and fades a piece in after the media, one beat per `delay` step.
private struct KitoEmptyStateEntrance: ViewModifier {
    let appeared: Bool
    let delay: Int
    let reduceMotion: Bool

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared || reduceMotion ? 0 : 12)
            .animation(reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.55, dampingFraction: 0.85).delay(0.08 * Double(delay)),
                       value: appeared)
    }
}

/// A gentle squeeze while pressed.
private struct KitoEmptyStatePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
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

    /// An animated illustration with a title, message and actions.
    static func illustrated(
        _ illustration: KitoEmptyStateIllustration,
        title: String? = nil,
        message: String? = nil,
        actions: [KitoEmptyStateAction] = [],
        layout: KitoEmptyStateLayout = .standard
    ) -> KitoEmptyStateView {
        KitoEmptyStateView(media: .illustration(illustration), title: title ?? illustration.name, message: message, actions: actions, layout: layout)
    }

    static func emptyCart(browse: @escaping () -> Void) -> KitoEmptyStateView {
        .illustrated(.cart, title: "Your cart is empty", message: "Items you add will show up here.",
                     actions: [KitoEmptyStateAction(title: "Start shopping", handler: browse)])
    }

    static func emptyInbox(message: String = "New messages will land here.") -> KitoEmptyStateView {
        .illustrated(.inbox, title: "Inbox zero", message: message)
    }

    static func noNotifications() -> KitoEmptyStateView {
        .illustrated(.notifications, title: "You're all caught up", message: "We'll let you know when something needs you.")
    }

    static func noFavourites(explore: @escaping () -> Void) -> KitoEmptyStateView {
        .illustrated(.favourites, title: "No favourites yet", message: "Tap the heart on anything you love to keep it here.",
                     actions: [KitoEmptyStateAction(title: "Explore", handler: explore)])
    }

    static func locationOff(openSettings: @escaping () -> Void) -> KitoEmptyStateView {
        .illustrated(.location, title: "Location is off", message: "Turn it on to see places and delivery times near you.",
                     actions: [KitoEmptyStateAction(title: "Open Settings", handler: openSettings)])
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
