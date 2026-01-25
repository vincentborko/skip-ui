// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception

import XCTest
import SwiftUI
import SkipUI

final class AdvancedGestureTests: XCTestCase {
    
    // MARK: - MagnifyGesture Tests
    
    func testMagnifyGestureInitialization() {
        let gesture = MagnifyGesture()
        XCTAssertNotNil(gesture)
        
        let gestureWithMinScale = MagnifyGesture(minimumScaleDelta: 0.01)
        XCTAssertNotNil(gestureWithMinScale)
    }
    
    func testMagnifyGestureValue() {
        // Test MagnifyGesture.Value properties
        let value = MagnifyGesture.Value(
            magnification: 1.5,
            anchor: .center,
            velocity: 0.2
        )
        
        XCTAssertEqual(value.magnification, 1.5, accuracy: 0.001)
        XCTAssertEqual(value.anchor, UnitPoint.center)
        XCTAssertEqual(value.velocity, 0.2, accuracy: 0.001)
    }
    
    func testMagnifyGestureTypeAlias() {
        // Test legacy type alias
        let gesture = MagnificationGesture()
        XCTAssertNotNil(gesture)
        
        let gestureWithMin = MagnificationGesture(minimumScaleDelta: 0.05)
        XCTAssertNotNil(gestureWithMin)
    }
    
    func testMagnifyGestureModifiers() {
        let baseGesture = MagnifyGesture()
        
        // Test onChanged modifier
        var changedValue: MagnifyGesture.Value?
        let withOnChanged = baseGesture.onChanged { value in
            changedValue = value
        }
        XCTAssertNotNil(withOnChanged)
        
        // Test onEnded modifier
        var endedValue: MagnifyGesture.Value?
        let withOnEnded = baseGesture.onEnded { value in
            endedValue = value
        }
        XCTAssertNotNil(withOnEnded)
        
        // Test chaining modifiers
        let chained = baseGesture
            .onChanged { _ in }
            .onEnded { _ in }
        XCTAssertNotNil(chained)
    }
    
    // MARK: - RotateGesture Tests
    
    func testRotateGestureInitialization() {
        let gesture = RotateGesture()
        XCTAssertNotNil(gesture)
        
        let gestureWithMinAngle = RotateGesture(minimumAngleDelta: Angle(degrees: 1))
        XCTAssertNotNil(gestureWithMinAngle)
    }
    
    func testRotateGestureValue() {
        // Test RotateGesture.Value properties
        let value = RotateGesture.Value(
            rotation: Angle(degrees: 45),
            anchor: .center,
            velocity: Angle(degrees: 10)
        )
        
        XCTAssertEqual(value.rotation.degrees, 45, accuracy: 0.001)
        XCTAssertEqual(value.anchor, UnitPoint.center)
        XCTAssertEqual(value.velocity.degrees, 10, accuracy: 0.001)
    }
    
    func testRotateGestureTypeAlias() {
        // Test legacy type alias
        let gesture = RotationGesture()
        XCTAssertNotNil(gesture)
        
        let gestureWithMin = RotationGesture(minimumAngleDelta: Angle(radians: 0.1))
        XCTAssertNotNil(gestureWithMin)
    }
    
    func testRotateGestureModifiers() {
        let baseGesture = RotateGesture()
        
        // Test onChanged modifier
        var changedValue: RotateGesture.Value?
        let withOnChanged = baseGesture.onChanged { value in
            changedValue = value
        }
        XCTAssertNotNil(withOnChanged)
        
        // Test onEnded modifier
        var endedValue: RotateGesture.Value?
        let withOnEnded = baseGesture.onEnded { value in
            endedValue = value
        }
        XCTAssertNotNil(withOnEnded)
    }
    
    // MARK: - SimultaneousGesture Tests
    
    func testSimultaneousGestureInitialization() {
        let drag = DragGesture()
        let magnify = MagnifyGesture()
        
        let simultaneous = SimultaneousGesture(drag, magnify)
        XCTAssertNotNil(simultaneous)
        
        XCTAssertNotNil(simultaneous.first)
        XCTAssertNotNil(simultaneous.second)
    }
    
    func testSimultaneousGestureValue() {
        // Test SimultaneousGesture.Value
        let dragValue = DragGesture.Value(
            time: Date(),
            location: CGPoint(x: 100, y: 200),
            startLocation: CGPoint(x: 50, y: 100),
            velocity: CGSize(width: 10, height: 20)
        )
        
        let magnifyValue = MagnifyGesture.Value(
            magnification: 2.0,
            anchor: .center,
            velocity: 0.5
        )
        
        let simultaneousValue = SimultaneousGesture<DragGesture, MagnifyGesture>.Value(
            first: dragValue,
            second: magnifyValue
        )
        
        XCTAssertNotNil(simultaneousValue.first)
        XCTAssertNotNil(simultaneousValue.second)
        XCTAssertEqual(simultaneousValue.first?.location.x, 100)
        XCTAssertEqual(simultaneousValue.second?.magnification, 2.0)
    }
    
    func testSimultaneousGestureWithNilValues() {
        // Test with nil values
        let value = SimultaneousGesture<DragGesture, MagnifyGesture>.Value(
            first: nil,
            second: nil
        )
        
        XCTAssertNil(value.first)
        XCTAssertNil(value.second)
    }
    
    func testGestureSimultaneouslyMethod() {
        let drag = DragGesture()
        let rotate = RotateGesture()
        
        // Test .simultaneously(with:) method
        let combined = drag.simultaneously(with: rotate)
        XCTAssertNotNil(combined)
    }
    
    // MARK: - DragGesture Velocity Tests
    
    func testDragGestureVelocity() {
        let value = DragGesture.Value(
            time: Date(),
            location: CGPoint(x: 100, y: 100),
            startLocation: CGPoint(x: 0, y: 0),
            velocity: CGSize(width: 50, height: 75)
        )
        
        XCTAssertEqual(value.velocity.width, 50)
        XCTAssertEqual(value.velocity.height, 75)
        
        // Test translation
        let translation = value.translation
        XCTAssertEqual(translation.width, 100)
        XCTAssertEqual(translation.height, 100)
    }
    
    // MARK: - Integration Tests
    
    func testMagnifyGestureInView() {
        struct TestView: View {
            @State private var scale: CGFloat = 1.0
            @State private var lastScale: CGFloat = 1.0
            
            var body: some View {
                Rectangle()
                    .scaleEffect(scale)
                    .gesture(
                        MagnifyGesture()
                            .onChanged { value in
                                scale = lastScale * value.magnification
                            }
                            .onEnded { value in
                                lastScale = scale
                            }
                    )
            }
        }
        
        let view = TestView()
        XCTAssertNotNil(view.body)
    }
    
    func testRotateGestureInView() {
        struct TestView: View {
            @State private var angle = Angle.zero
            @State private var lastAngle = Angle.zero
            
            var body: some View {
                Rectangle()
                    .rotationEffect(angle)
                    .gesture(
                        RotateGesture()
                            .onChanged { value in
                                angle = lastAngle + value.rotation
                            }
                            .onEnded { value in
                                lastAngle = angle
                            }
                    )
            }
        }
        
        let view = TestView()
        XCTAssertNotNil(view.body)
    }
    
    func testCombinedGesturesInView() {
        struct TestView: View {
            @State private var offset = CGSize.zero
            @State private var scale: CGFloat = 1.0
            @State private var angle = Angle.zero
            
            var body: some View {
                Rectangle()
                    .scaleEffect(scale)
                    .rotationEffect(angle)
                    .offset(offset)
                    .gesture(
                        DragGesture()
                            .simultaneously(with: MagnifyGesture())
                            .onChanged { value in
                                if let dragValue = value.first {
                                    offset = dragValue.translation
                                }
                                if let magnifyValue = value.second {
                                    scale = magnifyValue.magnification
                                }
                            }
                    )
            }
        }
        
        let view = TestView()
        XCTAssertNotNil(view.body)
    }
    
    func testTripleCombinedGestures() {
        struct TestView: View {
            @State private var offset = CGSize.zero
            @State private var scale: CGFloat = 1.0
            @State private var rotation = Angle.zero
            
            var body: some View {
                Image(systemName: "star.fill")
                    .scaleEffect(scale)
                    .rotationEffect(rotation)
                    .offset(offset)
                    .gesture(
                        DragGesture()
                            .simultaneously(
                                with: MagnifyGesture()
                                    .simultaneously(with: RotateGesture())
                            )
                            .onChanged { value in
                                if let dragValue = value.first {
                                    offset = dragValue.translation
                                }
                                if let combinedValue = value.second {
                                    if let magnifyValue = combinedValue.first {
                                        scale = magnifyValue.magnification
                                    }
                                    if let rotateValue = combinedValue.second {
                                        rotation = rotateValue.rotation
                                    }
                                }
                            }
                    )
            }
        }
        
        let view = TestView()
        XCTAssertNotNil(view.body)
    }
    
    func testGestureMinimumThresholds() {
        // Test minimum delta thresholds
        let magnifyWithThreshold = MagnifyGesture(minimumScaleDelta: 0.1)
        XCTAssertNotNil(magnifyWithThreshold)
        
        let rotateWithThreshold = RotateGesture(minimumAngleDelta: Angle(degrees: 5))
        XCTAssertNotNil(rotateWithThreshold)
        
        let dragWithDistance = DragGesture(minimumDistance: 10)
        XCTAssertNotNil(dragWithDistance)
    }
    
    func testGestureStateManagement() {
        struct TestView: View {
            @GestureState private var magnifyState: CGFloat = 1.0
            @GestureState private var rotateState = Angle.zero
            @GestureState private var dragState = CGSize.zero
            
            var body: some View {
                Circle()
                    .scaleEffect(magnifyState)
                    .rotationEffect(rotateState)
                    .offset(dragState)
                    .gesture(
                        DragGesture()
                            .updating($dragState) { value, state, _ in
                                state = value.translation
                            }
                    )
                    .gesture(
                        MagnifyGesture()
                            .updating($magnifyState) { value, state, _ in
                                state = value.magnification
                            }
                    )
                    .gesture(
                        RotateGesture()
                            .updating($rotateState) { value, state, _ in
                                state = value.rotation
                            }
                    )
            }
        }
        
        let view = TestView()
        XCTAssertNotNil(view.body)
    }
}