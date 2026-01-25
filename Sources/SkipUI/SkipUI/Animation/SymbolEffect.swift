// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if !SKIP_BRIDGE
import Foundation
#if SKIP
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.Box
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.graphicsLayer
import kotlinx.coroutines.delay
#endif

/// Protocol for all symbol effects
public protocol SymbolEffect {
    #if SKIP
    @Composable func apply(modifier: Modifier, isActive: Bool, options: SymbolEffectOptions) -> Modifier
    #endif
}

/// Protocol for indefinite (continuous) symbol effects
public protocol IndefiniteSymbolEffect: SymbolEffect {
}

/// Protocol for discrete (triggered) symbol effects
public protocol DiscreteSymbolEffect: SymbolEffect {
}

/// Options for symbol effects
public struct SymbolEffectOptions: Equatable {
    public let speed: Double
    public let repeatCount: Int?
    public let repeating: Bool
    
    private init(speed: Double = 1.0, repeatCount: Int? = nil, repeating: Bool = false) {
        self.speed = speed
        self.repeatCount = repeatCount
        self.repeating = repeating
    }
    
    public static let `default` = SymbolEffectOptions()
    public static let repeating = SymbolEffectOptions(repeating: true)
    public static let nonRepeating = SymbolEffectOptions(repeating: false)
    
    public static func speed(_ speed: Double) -> SymbolEffectOptions {
        return SymbolEffectOptions(speed: speed)
    }
    
    public static func `repeat`(_ count: Int?) -> SymbolEffectOptions {
        return SymbolEffectOptions(repeatCount: count, repeating: count != 1)
    }
}

/// Bounce symbol effect
public struct BounceSymbolEffect: IndefiniteSymbolEffect, DiscreteSymbolEffect {
    public init() {}
    
    #if SKIP
    @Composable public func apply(modifier: Modifier, isActive: Bool, options: SymbolEffectOptions) -> Modifier {
        let targetScale = if isActive { 1.2 } else { 1.0 }
        let animationDuration = Int(500 / options.speed)
        
        let scale = animateFloatAsState(
            targetValue: targetScale,
            animationSpec: spring(
                dampingRatio: Spring.DampingRatioMediumBouncy,
                stiffness: Spring.StiffnessLow
            ),
            label: "bounce"
        )
        
        // For discrete effects with repeat count
        if isActive && options.repeatCount != nil {
            var bounceCount = remember { mutableIntStateOf(0) }
            LaunchedEffect(isActive) {
                for _ in 0..<(options.repeatCount ?? 1) {
                    bounceCount.value += 1
                    delay(animationDuration.toLong())
                }
            }
        }
        
        return modifier.scale(scale.value)
    }
    #endif
}

/// Pulse symbol effect
public struct PulseSymbolEffect: IndefiniteSymbolEffect {
    public init() {}
    
    #if SKIP
    @Composable public func apply(modifier: Modifier, isActive: Bool, options: SymbolEffectOptions) -> Modifier {
        if !isActive {
            return modifier
        }
        
        let infiniteTransition = rememberInfiniteTransition(label: "pulse")
        let animationDuration = Int(1000 / options.speed)
        
        let alpha = infiniteTransition.animateFloat(
            initialValue: 1.0,
            targetValue: 0.3,
            animationSpec: infiniteRepeatable(
                animation: tween(durationMillis: animationDuration),
                repeatMode: RepeatMode.Reverse
            ),
            label: "pulseAlpha"
        )
        
        return modifier.alpha(alpha.value)
    }
    #endif
}

/// Variable color symbol effect
public struct VariableColorSymbolEffect: IndefiniteSymbolEffect {
    public init() {}
    
    #if SKIP
    @Composable public func apply(modifier: Modifier, isActive: Bool, options: SymbolEffectOptions) -> Modifier {
        if !isActive {
            return modifier
        }
        
        let infiniteTransition = rememberInfiniteTransition(label: "variableColor")
        let animationDuration = Int(1500 / options.speed)
        
        // Animate through hue values for color variation
        let hue = infiniteTransition.animateFloat(
            initialValue: 0.0,
            targetValue: 360.0,
            animationSpec: infiniteRepeatable(
                animation: tween(durationMillis: animationDuration)
            ),
            label: "variableColorHue"
        )
        
        return modifier.graphicsLayer {
            // Apply hue rotation for color variation effect
            rotationZ = 0.0  // No actual rotation, just using graphicsLayer for potential color matrix in future
        }
    }
    #endif
}

/// Scale symbol effect
public struct ScaleSymbolEffect: DiscreteSymbolEffect {
    public let scale: Double
    
    public init(scale: Double = 1.5) {
        self.scale = scale
    }
    
    #if SKIP
    @Composable public func apply(modifier: Modifier, isActive: Bool, options: SymbolEffectOptions) -> Modifier {
        let targetScale = if isActive { scale } else { 1.0 }
        let animationDuration = Int(300 / options.speed)
        
        let animatedScale = animateFloatAsState(
            targetValue: Float(targetScale),
            animationSpec: tween(durationMillis: animationDuration),
            label: "scale"
        )
        
        return modifier.scale(animatedScale.value)
    }
    #endif
}

/// Replace symbol effect (for icon swapping)
public struct ReplaceSymbolEffect: DiscreteSymbolEffect {
    public init() {}
    
    #if SKIP
    @Composable public func apply(modifier: Modifier, isActive: Bool, options: SymbolEffectOptions) -> Modifier {
        // Replace effect is handled differently - through crossfade of content
        // This is a placeholder implementation
        return modifier
    }
    #endif
}

/// Appear symbol effect
public struct AppearSymbolEffect: DiscreteSymbolEffect {
    public init() {}
    
    #if SKIP
    @Composable public func apply(modifier: Modifier, isActive: Bool, options: SymbolEffectOptions) -> Modifier {
        let targetAlpha = if isActive { 1.0 } else { 0.0 }
        let animationDuration = Int(400 / options.speed)
        
        let alpha = animateFloatAsState(
            targetValue: targetAlpha,
            animationSpec: tween(durationMillis: animationDuration),
            label: "appear"
        )
        
        return modifier.alpha(alpha.value)
    }
    #endif
}

/// Disappear symbol effect
public struct DisappearSymbolEffect: DiscreteSymbolEffect {
    public init() {}
    
    #if SKIP
    @Composable public func apply(modifier: Modifier, isActive: Bool, options: SymbolEffectOptions) -> Modifier {
        let targetAlpha = if isActive { 0.0 } else { 1.0 }
        let animationDuration = Int(400 / options.speed)
        
        let alpha = animateFloatAsState(
            targetValue: targetAlpha,
            animationSpec: tween(durationMillis: animationDuration),
            label: "disappear"
        )
        
        return modifier.alpha(alpha.value)
    }
    #endif
}

/// Breathe symbol effect (iOS 18)
public struct BreatheSymbolEffect: IndefiniteSymbolEffect {
    public init() {}
    
    #if SKIP
    @Composable public func apply(modifier: Modifier, isActive: Bool, options: SymbolEffectOptions) -> Modifier {
        if !isActive {
            return modifier
        }
        
        let infiniteTransition = rememberInfiniteTransition(label: "breathe")
        let animationDuration = Int(2000 / options.speed)
        
        let scale = infiniteTransition.animateFloat(
            initialValue: 1.0,
            targetValue: 1.1,
            animationSpec: infiniteRepeatable(
                animation: tween(durationMillis: animationDuration),
                repeatMode: RepeatMode.Reverse
            ),
            label: "breatheScale"
        )
        
        return modifier.scale(scale.value)
    }
    #endif
}

/// Rotate symbol effect (iOS 18)
public struct RotateSymbolEffect: IndefiniteSymbolEffect {
    public init() {}
    
    #if SKIP
    @Composable public func apply(modifier: Modifier, isActive: Bool, options: SymbolEffectOptions) -> Modifier {
        if !isActive {
            return modifier
        }
        
        let infiniteTransition = rememberInfiniteTransition(label: "rotate")
        let animationDuration = Int(2000 / options.speed)
        
        let rotation = infiniteTransition.animateFloat(
            initialValue: 0.0,
            targetValue: 360.0,
            animationSpec: infiniteRepeatable(
                animation: tween(durationMillis: animationDuration)
            ),
            label: "rotateAngle"
        )
        
        return modifier.rotate(rotation.value)
    }
    #endif
}

/// Wiggle symbol effect (iOS 18)
public struct WiggleSymbolEffect: IndefiniteSymbolEffect {
    public init() {}
    
    #if SKIP
    @Composable public func apply(modifier: Modifier, isActive: Bool, options: SymbolEffectOptions) -> Modifier {
        if !isActive {
            return modifier
        }
        
        let infiniteTransition = rememberInfiniteTransition(label: "wiggle")
        let animationDuration = Int(200 / options.speed)
        
        let rotation = infiniteTransition.animateFloat(
            initialValue: -5.0,
            targetValue: 5.0,
            animationSpec: infiniteRepeatable(
                animation: tween(durationMillis: animationDuration),
                repeatMode = RepeatMode.Reverse
            ),
            label: "wiggleAngle"
        )
        
        return modifier.rotate(rotation.value)
    }
    #endif
}

// Static accessors
extension SymbolEffect where Self == BounceSymbolEffect {
    public static var bounce: BounceSymbolEffect {
        BounceSymbolEffect()
    }
}

extension SymbolEffect where Self == PulseSymbolEffect {
    public static var pulse: PulseSymbolEffect {
        PulseSymbolEffect()
    }
}

extension SymbolEffect where Self == VariableColorSymbolEffect {
    public static var variableColor: VariableColorSymbolEffect {
        VariableColorSymbolEffect()
    }
}

extension SymbolEffect where Self == ScaleSymbolEffect {
    public static var scale: ScaleSymbolEffect {
        ScaleSymbolEffect()
    }
    
    public static func scale(_ value: Double) -> ScaleSymbolEffect {
        ScaleSymbolEffect(scale: value)
    }
}

extension SymbolEffect where Self == ReplaceSymbolEffect {
    public static var replace: ReplaceSymbolEffect {
        ReplaceSymbolEffect()
    }
}

extension SymbolEffect where Self == AppearSymbolEffect {
    public static var appear: AppearSymbolEffect {
        AppearSymbolEffect()
    }
}

extension SymbolEffect where Self == DisappearSymbolEffect {
    public static var disappear: DisappearSymbolEffect {
        DisappearSymbolEffect()
    }
}

extension SymbolEffect where Self == BreatheSymbolEffect {
    public static var breathe: BreatheSymbolEffect {
        BreatheSymbolEffect()
    }
}

extension SymbolEffect where Self == RotateSymbolEffect {
    public static var rotate: RotateSymbolEffect {
        RotateSymbolEffect()
    }
}

extension SymbolEffect where Self == WiggleSymbolEffect {
    public static var wiggle: WiggleSymbolEffect {
        WiggleSymbolEffect()
    }
}

#else
// SKIP_BRIDGE mode - provide minimal protocol definitions for bridge generation
public protocol SymbolEffect {}
public protocol IndefiniteSymbolEffect: SymbolEffect {}
public protocol DiscreteSymbolEffect: SymbolEffect {}

public struct SymbolEffectOptions: Equatable {
    public static let `default` = SymbolEffectOptions()
    public static func speed(_ speed: Double) -> SymbolEffectOptions { SymbolEffectOptions() }
    public func speed(_ speed: Double) -> SymbolEffectOptions { self }
    public static func `repeat`(_ count: Int) -> SymbolEffectOptions { SymbolEffectOptions() }
    public func `repeat`(_ count: Int) -> SymbolEffectOptions { self }
    public static var repeating: SymbolEffectOptions { SymbolEffectOptions() }
    public var repeating: SymbolEffectOptions { self }
}

// These structs need to exist for the bridge but don't need implementation
public struct BounceSymbolEffect: IndefiniteSymbolEffect, DiscreteSymbolEffect {}
public struct PulseSymbolEffect: IndefiniteSymbolEffect {}
public struct VariableColorSymbolEffect: IndefiniteSymbolEffect {}
public struct ScaleSymbolEffect: DiscreteSymbolEffect {}
public struct ReplaceSymbolEffect: DiscreteSymbolEffect {}
public struct AppearSymbolEffect: DiscreteSymbolEffect {}
public struct DisappearSymbolEffect: DiscreteSymbolEffect {}
public struct BreatheSymbolEffect: IndefiniteSymbolEffect {}
public struct RotateSymbolEffect: IndefiniteSymbolEffect {}
public struct WiggleSymbolEffect: IndefiniteSymbolEffect {}

#endif