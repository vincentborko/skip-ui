// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if !SKIP_BRIDGE
#if SKIP
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.Density
import kotlin.math.abs
#endif

public enum DynamicTypeSize : Int, Hashable, Comparable, CaseIterable {
    case xSmall
    case small
    case medium
    case large
    case xLarge
    case xxLarge
    case xxxLarge
    case accessibility1
    case accessibility2
    case accessibility3
    case accessibility4
    case accessibility5

    public var isAccessibilitySize: Bool {
        return rawValue >= DynamicTypeSize.accessibility1.rawValue
    }

    public static func < (a: DynamicTypeSize, b: DynamicTypeSize) -> Bool {
        return a.rawValue < b.rawValue
    }

    /// Pin `current` into the inclusive `[lower, upper]` band: bump up to `lower` if below it,
    /// down to `upper` if above it, otherwise leave it untouched. This is the core decision of the
    /// `dynamicTypeSize(_ range:)` overload, kept pure (no Compose) so it is unit-testable.
    public static func clamped(_ current: DynamicTypeSize, lowerBound lower: DynamicTypeSize, upperBound upper: DynamicTypeSize) -> DynamicTypeSize {
        if current < lower {
            return lower
        } else if current > upper {
            return upper
        } else {
            return current
        }
    }

    #if SKIP
    /// Approximate font-scale multiplier relative to `.large` (the default = 1.0), mirroring the
    /// content-size scaling iOS applies for each Dynamic Type category. Drives Compose's
    /// `Density.fontScale`, which is what `.sp` text sizes multiply by. Values are intentionally
    /// coarse (Android has no per-text-style table like UIKit's), but monotonic and visually faithful.
    var fontScaleMultiplier: Float {
        switch self {
        case .xSmall: return Float(0.82)
        case .small: return Float(0.88)
        case .medium: return Float(0.94)
        case .large: return Float(1.0)
        case .xLarge: return Float(1.12)
        case .xxLarge: return Float(1.23)
        case .xxxLarge: return Float(1.35)
        case .accessibility1: return Float(1.64)
        case .accessibility2: return Float(1.95)
        case .accessibility3: return Float(2.35)
        case .accessibility4: return Float(2.76)
        case .accessibility5: return Float(3.12)
        }
    }

    /// Inverse of `fontScaleMultiplier`: the category whose multiplier sits closest to the device's
    /// current `Density.fontScale`. Used by the range-clamp overload to decide whether the live
    /// device size falls outside the requested bounds.
    static func from(fontScale scale: Float) -> DynamicTypeSize {
        var closest = DynamicTypeSize.large
        var closestDelta = Float(1000.0)
        for size in DynamicTypeSize.allCases {
            let delta = abs(size.fontScaleMultiplier - scale)
            if delta < closestDelta {
                closestDelta = delta
                closest = size
            }
        }
        return closest
    }
    #endif
}

extension View {
    // The app-facing `dynamicTypeSize(_ size:)` / `dynamicTypeSize(_ range:)` overloads live in
    // SkipSwiftUI (native Swift, full `RangeExpression` support); they resolve to plain `Int`
    // ordinals and call the two `@bridge` entry points below. SkipUI itself only needs those.

    // SKIP @bridge
    public func dynamicTypeSize(bridgedSize: Int) -> any View {
        #if SKIP
        let size = DynamicTypeSize(rawValue: bridgedSize) ?? DynamicTypeSize.large
        // Wrap the subtree in a CompositionLocalProvider that overrides only Density.fontScale
        // (pixel `density` is kept intact, so `.dp` layout is unaffected — only `.sp` text rescales).
        return ModifiedContent(content: self, modifier: RenderModifier { renderable, context in
            let density = LocalDensity.current
            let newScale = size.fontScaleMultiplier
            // SKIP INSERT: val provided = LocalDensity provides Density(density.density, newScale)
            CompositionLocalProvider(provided) { renderable.Render(context: context) }
        })
        #else
        return self
        #endif
    }

    // SKIP @bridge
    public func dynamicTypeSize(bridgedLowerBound: Int, bridgedUpperBound: Int) -> any View {
        #if SKIP
        let lower = DynamicTypeSize(rawValue: bridgedLowerBound) ?? DynamicTypeSize.xSmall
        let upper = DynamicTypeSize(rawValue: bridgedUpperBound) ?? DynamicTypeSize.accessibility5
        return ModifiedContent(content: self, modifier: RenderModifier { renderable, context in
            let density = LocalDensity.current
            let current = DynamicTypeSize.from(fontScale: density.fontScale)
            let effective = DynamicTypeSize.clamped(current, lowerBound: lower, upperBound: upper)
            let newScale: Float
            if effective == current {
                // Within range: leave the device's actual font scale untouched so we don't
                // requantize a setting the user explicitly allows.
                newScale = density.fontScale
            } else {
                newScale = effective.fontScaleMultiplier
            }
            // SKIP INSERT: val provided = LocalDensity provides Density(density.density, newScale)
            CompositionLocalProvider(provided) { renderable.Render(context: context) }
        })
        #else
        return self
        #endif
    }
}

#endif
