//
//  Keyboard+EXT.swift
//  XSwiftUI
//
//  Created by shahanul on 11/20/24.
//

import SwiftUI
import Foundation

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public extension View {
    @ViewBuilder
    func addKeyboardDoneButton() -> some View {
        #if os(iOS)
        self.toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    hideKeyboard()
                }
            }
        }
        #else
        self
        #endif
    }
    
    func hideKeyboard() {
        #if os(iOS)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                     to: nil,
                                     from: nil,
                                     for: nil)
        #elseif os(macOS)
        NSApplication.shared.keyWindow?.makeFirstResponder(nil)
        #endif
    }
}
