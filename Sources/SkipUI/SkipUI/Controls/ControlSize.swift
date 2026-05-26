// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if !SKIP_BRIDGE

public enum ControlSize : Int, CaseIterable, Hashable /*, Comparable */ {
    case mini
    case small
    case regular
    case large
    case extraLarge

    #if SKIP
    /// Font-scale multiplier applied to a control's label relative to `.regular` (= 1.0),
    /// approximating how SwiftUI scales control text across sizes. Drives a `Density.fontScale`
    /// override scoped to the control, so only the control's `.sp` label text rescales (not the page).
    /// Intentionally coarse (Material has no per-size text-style table), but monotonic.
    var labelFontScale: Float {
        switch self {
        case .mini: return Float(0.80)
        case .small: return Float(0.88)
        case .regular: return Float(1.0)
        case .large: return Float(1.18)
        case .extraLarge: return Float(1.35)
        }
    }
    #endif
}

#endif
