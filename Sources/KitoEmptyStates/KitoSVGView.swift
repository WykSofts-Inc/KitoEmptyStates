//
//  KitoSVGView.swift
//  KitoEmptyStates
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import WebKit

/// Renders raw SVG markup from a `KitoMediaSource`. WebKit parses SVG
/// natively, so this needs no vector-graphics library — just a transparent
/// `WKWebView` with JavaScript disabled (the markup is trusted illustration
/// content, not a page that needs to run scripts).
public struct KitoSVGView: View {
    let source: KitoMediaSource
    @State private var data: Data?

    public init(source: KitoMediaSource) {
        self.source = source
    }

    public var body: some View {
        Group {
            if let data {
                KitoSVGRepresentable(svgData: data)
            } else {
                Color.clear
            }
        }
        .task(id: source) { data = await source.loadData() }
    }
}

struct KitoSVGRepresentable: UIViewRepresentable {
    let svgData: Data

    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = false
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let svgString = String(data: svgData, encoding: .utf8) ?? ""
        let html = """
        <!doctype html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            html, body { margin: 0; padding: 0; background: transparent; height: 100%; }
            body { display: flex; align-items: center; justify-content: center; }
            svg { max-width: 100%; max-height: 100%; }
          </style>
        </head>
        <body>\(svgString)</body>
        </html>
        """
        uiView.loadHTMLString(html, baseURL: nil)
    }
}
