//
//  KYMenuSwitchTableViewCell.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import UIKit

protocol KYMenuSwitchTableViewCellDelegate: AnyObject {
    func menuSwitchTableViewCell(_ cell: KYMenuSwitchTableViewCell, didSetOn isOn: Bool)
}

final class KYMenuSwitchTableViewCell: UITableViewCell {
    weak var delegate: KYMenuSwitchTableViewCellDelegate?

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var valueSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)

        if #available(iOS 13.0, *) {
            switchControl.overrideUserInterfaceStyle = .dark
        }
        switchControl.thumbTintColor = .white

        return switchControl
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueSwitch)
        contentView.backgroundColor = .black
        backgroundColor = .black
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            valueSwitch.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16
            ),
            valueSwitch.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    @objc func switchValueChanged(_ sender: UISwitch) {
        delegate?.menuSwitchTableViewCell(self, didSetOn: sender.isOn)
    }
}

extension KYMenuSwitchTableViewCell {
    static let identifier = "MenuSwitchTableViewCell"
}

