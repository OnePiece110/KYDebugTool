//
//  KYConfiguration.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/24.
//

import Foundation

/// Configuration options for the in app view debugger.
final class KYConfiguration: NSObject {
    /// Configuration for the 3D snapshot view.
    @objc var snapshotViewConfiguration = KYSnapshotViewConfiguration()

    /// Configuration for the hierarchy (tree) view.
    @objc var hierarchyViewConfiguration = KYHierarchyViewConfiguration()
}
