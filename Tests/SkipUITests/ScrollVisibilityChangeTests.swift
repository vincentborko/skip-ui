// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
import XCTest
import SkipUI

/// Pure-logic tests for the `onScrollVisibilityChange(threshold:_:)` crossing decision.
///
/// The *firing* side (measuring the row's clipped `boundsInWindow()` against its full size as it
/// scrolls, and invoking the callback only on a change) is interactive and lives in the showcase
/// for emulator review. But the core decision — given how much of a view's area is visible after
/// ancestor clipping, is it "visible" at the requested `threshold`? — is hermetically testable via
/// `ScrollVisibility.isConsideredVisible(visibleArea:totalArea:threshold:)`. If this is wrong the
/// badges would flip at the wrong scroll position (or never) — these assertions fail first.
final class ScrollVisibilityChangeTests: XCTestCase {
    func testHalfThresholdIsInclusive() {
        // Default threshold 0.5: exactly half visible counts as visible (>=), just under does not.
        XCTAssertTrue(ScrollVisibility.isConsideredVisible(visibleArea: 50, totalArea: 100, threshold: 0.5))
        XCTAssertFalse(ScrollVisibility.isConsideredVisible(visibleArea: 49, totalArea: 100, threshold: 0.5))
    }

    func testFullyVisibleAndFullyClipped() {
        // Entirely on-screen is visible at any threshold; entirely clipped out is never visible.
        XCTAssertTrue(ScrollVisibility.isConsideredVisible(visibleArea: 100, totalArea: 100, threshold: 0.9))
        XCTAssertFalse(ScrollVisibility.isConsideredVisible(visibleArea: 0, totalArea: 100, threshold: 0.1))
    }

    func testThresholdMatters() {
        // 30% visible: passes a low threshold, fails a high one — the lever the playground demos.
        XCTAssertTrue(ScrollVisibility.isConsideredVisible(visibleArea: 30, totalArea: 100, threshold: 0.1))
        XCTAssertFalse(ScrollVisibility.isConsideredVisible(visibleArea: 30, totalArea: 100, threshold: 0.5))
        XCTAssertFalse(ScrollVisibility.isConsideredVisible(visibleArea: 30, totalArea: 100, threshold: 0.9))
    }

    func testZeroAreaIsNeverVisible() {
        // A not-yet-laid-out view (zero total area) must not divide-by-zero or report visible,
        // even at threshold 0 — there is nothing on screen to be visible.
        XCTAssertFalse(ScrollVisibility.isConsideredVisible(visibleArea: 0, totalArea: 0, threshold: 0.5))
        XCTAssertFalse(ScrollVisibility.isConsideredVisible(visibleArea: 0, totalArea: 0, threshold: 0.0))
    }
}
