# ``KitoEmptyStates``

Themed empty, no-results, offline and error views, with a state view that switches over a load state.

## Overview

KitoEmptyStates provides one view for every "nothing to show" moment. ``KitoEmptyStateView``
combines optional media, a title, a message and any number of ``KitoEmptyStateAction`` buttons,
laid out in one of four ``KitoEmptyStateLayout`` styles: standard, compact for cards, inline for
an empty slot in a form, and full screen. Presets such as `noData(title:message:)`,
`noResults(query:)`, `noConnection(retry:)` and `error(message:retry:)` cover the common cases.

The artwork is described by ``KitoEmptyStateMedia``: an SF Symbol, an asset catalog image, a
remote image, an animated GIF, SVG, Lottie JSON, a looping muted video, or a
``KitoEmptyStateIllustration`` — an animated illustration drawn in SwiftUI with no assets. Bundled
presets include inbox, search, offline, cart, notifications, error, success and more, and you can
build your own from any SF Symbol. File and network media is supplied as a
``KitoEmptyStateSource``.

``KitoStateView`` switches over a `KitoLoadState` from KitoCore, showing a loader while loading,
an error state with a retry button on failure, and your content once loaded, so a whole screen's
loading and error logic collapses to one call.

```swift
struct TransactionsScreen: View {
    @State private var viewModel = TransactionsViewModel()

    var body: some View {
        KitoStateView(viewModel.state, retry: { Task { await viewModel.load() } }) { transactions in
            if transactions.isEmpty {
                KitoEmptyStateView(
                    media: .illustration(.wallet),
                    title: "No transactions",
                    message: "Add your first transaction to see it here."
                )
            } else {
                List(transactions) { TransactionRow($0) }
            }
        }
        .task { await viewModel.load() }
    }
}
```

Every view reads the Kito theme from the environment and respects Reduce Motion.

## Topics

### Essentials

- ``KitoEmptyStateView``
- ``KitoStateView``
- ``KitoEmptyStateAction``
- ``KitoEmptyStateActionRole``
- ``KitoEmptyStateLayout``

### Media

- ``KitoEmptyStateMedia``
- ``KitoEmptyStateSource``
- ``KitoEmptyStateIllustration``
- ``KitoEmptyStateIllustrationView``

### Media Views

- ``KitoGIFView``
- ``KitoSVGView``
- ``KitoLottieView``
- ``KitoLoopingVideoView``
