// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception

import XCTest
import SwiftUI
import SkipUI

#if !SKIP_BRIDGE

// Test models for Observable and Bindable
@Observable
class TestModel {
    var name: String = "Test"
    var count: Int = 0
    var isEnabled: Bool = true
    var items: [String] = []
    var optionalValue: String? = nil
    
    func increment() {
        count += 1
    }
    
    func toggle() {
        isEnabled.toggle()
    }
}

@Observable
class IdentifiableModel: Identifiable {
    let id = UUID()
    var title: String = "Item"
    var isCompleted: Bool = false
}

@Observable
class NestedModel {
    var child: TestModel = TestModel()
    var value: Double = 0.0
}

#endif

final class ObservableBindableTests: XCTestCase {
    
    #if !SKIP_BRIDGE
    
    // MARK: - @Observable Tests
    
    func testObservableClassBasicProperties() {
        let model = TestModel()
        
        XCTAssertEqual(model.name, "Test")
        XCTAssertEqual(model.count, 0)
        XCTAssertTrue(model.isEnabled)
        XCTAssertEqual(model.items, [])
        XCTAssertNil(model.optionalValue)
        
        // Modify properties
        model.name = "Updated"
        model.count = 5
        model.isEnabled = false
        model.items = ["a", "b", "c"]
        model.optionalValue = "Something"
        
        XCTAssertEqual(model.name, "Updated")
        XCTAssertEqual(model.count, 5)
        XCTAssertFalse(model.isEnabled)
        XCTAssertEqual(model.items, ["a", "b", "c"])
        XCTAssertEqual(model.optionalValue, "Something")
    }
    
    func testObservableClassMethods() {
        let model = TestModel()
        
        XCTAssertEqual(model.count, 0)
        model.increment()
        XCTAssertEqual(model.count, 1)
        model.increment()
        XCTAssertEqual(model.count, 2)
        
        XCTAssertTrue(model.isEnabled)
        model.toggle()
        XCTAssertFalse(model.isEnabled)
        model.toggle()
        XCTAssertTrue(model.isEnabled)
    }
    
    func testObservableIdentifiable() {
        let model1 = IdentifiableModel()
        let model2 = IdentifiableModel()
        
        XCTAssertNotEqual(model1.id, model2.id)
        XCTAssertEqual(model1.title, "Item")
        XCTAssertFalse(model1.isCompleted)
        
        model1.title = "Task 1"
        model1.isCompleted = true
        
        XCTAssertEqual(model1.title, "Task 1")
        XCTAssertTrue(model1.isCompleted)
        XCTAssertEqual(model2.title, "Item")
        XCTAssertFalse(model2.isCompleted)
    }
    
    func testObservableNestedModels() {
        let parent = NestedModel()
        
        XCTAssertEqual(parent.value, 0.0)
        XCTAssertEqual(parent.child.name, "Test")
        
        parent.value = 42.5
        parent.child.name = "Child Model"
        parent.child.count = 10
        
        XCTAssertEqual(parent.value, 42.5)
        XCTAssertEqual(parent.child.name, "Child Model")
        XCTAssertEqual(parent.child.count, 10)
    }
    
    // MARK: - @Bindable Tests
    
    func testBindableWithObservableClass() {
        struct TestView: View {
            @Bindable var model: TestModel
            
            var body: some View {
                VStack {
                    TextField("Name", text: $model.name)
                    
                    Stepper("Count: \(model.count)", value: $model.count)
                    
                    Toggle("Enabled", isOn: $model.isEnabled)
                    
                    if let value = model.optionalValue {
                        Text(value)
                    }
                    
                    TextField("Optional", text: Binding(
                        get: { model.optionalValue ?? "" },
                        set: { model.optionalValue = $0.isEmpty ? nil : $0 }
                    ))
                }
            }
        }
        
        let model = TestModel()
        let view = TestView(model: model)
        XCTAssertNotNil(view.body)
    }
    
    func testBindableWithIdentifiableModel() {
        struct ListView: View {
            @Bindable var item: IdentifiableModel
            
            var body: some View {
                HStack {
                    TextField("Title", text: $item.title)
                    Toggle("Completed", isOn: $item.isCompleted)
                }
            }
        }
        
        let item = IdentifiableModel()
        let view = ListView(item: item)
        XCTAssertNotNil(view.body)
    }
    
    func testBindableInForEach() {
        struct ContentView: View {
            @State private var items: [IdentifiableModel] = [
                IdentifiableModel(),
                IdentifiableModel(),
                IdentifiableModel()
            ]
            
            var body: some View {
                List {
                    ForEach(items) { item in
                        @Bindable var bindableItem = item
                        HStack {
                            TextField("Title", text: $bindableItem.title)
                            Toggle("Done", isOn: $bindableItem.isCompleted)
                        }
                    }
                }
            }
        }
        
        let view = ContentView()
        XCTAssertNotNil(view.body)
    }
    
    func testBindableWithStateObject() {
        struct ParentView: View {
            @State private var model = TestModel()
            
            var body: some View {
                ChildView(model: model)
            }
        }
        
        struct ChildView: View {
            @Bindable var model: TestModel
            
            var body: some View {
                VStack {
                    Text("Count: \(model.count)")
                    Button("Increment") {
                        model.increment()
                    }
                    TextField("Name", text: $model.name)
                }
            }
        }
        
        let view = ParentView()
        XCTAssertNotNil(view.body)
    }
    
    func testBindableNestedBinding() {
        struct OuterView: View {
            @State private var parent = NestedModel()
            
            var body: some View {
                InnerView(child: parent.child)
            }
        }
        
        struct InnerView: View {
            @Bindable var child: TestModel
            
            var body: some View {
                VStack {
                    TextField("Name", text: $child.name)
                    Stepper("Count", value: $child.count)
                }
            }
        }
        
        let view = OuterView()
        XCTAssertNotNil(view.body)
    }
    
    func testBindableArrayModification() {
        struct ItemListView: View {
            @Bindable var model: TestModel
            
            var body: some View {
                VStack {
                    ForEach(model.items, id: \.self) { item in
                        Text(item)
                    }
                    
                    Button("Add Item") {
                        model.items.append("Item \(model.items.count + 1)")
                    }
                    
                    Button("Clear") {
                        model.items.removeAll()
                    }
                }
            }
        }
        
        let model = TestModel()
        let view = ItemListView(model: model)
        XCTAssertNotNil(view.body)
    }
    
    func testBindableWithPicker() {
        struct PickerView: View {
            @Bindable var model: TestModel
            
            var body: some View {
                Picker("Count", selection: $model.count) {
                    ForEach(0..<10) { i in
                        Text("\(i)").tag(i)
                    }
                }
            }
        }
        
        let model = TestModel()
        let view = PickerView(model: model)
        XCTAssertNotNil(view.body)
    }
    
    func testBindableWithSheet() {
        struct MainView: View {
            @State private var model = TestModel()
            @State private var showSheet = false
            
            var body: some View {
                VStack {
                    Text("Name: \(model.name)")
                    Button("Edit") {
                        showSheet = true
                    }
                }
                .sheet(isPresented: $showSheet) {
                    EditView(model: model)
                }
            }
        }
        
        struct EditView: View {
            @Bindable var model: TestModel
            @Environment(\.dismiss) var dismiss
            
            var body: some View {
                VStack {
                    TextField("Name", text: $model.name)
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        
        let view = MainView()
        XCTAssertNotNil(view.body)
    }
    
    func testBindableWithEnvironment() {
        struct RootView: View {
            @State private var model = TestModel()
            
            var body: some View {
                ContentView()
                    .environment(model)
            }
        }
        
        struct ContentView: View {
            @Environment(TestModel.self) var model
            
            var body: some View {
                @Bindable var bindableModel = model
                VStack {
                    TextField("Name", text: $bindableModel.name)
                    Text("Count: \(model.count)")
                }
            }
        }
        
        let view = RootView()
        XCTAssertNotNil(view.body)
    }
    
    func testBindablePropertyAccess() {
        let model = TestModel()
        model.name = "Initial"
        model.count = 5
        
        struct TestView: View {
            @Bindable var model: TestModel
            
            var nameBinding: Binding<String> {
                $model.name
            }
            
            var countBinding: Binding<Int> {
                $model.count
            }
            
            var body: some View {
                VStack {
                    TextField("Name", text: nameBinding)
                    Stepper("Count", value: countBinding)
                }
            }
        }
        
        let view = TestView(model: model)
        XCTAssertNotNil(view.body)
    }
    
    #endif // !SKIP_BRIDGE
    
    // MARK: - Cross-platform tests
    
    func testBasicBindingCreation() {
        @State var value = "test"
        let binding = Binding(
            get: { value },
            set: { value = $0 }
        )
        
        XCTAssertEqual(binding.wrappedValue, "test")
        binding.wrappedValue = "updated"
        XCTAssertEqual(value, "updated")
    }
    
    func testConstantBinding() {
        let binding = Binding.constant("constant value")
        XCTAssertEqual(binding.wrappedValue, "constant value")
        
        let intBinding = Binding.constant(42)
        XCTAssertEqual(intBinding.wrappedValue, 42)
        
        let boolBinding = Binding.constant(true)
        XCTAssertTrue(boolBinding.wrappedValue)
    }
}