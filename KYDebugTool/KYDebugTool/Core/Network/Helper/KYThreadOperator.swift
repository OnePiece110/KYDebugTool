//
//  KYThreadOperator.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import Foundation

final class KYThreadOperator: NSObject {
    private let thread: Thread
    private let modes: [RunLoop.Mode]

    private var operation: (() -> Void)?

    override init() {
        self.thread = Thread.current

        if let mode = RunLoop.current.currentMode {
            self.modes = [mode, .default].map { $0 }
        } else {
            self.modes = [.default]
        }

        super.init()
    }

    func execute(_ operation: @escaping () -> Void) {
        self.operation = operation
        perform(
            #selector(operate),
            on: thread,
            with: nil,
            waitUntilDone: true,
            modes: modes.map(\.rawValue)
        )
        self.operation = nil
    }

    @objc private func operate() {
        operation?()
    }
}
