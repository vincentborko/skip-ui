// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception

#if os(iOS)
import SwiftUI
import XCTest

class SymbolEffectTests: XCTestCase {
    
    func testSymbolEffectTypes() {
        // Test that all effect types can be created
        let bounce = BounceSymbolEffect()
        XCTAssertNotNil(bounce)
        
        let pulse = PulseSymbolEffect()
        XCTAssertNotNil(pulse)
        
        let variableColor = VariableColorSymbolEffect()
        XCTAssertNotNil(variableColor)
        
        let scale = ScaleSymbolEffect()
        XCTAssertNotNil(scale)
        
        let scaleCustom = ScaleSymbolEffect(scale: 2.0)
        XCTAssertNotNil(scaleCustom)
        
        let replace = ReplaceSymbolEffect()
        XCTAssertNotNil(replace)
        
        let appear = AppearSymbolEffect()
        XCTAssertNotNil(appear)
        
        let disappear = DisappearSymbolEffect()
        XCTAssertNotNil(disappear)
        
        let breathe = BreatheSymbolEffect()
        XCTAssertNotNil(breathe)
        
        let rotate = RotateSymbolEffect()
        XCTAssertNotNil(rotate)
        
        let wiggle = WiggleSymbolEffect()
        XCTAssertNotNil(wiggle)
    }
    
    func testSymbolEffectOptions() {
        // Test default options
        let defaultOptions = SymbolEffectOptions.default
        XCTAssertEqual(defaultOptions.speed, 1.0)
        XCTAssertNil(defaultOptions.repeatCount)
        XCTAssertEqual(defaultOptions.repeating, false)
        
        // Test repeating options
        let repeatingOptions = SymbolEffectOptions.repeating
        XCTAssertEqual(repeatingOptions.repeating, true)
        
        // Test non-repeating options
        let nonRepeatingOptions = SymbolEffectOptions.nonRepeating
        XCTAssertEqual(nonRepeatingOptions.repeating, false)
        
        // Test speed options
        let fastOptions = SymbolEffectOptions.speed(2.0)
        XCTAssertEqual(fastOptions.speed, 2.0)
        
        let slowOptions = SymbolEffectOptions.speed(0.5)
        XCTAssertEqual(slowOptions.speed, 0.5)
        
        // Test repeat count options
        let repeat3Options = SymbolEffectOptions.repeat(3)
        XCTAssertEqual(repeat3Options.repeatCount, 3)
        XCTAssertEqual(repeat3Options.repeating, true)
        
        let repeat1Options = SymbolEffectOptions.repeat(1)
        XCTAssertEqual(repeat1Options.repeatCount, 1)
        XCTAssertEqual(repeat1Options.repeating, false)
    }
    
    func testStaticAccessors() {
        // Test that static accessors work
        let bounce = SymbolEffect.bounce
        XCTAssertNotNil(bounce)
        
        let pulse = SymbolEffect.pulse
        XCTAssertNotNil(pulse)
        
        let variableColor = SymbolEffect.variableColor
        XCTAssertNotNil(variableColor)
        
        let scale = SymbolEffect.scale
        XCTAssertNotNil(scale)
        
        let scale2 = SymbolEffect.scale(2.0)
        XCTAssertNotNil(scale2)
        
        let replace = SymbolEffect.replace
        XCTAssertNotNil(replace)
        
        let appear = SymbolEffect.appear
        XCTAssertNotNil(appear)
        
        let disappear = SymbolEffect.disappear
        XCTAssertNotNil(disappear)
        
        let breathe = SymbolEffect.breathe
        XCTAssertNotNil(breathe)
        
        let rotate = SymbolEffect.rotate
        XCTAssertNotNil(rotate)
        
        let wiggle = SymbolEffect.wiggle
        XCTAssertNotNil(wiggle)
    }
    
    func testIndefiniteSymbolEffectModifier() {
        // Test that indefinite effect modifiers can be applied
        let image = Image(systemName: "bell")
        
        // Test with bounce effect
        let bouncing = image.symbolEffect(.bounce, isActive: true)
        XCTAssertNotNil(bouncing)
        
        let notBouncing = image.symbolEffect(.bounce, isActive: false)
        XCTAssertNotNil(notBouncing)
        
        // Test with pulse effect
        let pulsing = image.symbolEffect(.pulse, isActive: true)
        XCTAssertNotNil(pulsing)
        
        // Test with options
        let fastBounce = image.symbolEffect(.bounce, options: .speed(2.0), isActive: true)
        XCTAssertNotNil(fastBounce)
    }
    
    func testDiscreteSymbolEffectModifier() {
        // Test that discrete effect modifiers can be applied
        let image = Image(systemName: "heart.fill")
        
        // Test with value trigger
        let bounceOnChange = image.symbolEffect(.bounce, value: 1)
        XCTAssertNotNil(bounceOnChange)
        
        // Test with different value types
        let bounceOnString = image.symbolEffect(.bounce, value: "test")
        XCTAssertNotNil(bounceOnString)
        
        let bounceOnBool = image.symbolEffect(.bounce, value: true)
        XCTAssertNotNil(bounceOnBool)
        
        // Test with options
        let fastBounce = image.symbolEffect(.bounce, options: .speed(2.0), value: 1)
        XCTAssertNotNil(fastBounce)
        
        let repeatBounce = image.symbolEffect(.bounce, options: .repeat(3), value: 1)
        XCTAssertNotNil(repeatBounce)
    }
    
    func testSymbolEffectsRemovedModifier() {
        // Test that effects can be removed
        let image = Image(systemName: "bell")
            .symbolEffect(.bounce, isActive: true)
        
        let effectsRemoved = image.symbolEffectsRemoved()
        XCTAssertNotNil(effectsRemoved)
        
        let effectsNotRemoved = image.symbolEffectsRemoved(false)
        XCTAssertNotNil(effectsNotRemoved)
    }
    
    func testMultipleEffects() {
        // Test that multiple effects can be chained
        let image = Image(systemName: "star.fill")
            .symbolEffect(.bounce, isActive: true)
            .symbolEffect(.pulse, value: 1)
        
        XCTAssertNotNil(image)
    }
    
    func testEffectProtocolConformance() {
        // Test that effects conform to correct protocols
        let bounce = BounceSymbolEffect()
        XCTAssertTrue(bounce is IndefiniteSymbolEffect)
        XCTAssertTrue(bounce is DiscreteSymbolEffect)
        XCTAssertTrue(bounce is SymbolEffect)
        
        let pulse = PulseSymbolEffect()
        XCTAssertTrue(pulse is IndefiniteSymbolEffect)
        XCTAssertTrue(pulse is SymbolEffect)
        
        let scale = ScaleSymbolEffect()
        XCTAssertTrue(scale is DiscreteSymbolEffect)
        XCTAssertTrue(scale is SymbolEffect)
    }
}
#endif