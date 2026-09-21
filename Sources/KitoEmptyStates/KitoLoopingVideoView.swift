//
//  KitoLoopingVideoView.swift
//  KitoEmptyStates
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import AVKit

/// A silent, looping video clip used as an illustration — no playback
/// controls, since a controls bar would read as "video player" rather than
/// "animated artwork".
public struct KitoLoopingVideoView: UIViewControllerRepresentable {
    let url: URL
    let loop: Bool
    let muted: Bool

    public init(url: URL, loop: Bool = true, muted: Bool = true) {
        self.url = url
        self.loop = loop
        self.muted = muted
    }

    public func makeCoordinator() -> Coordinator { Coordinator() }

    public func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let player = AVPlayer(url: url)
        player.isMuted = muted
        player.allowsExternalPlayback = false
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspect

        if loop {
            context.coordinator.observe(player: player)
        }
        player.play()
        return controller
    }

    public func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}

    public static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: Coordinator) {
        coordinator.stop()
    }

    public final class Coordinator {
        private var token: NSObjectProtocol?
        private weak var player: AVPlayer?

        func observe(player: AVPlayer) {
            self.player = player
            token = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { [weak player] _ in
                player?.seek(to: .zero)
                player?.play()
            }
        }

        func stop() {
            if let token {
                NotificationCenter.default.removeObserver(token)
            }
            player?.pause()
        }
    }
}
