//
//  EnvSetupView.swift
//  XSwiftUI
//
//  Created by shahanul on 11/20/24.
//


import Foundation
import SwiftUI

public struct EnvSetupView<Content: View>: View {
  @ViewBuilder var content: Content

  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content()
  }

  public var body: some View {
    GeometryReader { value in
      GeometryReader { proxy in
        content
              .toast()
          .environment(\.mainWindowSize, proxy.size)
        // .environment(\.safeAreaInsets, proxy.safeAreaInsets)
      }
      .ignoresSafeArea()
      .environment(\.safeAreaInsets, value.safeAreaInsets)
    }
  }
}

private struct MainWindowSizeKey: EnvironmentKey {
  static let defaultValue: CGSize = .zero
}

extension EnvironmentValues {
  public var mainWindowSize: CGSize {
    get { self[MainWindowSizeKey.self] }
    set { self[MainWindowSizeKey.self] = newValue }
  }

  public var safeAreaInsets: EdgeInsets {
    get { self[SafeAreaInsetsKey.self] }
    set { self[SafeAreaInsetsKey.self] = newValue }
  }
}

//private struct SafeAreaInsetsKey: EnvironmentKey {
//   static var defaultValue: EdgeInsets = .init()
//}

// Define SafeAreaInsetsKey as an EnvironmentKey with EdgeInsets default value
private struct SafeAreaInsetsKey: EnvironmentKey {
    static let defaultValue: EdgeInsets = EdgeInsets()
}



public struct InitialCardView<Content: View>: View {
  @ViewBuilder var content: () -> Content

  public var body: some View {
    EnvSetupView {
      content()
    }
  }

  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }
}
