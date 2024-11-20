//
//  InfiniteList.swift
//  XSwiftUI
//
//  Created by shahanul on 11/20/24.
//


import SwiftUI

public struct InfiniteList<Data, Content, LoadingView>: View
where
  Data: RandomAccessCollection,
  Data.Element: Hashable,
  Content: View,
  LoadingView: View
{

  @Binding var data: Data
  @State var isLoading: Bool
  @State private var isFetchingMore: Bool = false
  @State private var fetchTask: Task<Void, Never>? = nil
    let scrollEnable: Bool
  let loadingView: LoadingView
  let loadMore: () async -> Void
  let spacing: CGFloat
  let content: (Data.Element) -> Content

  public init(
    data: Binding<Data>,
    @ViewBuilder loadingView: @escaping () -> LoadingView,
    spacing: CGFloat = 10,
    scrollEnable: Bool = true,
    loadMore: @escaping () async -> Void,
    @ViewBuilder content: @escaping (Data.Element) -> Content
  ) {
    _data = data
    isLoading = false
    self.loadingView = loadingView()
    self.loadMore = loadMore
    self.spacing = spacing
    self.content = content
      self.scrollEnable = scrollEnable
  }

  public var body: some View {
      if scrollEnable == true {
          ScrollView {
            listContent
          }
      }else{
          listContent
      }
   
  }

  private var listContent: some View {
    LazyVStack(spacing: spacing) {
      ForEach(data, id: \.self) { item in
        content(item)
          .onAppear {
            onItemAppear(item: item)
          }
      }
      if isLoading {
        loadingView
          .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
      }
    }
  }

  func onItemAppear(item: Data.Element) {
    guard !isFetchingMore, let lastItem = data.last else { return }
    
    // Load more when the user scrolls close to the last item
    if item == lastItem {
      fetchMoreData()
    }
  }

  func fetchMoreData() {
    isFetchingMore = true
    fetchTask?.cancel()

    fetchTask = Task {
      guard !Task.isCancelled else { return }

      isLoading = true
      await loadMore()
      isLoading = false
      isFetchingMore = false
    }
  }
}

struct InfiniteListExample: View {
  @State private var data: [Int] = Array(1...20)
  @State private var isLoading = false
  @State private var l: Int = 0

  var body: some View {
    InfiniteList(
      data: $data,
      loadingView: {
        ProgressView()
          .foregroundColor(.blue)
      },
      scrollEnable: false,
      loadMore: {
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        loadMore()
        print("load more")
      }
    ) { item in
      Text("\(item)")
        .frame(width: 100, height: 50)
        .background(Color.blue)
        .cornerRadius(8)
    }
    .refreshable {
      try? await Task.sleep(nanoseconds: 1_000_000_000)
      print("refreshed list view -> \(l = l + 1)")
      data = Array(1...20)
    }
  }

  func loadMore() {
    DispatchQueue.main.asyncAfter(deadline: .now()) {
      let moreData = (data.count + 1)...(data.count + 20)
      data.append(contentsOf: moreData)
    }
  }
}

#Preview(body: {
  VStack {
      ScrollView{
          InfiniteListExample()
      }
  }
  .padding()
})
