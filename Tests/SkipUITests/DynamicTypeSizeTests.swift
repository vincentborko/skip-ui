// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
import XCTest
import SkipUI

/// Pure-logic tests for the `dynamicTypeSize(_ range:)` clamp decision.
///
/// The *rendering* side of `dynamicTypeSize(_:)` (text rescaling via `Density.fontScale`) is
/// visual and lives in the showcase for emulator review. But the clamp direction — whether a
/// device size is pinned up to the lower bound, down to the upper bound, or left alone — is the
/// bug-prone core of the range overload and is hermetically testable on both platforms.
final class DynamicTypeSizeTests: XCTestCase {
    func testClampBelowRangeBumpsUpToLower() {
        // Device at the default (.large) but a floor of .accessibility3 forces it up.
        XCTAssertEqual(DynamicTypeSize.clamped(.large, lowerBound: .accessibility3, upperBound: .accessibility5), .accessibility3)
    }

    func testClampAboveRangeCapsDownToUpper() {
        // Device at .large but capped at .small forces it down.
        XCTAssertEqual(DynamicTypeSize.clamped(.large, lowerBound: .xSmall, upperBound: .small), .small)
    }

    func testWithinRangeIsUnchanged() {
        XCTAssertEqual(DynamicTypeSize.clamped(.large, lowerBound: .large, upperBound: .xLarge), .large)
        XCTAssertEqual(DynamicTypeSize.clamped(.xxxLarge, lowerBound: .medium, upperBound: .accessibility5), .xxxLarge)
    }

    func testBoundsAreInclusive() {
        // Exactly on either bound counts as in-range (unchanged).
        XCTAssertEqual(DynamicTypeSize.clamped(.small, lowerBound: .small, upperBound: .large), .small)
        XCTAssertEqual(DynamicTypeSize.clamped(.large, lowerBound: .small, upperBound: .large), .large)
    }

    func testDegenerateSingleValueRangePins() {
        // A single-category band pins everything to that category.
        XCTAssertEqual(DynamicTypeSize.clamped(.accessibility5, lowerBound: .medium, upperBound: .medium), .medium)
        XCTAssertEqual(DynamicTypeSize.clamped(.xSmall, lowerBound: .medium, upperBound: .medium), .medium)
    }
}
