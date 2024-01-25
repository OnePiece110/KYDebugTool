//
//  KYTouchIndicatorView.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/24.
//

import UIKit

final class KYTouchIndicatorView: UIView {
    enum Constants {
        static let size = CGSize(width: 40.0, height: 40.0)
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    class func indicatorView() -> KYTouchIndicatorView {
        KYTouchIndicatorView(
            frame: CGRect(origin: .zero, size: Constants.size)
        )
    }

    private func setupView() {
        backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.7)
        layer.borderColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.7).cgColor
        layer.borderWidth = 1.0 / UIScreen.main.scale
        layer.zPosition = .greatestFiniteMagnitude
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOpacity = 0.7
        layer.shadowRadius = 3.0
        layer.shadowOffset = CGSize(width: 4.0, height: 4.0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(frame.size.width, frame.size.height) / 2
    }
}
