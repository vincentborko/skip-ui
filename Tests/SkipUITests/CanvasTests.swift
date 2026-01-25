// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
import SwiftUI
import XCTest
import OSLog
import Foundation

#if SKIP
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.size
import androidx.compose.ui.unit.dp
#endif

final class CanvasTests: XCSnapshotTestCase {
    
    /// Test basic Canvas creation and rendering
    func testCanvasBasicRendering() {
        let canvas = Canvas { context, size in
            // Should not crash
            _ = context.opacity
            _ = context.blendMode
            _ = size.width
            _ = size.height
        }
        XCTAssertNotNil(canvas)
    }
    
    /// Test Canvas with symbols
    func testCanvasWithSymbols() {
        let canvas = Canvas { context, size in
            // Try to resolve a symbol (will return nil since not bridged)
            let symbol = context.resolveSymbol(id: "test")
            XCTAssertNil(symbol)
        } symbols: {
            Image(systemName: "star.fill").tag("test")
        }
        XCTAssertNotNil(canvas)
    }
    
    /// Test GraphicsContext state modifications
    func testGraphicsContextState() {
        var stateTests = false
        let _ = Canvas { context, size in
            var mutableContext = context
            
            // Test opacity
            mutableContext.opacity = 0.5
            XCTAssertEqual(mutableContext.opacity, 0.5, accuracy: 0.01)
            
            // Test blend mode
            mutableContext.blendMode = .multiply
            XCTAssertEqual(mutableContext.blendMode, .multiply)
            
            // Test transforms
            mutableContext.translateBy(x: 10, y: 20)
            mutableContext.scaleBy(x: 2, y: 2)
            mutableContext.rotate(by: .degrees(45))
            
            stateTests = true
        }
        
        // Canvas renderer is executed during composition in Skip
        #if SKIP
        // State tests would be executed during composition
        #else
        // On iOS, Canvas doesn't execute immediately
        #endif
    }
    
    /// Test GraphicsContext drawing methods
    func testGraphicsContextDrawing() {
        let _ = Canvas { context, size in
            // Create a simple path
            let rect = Path(CGRect(x: 0, y: 0, width: 100, height: 100))
            
            // Test fill
            context.fill(rect, with: .color(.blue))
            
            // Test stroke with style
            let strokeStyle = StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .miter)
            context.stroke(rect, with: .color(.black), style: strokeStyle)
            
            // Test stroke with line width
            context.stroke(rect, with: .color(.red), lineWidth: 3)
            
            // Test text drawing
            let text = Text("Test")
            context.draw(text, at: CGPoint(x: 50, y: 50))
            
            // Test text with anchor
            context.draw(text, at: CGPoint(x: 100, y: 100), anchor: .bottomTrailing)
        }
    }
    
    /// Test GraphicsContext clipping
    func testGraphicsContextClipping() {
        let _ = Canvas { context, size in
            var mutableContext = context
            
            // Create a clip path
            let clipPath = Path(ellipseIn: CGRect(x: 0, y: 0, width: 100, height: 100))
            mutableContext.clip(to: clipPath)
            
            // Draw something that should be clipped
            let rect = Path(CGRect(x: 0, y: 0, width: 200, height: 200))
            mutableContext.fill(rect, with: .color(.green))
        }
    }
    
    /// Test GraphicsContext gradients
    func testGraphicsContextGradients() {
        let _ = Canvas { context, size in
            let rect = Path(CGRect(x: 0, y: 0, width: 100, height: 100))
            let gradient = Gradient(colors: [.red, .blue])
            
            // Linear gradient
            context.fill(rect, with: .linearGradient(
                gradient,
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: 100, y: 100)
            ))
            
            // Radial gradient
            context.fill(rect, with: .radialGradient(
                gradient,
                center: CGPoint(x: 50, y: 50),
                startRadius: 0,
                endRadius: 50
            ))
            
            // Conic gradient
            context.fill(rect, with: .conicGradient(
                gradient,
                center: CGPoint(x: 50, y: 50),
                angle: .degrees(0)
            ))
        }
    }
    
    /// Test ColorRenderingMode
    func testColorRenderingMode() {
        // Test all modes
        let _ = Canvas(opaque: false, colorMode: .nonLinear) { _, _ in }
        let _ = Canvas(opaque: false, colorMode: .linear) { _, _ in }
        let _ = Canvas(opaque: false, colorMode: .extendedLinear) { _, _ in }
        
        // Test opaque flag
        let _ = Canvas(opaque: true) { _, _ in }
        
        // Test async rendering flag
        let _ = Canvas(rendersAsynchronously: true) { _, _ in }
    }
    
    func testZStackOpacityOverlay() throws {
        XCTAssertEqual(try render(compact: 1, view: ZStack {
            Color.black.frame(width: 12.0, height: 12.0)
            Color.white.opacity(0.6).frame(width: 6.0, height: 6.0)
        }).pixmap,
        plaf("""
        0 0 0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0 0 0
        0 0 0 9 9 9 9 9 9 0 0 0
        0 0 0 9 9 9 9 9 9 0 0 0
        0 0 0 9 9 9 9 9 9 0 0 0
        0 0 0 9 9 9 9 9 9 0 0 0
        0 0 0 9 9 9 9 9 9 0 0 0
        0 0 0 9 9 9 9 9 9 0 0 0
        0 0 0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0 0 0
        """))
    }

    func testZStackMultiOpacityOverlay() throws {
        if isAndroid {
            throw XCTSkip("opacity overlay not passing on Android emulator")
        }

        XCTAssertEqual(try render(compact: 1, view: ZStack {
            Color.black.frame(width: 12.0, height: 12.0)
            Color.white.opacity(0.8).frame(width: 8.0, height: 8.0)
            Color.black.opacity(0.5).frame(width: 4.0, height: 4.0)
            Color.white.opacity(0.22).frame(width: 2.0, height: 2.0)
        }).pixmap,
        plaf("""
        0 0 0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0 0 0
        0 0 C C C C C C C C 0 0
        0 0 C C C C C C C C 0 0
        0 0 C C 6 6 6 6 C C 0 0
        0 0 C C 6 8 8 6 C C 0 0
        0 0 C C 6 8 8 6 C C 0 0
        0 0 C C 6 6 6 6 C C 0 0
        0 0 C C C C C C C C 0 0
        0 0 C C C C C C C C 0 0
        0 0 0 0 0 0 0 0 0 0 0 0
        0 0 0 0 0 0 0 0 0 0 0 0
        """))
    }


    func testRenderCustomShape() throws {
        #if !SKIP
        throw XCTSkip("Android-only function")
        #else
        XCTAssertEqual(try render(compact: 1, view: ComposeBuilder(content: { ctx in
            androidx.compose.foundation.layout.Box(modifier: androidx.compose.ui.Modifier.background(androidx.compose.ui.graphics.Color.White).size(12.dp), contentAlignment: androidx.compose.ui.Alignment.Center) {
                androidx.compose.foundation.layout.Box(modifier: androidx.compose.ui.Modifier.background(androidx.compose.ui.graphics.Color.Black).size(6.dp, 6.dp))
            }
            return .ok
        })).pixmap,
        plaf("""
        F F F F F F F F F F F F
        F F F F F F F F F F F F
        F F F F F F F F F F F F
        F F F 0 0 0 0 0 0 F F F
        F F F 0 0 0 0 0 0 F F F
        F F F 0 0 0 0 0 0 F F F
        F F F 0 0 0 0 0 0 F F F
        F F F 0 0 0 0 0 0 F F F
        F F F 0 0 0 0 0 0 F F F
        F F F F F F F F F F F F
        F F F F F F F F F F F F
        F F F F F F F F F F F F
        """))
        #endif
    }

    func testRenderCustomCanvas() throws {
        #if !SKIP
        throw XCTSkip("Android-only function")
        #else
        XCTAssertEqual(try render(compact: 1, view: ComposeBuilder(content: { ctx in
            androidx.compose.foundation.layout.Box(modifier: androidx.compose.ui.Modifier.size(12.dp).background(androidx.compose.ui.graphics.Color.White), contentAlignment: androidx.compose.ui.Alignment.Center) {
                androidx.compose.foundation.layout.Box(modifier: androidx.compose.ui.Modifier.size(6.dp, 6.dp).background(androidx.compose.ui.graphics.Color.Black))
            }
            return .ok
        })).pixmap,
        plaf("""
        F F F F F F F F F F F F
        F F F F F F F F F F F F
        F F F F F F F F F F F F
        F F F 0 0 0 0 0 0 F F F
        F F F 0 0 0 0 0 0 F F F
        F F F 0 0 0 0 0 0 F F F
        F F F 0 0 0 0 0 0 F F F
        F F F 0 0 0 0 0 0 F F F
        F F F 0 0 0 0 0 0 F F F
        F F F F F F F F F F F F
        F F F F F F F F F F F F
        F F F F F F F F F F F F
        """))
        #endif
    }
}
