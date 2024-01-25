//
//  KYLogsViewController.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import UIKit

final class KYLogsViewController: KYBaseController {

    private let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = .white
        textView.font = .systemFont(ofSize: 10)
        return textView
    }()

    init(text: String) {
        textView.text = text
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Logs"
        view.backgroundColor = .black

        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            textView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),
            textView.topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: 200
            ),
            textView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -100
            )
        ])
    }
}
