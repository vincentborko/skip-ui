// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
package skip.ui

import androidx.compose.foundation.layout.padding
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.BlurredEdgeTreatment
import androidx.compose.ui.draw.blur
import androidx.compose.ui.layout.layout
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.offset
import kotlin.math.ceil
import kotlin.math.max

/// Blur the content, letting the blur bleed outside the content bounds as it does on iOS.
///
/// `BlurredEdgeTreatment.Unbounded` alone is not enough: a render effect is clipped to the bounds of the
/// layer it is set on, so the blur is cut off in a hard-edged rectangle. Pad the layer to give the blur
/// room, then subtract the padding again from the reported size so that layout is unaffected.
fun Modifier.blurredOutwards(radius: Dp): Modifier {
    return this
        .layout { measurable, constraints ->
            val outset = ceil(radius.toPx()).toInt()
            val placeable = measurable.measure(constraints.offset(outset * 2, outset * 2))
            layout(max(0, placeable.width - outset * 2), max(0, placeable.height - outset * 2)) {
                placeable.place(-outset, -outset)
            }
        }
        .blur(radiusX = radius, radiusY = radius, edgeTreatment = BlurredEdgeTreatment.Unbounded)
        .padding(all = radius)
}
