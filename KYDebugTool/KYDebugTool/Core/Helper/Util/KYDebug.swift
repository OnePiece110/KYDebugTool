//
//  KYDebug.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import Foundation

public enum KYDebug {
    static var enable: Bool {
        KYDebugTool.Debugger.enable
    }

    static func execute(action: () -> Void) {
        guard enable else { return }
        action()
    }

    static func print(
        _ message: Any
    ) {
        guard enable else { return }
        Swift.print("[DebugSwift] 🚀 → \(message)")
    }
}
