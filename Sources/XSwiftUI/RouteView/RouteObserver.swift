////
////  RouteObserver.swift
////
////  Created by Shahanul Haque on 10/26/24.
////
//import SwiftUI
//import SwiftUIRouter
//import Utility
//import ios_common_model
//
//public class ScopeCleanupObserver: UIPilotObserverBase<AppRoute> {
//     init() {
//         super.init(id: "101")
//    }
//    
////    override func onPush(route: AppRoute) {
////        print("[ScopeCleanupObserver] AppRoute pushed: \(route)")
////    }
////
////    override func onPop(route: AppRoute) {
////        print("[ScopeCleanupObserver] AppRoute popped: \(route)")
////    }
////
////    override func onPopTo(route: AppRoute, inclusive: Bool) {
////        print("[ScopeCleanupObserver] PopTo AppRoute: \(route), inclusive: \(inclusive)")
////    }
//   
//    public override func onRouteChange(oldRoutes: [AppRoute], newRoutes: [AppRoute]) {
//        print("[ScopeCleanupObserver] oldRoutes: \(oldRoutes.count) \n newRoutes: \(newRoutes.count)")
//        
//        guard oldRoutes.count > newRoutes.count else{
//            
//            return
//        }
//        // Find routes that were removed
//        let removedRoutes = oldRoutes.filter { route in
//            !newRoutes.contains(route)
//        }
//       
//        // Get all paths that need cleanup
//        var pathsToCleanup: [[AppRoute]] = []
//       
//        for (index, route) in oldRoutes.enumerated() {
//            if removedRoutes.contains(route) {
//                // Get the full path up to this route
//                let pathToRoute = Array(oldRoutes[0...index])
//                pathsToCleanup.append(pathToRoute)
//            }
//        }
//       
//        // Clean up each path
//        pathsToCleanup.reversed().forEach { path in
//            // di.cleanupScope(path)
//            print("Cleaning up scope: \(path)")
//            
//            if let container = DIManager.DI as? SmartDI<AppRoute>{
//                container.cleanupScope(path)
//            }
//            
//        }
//        
//        DIContainer.shared.printRegistrations()
//    }
//}
