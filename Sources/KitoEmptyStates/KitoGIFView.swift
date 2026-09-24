//
//  KitoGIFView.swift
//  KitoEmptyStates
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import ImageIO
import UIKit

/// Plays an animated GIF from a `KitoEmptyStateSource`. Decodes every frame (and
/// its own per-frame delay) with ImageIO, so playback speed matches the
/// source file instead of a guessed constant frame rate.
public struct KitoGIFView: View {
    let source: KitoEmptyStateSource
    @State private var data: Data?

    public init(source: KitoEmptyStateSource) {
        self.source = source
    }

    public var body: some View {
        Group {
            if let data {
                KitoAnimatedImageRepresentable(data: data)
            } else {
                Color.clear
            }
        }
        .task(id: source) { data = await source.loadData() }
    }
}

struct KitoAnimatedImageRepresentable: UIViewRepresentable {
    let data: Data

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        applyFrames(to: imageView)
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {}

    private func applyFrames(to imageView: UIImageView) {
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else { return }
        let count = CGImageSourceGetCount(imageSource)
        guard count > 0 else { return }

        var images: [UIImage] = []
        var totalDuration: Double = 0
        for index in 0..<count {
            guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, index, nil) else { continue }
            let duration = Self.frameDuration(source: imageSource, index: index)
            totalDuration += duration
            images.append(UIImage(cgImage: cgImage))
        }

        guard !images.isEmpty else { return }
        if images.count == 1 {
            imageView.image = images[0]
            return
        }
        imageView.animationImages = images
        imageView.animationDuration = totalDuration > 0 ? totalDuration : Double(images.count) / 10
        imageView.animationRepeatCount = 0
        imageView.startAnimating()
    }

    private static func frameDuration(source: CGImageSource, index: Int) -> Double {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
              let gifProperties = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any] else {
            return 0.1
        }
        let unclamped = gifProperties[kCGImagePropertyGIFUnclampedDelayTime] as? Double
        let clamped = gifProperties[kCGImagePropertyGIFDelayTime] as? Double
        let duration = unclamped ?? clamped ?? 0.1
        return duration > 0.011 ? duration : 0.1
    }
}
