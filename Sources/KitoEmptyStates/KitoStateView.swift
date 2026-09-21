//
//  KitoStateView.swift
//  KitoEmptyStates
//
//  Created by Wycliff on 5/13/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
import KitoLoaders

/// Switches over a `KitoLoadState<Value>` and shows the matching UI — a
/// loader while `.loading`, the empty state on failure, or your content once
/// `.loaded`. Every list-backed screen in the ecosystem can share this
/// instead of re-deriving the same `if/else` chain.
public struct KitoStateView<Value, Content: View>: View {
    let state: KitoLoadState<Value>
    let retry: (() -> Void)?
    @ViewBuilder let content: (Value) -> Content

    public init(
        _ state: KitoLoadState<Value>,
        retry: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Value) -> Content
    ) {
        self.state = state
        self.retry = retry
        self.content = content
    }

    public var body: some View {
        switch state {
        case .idle, .loading:
            KitoSpinner()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let value):
            content(value)
        case .failed(let error):
            KitoEmptyStateView.error(message: error.localizedDescription) { retry?() }
        }
    }
}
