//
//  File.swift
//
//
//  Created by Shahanul Haque on 8/25/24.
//

import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
extension CGFloat {
    @MainActor public static var screenWidth: CGFloat {
        #if os(iOS)
        return UIScreen.main.bounds.width
        #elseif os(macOS)
        return NSScreen.main?.frame.width ?? 0
        #endif
    }
    
    @MainActor public static var screenHeight: CGFloat {
        #if os(iOS)
        return UIScreen.main.bounds.height
        #elseif os(macOS)
        return NSScreen.main?.frame.height ?? 0
        #endif
    }
}

extension CGFloat {

  public func height() -> CGFloat {
    return RM.shared.height(self)
  }

  public func width() -> CGFloat {
    return RM.shared.width(self)
  }

}

extension Int {

  public func height() -> CGFloat {
    return RM.shared.height(CGFloat(self))
  }

  public func width() -> CGFloat {
    return RM.shared.width(CGFloat(self))
  }

}
extension Int {
  public func compactFormatted() -> String {
    let num = Swift.abs(Double(self))
    let sign = (self < 0) ? "-" : ""

    switch num {
    case 1_000_000_000...:
      let formatted = (num / 1_000_000_000).rounded(toPlaces: 1)
      return "\(sign)\(formatted.cleanString)B"
    case 1_000_000...:
      let formatted = (num / 1_000_000).rounded(toPlaces: 1)
      return "\(sign)\(formatted.cleanString)M"
    case 1_000...:
      let formatted = (num / 1_000).rounded(toPlaces: 1)
      return formatted == 1000.0 ? "\(sign)1M" : "\(sign)\(formatted.cleanString)K"
    default:
      return "\(sign)\(self)"
    }
  }
}

public extension Double {
   var cleanString: String {
    // Remove the decimal point if the number is whole, otherwise show up to 1 decimal
    return self.truncatingRemainder(dividingBy: 1) == 0
      ? String(format: "%.0f", self) : String(format: "%.1f", self)
  }

  func rounded(toPlaces places: Int) -> Double {
    let divisor = pow(10.0, Double(places))
    return (self * divisor).rounded() / divisor
  }
    
    func formattedNumber(upto: Int = 2) -> String {
        return String(format: "%.\(upto)f", self)
    }
}

