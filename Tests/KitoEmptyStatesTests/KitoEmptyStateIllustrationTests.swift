//
//  KitoEmptyStateIllustrationTests.swift
//  KitoEmptyStates
//
//  Created by Wycliff on 9/24/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import XCTest
import SwiftUI
@testable import KitoEmptyStates

final class KitoEmptyStateIllustrationTests: XCTestCase {
    func testPresetsAreDistinctAndComplete() {
        let presets = KitoEmptyStateIllustration.presets
        XCTAssertEqual(presets.count, 15)
        XCTAssertEqual(Set(presets).count, presets.count)
        XCTAssertEqual(Set(presets.map(\.name)).count, presets.count)
        for preset in presets {
            XCTAssertFalse(preset.symbol.isEmpty, preset.name)
            XCTAssertGreaterThanOrEqual(preset.colors.count, 2, preset.name)
            XCTAssertFalse(preset.satellites.isEmpty, preset.name)
        }
    }

    func testTintedKeepsEverythingButColours() {
        let tinted = KitoEmptyStateIllustration.inbox.tinted(.green)
        XCTAssertEqual(tinted.symbol, KitoEmptyStateIllustration.inbox.symbol)
        XCTAssertEqual(tinted.colors, [.green])
        XCTAssertNotEqual(tinted, .inbox)
    }

    func testIllustrationWorksAsMedia() {
        let view = KitoEmptyStateView.illustrated(.search, message: "Try another word.")
        XCTAssertEqual(view.media, .illustration(.search))
        XCTAssertEqual(view.title, KitoEmptyStateIllustration.search.name)
        XCTAssertEqual(view.layout, .standard)
    }

    func testLayoutDefaultsToStandardAndIsSettable() {
        XCTAssertEqual(KitoEmptyStateView(title: "Empty").layout, .standard)
        XCTAssertEqual(KitoEmptyStateView(title: "Empty", layout: .inline).layout, .inline)
    }

    func testIllustratedPresetsCarryTheirActions() {
        var browsed = false
        let cart = KitoEmptyStateView.emptyCart { browsed = true }
        XCTAssertEqual(cart.media, .illustration(.cart))
        cart.actions.first?.handler()
        XCTAssertTrue(browsed)
        XCTAssertTrue(KitoEmptyStateView.noNotifications().actions.isEmpty)
    }

    func testPosesStayWithinASmallRange() {
        let motions: [KitoEmptyStateIllustration.Motion] = [.float, .swing, .shake, .bounce, .beat, .sweep, .rock]
        for motion in motions {
            for step in 0..<120 {
                let pose = KitoIllustrationPose.at(Double(step) * 0.05, motion: motion)
                XCTAssertLessThanOrEqual(abs(pose.x), 0.05, "\(motion)")
                XCTAssertLessThanOrEqual(abs(pose.y), 0.07, "\(motion)")
                XCTAssertLessThanOrEqual(abs(pose.rotation), 17, "\(motion)")
                XCTAssertEqual(pose.scale, 1, accuracy: 0.09)
            }
        }
    }

    func testSatellitesSitAroundTheTile() {
        for index in 0..<4 {
            let spot = KitoIllustrationLayout.satellite(index, of: 4)
            let distance = sqrt(spot.x * spot.x + spot.y * spot.y)
            XCTAssertGreaterThan(distance, 0.35)
            XCTAssertLessThan(distance, 0.5)
        }
    }

    func testTwinkleIsBounded() {
        for step in 0..<100 {
            let lit = KitoIllustrationLayout.twinkle(step % 4, at: Double(step) * 0.1)
            XCTAssertGreaterThanOrEqual(lit, 0)
            XCTAssertLessThanOrEqual(lit, 1)
        }
    }
}
