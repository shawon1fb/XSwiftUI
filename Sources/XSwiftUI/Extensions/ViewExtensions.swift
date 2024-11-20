//
//  ViewExtensions.swift
//  XSwiftUI
//
//  Created by shahanul on 11/20/24.
//

import Foundation
import SwiftUI

// MARK: - Define common corner type for both platforms
public struct RectCorners: OptionSet, Sendable {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let topLeft = RectCorners(rawValue: 1 << 0)
    public static let topRight = RectCorners(rawValue: 1 << 1)
    public static let bottomLeft = RectCorners(rawValue: 1 << 2)
    public static let bottomRight = RectCorners(rawValue: 1 << 3)
    public static let allCorners: RectCorners = [.topLeft, .topRight, .bottomLeft, .bottomRight]
    public static let topCorners: RectCorners = [.topLeft, .topRight]
    public static let bottomCorners: RectCorners = [.bottomLeft, .bottomRight]
    public static let leftCorners: RectCorners = [.topLeft, .bottomLeft]
    public static let rightCorners: RectCorners = [.topRight, .bottomRight]
}

#if os(iOS)
import UIKit
public typealias BezierPath = UIBezierPath

extension UIBezierPath {
    convenience init(roundedRect rect: CGRect, byRoundingCorners corners: RectCorners, cornerRadii: CGSize) {
        let uiRectCorners = UIRectCorner(rawValue: UInt(corners.rawValue))
        self.init(roundedRect: rect, byRoundingCorners: uiRectCorners, cornerRadii: cornerRadii)
    }
}
#elseif os(macOS)
import AppKit
public typealias BezierPath = NSBezierPath

extension NSBezierPath {
    convenience init(roundedRect rect: CGRect, byRoundingCorners corners: RectCorners, cornerRadii: CGSize) {
        self.init()
        
        let radius = min(cornerRadii.width, cornerRadii.height)
        
        let topLeft = corners.contains(.topLeft)
        let topRight = corners.contains(.topRight)
        let bottomLeft = corners.contains(.bottomLeft)
        let bottomRight = corners.contains(.bottomRight)
        
        // Start at top left
        if topLeft {
            self.move(to: NSPoint(x: rect.minX + radius, y: rect.minY))
        } else {
            self.move(to: NSPoint(x: rect.minX, y: rect.minY))
        }
        
        // Top right corner
        if topRight {
            self.line(to: NSPoint(x: rect.maxX - radius, y: rect.minY))
            self.appendArc(from: NSPoint(x: rect.maxX - radius, y: rect.minY),
                          to: NSPoint(x: rect.maxX, y: rect.minY + radius),
                          radius: radius)
        } else {
            self.line(to: NSPoint(x: rect.maxX, y: rect.minY))
        }
        
        // Bottom right corner
        if bottomRight {
            self.line(to: NSPoint(x: rect.maxX, y: rect.maxY - radius))
            self.appendArc(from: NSPoint(x: rect.maxX, y: rect.maxY - radius),
                          to: NSPoint(x: rect.maxX - radius, y: rect.maxY),
                          radius: radius)
        } else {
            self.line(to: NSPoint(x: rect.maxX, y: rect.maxY))
        }
        
        // Bottom left corner
        if bottomLeft {
            self.line(to: NSPoint(x: rect.minX + radius, y: rect.maxY))
            self.appendArc(from: NSPoint(x: rect.minX + radius, y: rect.maxY),
                          to: NSPoint(x: rect.minX, y: rect.maxY - radius),
                          radius: radius)
        } else {
            self.line(to: NSPoint(x: rect.minX, y: rect.maxY))
        }
        
        // Top left corner
        if topLeft {
            self.line(to: NSPoint(x: rect.minX, y: rect.minY + radius))
            self.appendArc(from: NSPoint(x: rect.minX, y: rect.minY + radius),
                          to: NSPoint(x: rect.minX + radius, y: rect.minY),
                          radius: radius)
        } else {
            self.line(to: NSPoint(x: rect.minX, y: rect.minY))
        }
        
        self.close()
    }
    
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        
        for i in 0...(self.elementCount - 1) {
            let type = self.element(at: i, associatedPoints: &points)
            
            switch type {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath:
                path.closeSubpath()
            case .cubicCurveTo:
                break
            case .quadraticCurveTo:
                break
            @unknown default:
                break
            }
        }
        
        return path
    }
}
#endif

// MARK: - Common code for both platforms
public extension View {
    func cornerRadius(_ radius: CGFloat, corners: RectCorners) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: RectCorners = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = BezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
