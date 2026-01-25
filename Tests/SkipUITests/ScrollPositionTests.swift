// Copyright 2025 Skip
// Copyright 2025 Skip
import SwiftUI
import XCTest
#if os(iOS)
@_spi(Internal) import SkipUI
#endif

final class ScrollPositionTests: XCSnapshotTestCase {
    
    @available(iOS 17.0, macOS 14.0, *)
    func testScrollPositionBinding() {
        struct ContentView: View {
            @State var scrolledID: Int? = nil
            let items = Array(1...50)
            
            var body: some View {
                VStack {
                    Text("Scrolled to: \(scrolledID ?? -1)")
                        .padding()
                    
                    ScrollView {
                        LazyVStack {
                            ForEach(items, id: \.self) { item in
                                Text("Item \(item)")
                                    .frame(maxWidth: .infinity, minHeight: 50)
                                    .background(scrolledID == item ? Color.blue.opacity(0.3) : Color.gray.opacity(0.1))
                                    .id(item)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollPosition(id: $scrolledID)
                    .frame(height: 300)
                    
                    HStack {
                        Button("Top") {
                            scrolledID = items.first
                        }
                        Button("Middle") {
                            scrolledID = items[items.count / 2]
                        }
                        Button("Bottom") {
                            scrolledID = items.last
                        }
                    }
                    .padding()
                }
            }
        }
        
        snapshotView(ContentView())
    }
    
    @available(iOS 17.0, macOS 14.0, *)
    func testPagingScrollTargetBehavior() {
        struct ContentView: View {
            let pages = ["Page 1", "Page 2", "Page 3", "Page 4", "Page 5"]
            
            var body: some View {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 0) {
                        ForEach(pages, id: \.self) { page in
                            VStack {
                                Text(page)
                                    .font(.largeTitle)
                            }
                            .frame(width: 300, height: 200)
                            .background(Color.blue.opacity(0.2))
                            .border(Color.blue)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .frame(width: 300, height: 200)
            }
        }
        
        snapshotView(ContentView())
    }
    
    @available(iOS 17.0, macOS 14.0, *)
    func testViewAlignedScrollTargetBehavior() {
        struct ContentView: View {
            let items = Array(1...20)
            
            var body: some View {
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(items, id: \.self) { item in
                            Text("Card \(item)")
                                .frame(width: 150, height: 100)
                                .background(Color.green.opacity(0.3))
                                .cornerRadius(10)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .frame(height: 120)
            }
        }
        
        snapshotView(ContentView())
    }
    
    @available(iOS 17.0, macOS 14.0, *)
    func testScrollTargetEnabled() {
        struct ContentView: View {
            @State var isSnapEnabled = true
            let items = Array(1...10)
            
            var body: some View {
                VStack {
                    Toggle("Enable Snapping", isOn: $isSnapEnabled)
                        .padding()
                    
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(items, id: \.self) { item in
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.orange.opacity(0.3))
                                    .frame(width: 200, height: 150)
                                    .overlay(Text("Item \(item)"))
                                    .scrollTarget(isEnabled: isSnapEnabled)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .frame(height: 150)
                }
            }
        }
        
        snapshotView(ContentView())
    }
    
    @available(iOS 17.0, macOS 14.0, *)
    func testScrollPositionWithLazyVStack() {
        struct ContentView: View {
            @State var scrolledID: String? = nil
            let sections = ["A", "B", "C", "D", "E"]
            
            var body: some View {
                VStack {
                    Text("Section: \(scrolledID ?? "None")")
                        .padding()
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 20) {
                            ForEach(sections, id: \.self) { section in
                                VStack(alignment: .leading) {
                                    Text("Section \(section)")
                                        .font(.headline)
                                        .id(section)
                                    
                                    ForEach(1...5, id: \.self) { item in
                                        Text("  Item \(section)\(item)")
                                            .padding(.leading)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollPosition(id: $scrolledID)
                    .frame(height: 300)
                }
            }
        }
        
        snapshotView(ContentView())
    }
}