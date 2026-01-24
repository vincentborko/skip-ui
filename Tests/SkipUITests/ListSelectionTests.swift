// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
import SwiftUI
import XCTest
import OSLog
import Foundation

struct TestItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct CustomItem {
    let id: Int
    let name: String
}

struct SingleSelectionTestView: View {
    @State var selectedItem: TestItem? = nil
    let items: [TestItem]
    
    var body: some View {
        VStack {
            Text("Selected: \(selectedItem?.title ?? "None")")
            List(items, selection: $selectedItem) { item in
                Text(item.title)
            }
        }
    }
}

struct MultiSelectionTestView: View {
    @State var selectedItems: Set<TestItem> = []
    let items: [TestItem]
    
    var body: some View {
        VStack {
            Text("Selected: \(selectedItems.count)")
            List(items, selection: $selectedItems) { item in
                Text(item.title)
            }
        }
    }
}

struct CustomIdSingleSelectionTestView: View {
    @State var selectedId: Int? = nil
    let items: [CustomItem]
    
    var body: some View {
        VStack {
            Text("Selected ID: \(selectedId?.description ?? "None")")
            List(items, id: \.id, selection: $selectedId) { item in
                Text(item.name)
            }
        }
    }
}

struct CustomIdMultiSelectionTestView: View {
    @State var selectedIds: Set<Int> = []
    let items: [CustomItem]
    
    var body: some View {
        VStack {
            Text("Selected: \(selectedIds.count) items")
            List(items, id: \.id, selection: $selectedIds) { item in
                Text(item.name)
            }
        }
    }
}

struct EmptySelectionTestView: View {
    @State var selectedItem: TestItem? = nil
    let items: [TestItem]
    
    var body: some View {
        VStack {
            Text("Selected: \(selectedItem?.title ?? "None")")
            List(items, selection: $selectedItem) { item in
                Text(item.title)
            }
        }
    }
}

struct PlainStyleSelectionTestView: View {
    @State var selectedItem: TestItem? = nil
    let items: [TestItem]
    
    var body: some View {
        List(items, selection: $selectedItem) { item in
            Text(item.title)
        }
        .listStyle(.plain)
    }
}

final class ListSelectionTests: XCSnapshotTestCase {
    
    func testListSingleSelectionBinding() throws {
        let items = [
            TestItem(title: "Item 1"),
            TestItem(title: "Item 2"),
            TestItem(title: "Item 3")
        ]
        
        _ = try render(view: SingleSelectionTestView(items: items))
    }
    
    func testListMultiSelectionBinding() throws {
        let items = [
            TestItem(title: "Item 1"),
            TestItem(title: "Item 2"),
            TestItem(title: "Item 3")
        ]
        
        _ = try render(view: MultiSelectionTestView(items: items))
    }
    
    func testListWithCustomIdSingleSelection() throws {
        let items = [
            CustomItem(id: 1, name: "First"),
            CustomItem(id: 2, name: "Second"),
            CustomItem(id: 3, name: "Third")
        ]
        
        _ = try render(view: CustomIdSingleSelectionTestView(items: items))
    }
    
    func testListWithCustomIdMultiSelection() throws {
        let items = [
            CustomItem(id: 1, name: "First"),
            CustomItem(id: 2, name: "Second"),
            CustomItem(id: 3, name: "Third")
        ]
        
        _ = try render(view: CustomIdMultiSelectionTestView(items: items))
    }
    
    func testEmptyListWithSelection() throws {
        let items: [TestItem] = []
        
        _ = try render(view: EmptySelectionTestView(items: items))
    }
    
    func testListSelectionWithPlainStyle() throws {
        let items = [
            TestItem(title: "Item 1"),
            TestItem(title: "Item 2")
        ]
        
        _ = try render(view: PlainStyleSelectionTestView(items: items))
    }
}