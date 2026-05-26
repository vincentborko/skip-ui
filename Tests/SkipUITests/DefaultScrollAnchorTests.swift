// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
import XCTest
import SkipUI

/// Pure-logic tests for the `defaultScrollAnchor(_:)` initial-offset mapping.
///
/// The *rendering* side (scrolling the Compose `ScrollState` to the anchor once content is
/// laid out) is interactive and lives in the showcase for emulator review. But the core math —
/// turning a `UnitPoint` anchor + the scroll range (`maxValue`) into a Compose scroll offset —
/// is hermetically testable via `ScrollView.defaultScrollOffset(anchor:maxValue:isVertical:)`.
/// Vertical scrolling keys off the anchor's `y`; horizontal off `x`. If this mapping is wrong the
/// scroll view would rest in the wrong place — these assertions fail first.
final class DefaultScrollAnchorTests: XCTestCase {
    func testVerticalAnchorsUseY() {
        // .top → y=0 → offset 0; .bottom → y=1 → full range; .center → y=0.5 → half.
        XCTAssertEqual(ScrollView.defaultScrollOffset(anchor: .top, maxValue: 1000, isVertical: true), 0)
        XCTAssertEqual(ScrollView.defaultScrollOffset(anchor: .bottom, maxValue: 1000, isVertical: true), 1000)
        XCTAssertEqual(ScrollView.defaultScrollOffset(anchor: .center, maxValue: 1000, isVertical: true), 500)
    }

    func testHorizontalAnchorsUseX() {
        // .leading → x=0 → 0; .trailing → x=1 → full range; .center → x=0.5 → half.
        XCTAssertEqual(ScrollView.defaultScrollOffset(anchor: .leading, maxValue: 800, isVertical: false), 0)
        XCTAssertEqual(ScrollView.defaultScrollOffset(anchor: .trailing, maxValue: 800, isVertical: false), 800)
        XCTAssertEqual(ScrollView.defaultScrollOffset(anchor: .center, maxValue: 800, isVertical: false), 400)
    }

    func testAxisSelectsTheRightComponent() {
        // .topLeading is x=0,y=0 in both axes → 0; .bottomTrailing is x=1,y=1 → full range in both.
        XCTAssertEqual(ScrollView.defaultScrollOffset(anchor: .topLeading, maxValue: 600, isVertical: true), 0)
        XCTAssertEqual(ScrollView.defaultScrollOffset(anchor: .topLeading, maxValue: 600, isVertical: false), 0)
        XCTAssertEqual(ScrollView.defaultScrollOffset(anchor: .bottomTrailing, maxValue: 600, isVertical: true), 600)
        XCTAssertEqual(ScrollView.defaultScrollOffset(anchor: .bottomTrailing, maxValue: 600, isVertical: false), 600)

        // .top is x=0.5,y=0: vertical rests at the top (0), horizontal at the middle (300).
        XCTAssertEqual(ScrollView.defaultScrollOffset(anchor: .top, maxValue: 600, isVertical: true), 0)
        XCTAssertEqual(ScrollView.defaultScrollOffset(anchor: .top, maxValue: 600, isVertical: false), 300)
    }

    func testZeroRangeYieldsZeroOffset() {
        // Content that fits (no scroll range) must never produce a non-zero offset — no regression
        // for scroll views that aren't actually scrollable.
        XCTAssertEqual(ScrollView.defaultScrollOffset(anchor: .bottom, maxValue: 0, isVertical: true), 0)
        XCTAssertEqual(ScrollView.defaultScrollOffset(anchor: .center, maxValue: 0, isVertical: false), 0)
    }
}
