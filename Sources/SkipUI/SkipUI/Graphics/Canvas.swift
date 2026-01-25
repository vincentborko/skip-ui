// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if !SKIP_BRIDGE
import Foundation
#if SKIP
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.DrawStyle
import androidx.compose.ui.graphics.drawscope.Fill
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.graphics.Paint
import androidx.compose.ui.graphics.PaintingStyle
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.translate
import androidx.compose.ui.graphics.drawscope.scale
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.graphics.BlendMode
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.drawscope.clipPath
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.TextMeasurer
import androidx.compose.ui.text.drawText
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.unit.Density
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.toSize
#elseif canImport(CoreGraphics)
import struct CoreGraphics.CGFloat
import struct CoreGraphics.CGSize
#endif

/// A view type that supports immediate mode drawing.
///
/// Use a canvas to draw rich and dynamic 2D graphics inside a SkipUI view.
/// The canvas passes a ``GraphicsContext`` to the closure that you use
/// to perform immediate mode drawing operations.
public struct Canvas<Symbols> where Symbols : View {
    public let symbols: Symbols
    public let renderer: (inout GraphicsContext, CGSize) -> Void
    public let isOpaque: Bool
    public let colorMode: ColorRenderingMode
    public let rendersAsynchronously: Bool

    /// Creates and configures a canvas that you supply with renderable child views.
    public init(opaque: Bool = false, colorMode: ColorRenderingMode = .nonLinear, rendersAsynchronously: Bool = false, renderer: @escaping (inout GraphicsContext, CGSize) -> Void, @ViewBuilder symbols: () -> Symbols) {
        self.isOpaque = opaque
        self.colorMode = colorMode
        self.rendersAsynchronously = rendersAsynchronously
        self.renderer = renderer
        self.symbols = symbols()
    }

    public typealias Body = NeverView
}

extension Canvas where Symbols == EmptyView {
    /// Creates and configures a canvas.
    public init(opaque: Bool = false, colorMode: ColorRenderingMode = .nonLinear, rendersAsynchronously: Bool = false, renderer: @escaping (inout GraphicsContext, CGSize) -> Void) {
        self.isOpaque = opaque
        self.colorMode = colorMode
        self.rendersAsynchronously = rendersAsynchronously
        self.renderer = renderer
        self.symbols = EmptyView()
    }
}

#if SKIP
extension Canvas : Renderable {
    @Composable public func Render(context: ComposeContext) {
        let density = LocalDensity.current
        let textMeasurer = rememberTextMeasurer()
        
        Canvas(modifier: context.modifier) { drawScope ->
            let size = CGSize(width: CGFloat(drawScope.size.width / density.density), height: CGFloat(drawScope.size.height / density.density))
            var graphicsContext = GraphicsContext(drawScope: drawScope, density: density, textMeasurer: textMeasurer, size: size)
            renderer(&graphicsContext, size)
        }
    }
}
#endif

extension Canvas : View {
    public var body: Body { fatalError() }
}

/// A working color space and storage format of a canvas.
public enum ColorRenderingMode : Hashable {
    case nonLinear
    case linear
    case extendedLinear
}

#endif