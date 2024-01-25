//
//  KYWindowManager.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/24.
//

import Foundation
import UIKit

enum KYWindowManager {
    static var isSelectingWindow: Bool = false
    static var rootNavigation: UINavigationController? {
        window.rootViewController as? UINavigationController
    }

    static let window: KYCustomWindow = {
        let window: KYCustomWindow
        if #available(iOS 13.0, *),
           let scene = UIWindow.currentWindow?.windowScene {
            window = KYCustomWindow(windowScene: scene)
        } else {
            window = KYCustomWindow(frame: UIScreen.main.bounds)
        }
        window.windowLevel = .alert + 1

        let navigation = UINavigationController(rootViewController: UIViewController())
        navigation.setBackgroundColor(color: .clear)
        window.rootViewController = navigation
        window.isHidden = false
        return window
    }()

    static func presentDebugger() {
        guard !KYFloatViewManager.isShowingDebuggerView else { return }
        KYFloatViewManager.isShowingDebuggerView = true
        if let viewController = KYFloatViewManager.shared.floatViewController {
            // Prevent clicks
            UIApplication.shared.beginIgnoringInteractionEvents()
            // Remove keyboard, if opened.
            UIWindow.currentWindow?.endEditing(true)

            rootNavigation?.pushViewController(
                viewController,
                animated: true
            )
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }

    static func removeDebugger() {
        KYFloatViewManager.isShowingDebuggerView = false
        removeNavigationBar()
        rootNavigation?.popViewController(animated: true)
    }

    static func showNavigationBar() {
        rootNavigation?.setBackgroundColor()
    }

    static func removeNavigationBar() {
        rootNavigation?.setBackgroundColor(color: .clear)
    }

    static func presentViewDebugger() {
        guard !KYFloatViewManager.isShowingDebuggerView else { return }
        KYFloatViewManager.isShowingDebuggerView = true

        let alertController = UIAlertController(
            title: "Select a Window",
            message: nil,
            preferredStyle: .actionSheet
        )

        let filteredWindows = UIApplication.shared.windows.filter { window in
            String(describing: type(of: window)) != "UITextEffectsWindow"
            && window.windowLevel < UIWindow.Level.alert
        }

        guard filteredWindows.count > 1 else {
            KYInAppViewDebugger.presentForWindow(filteredWindows.first)
            return
        }

        // Add an action for each window
        for window in filteredWindows {
            let className = NSStringFromClass(type(of: window))
            let moduleName = Bundle(for: type(of: window)).bundleIdentifier ?? "Unknown Module"

            let actionTitle = "\(className) - \(moduleName)"
            let action = UIAlertAction(title: actionTitle, style: .default) { _ in
                // Handle the selected window here
                isSelectingWindow = false
                KYInAppViewDebugger.presentForWindow(window)
            }
            alertController.addAction(action)
        }

        // Add a cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            isSelectingWindow = false
            removeViewDebugger()
        }
        alertController.addAction(cancelAction)

        // Present the UIAlertController
        isSelectingWindow = true
        rootNavigation?.present(alertController, animated: true)
    }

    static func removeViewDebugger() {
        KYFloatViewManager.isShowingDebuggerView = false
        rootNavigation?.dismiss(animated: true)
    }
}

final class KYCustomWindow: UIWindow {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if KYWindowManager.isSelectingWindow { return true }

        let ballView = KYFloatViewManager.shared.ballView
        if
            ballView.point(inside: convert(point, to: ballView), with: event) ||
            KYFloatViewManager.isShowingDebuggerView
        {
            return true
        }

        return false
    }
}
