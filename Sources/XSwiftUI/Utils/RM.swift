//
//  RM.swift
//  XSwiftUI
//
//  Created by shahanul on 11/20/24.
//


import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public final class RM:Sendable {
    public static let shared = RM()
    
    #if os(iOS)
    var bounds: CGRect = UIScreen.main.bounds
    #elseif os(macOS)
    var bounds: CGRect {
        NSScreen.main?.frame ?? CGRect(x: 0, y: 0, width: 1440, height: 900)
    }
    #endif
    
    let baseWidth: CGFloat = 375
    let baseHeight: CGFloat = 812
    
    let iphone10Width: CGFloat = 375
    let iphone10Height: CGFloat = 812
    
    public func getDeviceWidth() -> CGFloat {
        bounds.size.width
    }
    
    public func getDeviceHeight() -> CGFloat {
        bounds.size.height
    }
    
    public func getNewsImageWidth() -> CGFloat {
        bounds.size.width - 30
    }
    
    #if os(iOS)
    public func width(_ value: CGFloat) -> CGFloat {
        switch UIDevice.modelName {
        case "iPhone 6", "iPhone 6s", "iPhone 7", "iPhone 8", "iPhone SE", "iPhone SE (2nd generation)", "iPhone SE (3rd generation)":
            let resolutionDifference = baseWidth/iphone10Width
            let actualWidth = CGFloat(value)/resolutionDifference
            return actualWidth
            
        case "iPhone 6s Plus", "iPhone 7 Plus", "iPhone 8 Plus":
            let resolutionDifference = baseWidth/baseWidth
            let actualWidth = CGFloat(value)/resolutionDifference
            return actualWidth
            
        default:
            let resolutionDifference = baseWidth/getDeviceWidth()
            let actualWidth = CGFloat(value)/resolutionDifference
            return actualWidth
        }
    }
    
    public func height(_ value: CGFloat) -> CGFloat {
        switch UIDevice.modelName {
        case "iPhone 6", "iPhone 6s", "iPhone 7", "iPhone 8", "iPhone SE", "iPhone SE (2nd generation)", "iPhone SE (3rd generation)":
            let resolutionDifference = baseHeight/iphone10Height
            let actualHeight = CGFloat(value)/resolutionDifference
            return actualHeight
            
        case "iPhone 6s Plus", "iPhone 7 Plus", "iPhone 8 Plus":
            let resolutionDifference = baseHeight/baseHeight
            let actualHeight = CGFloat(value)/resolutionDifference
            return actualHeight
            
        default:
            let resolutionDifference = baseHeight/getDeviceHeight()
            let actualHeight = CGFloat(value)/resolutionDifference
            return actualHeight
        }
    }
    #elseif os(macOS)
    public func width(_ value: CGFloat) -> CGFloat {
        let resolutionDifference = baseWidth/getDeviceWidth()
        let actualWidth = CGFloat(value)/resolutionDifference
        return actualWidth
    }
    
    public func height(_ value: CGFloat) -> CGFloat {
        let resolutionDifference = baseHeight/getDeviceHeight()
        let actualHeight = CGFloat(value)/resolutionDifference
        return actualHeight
    }
    #endif
}
