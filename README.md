# KitoEmptyStates

Themed empty, no-results, offline, and error views — plus `KitoStateView`,
which switches over `KitoLoadState<Value>` (from KitoCore) so a whole screen's
loading/error/content logic collapses to one call.

## Install

```swift
.package(url: "https://github.com/WykSofts-Inc/KitoEmptyStates.git", from: "1.1.0"),
```

## Samples

**Presets:**
```swift
KitoEmptyStateView.noData(message: "Add your first transaction to see it here.")
KitoEmptyStateView.noResults(query: searchText)
KitoEmptyStateView.noConnection { viewModel.reload() }
KitoEmptyStateView.error(message: error.localizedDescription) { viewModel.reload() }
```

**Custom:**
```swift
KitoEmptyStateView(
    systemImage: "cart",
    title: "Your cart is empty",
    message: "Items you add will show up here.",
    action: KitoEmptyStateAction(title: "Browse products") { router.push(.catalog) }
)
```

**Animated illustrations** — drawn in SwiftUI, no assets:
```swift
KitoEmptyStateView(
    media: .illustration(.inbox),
    title: "Inbox zero",
    message: "New messages will land here."
)

KitoEmptyStateView.emptyCart { router.push(.catalog) }
KitoEmptyStateView.noNotifications()
KitoEmptyStateView.illustrated(.offline.tinted(.indigo, .purple), title: "No signal")

// Your own, from any SF Symbol
let noTrips = KitoEmptyStateIllustration(name: "No trips", symbol: "airplane",
                                         satellites: ["suitcase.fill", "map.fill"],
                                         colors: [.teal, .blue], motion: .float)
```
Presets: `.inbox`, `.search`, `.offline`, `.cart`, `.notifications`, `.error`,
`.success`, `.location`, `.photos`, `.favourites`, `.messages`, `.calendar`,
`.wallet`, `.downloads`, `.locked`. `KitoEmptyStateIllustrationView` renders one on its own.

**Layouts:**
```swift
KitoEmptyStateView(media: .illustration(.wallet), title: "No transactions", layout: .compact)   // beside the text, for cards
KitoEmptyStateView(media: .systemImage("creditcard"), message: "No cards yet",
                   actions: [KitoEmptyStateAction(title: "Add") { }], layout: .inline)          // one dashed row
KitoEmptyStateView(media: .illustration(.success), title: "You're all set", layout: .fullScreen) // fills the screen
```

**Whole-screen state handling in one call:**
```swift
struct TransactionsScreen: View {
    @State private var viewModel = TransactionsViewModel()

    var body: some View {
        KitoStateView(viewModel.state, retry: viewModel.load) { transactions in
            List(transactions) { TransactionRow($0) }
        }
        .task { await viewModel.load() }
    }
}
```

## License

MIT
