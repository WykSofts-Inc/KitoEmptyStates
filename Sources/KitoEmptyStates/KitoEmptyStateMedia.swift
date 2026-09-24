//
//  KitoEmptyStateMedia.swift
//  KitoEmptyStates
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import Foundation

/// Where a piece of media comes from — in-memory bytes, or a local/remote
/// URL. `KitoGIFView`/`KitoSVGView`/`KitoLottieView` all resolve this the
/// same way, so a caller can supply a bundled asset or a downloaded one
/// through the same enum.
public enum KitoEmptyStateSource: Sendable, Equatable, Hashable {
    case data(Data)
    case url(URL)

    /// Loads the underlying bytes — synchronously off `Data`/a file URL,
    /// or over the network for a remote URL.
    func loadData() async -> Data? {
        switch self {
        case .data(let data):
            return data
        case .url(let url):
            if url.isFileURL {
                return try? Data(contentsOf: url)
            }
            return try? await URLSession.shared.data(from: url).0
        }
    }
}

/// What an empty state illustrates itself with. Every case a designer might
/// hand you — an SF Symbol for the quick case, all the way to a full Lottie
/// animation — so `KitoEmptyStateView` never forces a re-export or a custom
/// wrapper just to swap the art.
public enum KitoEmptyStateMedia: Sendable, Equatable, Hashable {
    /// No illustration at all — just title/message/actions.
    case none
    /// An SF Symbol, rendered at a large size (the original, simplest case).
    case systemImage(String)
    /// An animated illustration drawn in SwiftUI, e.g. `.illustration(.inbox)`.
    case illustration(KitoEmptyStateIllustration)
    /// A name from the host app's asset catalog.
    case image(String)
    /// A static image loaded from a local file or downloaded from the network.
    case remoteImage(KitoEmptyStateSource)
    /// An animated GIF, decoded frame-by-frame with ImageIO (no external
    /// dependency) and looped.
    case gif(KitoEmptyStateSource)
    /// Raw SVG markup, rendered by a transparent `WKWebView` (WebKit parses
    /// SVG natively — no vector library needed).
    case svg(KitoEmptyStateSource)
    /// A Lottie JSON animation, played by a bundled offline copy of
    /// lottie-web inside a transparent `WKWebView` — no CocoaPods/SPM
    /// dependency on a Lottie runtime, and no network access at play time.
    case lottie(KitoEmptyStateSource, loop: Bool = true)
    /// A short video, looped and muted by default — a silent looping clip
    /// reads as an illustration, not a video player.
    case video(URL, loop: Bool = true, muted: Bool = true)
}
