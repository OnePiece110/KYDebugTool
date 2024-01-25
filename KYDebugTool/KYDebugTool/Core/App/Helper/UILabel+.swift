//
//  UILabel+.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import UIKit

extension UILabel {
    func setAttributedText(title: String, subtitle: String, scale: CGFloat) {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16 * scale)
        ]

        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12 * scale),
            .foregroundColor: UIColor.lightGray
        ]

        let attributedString = NSMutableAttributedString()

        let titleAttributedString = NSAttributedString(string: title, attributes: titleAttributes)
        attributedString.append(titleAttributedString)

        attributedString.append(NSAttributedString(string: "\n"))

        let subtitleAttributedString = NSAttributedString(
            string: subtitle, attributes: subtitleAttributes
        )
        attributedString.append(subtitleAttributedString)

        attributedText = attributedString
        numberOfLines = 0
    }
}
