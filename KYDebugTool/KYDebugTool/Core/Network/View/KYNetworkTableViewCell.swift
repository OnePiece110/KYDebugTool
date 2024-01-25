//
//  KYNetworkTableViewCell.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import UIKit

final class KYNetworkTableViewCell: UITableViewCell {
    let methodLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(
            ofSize: 17,
            weight: .bold
        )
        label.textColor = .gray
        return label
    }()

    let numberLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(
            ofSize: 18,
            weight: .medium
        )
        label.textColor = .white
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.layer.cornerRadius = 1
        label.layer.borderWidth = 0
        return label
    }()

    let statusCodeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(
            ofSize: 17,
            weight: .bold
        )
        label.textColor = .green
        label.textAlignment = .center
        return label
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(
            ofSize: 13
        )
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(
            ofSize: 12,
            weight: .semibold
        )
        label.textColor = .white
        label.textColor = .green
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    func setup(_ model: KYHttpModel) {
        methodLabel.text = "[\(model.method ?? "")]"
        numberLabel.text = model.id
        statusCodeLabel.text = model.statusCode
        descriptionLabel.text = model.url?.absoluteString
        timestampLabel.text = model.startTime

        let textColor: UIColor
        if model.isSuccess {
            textColor = .green
        } else {
            textColor = .red
        }
        numberLabel.textColor = textColor
        statusCodeLabel.textColor = textColor
        timestampLabel.textColor = textColor
    }

    private func setupUI() {
        setupViews()
        setupConstraints()
    }

    func setupViews() {
        contentView.addSubview(methodLabel)
        contentView.addSubview(numberLabel)
        contentView.addSubview(statusCodeLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(timestampLabel)

        contentView.backgroundColor = .black
        backgroundColor = .black
        selectionStyle = .none
    }

    func setupConstraints() {
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            numberLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 8),
            numberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            numberLabel.widthAnchor.constraint(equalToConstant: 40)
        ])

        methodLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            methodLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            methodLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)
        ])

        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timestampLabel.leadingAnchor.constraint(equalTo: methodLabel.trailingAnchor, constant: 8),

            timestampLabel.centerYAnchor.constraint(equalTo: methodLabel.centerYAnchor)
        ])

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: methodLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: numberLabel.trailingAnchor, constant: 4),
            descriptionLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -60
            ),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])

        statusCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statusCodeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusCodeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
}
