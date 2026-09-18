// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
import SwiftUI
import XCTest
import OSLog
import Foundation

/// Renders the glow case to a PNG for visual inspection. Not an assertion.
final class OpacityImageTests: XCSnapshotTestCase {
    func testRenderGlowImage() throws {
        let view = AnyView(ZStack {
            Color(red: 0.06, green: 0.07, blue: 0.13)
            ZStack {
                RoundedRectangle(cornerRadius: 16.0)
                    .fill(LinearGradient(colors: [Color(red: 0.49, green: 0.23, blue: 0.93), Color(red: 0.02, green: 0.71, blue: 0.83)], startPoint: .leading, endPoint: .trailing))
                    .blur(radius: 15.0)
                    .opacity(0.6)
                RoundedRectangle(cornerRadius: 16.0)
                    .fill(LinearGradient(colors: [Color(red: 0.49, green: 0.23, blue: 0.93), Color(red: 0.02, green: 0.71, blue: 0.83)], startPoint: .leading, endPoint: .trailing))
            }
            .frame(width: 200.0, height: 52.0)
        }
        .frame(width: 320.0, height: 160.0))
        let out = NSTemporaryDirectory() + "/glow"
        _ = try render(outputFile: out, view: view)
        logger.info("glow image written to \(out)")
    }
}
