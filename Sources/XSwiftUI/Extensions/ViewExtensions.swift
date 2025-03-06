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
        let minX = rect.minX
        let minY = rect.minY
        let maxX = rect.maxX
        let maxY = rect.maxY
        
        // Start from the correct position based on which corners are rounded
        let startPoint = corners.contains(.topLeft)
            ? CGPoint(x: minX + radius, y: minY)
            : CGPoint(x: minX, y: minY)
        
        move(to: startPoint)
        
        // Top edge and top right corner
        if corners.contains(.topRight) {
            line(to: CGPoint(x: maxX - radius, y: minY))
            curve(to: CGPoint(x: maxX, y: minY + radius),
                  controlPoint1: CGPoint(x: maxX - radius * 0.5, y: minY),
                  controlPoint2: CGPoint(x: maxX, y: minY + radius * 0.5))
        } else {
            line(to: CGPoint(x: maxX, y: minY))
        }
        
        // Right edge and bottom right corner
        if corners.contains(.bottomRight) {
            line(to: CGPoint(x: maxX, y: maxY - radius))
            curve(to: CGPoint(x: maxX - radius, y: maxY),
                  controlPoint1: CGPoint(x: maxX, y: maxY - radius * 0.5),
                  controlPoint2: CGPoint(x: maxX - radius * 0.5, y: maxY))
        } else {
            line(to: CGPoint(x: maxX, y: maxY))
        }
        
        // Bottom edge and bottom left corner
        if corners.contains(.bottomLeft) {
            line(to: CGPoint(x: minX + radius, y: maxY))
            curve(to: CGPoint(x: minX, y: maxY - radius),
                  controlPoint1: CGPoint(x: minX + radius * 0.5, y: maxY),
                  controlPoint2: CGPoint(x: minX, y: maxY - radius * 0.5))
        } else {
            line(to: CGPoint(x: minX, y: maxY))
        }
        
        // Left edge and top left corner
        if corners.contains(.topLeft) {
            line(to: CGPoint(x: minX, y: minY + radius))
            curve(to: CGPoint(x: minX + radius, y: minY),
                  controlPoint1: CGPoint(x: minX, y: minY + radius * 0.5),
                  controlPoint2: CGPoint(x: minX + radius * 0.5, y: minY))
        } else {
            line(to: CGPoint(x: minX, y: minY))
        }
        
        close()
    }
    
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        
        for i in 0..<elementCount {
            let type = element(at: i, associatedPoints: &points)
            
            switch type {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath:
                path.closeSubpath()
             default:
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


struct Inverted: ViewModifier {
    func body(content: Content) -> some View {
        content
            .rotationEffect(.radians(Double.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}

public extension View {
    func inverted() -> some View {
        modifier(Inverted())
    }
}
