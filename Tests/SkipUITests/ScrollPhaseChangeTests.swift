// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
import XCTest
import SkipUI

/// Pure-logic tests for the `onScrollPhaseChange(_:)` phase decision.
///
/// The *firing* side (tracking pointer-pressed state with a non-consuming pointerInput, observing
/// `scrollState.isScrollInProgress` off-composition, and invoking the callback only on a change) is
/// interactive and lives in the showcase for emulator review. But the core decision — given whether a
/// pointer is pressed and whether a scroll is in progress, which `ScrollPhase` are we in? — is
/// hermetically testable via `ScrollView.scrollPhase(isPressed:isScrollInProgress:)`. If this mapping
/// is wrong the reported phase would be wrong (e.g. a fling reported as `.interacting`, or a resting
/// finger as `.idle`) — these assertions fail first.
final class ScrollPhaseChangeTests: XCTestCase {
    func testFingerDownAndMovingIsInteracting() {
        // The user is actively dragging the content.
        XCTAssertEqual(ScrollView.scrollPhase(isPressed: true, isScrollInProgress: true), ScrollPhase.interacting)
    }

    func testFingerDownButStillIsTracking() {
        // Finger is on the screen but the content hasn't started moving yet.
        XCTAssertEqual(ScrollView.scrollPhase(isPressed: true, isScrollInProgress: false), ScrollPhase.tracking)
    }

    func testFingerUpButStillMovingIsDecelerating() {
        // The user lifted off and the content is coasting (a fling).
        XCTAssertEqual(ScrollView.scrollPhase(isPressed: false, isScrollInProgress: true), ScrollPhase.decelerating)
    }

    func testNothingHappeningIsIdle() {
        // No touch, not moving — at rest.
        XCTAssertEqual(ScrollView.scrollPhase(isPressed: false, isScrollInProgress: false), ScrollPhase.idle)
    }

    func testRawValuesAreTheBridgeContract() {
        // The raw values are what crosses the bridge to SkipSwiftUI's ScrollPhase; if they drift the
        // far side would reconstruct the wrong phase. Pin them.
        XCTAssertEqual(ScrollPhase.idle.rawValue, 0)
        XCTAssertEqual(ScrollPhase.tracking.rawValue, 1)
        XCTAssertEqual(ScrollPhase.interacting.rawValue, 2)
        XCTAssertEqual(ScrollPhase.decelerating.rawValue, 3)
        XCTAssertEqual(ScrollPhase.animating.rawValue, 4)
    }
}
