// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if !SKIP_BRIDGE
#if SKIP
import androidx.compose.runtime.Composable
import androidx.compose.ui.geometry.Rect
#elseif canImport(CoreGraphics)
import struct CoreGraphics.CGFloat
#endif

public struct SafeAreaRegions : OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let container = SafeAreaRegions(rawValue: 1)
    public static let keyboard = SafeAreaRegions(rawValue: 2)
    public static let all = SafeAreaRegions(rawValue: 3)
}

#if SKIP
import androidx.compose.ui.geometry.Rect

/// Track safe area.
struct SafeArea: Equatable, CustomStringConvertible {
    /// Total bounds of presentation root.
    let presentationBoundsPx: Rect

    /// Safe bounds of presentation root.
    let safeBoundsPx: Rect

    /// The edges whose safe area is solely due to system bars.
    let absoluteSystemBarEdges: Edge.Set

    init(presentation: Rect, safe: Rect, absoluteSystemBars: Edge.Set = []) {
        self.presentationBoundsPx = presentation
        self.safeBoundsPx = safe
        self.absoluteSystemBarEdges = absoluteSystemBars
    }

    /// Update the safe area.
    @Composable func insetting(_ edge: Edge, to value: Float) -> SafeArea {
        guard value > Float(0.0) else {
            return self
        }
        var systemBarEdges = absoluteSystemBarEdges
        var (safeLeft, safeTop, safeRight, safeBottom) = safeBoundsPx
        switch edge {
        case .top:
            safeTop = value
            systemBarEdges.remove(.top)
        case .bottom:
            safeBottom = value
            systemBarEdges.remove(.bottom)
        case .leading:
            safeLeft = value
            systemBarEdges.remove(.leading)
        case .trailing:
            safeRight = value
            systemBarEdges.remove(.trailing)
        }
        return SafeArea(presentation: presentationBoundsPx, safe: Rect(top: safeTop, left: safeLeft, bottom: safeBottom, right: safeRight), absoluteSystemBars: systemBarEdges)
    }
    
    var description: String {
        "SafeArea(presentationBoundsPx: \(presentationBoundsPx), safeBoundsPx: \(safeBoundsPx), absoluteSystemBarEdges: \(absoluteSystemBarEdges))"
    }
}
#endif

extension View {
    public func safeAreaInset(edge: VerticalEdge, alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: () -> any View) -> any View {
        #if SKIP
        // Reserve space for the inset bar by stacking it with the main content at the given
        // vertical edge. The main content fills the remaining height (VStack gives a
        // `maxHeight: .infinity` child `weight(1)`), so the bar sits flush against the edge —
        // the common full-bleed safeAreaInset visual. Note: unlike SwiftUI we don't shrink an
        // enclosing ScrollView's safe area, so scrollable content won't scroll *under* the bar.
        let inset = content()
        let main = frame(maxHeight: .infinity)
        switch edge {
        case .top:
            return VStack(alignment: alignment, spacing: spacing ?? 0.0) {
                inset
                main
            }
        case .bottom:
            return VStack(alignment: alignment, spacing: spacing ?? 0.0) {
                main
                inset
            }
        }
        #else
        return self
        #endif
    }

    public func safeAreaInset(edge: HorizontalEdge, alignment: VerticalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: () -> any View) -> any View {
        #if SKIP
        // Horizontal counterpart: the main content fills the remaining width so the bar pins
        // to the leading/trailing edge. See the vertical overload for the safe-area caveat.
        let inset = content()
        let main = frame(maxWidth: .infinity)
        switch edge {
        case .leading:
            return HStack(alignment: alignment, spacing: spacing ?? 0.0) {
                inset
                main
            }
        case .trailing:
            return HStack(alignment: alignment, spacing: spacing ?? 0.0) {
                main
                inset
            }
        }
        #else
        return self
        #endif
    }

    // SKIP @bridge
    public func safeAreaInset(bridgedEdge: Int, isVertical: Bool, alignmentKey: String, spacing: CGFloat?, bridgedContent: any View) -> any View {
        if isVertical {
            return safeAreaInset(edge: VerticalEdge(rawValue: bridgedEdge) ?? .bottom, alignment: HorizontalAlignment(key: alignmentKey), spacing: spacing) { bridgedContent }
        } else {
            return safeAreaInset(edge: HorizontalEdge(rawValue: bridgedEdge) ?? .trailing, alignment: VerticalAlignment(key: alignmentKey), spacing: spacing) { bridgedContent }
        }
    }

    @available(*, unavailable)
    public func safeAreaPadding(_ insets: EdgeInsets) -> some View {
        return self
    }

    @available(*, unavailable)
    public func safeAreaPadding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
        return self
    }

    @available(*, unavailable)
    public func safeAreaPadding(_ length: CGFloat) -> some View {
        return self
    }

    @available(*, unavailable)
    public func safeAreaBar(edge: VerticalEdge, alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: () -> some View) -> some View {
        return self
    }

    @available(*, unavailable)
    public func safeAreaBar(edge: HorizontalEdge, alignment: VerticalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: () -> some View) -> some View {
        return self
    }
}

#endif
