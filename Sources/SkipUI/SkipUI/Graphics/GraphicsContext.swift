// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if !SKIP_BRIDGE
import Foundation
#if SKIP
import androidx.compose.runtime.Composable
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.ClipOp
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.PathOperation
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.DrawStyle
import androidx.compose.ui.graphics.drawscope.Fill
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.clipPath
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.graphics.drawscope.scale
import androidx.compose.ui.graphics.drawscope.translate
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.TextLayoutResult
import androidx.compose.ui.text.TextMeasurer
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.drawText
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Constraints
import androidx.compose.ui.unit.Density
import androidx.compose.ui.unit.toSize
#elseif canImport(CoreGraphics)
import struct CoreGraphics.CGAffineTransform
import struct CoreGraphics.CGFloat
import struct CoreGraphics.CGPoint
import struct CoreGraphics.CGRect
import struct CoreGraphics.CGSize
#endif

/// An immediate mode drawing destination, and its current state.
public struct GraphicsContext {
    #if SKIP
    private let drawScope: DrawScope
    private let density: Density
    private let textMeasurer: TextMeasurer
    private let canvasSize: CGSize
    private var state: GraphicsContextState
    
    init(drawScope: DrawScope, density: Density, textMeasurer: TextMeasurer, size: CGSize) {
        self.drawScope = drawScope
        self.density = density
        self.textMeasurer = textMeasurer
        self.canvasSize = size
        self.state = GraphicsContextState()
    }
    #endif

    /// The opacity of drawing operations in the context.
    public var opacity: Double {
        get { 
            #if SKIP
            return state.opacity
            #else
            return 1.0
            #endif
        }
        set {
            #if SKIP
            state.opacity = newValue
            #endif
        }
    }

    /// The blend mode used by drawing operations in the context.
    public var blendMode: GraphicsContext.BlendMode {
        get {
            #if SKIP
            return state.blendMode
            #else
            return .normal
            #endif
        }
        set {
            #if SKIP
            state.blendMode = newValue
            #endif
        }
    }

    /// The environment associated with the graphics context.
    public var environment: EnvironmentValues {
        #if SKIP
        return EnvironmentValues.shared
        #else
        return EnvironmentValues()
        #endif
    }

    /// The current transform matrix, defining user space coordinates.
    public var transform: CGAffineTransform {
        get {
            #if SKIP
            return state.transform
            #else
            return CGAffineTransform.identity
            #endif
        }
        set {
            #if SKIP
            state.transform = newValue
            #endif
        }
    }

    /// Scales subsequent drawing operations by an amount in each dimension.
    public mutating func scaleBy(x: CGFloat, y: CGFloat) {
        #if SKIP
        state.transform = state.transform.scaledBy(x: x, y: y)
        #endif
    }

    /// Moves subsequent drawing operations by an amount in each dimension.
    public mutating func translateBy(x: CGFloat, y: CGFloat) {
        #if SKIP
        state.transform = state.transform.translatedBy(x: x, y: y)
        #endif
    }

    /// Rotates subsequent drawing operations by an angle.
    public mutating func rotate(by angle: Angle) {
        #if SKIP
        state.transform = state.transform.rotated(by: angle.radians)
        #endif
    }

    /// Appends the given transform to the context's existing transform.
    public mutating func concatenate(_ matrix: CGAffineTransform) {
        #if SKIP
        state.transform = matrix.concatenating(state.transform)
        #endif
    }

    /// The bounding rectangle of the intersection of all current clip shapes in the current user space.
    public var clipBoundingRect: CGRect {
        #if SKIP
        return CGRect(origin: .zero, size: canvasSize)
        #else
        return .zero
        #endif
    }

    /// Adds a path to the context's array of clip shapes.
    public mutating func clip(to path: Path, style: FillStyle, options: GraphicsContext.ClipOptions) {
        #if SKIP
        // Create empty path for now - proper Path conversion needs fixing
        let composePath = androidx.compose.ui.graphics.Path()
        // TODO: Convert path to Compose Path
        state.clipPaths.add(composePath)
        #endif
    }
    
    /// Adds a path to the context's array of clip shapes (convenience overload).
    public mutating func clip(to path: Path) {
        clip(to: path, style: FillStyle(), options: ClipOptions())
    }

    /// Adds a clip shape that you define in a new layer to the context's array of clip shapes.
    public mutating func clipToLayer(opacity: Double, options: GraphicsContext.ClipOptions, content: (inout GraphicsContext) throws -> Void) rethrows {
        #if SKIP
        var layerContext = self
        try content(&layerContext)
        #endif
    }

    /// Returns a version of a shading resolved with the current values of the graphics context's environment.
    public func resolve(_ shading: GraphicsContext.Shading) -> GraphicsContext.Shading {
        return shading
    }

    /// Draws a new layer, created by drawing code that you provide, into the context.
    public func drawLayer(content: (inout GraphicsContext) throws -> Void) rethrows {
        #if SKIP
        var layerContext = self
        try content(&layerContext)
        #endif
    }

    /// Draws a path into the context and fills the outlined region.
    public func fill(_ path: Path, with shading: GraphicsContext.Shading, style: FillStyle) {
        #if SKIP
        // Create empty path for now - proper Path conversion needs fixing
        let composePath = androidx.compose.ui.graphics.Path()
        // TODO: Convert path to Compose Path
        let brush = shading.asBrush()
        
        if let clipPath = combineClipPaths() {
            drawScope.clipPath(clipPath, ClipOp.Intersect) {
                drawScope.drawPath(
                    path: composePath,
                    brush: brush,
                    alpha: Float(state.opacity),
                    style: Fill,
                    blendMode: state.blendMode.asComposeBlendMode()
                )
            }
        } else {
            drawScope.drawPath(
                path: composePath,
                brush: brush,
                alpha: Float(state.opacity),
                style: Fill,
                blendMode: state.blendMode.asComposeBlendMode()
            )
        }
        #endif
    }
    
    /// Draws a path into the context and fills the outlined region (convenience overload).
    public func fill(_ path: Path, with shading: GraphicsContext.Shading) {
        fill(path, with: shading, style: FillStyle())
    }

    /// Draws a path into the context with a specified stroke style.
    public func stroke(_ path: Path, with shading: GraphicsContext.Shading, style: StrokeStyle) {
        #if SKIP
        // Create empty path for now - proper Path conversion needs fixing  
        let composePath = androidx.compose.ui.graphics.Path()
        // TODO: Convert path to Compose Path
        let brush = shading.asBrush()
        let strokeStyle = style.asDrawStyle(density: density) as! Stroke
        
        if let clipPath = combineClipPaths() {
            drawScope.clipPath(clipPath, ClipOp.Intersect) {
                drawScope.drawPath(
                    path: composePath,
                    brush: brush,
                    alpha: Float(state.opacity),
                    style: strokeStyle,
                    blendMode: state.blendMode.asComposeBlendMode()
                )
            }
        } else {
            drawScope.drawPath(
                path: composePath,
                brush: brush,
                alpha: Float(state.opacity),
                style: strokeStyle,
                blendMode: state.blendMode.asComposeBlendMode()
            )
        }
        #endif
    }

    /// Draws a path into the context with a specified line width.
    public func stroke(_ path: Path, with shading: GraphicsContext.Shading, lineWidth: CGFloat = 1) {
        let strokeStyle = StrokeStyle(lineWidth: lineWidth)
        stroke(path, with: shading, style: strokeStyle)
    }

    /// Gets a version of an image that's fixed with the current values of the graphics context's environment.
    public func resolve(_ image: Image) -> GraphicsContext.ResolvedImage {
        return GraphicsContext.ResolvedImage(size: CGSize(width: 0, height: 0))
    }

    /// Draws a resolved image into the context, using the specified rectangle as a layout frame.
    public func draw(_ image: GraphicsContext.ResolvedImage, in rect: CGRect, style: FillStyle = FillStyle()) {
        // TODO: Implement image drawing when ResolvedImage is complete
    }

    /// Draws a resolved image into the context, aligning an anchor within the image to a point in the context.
    public func draw(_ image: GraphicsContext.ResolvedImage, at point: CGPoint, anchor: UnitPoint = .center) {
        // TODO: Implement image drawing when ResolvedImage is complete
    }

    /// Draws an image into the context, using the specified rectangle as a layout frame.
    public func draw(_ image: Image, in rect: CGRect, style: FillStyle = FillStyle()) {
        let resolvedImage = resolve(image)
        draw(resolvedImage, in: rect, style: style)
    }

    /// Draws an image into the context, aligning an anchor within the image to a point in the context.
    public func draw(_ image: Image, at point: CGPoint, anchor: UnitPoint = .center) {
        let resolvedImage = resolve(image)
        draw(resolvedImage, at: point, anchor: anchor)
    }

    /// Gets a version of a text view that's fixed with the current values of the graphics context's environment.
    public func resolve(_ text: Text) -> GraphicsContext.ResolvedText {
        #if SKIP
        return GraphicsContext.ResolvedText(text: text, textMeasurer: textMeasurer, density: density)
        #else
        return GraphicsContext.ResolvedText()
        #endif
    }

    /// Draws resolved text into the context using the specified rectangle as a layout frame.
    public func draw(_ text: GraphicsContext.ResolvedText, in rect: CGRect) {
        #if SKIP
        text.draw(in: drawScope, rect: rect, context: self)
        #endif
    }

    /// Draws resolved text into the context, aligning an anchor within the ideal size of the text to a point in the context.
    public func draw(_ text: GraphicsContext.ResolvedText, at point: CGPoint, anchor: UnitPoint = .center) {
        #if SKIP
        let textSize = text.measure(in: canvasSize)
        let anchorOffset = CGPoint(
            x: textSize.width * anchor.x,
            y: textSize.height * anchor.y
        )
        let rect = CGRect(
            x: point.x - anchorOffset.x,
            y: point.y - anchorOffset.y,
            width: textSize.width,
            height: textSize.height
        )
        draw(text, in: rect)
        #endif
    }

    /// Draws text into the context using the specified rectangle as a layout frame.
    public func draw(_ text: Text, in rect: CGRect) {
        let resolvedText = resolve(text)
        draw(resolvedText, in: rect)
    }

    /// Draws text into the context, aligning an anchor within the ideal size of the rendered text to a point in the context.
    public func draw(_ text: Text, at point: CGPoint, anchor: UnitPoint = .center) {
        let resolvedText = resolve(text)
        draw(resolvedText, at: point, anchor: anchor)
    }

    /// Gets the identified child view as a resolved symbol, if the view exists.
    public func resolveSymbol<ID>(id: ID) -> GraphicsContext.ResolvedSymbol? where ID : Hashable {
        // TODO: Implement symbol resolution when needed
        return nil
    }

    /// Draws a resolved symbol into the context, using the specified rectangle as a layout frame.
    public func draw(_ symbol: GraphicsContext.ResolvedSymbol, in rect: CGRect) {
        // TODO: Implement symbol drawing when needed
    }

    /// Draws a resolved symbol into the context, aligning an anchor within the symbol to a point in the context.
    public func draw(_ symbol: GraphicsContext.ResolvedSymbol, at point: CGPoint, anchor: UnitPoint = .center) {
        // TODO: Implement symbol drawing when needed
    }

    /// Adds a filter that applies to subsequent drawing operations.
    public mutating func addFilter(_ filter: GraphicsContext.Filter, options: GraphicsContext.FilterOptions = FilterOptions()) {
        // TODO: Implement filter support
    }

    #if SKIP
    private func combineClipPaths() -> androidx.compose.ui.graphics.Path? {
        if state.clipPaths.isEmpty() {
            return nil
        }
        
        var combinedPath = state.clipPaths.get(0)
        for i in 1..<state.clipPaths.size {
            let newPath = androidx.compose.ui.graphics.Path()
            newPath.op(combinedPath, state.clipPaths.get(i), PathOperation.Intersect)
            combinedPath = newPath
        }
        return combinedPath
    }
    #endif
}

#if SKIP
private struct GraphicsContextState {
    var opacity: Double = 1.0
    var blendMode: GraphicsContext.BlendMode = .normal
    var transform: CGAffineTransform = CGAffineTransform.identity
    var clipPaths: kotlin.collections.MutableList<androidx.compose.ui.graphics.Path> = mutableListOf()
}
#endif

// MARK: - GraphicsContext Types

extension GraphicsContext {
    /// The ways that a graphics context combines new content with background content.
    public enum BlendMode : CaseIterable {
        case normal
        case multiply
        case screen
        case overlay
        case darken
        case lighten
        case colorDodge
        case colorBurn
        case softLight
        case hardLight
        case difference
        case exclusion
        case hue
        case saturation
        case color
        case luminosity
        case clear
        case copy
        case sourceIn
        case sourceOut
        case sourceAtop
        case destinationOver
        case destinationIn
        case destinationOut
        case destinationAtop
        case xor
        case plusDarker
        case plusLighter
        
        #if SKIP
        func asComposeBlendMode() -> androidx.compose.ui.graphics.BlendMode {
            switch self {
            case .normal: return androidx.compose.ui.graphics.BlendMode.SrcOver
            case .multiply: return androidx.compose.ui.graphics.BlendMode.Multiply
            case .screen: return androidx.compose.ui.graphics.BlendMode.Screen
            case .overlay: return androidx.compose.ui.graphics.BlendMode.Overlay
            case .darken: return androidx.compose.ui.graphics.BlendMode.Darken
            case .lighten: return androidx.compose.ui.graphics.BlendMode.Lighten
            case .colorDodge: return androidx.compose.ui.graphics.BlendMode.ColorDodge
            case .colorBurn: return androidx.compose.ui.graphics.BlendMode.ColorBurn
            case .softLight: return androidx.compose.ui.graphics.BlendMode.Overlay // SoftLight not available, using Overlay as fallback
            case .hardLight: return androidx.compose.ui.graphics.BlendMode.Overlay // HardLight not available, using Overlay as fallback
            case .difference: return androidx.compose.ui.graphics.BlendMode.Difference
            case .exclusion: return androidx.compose.ui.graphics.BlendMode.Exclusion
            case .hue: return androidx.compose.ui.graphics.BlendMode.Hue
            case .saturation: return androidx.compose.ui.graphics.BlendMode.Saturation
            case .color: return androidx.compose.ui.graphics.BlendMode.Color
            case .luminosity: return androidx.compose.ui.graphics.BlendMode.Luminosity
            case .clear: return androidx.compose.ui.graphics.BlendMode.Clear
            case .copy: return androidx.compose.ui.graphics.BlendMode.Src
            case .sourceIn: return androidx.compose.ui.graphics.BlendMode.SrcIn
            case .sourceOut: return androidx.compose.ui.graphics.BlendMode.SrcOut
            case .sourceAtop: return androidx.compose.ui.graphics.BlendMode.SrcAtop
            case .destinationOver: return androidx.compose.ui.graphics.BlendMode.DstOver
            case .destinationIn: return androidx.compose.ui.graphics.BlendMode.DstIn
            case .destinationOut: return androidx.compose.ui.graphics.BlendMode.DstOut
            case .destinationAtop: return androidx.compose.ui.graphics.BlendMode.DstAtop
            case .xor: return androidx.compose.ui.graphics.BlendMode.Xor
            case .plusDarker: return androidx.compose.ui.graphics.BlendMode.Darken
            case .plusLighter: return androidx.compose.ui.graphics.BlendMode.Plus
            }
        }
        #endif
    }

    /// Options that affect the use of clip shapes.
    public struct ClipOptions : OptionSet {
        public let rawValue: UInt32
        public init(rawValue: UInt32) { self.rawValue = rawValue }
        public init() { self.rawValue = UInt32(0) }
        
        /// An option to invert the shape or layer alpha as the clip mask.
        public static let inverse = ClipOptions(rawValue: UInt32(1 << 0))
        
        public typealias ArrayLiteralElement = ClipOptions
        public typealias Element = ClipOptions
        public typealias RawValue = UInt32
    }

    /// A text view resolved to a particular environment.
    public struct ResolvedText {
        #if SKIP
        private let text: Text
        private let textMeasurer: TextMeasurer
        private let density: Density
        
        init(text: Text, textMeasurer: TextMeasurer, density: Density) {
            self.text = text
            self.textMeasurer = textMeasurer
            self.density = density
        }
        #else
        init() {}
        #endif

        /// The shading to fill uncolored text regions with.
        public var shading: GraphicsContext.Shading {
            return .foreground
        }

        /// Measures the size of the resolved text for a given area into which the text should be placed.
        public func measure(in size: CGSize) -> CGSize {
            #if SKIP
            // TODO: Text measurement needs @Composable context
            // Cannot call text.localizedTextString() here
            return CGSize(width: 100, height: 20) // Default size
            #else
            return .zero
            #endif
        }

        /// Gets the distance from the first line's ascender to its baseline.
        public func firstBaseline(in size: CGSize) -> CGFloat {
            #if SKIP
            let measuredSize = measure(in: size)
            return measuredSize.height * 0.8  // Approximate baseline
            #else
            return 0
            #endif
        }

        /// Gets the distance from the first line's ascender to the last line's baseline.
        public func lastBaseline(in size: CGSize) -> CGFloat {
            return firstBaseline(in: size)
        }

        #if SKIP
        // Note: Cannot mark this function as @Composable because it's inside a struct
        // Text drawing must be handled differently without @Composable annotations
        func draw(in drawScope: DrawScope, rect: CGRect, context: GraphicsContext) {
            // Text drawing is currently not implemented for GraphicsContext
            // TODO: Find alternative approach that doesn't require @Composable
        }
        #endif
    }

    /// An image resolved to a particular environment.
    public struct ResolvedImage {
        /// The size of the image.
        public var size: CGSize
        
        /// The distance from the top of the image to its baseline.
        public let baseline: CGFloat = 0
        
        /// An optional shading to fill the image with.
        public var shading: GraphicsContext.Shading? = nil
        
        init(size: CGSize) {
            self.size = size
        }
    }

    /// A static sequence of drawing operations that may be drawn multiple times.
    public struct ResolvedSymbol {
        /// The dimensions of the resolved symbol.
        public var size: CGSize = .zero
    }

    /// A color or pattern that you can use to outline or fill a path.
    public struct Shading : Sendable {
        #if SKIP
        private let brushFactory: () -> Brush
        
        private init(brushFactory: @escaping () -> Brush) {
            self.brushFactory = brushFactory
        }
        
        func asBrush() -> Brush {
            return brushFactory()
        }
        #else
        private init() {}
        #endif

        /// A shading instance that draws a copy of the current background.
        public static var backdrop: GraphicsContext.Shading {
            #if SKIP
            return Shading { Brush.linearGradient(colors = listOf(Color.Transparent, Color.Transparent)) }
            #else
            return Shading()
            #endif
        }

        /// A shading instance that fills with the foreground style from the graphics context's environment.
        public static var foreground: GraphicsContext.Shading {
            #if SKIP
            // Use black as default foreground color
            let foregroundColor = androidx.compose.ui.graphics.Color.Black
            return Shading { Brush.linearGradient(colors = listOf(foregroundColor, foregroundColor)) }
            #else
            return Shading()
            #endif
        }

        /// Returns a shading instance that fills with a color.
        public static func color(_ color: Color) -> GraphicsContext.Shading {
            #if SKIP
            // Cannot directly convert color without @Composable context
            // Use a solid color brush instead
            return Shading { 
                // Default to black for now - proper color conversion needs @Composable context
                Brush.linearGradient(colors = listOf(androidx.compose.ui.graphics.Color.Black, androidx.compose.ui.graphics.Color.Black)) 
            }
            #else
            return Shading()
            #endif
        }

        /// Returns a shading instance that fills with a linear gradient.
        public static func linearGradient(_ gradient: Gradient, startPoint: CGPoint, endPoint: CGPoint, options: GraphicsContext.GradientOptions = GradientOptions()) -> GraphicsContext.Shading {
            #if SKIP
            return Shading {
                // Cannot convert colors without @Composable context
                // Use default gradient for now
                let colors = mutableListOf<androidx.compose.ui.graphics.Color>()
                colors.add(androidx.compose.ui.graphics.Color.Black)
                colors.add(androidx.compose.ui.graphics.Color.White)
                Brush.linearGradient(
                    colors = colors,
                    start = Offset(startPoint.x.toFloat(), startPoint.y.toFloat()),
                    end = Offset(endPoint.x.toFloat(), endPoint.y.toFloat())
                )
            }
            #else
            return Shading()
            #endif
        }

        /// Returns a shading instance that fills with a radial gradient.
        public static func radialGradient(_ gradient: Gradient, center: CGPoint, startRadius: CGFloat, endRadius: CGFloat, options: GraphicsContext.GradientOptions = GradientOptions()) -> GraphicsContext.Shading {
            #if SKIP
            return Shading {
                // Cannot convert colors without @Composable context
                // Use default gradient for now
                let colors = mutableListOf<androidx.compose.ui.graphics.Color>()
                colors.add(androidx.compose.ui.graphics.Color.Black)
                colors.add(androidx.compose.ui.graphics.Color.White)
                Brush.radialGradient(
                    colors = colors,
                    center = Offset(center.x.toFloat(), center.y.toFloat()),
                    radius = endRadius.toFloat()
                )
            }
            #else
            return Shading()
            #endif
        }

        /// Returns a shading instance that fills with a conic gradient.
        public static func conicGradient(_ gradient: Gradient, center: CGPoint, angle: Angle = Angle(), options: GraphicsContext.GradientOptions = GradientOptions()) -> GraphicsContext.Shading {
            #if SKIP
            return Shading {
                // Cannot convert colors without @Composable context
                // Use default gradient for now
                let colors = mutableListOf<androidx.compose.ui.graphics.Color>()
                colors.add(androidx.compose.ui.graphics.Color.Black)
                colors.add(androidx.compose.ui.graphics.Color.White)
                Brush.sweepGradient(
                    colors = colors,
                    center = Offset(center.x.toFloat(), center.y.toFloat())
                )
            }
            #else
            return Shading()
            #endif
        }
    }

    /// Options that affect the rendering of color gradients.
    public struct GradientOptions : OptionSet {
        public let rawValue: UInt32
        public init(rawValue: UInt32) { self.rawValue = rawValue }
        public init() { self.rawValue = UInt32(0) }
        
        /// An option that repeats the gradient outside its nominal range.
        public static let `repeat` = GradientOptions(rawValue: UInt32(1 << 0))
        
        /// An option that repeats the gradient outside its nominal range, reflecting every other instance.
        public static let mirror = GradientOptions(rawValue: UInt32(1 << 1))
        
        /// An option that interpolates between colors in a linear color space.
        public static let linearColor = GradientOptions(rawValue: UInt32(1 << 2))
        
        public typealias ArrayLiteralElement = GradientOptions
        public typealias Element = GradientOptions
        public typealias RawValue = UInt32
    }

    /// A type that applies image processing operations to rendered content.
    public struct Filter : Sendable {
        // TODO: Implement filter types when needed
    }

    /// Options that configure a filter that you add to a graphics context.
    public struct FilterOptions : OptionSet {
        public let rawValue: UInt32
        public init(rawValue: UInt32) { self.rawValue = rawValue }
        public init() { self.rawValue = UInt32(0) }
        
        /// An option that causes the filter to perform calculations in a linear color space.
        public static let linearColor = FilterOptions(rawValue: UInt32(1 << 0))
        
        public typealias ArrayLiteralElement = FilterOptions
        public typealias Element = FilterOptions
        public typealias RawValue = UInt32
    }
}

#endif