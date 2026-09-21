# KitoEmptyStates

Themed empty, no-results, offline, and error views — plus `KitoStateView`,
which switches over `KitoLoadState<Value>` (from KitoCore) so a whole screen's
loading/error/content logic collapses to one call.

## Install

```swift
.package(url: "https://github.com/WykSofts-Inc/KitoEmptyStates.git", from: "1.0.0"),
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
