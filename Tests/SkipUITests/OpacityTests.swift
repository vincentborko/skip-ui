// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
import SwiftUI
import XCTest
import OSLog
import Foundation

final class OpacityTests: XCSnapshotTestCase {
    /// Black content that draws 5 wide inside a 1 wide layout frame, on a white 5x1 background.
    private func overflowingContent(opacity: Double?) -> AnyView {
        let base = Color.black.frame(width: 5.0, height: 1.0).frame(width: 1.0, height: 1.0)
        let content = opacity == nil ? AnyView(base) : AnyView(base.opacity(opacity!))
        return AnyView(ZStack {
            Color.white
            content
        }
        .frame(width: 5.0, height: 1.0))
    }

    private func dimmed(_ opacity: Double) -> AnyView {
        return AnyView(ZStack {
            Color.white
            Color.black.frame(width: 5.0, height: 1.0).opacity(opacity)
        }
        .frame(width: 5.0, height: 1.0))
    }

    /// Checks both ends of the rendered row. Emulators scale by display density, so the tests
    /// compare the first and last pixel rather than an exact pixel count.
    private func assertEnds(_ view: AnyView, _ expected: String) throws {
        let pixels = try render(view: view).pixmap.split(separator: " ").map { String($0) }
        XCTAssertFalse(pixels.isEmpty)
        XCTAssertEqual(expected, pixels.first!)
        XCTAssertEqual(expected, pixels.last!)
    }

    /// `opacity` must not clip what its content draws outside the layout bounds: the layer it
    /// composites into is bounded by the clip, not by the 1 wide frame. An unbounded `blur()`
    /// underneath an `opacity()` depends on this.
    func testOpacityDoesNotClipOverflowingContent() throws {
        try assertEnds(overflowingContent(opacity: 0.5), plaf("7F7F7F", android: "7E7E7E"))
    }

    /// Control: without `opacity` the same content covers the full width.
    func testOverflowingContentWithoutOpacity() throws {
        try assertEnds(overflowingContent(opacity: nil), "000000")
    }

    /// Control: `opacity` dims by the amount it is given, so a wrong alpha fails here.
    func testOpacityDimsByHalf() throws {
        try assertEnds(dimmed(0.5), plaf("7F7F7F", android: "7E7E7E"))
    }

    /// Control: a second amount, so an alpha applied twice fails here.
    func testOpacityDimsByAQuarter() throws {
        try assertEnds(dimmed(0.25), plaf("BFBFBF", android: "BEBEBE"))
    }

    /// Control: fully opaque is unchanged.
    func testOpacityOpaque() throws {
        try assertEnds(dimmed(1.0), "000000")
    }

    /// Control: fully transparent draws nothing.
    func testOpacityTransparent() throws {
        try assertEnds(dimmed(0.0), "FFFFFF")
    }
}
