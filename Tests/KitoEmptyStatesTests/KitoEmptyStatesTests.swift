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
        XCTAssertTrue(view.title.contains("sneakers"))
    }

    func testNoConnectionHasRetryAction() {
        var retried = false
        let view = KitoEmptyStateView.noConnection { retried = true }
        view.action?.handler()
        XCTAssertTrue(retried)
    }
}
