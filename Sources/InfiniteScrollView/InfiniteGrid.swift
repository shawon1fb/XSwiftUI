//
//  InfiniteGrid.swift
//  XSwiftUI
//
//  Created by shahanul on 11/20/24.
//

import SwiftUI

public struct InfiniteGrid<Data, Content, LoadingView>: View
where
  Data: RandomAccessCollection,
  Data.Element: Hashable,
  Content: View,
  LoadingView: View
{

  @Binding var data: Data
  @State var isLoading: Bool
  @State private var fetchTask: Task<Void, Never>? = nil
  let loadingView: LoadingView
  let loadMore: () async -> Void
  let columns: [GridItem]
  let spacing: CGFloat
  let scrollEnable: Bool
  let showsIndicators: Bool
  let alignment: HorizontalAlignment
  let pinnedViews: PinnedScrollableViews
  let content: (Data.Element) -> Content

  public init(
    data: Binding<Data>,
    @ViewBuilder loadingView: @escaping () -> LoadingView,
    columns: [GridItem],
    spacing: CGFloat = 10,
    scrollEnable: Bool = true,
    showsIndicators: Bool = false,
    alignment: HorizontalAlignment = .center,
    pinnedViews: PinnedScrollableViews = .init(),
    loadMore: @escaping () async -> Void,
    @ViewBuilder content: @escaping (Data.Element) -> Content
  ) {
    _data = data
    isLoading = false
    self.loadingView = loadingView()
    self.loadMore = loadMore
    self.columns = columns
    self.spacing = spacing
    self.content = content
    self.scrollEnable = scrollEnable
    self.showsIndicators = showsIndicators
    self.alignment = alignment
    self.pinnedViews = pinnedViews
  }

  public var body: some View {
    if scrollEnable == true {
        ScrollView(showsIndicators: showsIndicators) {
        gridContent
          .onAppear(perform: onAppear)
      }
    } else {
      gridContent
        .onAppear(perform: onAppear)
    }

  }

  func onAppear() {
    // Cancel any previous task to avoid multiple triggers.
    fetchTask?.cancel()

    // Create a new fetch task
    fetchTask = Task {
      guard !Task.isCancelled else { return }

      isLoading = true
      await loadMore()
      isLoading = false
    }
  }

  private var gridContent: some View {
    Group {
        LazyVGrid(columns: columns, alignment: alignment,spacing: spacing,pinnedViews: pinnedViews) {
        gridItems
      }
      if isLoading {
        loadingView
          .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
      }
    }
  }

  private var gridItems: some View {
    Group {
      ForEach(data, id: \.self) { item in
        content(item)
          .onAppear {
            // Only call loadMore when the user reaches the last item in the list
            if item == data.last, !isLoading {
              onAppear()  // Trigger loadMore only once when the last item is visible
            }
          }
      }
    }
  }
}

public struct InfiniteGridExample: View {
  @State private var data: [Int] = Array(1...20)
  // @State private var isLoading = false
  @State var l: Int = 0
  @State var loadMoreCount: Int = 0

  public init() {

  }

  public var body: some View {
      InfiniteGrid(
        data: $data,
        loadingView: {
          ProgressView()
            .foregroundColor(.blue)
        },
        columns: Array(repeating: GridItem(.flexible()), count: 2),
        scrollEnable: false,
        loadMore: {
          try? await Task.sleep(nanoseconds: 1_000_000_000)
          loadMore()
          loadMoreCount += 1
          print("load more \(loadMoreCount)")
        }
      ) { item in
        Text("\(item)")
          .frame(width: 100, height: 100)
          .background(Color.blue)
          .cornerRadius(8)
      }
    .refreshable {
      // Perform refresh and reset data
      try? await Task.sleep(nanoseconds: 1_000_000_000)
      l = l + 1
      print("refreshed grid view -> \(l )")

        data = Array(1...20)

      // Reset the loading state to allow loadMore to be triggered again
      // isLoading = false
    }
  }

  func loadMore() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      let moreData = (data.count + 1)...(data.count + 20)
      data.append(contentsOf: moreData)
    }
  }
}

// Preview code remains unchanged
#Preview(body: {
  VStack {
      ScrollView{
          InfiniteGridExample()
      }
  }
  .padding()
})
