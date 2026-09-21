//
//  KitoLottieView.swift
//  KitoEmptyStates
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import WebKit

/// Plays a Lottie JSON animation from a `KitoMediaSource`, using a bundled
/// offline copy of lottie-web (Resources/lottie.min.js) inside a transparent
/// `WKWebView`. This is deliberate: it gives KitoEmptyStates real Lottie
/// support without taking a hard SPM/CocoaPods dependency on a Lottie
/// runtime, and without any network access at play time — the player script
/// ships inside the package, inlined straight into the HTML shell.
public struct KitoLottieView: View {
    let source: KitoMediaSource
    let loop: Bool
    @State private var json: String?

    public init(source: KitoMediaSource, loop: Bool = true) {
        self.source = source
        self.loop = loop
    }

    public var body: some View {
        Group {
            if let json {
                KitoLottieRepresentable(animationJSON: json, loop: loop)
            } else {
                Color.clear
            }
        }
        .task(id: source) {
            guard let data = await source.loadData() else { return }
            json = String(data: data, encoding: .utf8)
        }
    }
}

struct KitoLottieRepresentable: UIViewRepresentable {
    let animationJSON: String
    let loop: Bool

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let playerScript = Self.playerScript else { return }
        let html = """
        <!doctype html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            html, body { margin: 0; padding: 0; background: transparent; height: 100%; }
            #anim { width: 100%; height: 100%; }
          </style>
        </head>
        <body>
          <div id="anim"></div>
          <script>\(playerScript)</script>
          <script>
            lottie.loadAnimation({
              container: document.getElementById('anim'),
              renderer: 'svg',
              loop: \(loop),
              autoplay: true,
              animationData: \(animationJSON)
            });
          </script>
        </body>
        </html>
        """
        uiView.loadHTMLString(html, baseURL: nil)
    }

    /// Read once per process — the bundled player script never changes at
    /// runtime.
    private static let playerScript: String? = {
        guard let url = Bundle.module.url(forResource: "lottie.min", withExtension: "js") else { return nil }
        return try? String(contentsOf: url, encoding: .utf8)
    }()
}
