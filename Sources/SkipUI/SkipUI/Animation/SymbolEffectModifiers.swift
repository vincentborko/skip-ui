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
    
    @Composable public override func Render(context: ComposeContext) {
        // When enabled, render without any effects
        context.content()
    }
}

/// Modifier for indefinite symbol effects
struct IndefiniteSymbolEffectModifier<T: IndefiniteSymbolEffect & SymbolEffect>: RenderModifier {
    let effect: T
    let options: SymbolEffectOptions
    let isActive: Bool
    
    @Composable public override func Render(context: ComposeContext) {
        let modifier = remember { Modifier }
        let effectModifier = effect.apply(modifier: modifier, isActive: isActive, options: options)
        
        // Apply the effect modifier to the content
        ComposeContainer(modifier: effectModifier) {
            context.content()
        }
    }
}

/// Modifier for discrete symbol effects triggered by value changes
struct DiscreteSymbolEffectModifier<T: DiscreteSymbolEffect & SymbolEffect, U: Equatable>: RenderModifier {
    let effect: T
    let options: SymbolEffectOptions
    let value: U
    
    @Composable public override func Render(context: ComposeContext) {
        var previousValue by remember { mutableStateOf(value) }
        var triggerEffect by remember { mutableStateOf(false) }
        
        // Detect value changes
        LaunchedEffect(value) {
            if value != previousValue {
                previousValue = value
                triggerEffect = true
                
                // Reset after animation completes
                kotlinx.coroutines.delay((500 / options.speed).toLong())
                triggerEffect = false
            }
        }
        
        let modifier = remember { Modifier }
        let effectModifier = effect.apply(modifier: modifier, isActive: triggerEffect, options: options)
        
        // Apply the effect modifier to the content
        ComposeContainer(modifier: effectModifier) {
            context.content()
        }
    }
}
#endif
#endif