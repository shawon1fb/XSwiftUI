//
//  Color+EXT.swift
//  XSwiftUI
//
//  Created by shahanul on 11/21/24.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// Platform-specific type alias
#if canImport(UIKit)
public typealias NativeColor = UIColor
#elseif canImport(AppKit)
public typealias NativeColor = NSColor
#endif

extension Color {
    @available(*, deprecated, message: "Use init(hex:alpha:) instead", renamed: "init(hex:alpha:)")
    public init(hexString: String, alpha: Double = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        
        if hexString.hasPrefix("#") {
            scanner.currentIndex = .init(utf16Offset: 1, in: hexString)
        }
        
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        let mask = 0x0000_00FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red = Double(r) / 255.0
        let green = Double(g) / 255.0
        let blue = Double(b) / 255.0
        
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
}

extension Color {
    public init(hex: String, alpha: Double = 1.0) {
        let hexString: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        
        if hexString.hasPrefix("#") {
            scanner.currentIndex = .init(utf16Offset: 1, in: hexString)
        }
        
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        let mask = 0x0000_00FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red = Double(r) / 255.0
        let green = Double(g) / 255.0
        let blue = Double(b) / 255.0
        
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
    
    // Convert SwiftUI Color to platform-native color
    public var nativeColor: NativeColor {
        NativeColor(color: self)
    }
    
    // Convert platform-native color to SwiftUI Color
    public func nativeColorToColor(color: NativeColor) -> Color {
        Color(color)
    }
}

// Platform-specific color conversion
#if canImport(UIKit)
extension UIColor {
    public convenience init(color: Color) {
        let components = color.cgColor?.components ?? [0, 0, 0, 1]
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        let alpha = components.count > 3 ? components[3] : 1.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    public var toColor: Color {
        Color(self)
    }
}
#elseif canImport(AppKit)
extension NSColor {
    public convenience init(color: Color) {
        let components = color.cgColor?.components ?? [0, 0, 0, 1]
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        let alpha = components.count > 3 ? components[3] : 1.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    public var toColor: Color {
        Color(self)
    }
}
#endif
