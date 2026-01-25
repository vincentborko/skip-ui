// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if !SKIP_BRIDGE
import Foundation
#if SKIP
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.AnimationSpec
import androidx.compose.animation.core.tween
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import kotlinx.coroutines.delay
#endif

// SKIP @bridge
public struct PhaseAnimator<Phase, Content> : View where Phase : Equatable, Content : View {
    #if SKIP
    private let phases: [Phase]
    private let trigger: Any?
    private let content: (Phase) -> Content
    private let animation: (Phase) -> Animation?
    
    public init(
        _ phases: [Phase],
        @ViewBuilder content: @escaping (Phase) -> Content,
        animation: @escaping (Phase) -> Animation? = { _ in .default }
    ) {
        self.phases = phases
        self.trigger = nil
        self.content = content
        self.animation = animation
    }
    
    public init(
        _ phases: [Phase],
        trigger: some Equatable,
        @ViewBuilder content: @escaping (Phase) -> Content,
        animation: @escaping (Phase) -> Animation? = { _ in .default }
    ) {
        self.phases = phases
        self.trigger = trigger
        self.content = content
        self.animation = animation
    }
    
    @Composable public override func ComposeContent(context: ComposeContext) {
        guard !phases.isEmpty else { return }
        
        var currentPhaseIndex by remember { mutableStateOf(0) }
        let currentPhase = phases[currentPhaseIndex]
        
        // For triggered animations, reset when trigger changes
        if let trigger = trigger {
            LaunchedEffect(trigger) {
                currentPhaseIndex = 0
                
                // Cycle through phases once
                for i in 1..<phases.count {
                    let phase = phases[i - 1]
                    let animSpec = animation(phase)?.asAnimationSpec() ?? tween<Any>()
                    
                    // Extract duration from animation spec if possible
                    let durationMillis = when (animSpec) {
                        is TweenSpec<*> -> (animSpec as TweenSpec<*>).durationMillis
                        else -> 350 // Default duration
                    }
                    
                    delay(Long(durationMillis))
                    currentPhaseIndex = i
                }
            }
        } else {
            // Continuous looping animation
            LaunchedEffect(Unit) {
                while (true) {
                    let phase = phases[currentPhaseIndex]
                    let animSpec = animation(phase)?.asAnimationSpec() ?? tween<Any>()
                    
                    // Extract duration from animation spec if possible
                    let durationMillis = when (animSpec) {
                        is TweenSpec<*> -> (animSpec as TweenSpec<*>).durationMillis
                        else -> 350 // Default duration
                    }
                    
                    delay(Long(durationMillis))
                    currentPhaseIndex = (currentPhaseIndex + 1) % phases.count
                }
            }
        }
        
        // Apply animation to content transition
        let phaseAnimation = animation(currentPhase)
        Animation.withAnimation(phaseAnimation) {
            content(currentPhase).ComposeContent(context: context)
        }
    }
    #else
    public init(
        _ phases: [Phase],
        @ViewBuilder content: @escaping (Phase) -> Content,
        animation: @escaping (Phase) -> Animation? = { _ in .default }
    ) {
        fatalError()
    }
    
    public init(
        _ phases: [Phase],
        trigger: some Equatable,
        @ViewBuilder content: @escaping (Phase) -> Content,
        animation: @escaping (Phase) -> Animation? = { _ in .default }
    ) {
        fatalError()
    }
    
    public var body: some View {
        fatalError()
    }
    #endif
}
#endif