//
//  KYCustomAction.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import Foundation

public struct KYCustomAction {
    public init(title: String, actions: Actions) {
        self.title = title
        self.actions = actions
    }

    let title: String
    let actions: Actions
}

extension KYCustomAction {

    public typealias Actions = [Action]

    public struct Action {
        public init(title: String, action: (() -> Void)?) {
            self.title = title
            self.action = action
        }

        let title: String
        let action: (() -> Void)?
    }
}
