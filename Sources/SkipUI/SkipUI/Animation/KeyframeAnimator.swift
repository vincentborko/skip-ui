// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if !SKIP_BRIDGE
import Foundation
#if SKIP
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.AnimationSpec
import androidx.compose.animation.core.AnimationVector
import androidx.compose.animation.core.KeyframesSpec
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.keyframes
import androidx.compose.animation.core.animate
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import kotlinx.coroutines.launch
#endif

// Note: Animatable protocol already exists in Animation.swift
// We'll use the existing protocol

public protocol Keyframes {
    // Protocol for keyframe sequences
}

public protocol KeyframeTrackContent {
    // Protocol for keyframe track content
}

public struct KeyframeAnimator<Value, KeyframePath, Content> : View 
    where Value : Animatable, KeyframePath : Keyframes, Content : View {
    
    #if SKIP
    private let initialValue: Value
    private let trigger: Any?
    private let content: (Value) -> Content
    private let keyframes: () -> KeyframePath
    
    public init(
        initialValue: Value,
        @ViewBuilder content: @escaping (Value) -> Content,
        @KeyframesBuilder<Value> keyframes: () -> KeyframePath
    ) {
        self.initialValue = initialValue
        self.trigger = nil
        self.content = content
        self.keyframes = keyframes
    }
    
    public init(
        initialValue: Value,
        trigger: some Equatable,
        @ViewBuilder content: @escaping (Value) -> Content,
        @KeyframesBuilder<Value> keyframes: () -> KeyframePath
    ) {
        self.initialValue = initialValue
        self.trigger = trigger
        self.content = content
        self.keyframes = keyframes
    }
    
    @Composable public override func ComposeContent(context: ComposeContext) {
        let animatedValueState = remember { mutableStateOf(initialValue) }
        var animatedValue = animatedValueState.value
        
        // Trigger animation when trigger changes or continuously if no trigger
        if let trigger = trigger {
            LaunchedEffect(trigger) {
                // Reset to initial value and animate
                animatedValueState.value = initialValue
                // TODO: Apply keyframe animation sequence
                // For now, just set to initial value
            }
        } else {
            LaunchedEffect(Unit) {
                // Continuous animation
                // TODO: Apply keyframe animation sequence
            }
        }
        
        content(animatedValueState.value).ComposeContent(context: context)
    }
    #else
    public init(
        initialValue: Value,
        @ViewBuilder content: @escaping (Value) -> Content,
        @KeyframesBuilder<Value> keyframes: () -> KeyframePath
    ) {
        fatalError()
    }
    
    public init(
        initialValue: Value,
        trigger: some Equatable,
        @ViewBuilder content: @escaping (Value) -> Content,
        @KeyframesBuilder<Value> keyframes: () -> KeyframePath
    ) {
        fatalError()
    }
    
    public var body: some View {
        fatalError()
    }
    #endif
}

@resultBuilder
public struct KeyframesBuilder<Value> where Value : Animatable {
    public static func buildBlock<K>(_ keyframes: K) -> K where K : Keyframes {
        return keyframes
    }
    
    public static func buildBlock<K0, K1>(_ k0: K0, _ k1: K1) -> some Keyframes 
        where K0 : Keyframes, K1 : Keyframes {
        #if SKIP
        return CombinedKeyframes(first: k0, second: k1)
        #else
        return k0 // Return first keyframe in non-SKIP case
        #endif
    }
}

#if SKIP
// Internal type for combining keyframes
struct CombinedKeyframes : Keyframes {
    let first: Any
    let second: Any
}
#endif

public struct KeyframeTrack<Root, Value, Content> : Keyframes where Value : Animatable {
    #if SKIP
    // Skip doesn't support KeyPath, so we use a string representation
    private let propertyName: String
    private let content: Content
    #endif
    
    // For now, we'll accept a WritableKeyPath but just extract the property name
    // In a full implementation, this would need proper property access
    public init(_ keyPath: WritableKeyPath<Root, Value>, @KeyframeTrackContentBuilder<Value> content: () -> Content) {
        #if SKIP
        // Extract property name from keyPath (simplified - real implementation would be more complex)
        self.propertyName = String(describing: keyPath)
        self.content = content()
        #else
        fatalError()
        #endif
    }
}

@resultBuilder
public struct KeyframeTrackContentBuilder<Value> where Value : Animatable {
    public static func buildBlock<K>(_ keyframe: K) -> K where K : KeyframeTrackContent {
        return keyframe
    }
    
    public static func buildBlock<K0, K1>(_ k0: K0, _ k1: K1) -> some KeyframeTrackContent 
        where K0 : KeyframeTrackContent, K1 : KeyframeTrackContent {
        #if SKIP
        return CombinedKeyframeContent(first: k0, second: k1)
        #else
        return k0 // Return first content in non-SKIP case
        #endif
    }
}

#if SKIP
// Internal type for combining keyframe content
struct CombinedKeyframeContent : KeyframeTrackContent {
    let first: Any
    let second: Any
}
#endif

#else
// SKIP_BRIDGE mode - provide minimal definitions for bridge generation
// SKIP_BRIDGE
public protocol Keyframes {
    // Protocol for keyframes
}

// SKIP_BRIDGE  
public protocol KeyframeTrackContent {
    // Protocol for keyframe track content  
}

public struct KeyframeAnimator<Value, KeyframePath, Content> : View 
    where Value : Animatable, KeyframePath : Keyframes, Content : View {
    public init(initialValue: Value, content: @escaping (KeyframeAnimatorContext<Value>) -> Content, keyframes: @escaping (Value) -> some View) { }
    public var body: some View { EmptyView() }
}

public struct KeyframeAnimatorContext<Value> where Value : Animatable {
    public var value: Value { fatalError() }
    public var velocity: Value { fatalError() }
}

public struct KeyframeTrack<Value, Root> : Keyframes where Value : Animatable {
    public init(_ keyPath: WritableKeyPath<Root, Value>, content: () -> some View) { }
}

@resultBuilder
public struct KeyframesBuilder<Value> where Value : Animatable {
    public static func buildBlock<Content>(_ content: Content) -> some View where Content : View {
        return EmptyView()
    }
}
#endif