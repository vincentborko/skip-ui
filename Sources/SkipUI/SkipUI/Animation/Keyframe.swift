// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if !SKIP_BRIDGE
import Foundation
#if SKIP
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.spring
#endif

// Simplified without Animatable constraint for now
public struct LinearKeyframe<Value> : KeyframeTrackContent {
    #if SKIP
    public let value: Value
    public let duration: TimeInterval
    #endif
    
    public init(_ value: Value, duration: TimeInterval = 0.0) {
        #if SKIP
        self.value = value
        self.duration = duration
        #else
        fatalError()
        #endif
    }
}

public struct CubicKeyframe<Value> : KeyframeTrackContent {
    #if SKIP
    public let value: Value
    public let duration: TimeInterval
    public let x1: Double
    public let y1: Double
    public let x2: Double
    public let y2: Double
    #endif
    
    public init(_ value: Value, duration: TimeInterval = 0.0) {
        #if SKIP
        self.value = value
        self.duration = duration
        // Default cubic-bezier values for ease-in-out
        self.x1 = 0.42
        self.y1 = 0.0
        self.x2 = 0.58
        self.y2 = 1.0
        #else
        fatalError()
        #endif
    }
    
    public init(_ value: Value, duration: TimeInterval = 0.0, x1: Double, y1: Double, x2: Double, y2: Double) {
        #if SKIP
        self.value = value
        self.duration = duration
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
        #else
        fatalError()
        #endif
    }
}

public struct SpringKeyframe<Value> : KeyframeTrackContent {
    #if SKIP
    public let value: Value
    public let spring: Spring
    public let duration: TimeInterval?
    #endif
    
    public init(_ value: Value, spring: Spring = Spring()) {
        #if SKIP
        self.value = value
        self.spring = spring
        self.duration = nil
        #else
        fatalError()
        #endif
    }
    
    public init(_ value: Value, duration: TimeInterval, spring: Spring = Spring()) {
        #if SKIP
        self.value = value
        self.spring = spring
        self.duration = duration
        #else
        fatalError()
        #endif
    }
}

public struct MoveKeyframe<Value> : KeyframeTrackContent {
    #if SKIP
    public let value: Value
    #endif
    
    public init(_ value: Value) {
        #if SKIP
        self.value = value
        #else
        fatalError()
        #endif
    }
}

#else
// SKIP_BRIDGE mode - provide minimal definitions for bridge generation
public struct LinearKeyframe<Value> : KeyframeTrackContent where Value : Animatable {
    public init(_ value: Value, duration: Double = 0.0) { }
}

public struct CubicKeyframe<Value> : KeyframeTrackContent {
    public init(_ value: Value, duration: Double = 0.0) { }
    public init(_ value: Value, duration: Double = 0.0, x1: Double, y1: Double, x2: Double, y2: Double) { }
}

public struct SpringKeyframe<Value> : KeyframeTrackContent {
    public init(_ value: Value, spring: Spring = Spring()) { }
    public init(_ value: Value, duration: Double, spring: Spring = Spring()) { }
}

public struct MoveKeyframe<Value> : KeyframeTrackContent {
    public init(_ value: Value) { }
}
#endif