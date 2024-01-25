//
//  UITableViewCell+.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import UIKit

extension UITableViewCell {
    func setup(
        title: String,
        subtitle: String? = nil,
        description: String? = nil,
        image: UIImage? = .named("chevron.right", default: "→"),
        scale: CGFloat = 1
    ) {
        
        subviews.filter { $0.tag == 111 }.forEach { $0.removeFromSuperview() }

        accessoryView = nil

        textLabel?.text = title
        textLabel?.textColor = .white
        textLabel?.numberOfLines = 0
        textLabel?.font = .systemFont(ofSize: 16 * scale)

        if let subtitle, !subtitle.isEmpty {
            textLabel?.setAttributedText(title: title, subtitle: subtitle, scale: scale)
        }

        backgroundColor = .clear
        selectionStyle = .none

        if let image {
            let disclosureIndicator = UIImageView(image: image)
            disclosureIndicator.tintColor = .white
            accessoryView = disclosureIndicator
        } else if let description {
            let label = UILabel()
            label.text = description
            label.textColor = .darkGray
            label.numberOfLines = 0
            label.textAlignment = .right
            label.translatesAutoresizingMaskIntoConstraints = false
            label.tag = 111
            addSubview(label)

            NSLayoutConstraint.activate([
                label.centerYAnchor.constraint(equalTo: centerYAnchor),
                label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: UIScreen.main.bounds.width / 2)
            ])
        }

        sizeToFit()
    }
}
