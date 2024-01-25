//
//  KYGridOverlayColorScheme.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/24.
//

import UIKit

final class KYGridOverlayColorScheme: Equatable {
    static func == (lhs: KYGridOverlayColorScheme, rhs: KYGridOverlayColorScheme) -> Bool {
        lhs.primaryColor == rhs.primaryColor && rhs.secondaryColor == lhs.secondaryColor
    }

    // MARK: - Properties

    private(set) var primaryColor: UIColor
    private(set) var secondaryColor: UIColor

    // MARK: - Initialization

    init(primaryColor: UIColor, secondaryColor: UIColor) {
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
    }

    class func colorScheme(
        withPrimaryColor primaryColor: UIColor,
        secondaryColor: UIColor
    ) -> KYGridOverlayColorScheme {
        KYGridOverlayColorScheme(primaryColor: primaryColor, secondaryColor: secondaryColor)
    }
}
