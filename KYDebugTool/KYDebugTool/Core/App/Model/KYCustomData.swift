//
//  KYCustomData.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import Foundation

public struct KYCustomData {
    public init(title: String, infos: [Info]) {
        self.title = title
        self.infos = infos
    }

    let title: String
    let infos: [Info]
}

extension KYCustomData {
    public struct Info {
        public init(title: String, subtitle: String) {
            self.title = title
            self.subtitle = subtitle
        }

        let title: String
        let subtitle: String
    }
}
