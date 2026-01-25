// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if !SKIP_BRIDGE

// Model Bindable as a class rather than struct to avoid copy overhead on mutation
// Note: @Bindable is primarily used on Swift side for @Observable classes
// The Skip transpiler does not support dynamic member lookup or property wrappers fully
// This is a simplified implementation for basic compatibility
public final class Bindable<Value> {
    public init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public var wrappedValue: Value

    public var projectedValue: Bindable<Value> {
        return self
    }
}

#endif
