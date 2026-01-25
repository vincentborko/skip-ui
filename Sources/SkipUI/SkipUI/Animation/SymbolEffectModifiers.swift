// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if !SKIP_BRIDGE
#if SKIP
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier

/// Modifier for removing symbol effects
struct SymbolEffectsRemovedModifier: RenderModifier {
    let isEnabled: Bool
    
    init(isEnabled: Bool) {
        self.isEnabled = isEnabled
        super.init { content, context in
            // When enabled, render without any effects
            content.Render(context: context)
        }
    }
}

/// Modifier for indefinite symbol effects
struct IndefiniteSymbolEffectModifier: RenderModifier {
    let effect: any IndefiniteSymbolEffect
    let options: SymbolEffectOptions
    let isActive: Bool
    
    init(effect: any IndefiniteSymbolEffect, options: SymbolEffectOptions, isActive: Bool) {
        self.effect = effect
        self.options = options
        self.isActive = isActive
        super.init { content, context in
            let modifier = remember { Modifier }
            let effectModifier = effect.apply(modifier: modifier, isActive: isActive, options: options)
            
            // Apply the effect modifier to the content
            var modifiedContext = context
            modifiedContext.modifier = modifiedContext.modifier.then(effectModifier)
            content.Render(context: modifiedContext)
        }
    }
}

/// Modifier for discrete symbol effects triggered by value changes
struct DiscreteSymbolEffectModifier<U: Equatable>: RenderModifier {
    let effect: any DiscreteSymbolEffect
    let options: SymbolEffectOptions
    let value: U
    
    init(effect: any DiscreteSymbolEffect, options: SymbolEffectOptions, value: U) {
        self.effect = effect
        self.options = options
        self.value = value
        super.init { content, context in
            var previousValue = remember { mutableStateOf(value) }
            var triggerEffect = remember { mutableStateOf(false) }
            
            // Detect value changes
            LaunchedEffect(value) {
                if value != previousValue.value {
                    previousValue.value = value
                    triggerEffect.value = true
                    
                    // Reset after animation completes
                    kotlinx.coroutines.delay((500 / options.speed).toLong())
                    triggerEffect.value = false
                }
            }
            
            let modifier = remember { Modifier }
            let effectModifier = effect.apply(modifier: modifier, isActive: triggerEffect.value, options: options)
            
            // Apply the effect modifier to the content
            var modifiedContext = context
            modifiedContext.modifier = modifiedContext.modifier.then(effectModifier)
            content.Render(context: modifiedContext)
        }
    }
}
#endif
#endif