// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception

import XCTest
import SwiftUI
import SkipUI

final class SensoryFeedbackTests: XCTestCase {
    
    func testSensoryFeedbackTypes() {
        // Test all feedback types are available
        let feedbackTypes: [SensoryFeedback] = [
            .success,
            .warning,
            .error,
            .selection,
            .increase,
            .decrease,
            .start,
            .stop,
            .alignment,
            .levelChange,
            .impact
        ]
        
        // Verify raw values are unique
        let rawValues = feedbackTypes.map { $0.rawValue }
        XCTAssertEqual(rawValues.count, Set(rawValues).count, "All feedback types should have unique raw values")
        
        // Test impact factory methods
        let lightImpact = SensoryFeedback.impact(weight: .light)
        XCTAssertEqual(lightImpact.rawValue, SensoryFeedback.impact.rawValue)
        
        let mediumImpact = SensoryFeedback.impact(weight: .medium, intensity: 0.5)
        XCTAssertEqual(mediumImpact.rawValue, SensoryFeedback.impact.rawValue)
        
        let heavyImpact = SensoryFeedback.impact(weight: .heavy, intensity: 1.0)
        XCTAssertEqual(heavyImpact.rawValue, SensoryFeedback.impact.rawValue)
        
        let rigidImpact = SensoryFeedback.impact(flexibility: .rigid)
        XCTAssertEqual(rigidImpact.rawValue, SensoryFeedback.impact.rawValue)
        
        let solidImpact = SensoryFeedback.impact(flexibility: .solid, intensity: 0.7)
        XCTAssertEqual(solidImpact.rawValue, SensoryFeedback.impact.rawValue)
        
        let softImpact = SensoryFeedback.impact(flexibility: .soft, intensity: 0.3)
        XCTAssertEqual(softImpact.rawValue, SensoryFeedback.impact.rawValue)
    }
    
    func testSensoryFeedbackEquality() {
        XCTAssertEqual(SensoryFeedback.success, SensoryFeedback.success)
        XCTAssertNotEqual(SensoryFeedback.success, SensoryFeedback.error)
        
        // Test custom raw value
        let custom1 = SensoryFeedback(rawValue: 100)
        let custom2 = SensoryFeedback(rawValue: 100)
        let custom3 = SensoryFeedback(rawValue: 101)
        
        XCTAssertEqual(custom1, custom2)
        XCTAssertNotEqual(custom1, custom3)
    }
    
    func testSensoryFeedbackActivate() {
        // Test that activate() can be called without crashing
        // (actual haptic feedback depends on platform support)
        SensoryFeedback.success.activate()
        SensoryFeedback.warning.activate()
        SensoryFeedback.error.activate()
        SensoryFeedback.selection.activate()
        SensoryFeedback.impact.activate()
        
        // Test custom feedback
        let customFeedback = SensoryFeedback(rawValue: 999)
        customFeedback.activate() // Should handle gracefully
    }
    
    func testSensoryFeedbackModifierWithTrigger() {
        struct TestView: View {
            @State var counter = 0
            @State var feedbackTriggered = false
            
            var body: some View {
                Button("Increment") {
                    counter += 1
                }
                .sensoryFeedback(.success, trigger: counter)
                .onChange(of: counter) { _ in
                    feedbackTriggered = true
                }
            }
        }
        
        // Basic verification that the modifier can be applied
        let view = TestView()
        XCTAssertNotNil(view.body)
    }
    
    func testSensoryFeedbackModifierWithCondition() {
        struct TestView: View {
            @State var value = 0
            @State var feedbackCount = 0
            
            var body: some View {
                Button("Change") {
                    value += 1
                }
                .sensoryFeedback(.warning, trigger: value) { oldValue, newValue in
                    // Only trigger feedback when value increases by more than 1
                    return (newValue - oldValue) > 1
                }
                .onChange(of: value) { _ in
                    feedbackCount += 1
                }
            }
        }
        
        let view = TestView()
        XCTAssertNotNil(view.body)
    }
    
    func testSensoryFeedbackModifierWithClosure() {
        struct TestView: View {
            @State var state = 0
            
            var body: some View {
                Button("Toggle") {
                    state = (state + 1) % 3
                }
                .sensoryFeedback(trigger: state) { oldValue, newValue in
                    if newValue == 0 {
                        return .success
                    } else if newValue == 1 {
                        return .warning
                    } else if newValue == 2 {
                        return .error
                    } else {
                        return nil
                    }
                }
            }
        }
        
        let view = TestView()
        XCTAssertNotNil(view.body)
    }
    
    func testSensoryFeedbackBridgedModifier() {
        struct TestView: View {
            @State var trigger = false
            
            var body: some View {
                Button("Test") {
                    trigger.toggle()
                }
                .sensoryFeedback(bridgedFeedback: SensoryFeedback.selection.rawValue, trigger: trigger as Any?)
            }
        }
        
        let view = TestView()
        XCTAssertNotNil(view.body)
    }
    
    func testSensoryFeedbackClosureBridgedModifier() {
        struct TestView: View {
            @State var value = 0
            
            var body: some View {
                Button("Test") {
                    value += 1
                }
                .sensoryFeedbackClosure(trigger: value as Any?) { oldValue, newValue in
                    guard let old = oldValue as? Int,
                          let new = newValue as? Int else {
                        return nil
                    }
                    
                    if new > old {
                        return SensoryFeedback.increase.rawValue
                    } else if new < old {
                        return SensoryFeedback.decrease.rawValue
                    } else {
                        return nil
                    }
                }
            }
        }
        
        let view = TestView()
        XCTAssertNotNil(view.body)
    }
    
    func testWeightEnum() {
        let weights: [SensoryFeedback.Weight] = [.light, .medium, .heavy]
        
        // Test that all cases are distinct
        XCTAssertEqual(weights.count, 3)
        
        // Test equality
        XCTAssertEqual(SensoryFeedback.Weight.light, SensoryFeedback.Weight.light)
        XCTAssertNotEqual(SensoryFeedback.Weight.light, SensoryFeedback.Weight.heavy)
    }
    
    func testFlexibilityEnum() {
        let flexibilities: [SensoryFeedback.Flexibility] = [.rigid, .solid, .soft]
        
        // Test that all cases are distinct
        XCTAssertEqual(flexibilities.count, 3)
        
        // Test equality
        XCTAssertEqual(SensoryFeedback.Flexibility.rigid, SensoryFeedback.Flexibility.rigid)
        XCTAssertNotEqual(SensoryFeedback.Flexibility.rigid, SensoryFeedback.Flexibility.soft)
    }
    
    func testSensoryFeedbackIntegrationWithState() {
        struct ContentView: View {
            @State private var score = 0
            @State private var lastAction = ""
            
            var body: some View {
                VStack {
                    Text("Score: \(score)")
                    
                    HStack {
                        Button("Win") {
                            score += 10
                            lastAction = "win"
                        }
                        .sensoryFeedback(.success, trigger: score)
                        
                        Button("Lose") {
                            score -= 5
                            lastAction = "lose"
                        }
                        .sensoryFeedback(.error, trigger: score)
                        
                        Button("Reset") {
                            score = 0
                            lastAction = "reset"
                        }
                        .sensoryFeedback(.warning, trigger: lastAction)
                    }
                    
                    Slider(value: Binding(
                        get: { Double(score) },
                        set: { score = Int($0) }
                    ), in: -50...100)
                    .sensoryFeedback(trigger: score) { oldValue, newValue in
                        if newValue > oldValue {
                            return .increase
                        } else if newValue < oldValue {
                            return .decrease
                        } else {
                            return nil
                        }
                    }
                }
            }
        }
        
        let view = ContentView()
        XCTAssertNotNil(view.body)
    }
}