//
//  KYApplicationDirectories.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import Foundation

final class KYApplicationDirectories {
    static let shared = KYApplicationDirectories()

    var support: URL {
        guard let supportDirectory = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        ).first
        else {
            fatalError("Unable to retrieve application support directory.")
        }
        return supportDirectory
    }
}
