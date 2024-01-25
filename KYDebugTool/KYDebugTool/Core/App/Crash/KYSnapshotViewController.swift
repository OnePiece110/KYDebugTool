//
//  KYSnapshotViewController.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import UIKit

final class KYSnapshotViewController: KYBaseController {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    init(image: UIImage) {
        imageView.image = image
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = "Snapshot"
        view.backgroundColor = .black

        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            imageView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),
            imageView.topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: 200
            ),
            imageView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -100
            )
        ])

        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
    }
}
