//
//  KYInAppViewDebugger.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/24.
//

import UIKit

/// Exposes APIs for presenting the view debugger.
final class KYInAppViewDebugger: NSObject {
    /// Takes a snapshot of the application's key window and presents the debugger
    /// view controller from the root view controller.
    class func present() {
        presentForWindow(UIWindow.currentWindow)
    }

    /// Takes a snapshot of the specified window and presents the debugger view controller
    /// from the root view controller.
    ///
    /// - Parameters:
    ///   - window: The view controller whose view should be snapshotted.
    ///   - configuration: Optional configuration for the view debugger.
    ///   - completion: Completion block to be called once the view debugger has
    ///   been presented.
    class func presentForWindow(
        _ window: UIWindow?,
        configuration: KYConfiguration? = nil,
        completion: (() -> Void)? = nil
    ) {
        guard let window = window else {
            return
        }

        let snapshot = KYSnapshot(element: KYViewElement(view: window))
        presentWithSnapshot(
            snapshot,
            rootViewController: window.rootViewController,
            configuration: configuration,
            completion: completion
        )
    }

    /// Takes a snapshot of the specified view and presents the debugger view controller
    /// from the nearest ancestor view controller.
    ///
    /// - Parameters:
    ///   - view: The view controller whose view should be snapshotted.
    ///   - configuration: Optional configuration for the view debugger.
    ///   - completion: Completion block to be called once the view debugger has
    ///   been presented.
    class func presentForView(
        _ view: UIView?,
        configuration: KYConfiguration? = nil,
        completion: (() -> Void)? = nil
    ) {
        guard let view = view else {
            return
        }
        let snapshot = KYSnapshot(element: KYViewElement(view: view))
        presentWithSnapshot(snapshot, rootViewController: getNearestAncestorViewController(responder: view), configuration: configuration, completion: completion)
    }

    /// Takes a snapshot of the view of the specified view controller and presents
    /// the debugger view controller.
    ///
    /// - Parameters:
    ///   - viewController: The view controller whose view should be snapshotted.
    ///   - configuration: Optional configuration for the view debugger.
    ///   - completion: Completion block to be called once the view debugger has
    ///   been presented.
    class func presentForViewController(_ viewController: UIViewController?, configuration: KYConfiguration? = nil, completion: (() -> Void)? = nil) {
        guard let view = viewController?.view else {
            return
        }
        let snapshot = KYSnapshot(element: KYViewElement(view: view))
        presentWithSnapshot(snapshot, rootViewController: viewController, configuration: configuration, completion: completion)
    }

    /// Presents a view debugger for the a snapshot as a modal view controller on
    /// top of the specified root view controller.
    ///
    /// - Parameters:
    ///   - snapshot: The snapshot to render.
    ///   - rootViewController: The root view controller to present the debugger view
    ///   controller from.
    ///   - configuration: Optional configuration for the view debugger.
    ///   - completion: Completion block to be called once the view debugger has
    ///   been presented.
    class func presentWithSnapshot(
        _ snapshot: KYSnapshot,
        rootViewController: UIViewController?,
        configuration: KYConfiguration? = nil,
        completion: (() -> Void)? = nil
    ) {
        guard let rootViewController = rootViewController else {
            return
        }
        let debuggerViewController = KYViewDebuggerViewController(
            snapshot: snapshot,
            configuration: configuration ?? KYConfiguration()
        )
        let navigationController = UINavigationController(rootViewController: debuggerViewController)
        navigationController.modalPresentationStyle = .fullScreen
        KYWindowManager.rootNavigation?.present(
            navigationController,
            animated: true,
            completion: completion
        )
    }

    @available(*, unavailable)
    override init() {
        fatalError()
    }
}
