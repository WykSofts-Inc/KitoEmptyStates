//
//  KitoEmptyStateIllustrationView.swift
//  KitoEmptyStates
//
//  Created by Wycliff on 9/24/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// Renders a `KitoEmptyStateIllustration`: a breathing glow, a slowly turning dashed
/// orbit, a glossy gradient tile with the symbol, satellite chips bobbing around it
/// and sparkles twinkling in turn. Everything scales with `size`. With Reduce Motion
/// on, the composition holds still.
public struct KitoEmptyStateIllustrationView: View {
    @Environment(\.kitoTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let illustration: KitoEmptyStateIllustration
    let size: CGFloat

    @State private var appeared = false

    public init(_ illustration: KitoEmptyStateIllustration, size: CGFloat = 180) {
        self.illustration = illustration
        self.size = size
    }

    public var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { context in
            let time = reduceMotion ? 0.6 : context.date.timeIntervalSinceReferenceDate
            let pose = KitoIllustrationPose.at(time, motion: illustration.motion)
            ZStack {
                glow(time)
                orbit(time)
                disc
                ForEach(Array(illustration.satellites.prefix(4).enumerated()), id: \.offset) { index, symbol in
                    satellite(symbol, index: index, time: time)
                }
                ForEach(0..<4, id: \.self) { sparkle($0, time: time) }
                shadow(pose)
                tile(pose)
            }
            .frame(width: size, height: size)
        }
        .scaleEffect(appeared || reduceMotion ? 1 : 0.7)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(reduceMotion ? .easeOut(duration: 0.25) : .spring(response: 0.6, dampingFraction: 0.62)) { appeared = true }
        }
        .accessibilityElement()
        .accessibilityLabel(illustration.name)
        .accessibilityAddTraits(.isImage)
    }

    // MARK: Layers

    private var colors: [Color] {
        let base = illustration.colors.isEmpty ? [theme.colors.primary, theme.colors.primary.opacity(0.7)] : illustration.colors
        return base.count == 1 ? [base[0], base[0].opacity(0.75)] : base
    }

    private func glow(_ time: TimeInterval) -> some View {
        Circle()
            .fill(RadialGradient(colors: [colors[0].opacity(colorScheme == .dark ? 0.45 : 0.3), .clear],
                                 center: .center, startRadius: 0, endRadius: size * 0.5))
            .scaleEffect(1 + 0.05 * sin(time * 1.3))
    }

    private func orbit(_ time: TimeInterval) -> some View {
        Circle()
            .strokeBorder(colors.last!.opacity(0.28), style: StrokeStyle(lineWidth: 1.2, dash: [2, 6]))
            .frame(width: size * 0.86, height: size * 0.86)
            .rotationEffect(.degrees(time * 8))
    }

    private var disc: some View {
        Circle()
            .fill(LinearGradient(colors: [colors[0].opacity(0.16), colors.last!.opacity(0.06)], startPoint: .top, endPoint: .bottom))
            .overlay(Circle().strokeBorder(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.6), lineWidth: 1))
            .frame(width: size * 0.64, height: size * 0.64)
    }

    private func tile(_ pose: KitoIllustrationPose) -> some View {
        let side = size * 0.4
        return ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: side * 0.3, style: .continuous)
                .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(
                    // Gloss along the top edge.
                    RoundedRectangle(cornerRadius: side * 0.3, style: .continuous)
                        .fill(LinearGradient(colors: [.white.opacity(0.35), .clear], startPoint: .top, endPoint: .center))
                )
                .overlay(RoundedRectangle(cornerRadius: side * 0.3, style: .continuous).strokeBorder(.white.opacity(0.25), lineWidth: 1))
                .overlay(
                    Image(systemName: illustration.symbol)
                        .font(.system(size: side * 0.42, weight: .semibold))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                )
                .frame(width: side, height: side)
                .shadow(color: colors[0].opacity(0.45), radius: side * 0.22, y: side * 0.14)

            if let badge = illustration.badge {
                Image(systemName: badge)
                    .font(.system(size: side * 0.16, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(width: side * 0.34, height: side * 0.34)
                    .background(Circle().fill(theme.colors.danger))
                    .overlay(Circle().strokeBorder(theme.colors.background, lineWidth: side * 0.045))
                    .offset(x: side * 0.12, y: -side * 0.12)
            }
        }
        .scaleEffect(x: pose.scale * (2 - pose.squash), y: pose.scale * pose.squash, anchor: .bottom)
        .rotationEffect(.degrees(pose.rotation), anchor: illustration.motion == .swing ? .top : .center)
        .offset(x: pose.x * size, y: pose.y * size)
    }

    private func shadow(_ pose: KitoIllustrationPose) -> some View {
        Ellipse()
            .fill(Color.black.opacity(colorScheme == .dark ? 0.35 : 0.12))
            .frame(width: size * 0.3 * (1 + pose.y * 3), height: size * 0.05)
            .blur(radius: 4)
            .offset(y: size * 0.26)
    }

    private func satellite(_ symbol: String, index: Int, time: TimeInterval) -> some View {
        let spot = KitoIllustrationLayout.satellite(index, of: illustration.satellites.count)
        let chip = size * (index.isMultiple(of: 2) ? 0.17 : 0.14)
        return Image(systemName: symbol)
            .font(.system(size: chip * 0.46, weight: .bold))
            .foregroundStyle(colors[index % colors.count])
            .frame(width: chip, height: chip)
            .background(Circle().fill(theme.colors.surface))
            .overlay(Circle().strokeBorder(colors[0].opacity(0.15), lineWidth: 1))
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.4 : 0.1), radius: 6, y: 3)
            .rotationEffect(.degrees(sin(time + Double(index)) * 8))
            .offset(x: spot.x * size, y: (spot.y + KitoIllustrationLayout.bob(index, at: time)) * size)
    }

    private func sparkle(_ index: Int, time: TimeInterval) -> some View {
        let spots: [CGPoint] = [CGPoint(x: -0.3, y: 0.18), CGPoint(x: 0.36, y: -0.32), CGPoint(x: 0.12, y: -0.4), CGPoint(x: -0.4, y: -0.1)]
        let lit = reduceMotion ? 0.7 : KitoIllustrationLayout.twinkle(index, at: time)
        return Image(systemName: index.isMultiple(of: 2) ? "sparkle" : "circle.fill")
            .font(.system(size: size * (index.isMultiple(of: 2) ? 0.07 : 0.025)))
            .foregroundStyle(colors[index % colors.count].opacity(0.4 + 0.6 * lit))
            .scaleEffect(0.5 + 0.5 * lit)
            .offset(x: spots[index].x * size, y: spots[index].y * size)
    }
}
