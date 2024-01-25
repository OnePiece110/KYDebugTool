//
//  KYSnapshot.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/24.
//

import Foundation
import CoreGraphics

final class KYSnapshot: NSObject {
    /// Unique identifier for the snapshot.
    let identifier = UUID().uuidString

    /// Identifying information for the element, like its name and classification.
    let label: KYElementLabel

    /// The frame of the element in its parent's coordinate space.
    let frame: CGRect

    /// Whether the element is hidden from view or not.
    let isHidden: Bool

    /// A snapshot image of the element in its current state.
    let snapshotImage: CGImage?

    /// The child snapshots of the snapshot (one per child element).
    let children: [KYSnapshot]

    /// The element used to create the snapshot.
    let element: KYElement

    /// Constructs a new `Snapshot`
    ///
    /// - Parameter element: The element to construct the snapshot from. The
    /// data stored in the snapshot will be the data provided by the element
    /// at the time that this constructor is called.
    init(element: KYElement) {
        self.label = element.label
        self.frame = element.frame
        self.isHidden = element.isHidden
        self.snapshotImage = element.snapshotImage
        self.children = element.children.map { KYSnapshot(element: $0) }
        self.element = element
    }
}
