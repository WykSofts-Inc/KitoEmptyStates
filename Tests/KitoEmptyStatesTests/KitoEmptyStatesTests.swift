//
//  KitoEmptyStatesTests.swift
//  KitoEmptyStates
//
//  Created by Wycliff on 5/14/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import XCTest
@testable import KitoEmptyStates

final class KitoEmptyStatesTests: XCTestCase {
    func testNoResultsIncludesQueryInTitle() {
        let view = KitoEmptyStateView.noResults(query: "sneakers")
        XCTAssertTrue(view.title?.contains("sneakers") == true)
    }

    func testNoConnectionHasRetryAction() {
        var retried = false
        let view = KitoEmptyStateView.noConnection { retried = true }
        view.actions.first?.handler()
        XCTAssertTrue(retried)
    }

    func testBackCompatSystemImageInitProducesSingleAction() {
        var tapped = false
        let view = KitoEmptyStateView(systemImage: "tray", title: "Empty", action: KitoEmptyStateAction(title: "Retry") { tapped = true })
        XCTAssertEqual(view.actions.count, 1)
        view.actions[0].handler()
        XCTAssertTrue(tapped)
    }

    func testGeneralInitSupportsMultipleActionsAndOptionalTitle() {
        let view = KitoEmptyStateView(
            media: .systemImage("cart"),
            message: "No title here, just a message.",
            actions: [
                KitoEmptyStateAction(title: "Keep shopping", role: .primary) {},
                KitoEmptyStateAction(title: "Clear cart", role: .destructive) {},
            ],
            actionsAxis: .horizontal
        )
        XCTAssertNil(view.title)
        XCTAssertEqual(view.actions.count, 2)
        XCTAssertEqual(view.actionsAxis, .horizontal)
    }

    func testMediaSourceLoadsInMemoryDataDirectly() async {
        let payload = Data("hello".utf8)
        let loaded = await KitoEmptyStateSource.data(payload).loadData()
        XCTAssertEqual(loaded, payload)
    }

    func testMediaSourceLoadsLocalFileURL() async throws {
        let payload = Data("file contents".utf8)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try payload.write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }

        let loaded = await KitoEmptyStateSource.url(url).loadData()
        XCTAssertEqual(loaded, payload)
    }
}
