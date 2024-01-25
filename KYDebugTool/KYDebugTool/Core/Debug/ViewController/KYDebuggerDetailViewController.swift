//
//  KYDebuggerDetailViewController.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import UIKit

final class KYDebuggerDetailViewController: UIViewController {

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    init(snapshot: KYSnapshot) {
        super.init(nibName: nil, bundle: nil)
        title = snapshot.element.title
        textView.text = snapshot.element.description
        if let cgImage = snapshot.snapshotImage {
            imageView.image =  .init(cgImage: cgImage).outline()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        // Adiciona a UIImageView
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
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 20
            ),
            imageView.heightAnchor.constraint(
                equalTo: view.heightAnchor,
                multiplier: 1/3
            )
        ])

        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            textView.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
