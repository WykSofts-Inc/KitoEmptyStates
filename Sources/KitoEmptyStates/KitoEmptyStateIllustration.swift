//
//  KitoEmptyStateIllustration.swift
//  KitoEmptyStates
//
//  Created by Wycliff on 9/24/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI

/// An animated illustration drawn entirely in SwiftUI — a glossy tile with a symbol,
/// a breathing glow, floating satellite chips and twinkling sparkles. No assets, no
/// Lottie, and it follows the theme and Dynamic Type of the app around it.
///
/// Use a preset (`.inbox`, `.search`, `.offline`, …) as `KitoEmptyStateMedia.illustration`,
/// or build your own from any SF Symbol.
public struct KitoEmptyStateIllustration: Equatable, Hashable, Sendable {
    /// The tile's signature movement.
    public enum Motion: Equatable, Hashable, Sendable {
        /// Drifts gently up and down.
        case float
        /// Swings from the top, like a bell.
        case swing
        /// A short shake every couple of seconds, like a "no".
        case shake
        /// Bounces on the spot, with a squash on landing.
        case bounce
        /// Beats like a heart.
        case beat
        /// Circles slowly, like a magnifier scanning.
        case sweep
        /// Tilts from side to side, like something rocking.
        case rock
    }

    /// Spoken by VoiceOver, e.g. "Empty inbox".
    public var name: String
    public var symbol: String
    /// Small symbols in chips floating around the tile.
    public var satellites: [String]
    /// The tile's gradient. Empty uses the theme's primary colour.
    public var colors: [Color]
    public var motion: Motion
    /// A small symbol in a bubble on the tile's corner, e.g. "exclamationmark".
    public var badge: String?

    public init(name: String, symbol: String, satellites: [String] = [], colors: [Color] = [], motion: Motion = .float, badge: String? = nil) {
        self.name = name
        self.symbol = symbol
        self.satellites = satellites
        self.colors = colors
        self.motion = motion
        self.badge = badge
    }

    /// The same illustration in other colours.
    public func tinted(_ colors: Color...) -> KitoEmptyStateIllustration {
        var copy = self
        copy.colors = colors
        return copy
    }
}

// MARK: - Presets

public extension KitoEmptyStateIllustration {
    static let inbox = KitoEmptyStateIllustration(
        name: "Empty inbox", symbol: "tray.fill", satellites: ["envelope.fill", "paperplane.fill", "doc.text.fill"],
        colors: [Color(red: 0.36, green: 0.42, blue: 1.0), Color(red: 0.55, green: 0.33, blue: 0.98)], motion: .float)

    static let search = KitoEmptyStateIllustration(
        name: "Nothing found", symbol: "magnifyingglass", satellites: ["questionmark", "doc.fill", "tag.fill"],
        colors: [Color(red: 0.08, green: 0.72, blue: 0.78), Color(red: 0.18, green: 0.45, blue: 0.95)], motion: .sweep)

    static let offline = KitoEmptyStateIllustration(
        name: "Offline", symbol: "wifi.slash", satellites: ["cloud.fill", "antenna.radiowaves.left.and.right", "icloud.slash.fill"],
        colors: [Color(red: 0.42, green: 0.47, blue: 0.58), Color(red: 0.22, green: 0.26, blue: 0.36)], motion: .rock, badge: "exclamationmark")

    static let cart = KitoEmptyStateIllustration(
        name: "Empty cart", symbol: "cart.fill", satellites: ["bag.fill", "tag.fill", "gift.fill"],
        colors: [Color(red: 1.0, green: 0.55, blue: 0.2), Color(red: 1.0, green: 0.3, blue: 0.45)], motion: .rock)

    static let notifications = KitoEmptyStateIllustration(
        name: "No notifications", symbol: "bell.fill", satellites: ["moon.zzz.fill", "checkmark", "sparkles"],
        colors: [Color(red: 1.0, green: 0.72, blue: 0.15), Color(red: 1.0, green: 0.48, blue: 0.2)], motion: .swing)

    static let error = KitoEmptyStateIllustration(
        name: "Something went wrong", symbol: "exclamationmark.triangle.fill", satellites: ["bolt.fill", "wrench.fill", "arrow.clockwise"],
        colors: [Color(red: 1.0, green: 0.32, blue: 0.35), Color(red: 1.0, green: 0.55, blue: 0.25)], motion: .shake)

    static let success = KitoEmptyStateIllustration(
        name: "All done", symbol: "checkmark.seal.fill", satellites: ["star.fill", "hands.clap.fill", "party.popper.fill"],
        colors: [Color(red: 0.13, green: 0.78, blue: 0.5), Color(red: 0.1, green: 0.62, blue: 0.75)], motion: .bounce)

    static let location = KitoEmptyStateIllustration(
        name: "Location off", symbol: "mappin.and.ellipse", satellites: ["map.fill", "location.fill", "car.fill"],
        colors: [Color(red: 0.95, green: 0.28, blue: 0.42), Color(red: 0.78, green: 0.25, blue: 0.85)], motion: .bounce)

    static let photos = KitoEmptyStateIllustration(
        name: "No photos", symbol: "photo.on.rectangle.angled", satellites: ["camera.fill", "sparkles", "heart.fill"],
        colors: [Color(red: 0.7, green: 0.35, blue: 1.0), Color(red: 1.0, green: 0.38, blue: 0.62)], motion: .float)

    static let favourites = KitoEmptyStateIllustration(
        name: "No favourites", symbol: "heart.fill", satellites: ["star.fill", "bookmark.fill", "sparkle"],
        colors: [Color(red: 1.0, green: 0.3, blue: 0.5), Color(red: 1.0, green: 0.45, blue: 0.35)], motion: .beat)

    static let messages = KitoEmptyStateIllustration(
        name: "No messages", symbol: "bubble.left.and.bubble.right.fill", satellites: ["face.smiling.fill", "paperplane.fill", "phone.fill"],
        colors: [Color(red: 0.2, green: 0.75, blue: 0.45), Color(red: 0.12, green: 0.58, blue: 0.9)], motion: .float)

    static let calendar = KitoEmptyStateIllustration(
        name: "Nothing scheduled", symbol: "calendar", satellites: ["clock.fill", "sun.max.fill", "cup.and.saucer.fill"],
        colors: [Color(red: 0.98, green: 0.36, blue: 0.3), Color(red: 0.95, green: 0.6, blue: 0.2)], motion: .rock)

    static let wallet = KitoEmptyStateIllustration(
        name: "No transactions", symbol: "creditcard.fill", satellites: ["banknote.fill", "arrow.left.arrow.right", "chart.line.uptrend.xyaxis"],
        colors: [Color(red: 0.1, green: 0.1, blue: 0.14), Color(red: 0.32, green: 0.3, blue: 0.42)], motion: .float)

    static let downloads = KitoEmptyStateIllustration(
        name: "No downloads", symbol: "arrow.down.circle.fill", satellites: ["music.note", "film.fill", "book.fill"],
        colors: [Color(red: 0.2, green: 0.55, blue: 1.0), Color(red: 0.35, green: 0.85, blue: 0.95)], motion: .bounce)

    static let locked = KitoEmptyStateIllustration(
        name: "Locked", symbol: "lock.fill", satellites: ["key.fill", "faceid", "shield.fill"],
        colors: [Color(red: 0.35, green: 0.3, blue: 0.95), Color(red: 0.15, green: 0.6, blue: 0.95)], motion: .shake)

    /// Every preset, for pickers and galleries.
    static let presets: [KitoEmptyStateIllustration] = [
        .inbox, .search, .offline, .cart, .notifications, .error, .success, .location,
        .photos, .favourites, .messages, .calendar, .wallet, .downloads, .locked,
    ]
}

// MARK: - Motion

/// The tile's pose at a moment: an offset (in units of the illustration's size), a
/// rotation, a scale and a squash, all pure so they can be tested.
struct KitoIllustrationPose: Equatable {
    var x: Double = 0
    var y: Double = 0
    var rotation: Double = 0
    var scale: Double = 1
    var squash: Double = 1

    static func at(_ time: TimeInterval, motion: KitoEmptyStateIllustration.Motion) -> KitoIllustrationPose {
        switch motion {
        case .float:
            return KitoIllustrationPose(y: sin(time * 1.6) * 0.03, rotation: sin(time * 0.8) * 2)
        case .swing:
            // A swing burst, then rest, every 2.4 s.
            let local = time.truncatingRemainder(dividingBy: 2.4)
            let damp = local < 1.2 ? exp(-local * 2.6) : 0
            return KitoIllustrationPose(y: sin(time * 1.6) * 0.012, rotation: sin(local * 14) * 16 * damp)
        case .shake:
            let local = time.truncatingRemainder(dividingBy: 2.2)
            let active = local < 0.5 ? sin(local / 0.5 * .pi) : 0
            return KitoIllustrationPose(x: sin(local * 48) * 0.025 * active, rotation: sin(local * 48) * 3 * active)
        case .bounce:
            let local = time.truncatingRemainder(dividingBy: 1.3) / 1.3
            let height = max(0, sin(local * .pi))
            let landing = local > 0.9 || local < 0.06 ? 0.9 : 1
            return KitoIllustrationPose(y: -height * 0.06, squash: landing)
        case .beat:
            let local = time.truncatingRemainder(dividingBy: 1.1) / 1.1
            let lub = exp(-pow((local - 0.12) / 0.06, 2)), dub = 0.6 * exp(-pow((local - 0.32) / 0.06, 2))
            return KitoIllustrationPose(scale: 1 + 0.08 * min(lub + dub, 1))
        case .sweep:
            return KitoIllustrationPose(x: cos(time * 1.4) * 0.04, y: sin(time * 1.4) * 0.03, rotation: sin(time * 1.4) * 6)
        case .rock:
            return KitoIllustrationPose(y: abs(sin(time * 1.5)) * -0.015, rotation: sin(time * 1.5) * 6)
        }
    }
}

enum KitoIllustrationLayout {
    /// Where satellite `index` of `count` sits, as a unit offset from the centre: spread
    /// over the upper-left, upper-right and lower-right, clear of the tile.
    static func satellite(_ index: Int, of count: Int) -> CGPoint {
        let angles: [Double] = [-150, -35, 25, 160, -95]
        let angle = angles[index % angles.count] * .pi / 180
        let radius = index.isMultiple(of: 2) ? 0.4 : 0.44
        return CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
    }

    /// Each satellite bobs on its own phase, so they never move in lockstep.
    static func bob(_ index: Int, at time: TimeInterval) -> Double {
        sin(time * (1.1 + Double(index) * 0.23) + Double(index) * 1.7) * 0.025
    }

    /// Sparkles twinkle in turn: 0 hidden, 1 fully lit.
    static func twinkle(_ index: Int, at time: TimeInterval) -> Double {
        let local = (time + Double(index) * 0.7).truncatingRemainder(dividingBy: 2.8) / 2.8
        return max(0, sin(local * .pi * 2))
    }
}
