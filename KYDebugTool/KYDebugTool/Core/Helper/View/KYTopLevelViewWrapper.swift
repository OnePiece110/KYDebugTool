//
//  KYTopLevelViewWrapper.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/24.
//

import UIKit

class KYTopLevelViewWrapper: UIView {
    func toggle(with newValue: Bool) {
        if newValue {
            showWidgetWindow()
        }

        UIView.animate(
            withDuration: 0.35,
            animations: {
                self.alpha = newValue ? 1.0 : 0.0
            }
        ) { _ in
            self.isHidden = !newValue
            if !newValue {
                self.removeWidgetWindow()
            }
        }
    }

    func showWidgetWindow() {
        KYWindowManager.window.rootViewController?.view.addSubview(self)
        alpha = .zero
        UIView.animate(withDuration: 0.35) { self.alpha = 1.0 }
    }

    func removeWidgetWindow() {
        removeFromSuperview()
    }
}
