// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
import XCTest
import SkipUI

/// Pure-logic tests for the `controlSize(_:)` Swift↔Kotlin bridge contract.
///
/// The *rendering* side (button padding + label font scaling) is visual and lives in the showcase
/// for emulator review. But the bridge ordinals are hermetically testable: `controlSize(_:)` crosses
/// the Fuse bridge as an `Int` (`SkipSwiftUI` sends the case's `allCases` index; SkipUI decodes with
/// `ControlSize(rawValue:)`). Both sides must agree on `mini=0 … extraLarge=4`. If these cases are
/// ever reordered or given explicit raw values, the bridge would silently apply the wrong size —
/// these assertions fail first.
final class ControlSizeTests: XCTestCase {
    func testRawValuesAreTheBridgeOrdinals() {
        XCTAssertEqual(ControlSize.mini.rawValue, 0)
        XCTAssertEqual(ControlSize.small.rawValue, 1)
        XCTAssertEqual(ControlSize.regular.rawValue, 2)
        XCTAssertEqual(ControlSize.large.rawValue, 3)
        XCTAssertEqual(ControlSize.extraLarge.rawValue, 4)
    }

    func testAllCasesOrderIsContiguousFromZero() {
        // `SkipSwiftUI.ControlSize.bridgedValue` is the `allCases` index; this guards SkipUI's matching end.
        XCTAssertEqual(ControlSize.allCases.map(\.rawValue), [0, 1, 2, 3, 4])
    }

    func testBridgeDecodeRoundTrips() {
        // The decode used by `controlSize(bridgedControlSize:)`.
        XCTAssertEqual(ControlSize(rawValue: 0), .mini)
        XCTAssertEqual(ControlSize(rawValue: 4), .extraLarge)
    }

    func testBridgeDecodeFallsBackForOutOfRange() {
        // Out-of-range ints must hit the `?? .regular` fallback (decode returns nil for them).
        XCTAssertNil(ControlSize(rawValue: -1))
        XCTAssertNil(ControlSize(rawValue: 5))
    }
}
