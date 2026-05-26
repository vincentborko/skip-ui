// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
import XCTest
import SkipUI

/// Pure-logic tests for the `scrollBounceBehavior(_:axes:)` Swift↔Kotlin bridge contract.
///
/// The *rendering* side (suppressing the Compose stretch overscroll when `.basedOnSize` and the
/// content fits) is interactive/visual and lives in the showcase for emulator review. But the bridge
/// ordinals are hermetically testable: `scrollBounceBehavior` crosses the Fuse bridge as an `Int`
/// (`SkipSwiftUI.ScrollBounceBehavior.bridgedValue` sends 0/1/2; SkipUI decodes with
/// `ScrollBounceBehavior(rawValue:)`). Both sides must agree on `automatic=0, always=1, basedOnSize=2`.
/// If these cases are ever reordered or given different raw values, the bridge would silently apply
/// the wrong behavior — these assertions fail first.
final class ScrollBounceBehaviorTests: XCTestCase {
    func testRawValuesAreTheBridgeOrdinals() {
        XCTAssertEqual(ScrollBounceBehavior.automatic.rawValue, 0)
        XCTAssertEqual(ScrollBounceBehavior.always.rawValue, 1)
        XCTAssertEqual(ScrollBounceBehavior.basedOnSize.rawValue, 2)
    }

    func testBridgeDecodeRoundTrips() {
        // The decode used by `scrollBounceBehavior(bridgedBehavior:bridgedAxes:)`.
        XCTAssertEqual(ScrollBounceBehavior(rawValue: 0), .automatic)
        XCTAssertEqual(ScrollBounceBehavior(rawValue: 1), .always)
        XCTAssertEqual(ScrollBounceBehavior(rawValue: 2), .basedOnSize)
    }

    func testBridgeDecodeFallsBackForOutOfRange() {
        // Out-of-range ints must hit the `?? .automatic` fallback (decode returns nil for them).
        XCTAssertNil(ScrollBounceBehavior(rawValue: -1))
        XCTAssertNil(ScrollBounceBehavior(rawValue: 3))
    }
}
