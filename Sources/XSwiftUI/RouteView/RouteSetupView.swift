//
//  RouteSetupView.swift
//  DecoraanUIComponents
//
//  Created by Shahanul Haque on 10/26/24.
//

//import SwiftUI
//import SUIRouter
//public struct RouteSetupView<Content: View>: View {
//
//  @StateObject var pilot: UIPilot<AppRoute>
//  @ViewBuilder var content: Content
//
//  public init(
//    pilot: UIPilot<Route: Equatable>,
//    @ViewBuilder content: @escaping (_ pilot: UIPilot<AppRoute>) -> Content
//  ) {
//    pilot.addObserver(ScopeCleanupObserver())
//    _pilot = StateObject(wrappedValue: pilot)
//    self.content = content(pilot)
//    DIManager.shared.registerSelf(pilot: pilot)
//  }
//
//  public var body: some View {
//    content
//          .toast()
//  }
//}
