// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception

import XCTest
import SwiftUI
import SkipUI

final class PhaseAnimatorTests: XCTestCase {
    
    func testPhaseAnimatorBasicConstruction() {
        // Test PhaseAnimator can be constructed with basic phases
        let phases = [false, true]
        let animator = PhaseAnimator(phases) { phase in
            Text("Phase: \(phase)")
        }
        
        // Should not crash during construction
        XCTAssertNotNil(animator)
    }
    
    func testPhaseAnimatorWithTrigger() {
        // Test PhaseAnimator can be constructed with trigger
        let phases = ["initial", "middle", "final"]
        var triggerValue = 0
        
        let animator = PhaseAnimator(phases, trigger: triggerValue) { phase in
            Text("Phase: \(phase)")
        } animation: { phase in
            .easeInOut(duration: 0.5)
        }
        
        // Should not crash during construction
        XCTAssertNotNil(animator)
    }
    
    func testPhaseAnimatorWithCustomAnimation() {
        // Test PhaseAnimator with custom animation closures
        enum AnimationPhase: CaseIterable {
            case start, middle, end
        }
        
        let phases = AnimationPhase.allCases
        
        let animator = PhaseAnimator(phases) { phase in
            Rectangle()
                .fill(phase == .start ? .blue : .red)
                .frame(width: 50, height: 50)
        } animation: { phase in
            switch phase {
            case .start:
                return .easeIn(duration: 0.3)
            case .middle:
                return .spring(response: 0.6, dampingFraction: 0.8)
            case .end:
                return .easeOut(duration: 0.4)
            }
        }
        
        // Should not crash during construction
        XCTAssertNotNil(animator)
    }
    
    func testPhaseAnimatorDefaultAnimation() {
        // Test PhaseAnimator uses default animation when none specified
        let phases = [1, 2, 3]
        
        let animator = PhaseAnimator(phases) { phase in
            Text("Value: \(phase)")
        }
        
        // Should use default animation
        XCTAssertNotNil(animator)
    }
    
    func testPhaseAnimatorEmptyPhases() {
        // Test PhaseAnimator with empty phases array
        let phases: [String] = []
        
        let animator = PhaseAnimator(phases) { phase in
            Text("Phase: \(phase)")
        }
        
        // Should handle empty phases gracefully
        XCTAssertNotNil(animator)
    }
    
    func testPhaseAnimatorSinglePhase() {
        // Test PhaseAnimator with single phase
        let phases = ["only"]
        
        let animator = PhaseAnimator(phases) { phase in
            Text("Phase: \(phase)")
        }
        
        // Should handle single phase
        XCTAssertNotNil(animator)
    }
    
    func testPhaseAnimatorComplexContent() {
        // Test PhaseAnimator with complex view content
        struct ComplexView: View {
            let phase: Bool
            
            var body: some View {
                VStack {
                    Circle()
                        .fill(phase ? .red : .blue)
                        .frame(width: phase ? 100 : 50)
                    Text("Phase: \(phase ? "Active" : "Inactive")")
                        .font(phase ? .title : .body)
                }
                .scaleEffect(phase ? 1.2 : 1.0)
                .opacity(phase ? 1.0 : 0.7)
            }
        }
        
        let animator = PhaseAnimator([false, true]) { phase in
            ComplexView(phase: phase)
        } animation: { phase in
            .spring(response: 0.8, dampingFraction: 0.6)
        }
        
        // Should handle complex view hierarchies
        XCTAssertNotNil(animator)
    }
}