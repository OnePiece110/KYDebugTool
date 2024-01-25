//
//  KYElement.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/24.
//

import Foundation
import CoreGraphics

/// Provides identifying information for an element that is displayed in the
/// view debugger.
final class KYElementLabel: NSObject {
    /// Classification for an element that determines how it is represented
    /// in the view debugger.
    enum Classification: Int {
        /// An element of normal importance.
        case normal

        /// An element of higher importance that is highlighted
        case important
    }

    /// A human readable name for the element.
    let name: String?

    /// Classification for an element that determines how it is represented
    /// in the view debugger.
    let classification: Classification

    /// Constructs a new `Element`
    ///
    /// - Parameters:
    ///   - name: A human readable name for the element
    ///   - classification: Classification for an element that determines how it
    /// is represented in the view debugger.
    init(name: String?, classification: Classification = .normal) {
        self.name = name
        self.classification = classification
    }
}

/// A UI element that can be snapshotted.
protocol KYElement {
    /// Identifying information for the element, like its name and classification.
    var label: KYElementLabel { get }

    /// A shortened description of the element.
    var shortDescription: String { get }

    /// The full length description of the element.
    var title: String { get }

    /// The full length description of the element.
    var description: String { get }

    /// The frame of the element in its parent's coordinate space.
    var frame: CGRect { get }

    /// Whether the element is hidden from view or not.
    var isHidden: Bool { get }

    /// A snapshot image of the element in its current state.
    var snapshotImage: CGImage? { get }

    /// The child elements of the element.
    var children: [KYElement] { get }
}
