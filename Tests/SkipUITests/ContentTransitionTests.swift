// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
import SwiftUI
import XCTest
import OSLog
import Foundation

struct IdentityContentTransitionTestView: View {
    @State var isToggled = false
    
    var body: some View {
        VStack {
            Button("Toggle") {
                withAnimation(.default) {
                    isToggled.toggle()
                }
            }
            Text(isToggled ? "ON" : "OFF")
                .contentTransition(.identity)
                .font(.title)
        }
    }
}

struct OpacityContentTransitionTestView: View {
    @State var currentText = "First"
    let texts = ["First", "Second", "Third"]
    
    var body: some View {
        VStack {
            Button("Next") {
                withAnimation(.default) {
                    let currentIndex = texts.firstIndex(of: currentText) ?? 0
                    let nextIndex = (currentIndex + 1) % texts.count
                    currentText = texts[nextIndex]
                }
            }
            Text(currentText)
                .contentTransition(.opacity)
                .font(.title)
        }
    }
}

struct InterpolateContentTransitionTestView: View {
    @State var isExpanded = false
    
    var body: some View {
        VStack {
            Button("Toggle") {
                withAnimation(.default) {
                    isExpanded.toggle()
                }
            }
            Text(isExpanded ? "Show Less" : "Show More")
                .contentTransition(.interpolate)
                .font(.title)
        }
    }
}

struct NumericTextContentTransitionTestView: View {
    @State var count = 0
    
    var body: some View {
        VStack {
            HStack {
                Button("-1") {
                    withAnimation(.default) {
                        count = max(0, count - 1)
                    }
                }
                Button("+1") {
                    withAnimation(.default) {
                        count += 1
                    }
                }
            }
            Text("\\(count)")
                .contentTransition(.numericText())
                .font(.largeTitle)
                .monospacedDigit()
        }
    }
}

struct NumericTextCountdownContentTransitionTestView: View {
    @State var score = 100
    
    var body: some View {
        VStack {
            Button("Random Score") {
                withAnimation(.default) {
                    score = Int.random(in: 0...100)
                }
            }
            Text("Score: \\(score)")
                .contentTransition(.numericText(countsDown: true))
                .font(.title2)
                .monospacedDigit()
        }
    }
}

struct NestedContentTransitionTestView: View {
    @State var count = 42
    @State var isVisible = true
    
    var body: some View {
        VStack {
            HStack {
                Button("Toggle Visibility") {
                    withAnimation(.default) {
                        isVisible.toggle()
                    }
                }
                Button("Change Count") {
                    withAnimation(.default) {
                        count = Int.random(in: 0...999)
                    }
                }
            }
            
            if isVisible {
                VStack {
                    Text("\\(count)")
                        .contentTransition(.numericText())
                        .font(.largeTitle)
                        .monospacedDigit()
                    
                    Text(count < 10 ? "Single Digit" : count < 100 ? "Double Digit" : "Triple Digit")
                        .contentTransition(.interpolate)
                        .font(.caption)
                }
                .contentTransition(.opacity)
            }
        }
    }
}

struct NonTextContentTransitionTestView: View {
    @State var isCircle = true
    
    var body: some View {
        VStack {
            Button("Toggle Shape") {
                withAnimation(.default) {
                    isCircle.toggle()
                }
            }
            
            Group {
                if isCircle {
                    Circle()
                        .fill(Color.blue)
                } else {
                    Rectangle()
                        .fill(Color.red)
                }
            }
            .contentTransition(.opacity)
            .frame(width: 100, height: 100)
        }
    }
}

final class ContentTransitionTests: XCSnapshotTestCase {
    
    func testIdentityContentTransition() throws {
        _ = try render(view: IdentityContentTransitionTestView())
    }
    
    func testOpacityContentTransition() throws {
        _ = try render(view: OpacityContentTransitionTestView())
    }
    
    func testInterpolateContentTransition() throws {
        _ = try render(view: InterpolateContentTransitionTestView())
    }
    
    func testNumericTextContentTransition() throws {
        _ = try render(view: NumericTextContentTransitionTestView())
    }
    
    func testNumericTextCountdownContentTransition() throws {
        _ = try render(view: NumericTextCountdownContentTransitionTestView())
    }
    
    func testNestedContentTransitions() throws {
        _ = try render(view: NestedContentTransitionTestView())
    }
    
    func testNonTextContentTransition() throws {
        _ = try render(view: NonTextContentTransitionTestView())
    }
    
    func testContentTransitionWithDifferentAnimations() throws {
        let view = VStack {
            Text("0")
                .contentTransition(.numericText())
                .font(.largeTitle)
        }
        
        _ = try render(view: view)
    }
    
    func testContentTransitionWithoutAnimation() throws {
        let view = VStack {
            Text("Static Text")
                .contentTransition(.identity)
                .font(.title)
        }
        
        _ = try render(view: view)
    }
    
    func testMultipleContentTransitionsOnSameText() throws {
        let view = VStack {
            Text("Test")
                .contentTransition(.opacity)
                .contentTransition(.interpolate) // Should use the last one
                .font(.title)
        }
        
        _ = try render(view: view)
    }
}