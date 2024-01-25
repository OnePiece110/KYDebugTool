//
//  KYDebugSnapshotViewController.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/24.
//

import UIKit

protocol KYDebugSnapshotViewControllerDelegate: AnyObject {
    func debugSnapshotViewController(_ viewController: KYDebugSnapshotViewController, didSelectSnapshot snapshot: KYSnapshot)
    func debugSnapshotViewController(_ viewController: KYDebugSnapshotViewController, didDeselectSnapshot snapshot: KYSnapshot)
    func debugSnapshotViewController(_ viewController: KYDebugSnapshotViewController, didFocusOnSnapshot snapshot: KYSnapshot)
    func debugSnapshotViewControllerWillNavigateBackToPreviousSnapshot(_ viewController: KYDebugSnapshotViewController)
}

/// View controller that renders a 3D snapshot view using SceneKit.
final class KYDebugSnapshotViewController: UIViewController, KYSnapshotViewDelegate, KYDebugSnapshotViewControllerDelegate {
    private let snapshot: KYSnapshot
    private let configuration: KYSnapshotViewConfiguration

    private var snapshotView: KYSnapshotView?
    weak var delegate: KYDebugSnapshotViewControllerDelegate?

    init(
        snapshot: KYSnapshot,
        configuration: KYSnapshotViewConfiguration = KYSnapshotViewConfiguration(),
        delegate: KYDebugSnapshotViewControllerDelegate?
    ) {
        self.snapshot = snapshot
        self.configuration = configuration
        self.delegate = delegate

        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .black
        navigationItem.title = snapshot.element.label.name
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    override func loadView() {
        let snapshotView = KYSnapshotView(snapshot: snapshot, configuration: configuration)
        snapshotView.delegate = self
        self.snapshotView = snapshotView
        self.view = snapshotView
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            snapshotView?.deselectAll()
            delegate?.debugSnapshotViewControllerWillNavigateBackToPreviousSnapshot(self)
        }
    }

    // MARK: API

    func select(snapshot: KYSnapshot) {
        let topViewController = topDebugSnapshotViewController()
        if topViewController == self {
            snapshotView?.select(snapshot: snapshot)
        } else {
            topViewController.select(snapshot: snapshot)
        }
    }

    func deselect(snapshot: KYSnapshot) {
        let topViewController = topDebugSnapshotViewController()
        if topViewController == self {
            snapshotView?.deselect(snapshot: snapshot)
        } else {
            topViewController.deselect(snapshot: snapshot)
        }
    }

    func focus(snapshot: KYSnapshot) {
        focus(snapshot: snapshot, callDelegate: false)
    }

    // MARK: SnapshotViewDelegate

    func snapshotView(_ snapshotView: KYSnapshotView, didSelectSnapshot snapshot: KYSnapshot) {
        delegate?.debugSnapshotViewController(self, didSelectSnapshot: snapshot)
    }

    func snapshotView(_ snapshotView: KYSnapshotView, didDeselectSnapshot snapshot: KYSnapshot) {
        delegate?.debugSnapshotViewController(self, didDeselectSnapshot: snapshot)
    }

    func snapshotView(_ snapshotView: KYSnapshotView, didLongPressSnapshot snapshot: KYSnapshot, point: CGPoint) {
        let actionSheet = makeActionSheet(snapshot: snapshot, sourceView: snapshotView, sourcePoint: point) { snapshot in
            self.focus(snapshot: snapshot, callDelegate: true)
        }
        present(actionSheet, animated: true, completion: nil)
    }

    func snapshotView(_ snapshotView: KYSnapshotView, showAlertController alertController: UIAlertController) {
        present(alertController, animated: true, completion: nil)
    }

    // MARK: DebugSnapshotViewControllerDelegate

    func debugSnapshotViewController(_ viewController: KYDebugSnapshotViewController, didSelectSnapshot snapshot: KYSnapshot) {
        delegate?.debugSnapshotViewController(self, didSelectSnapshot: snapshot)
    }

    func debugSnapshotViewController(_ viewController: KYDebugSnapshotViewController, didDeselectSnapshot snapshot: KYSnapshot) {
        delegate?.debugSnapshotViewController(self, didDeselectSnapshot: snapshot)
    }

    func debugSnapshotViewController(_ viewController: KYDebugSnapshotViewController, didFocusOnSnapshot snapshot: KYSnapshot) {
        delegate?.debugSnapshotViewController(self, didFocusOnSnapshot: snapshot)
    }

    func debugSnapshotViewControllerWillNavigateBackToPreviousSnapshot(_ viewController: KYDebugSnapshotViewController) {
        delegate?.debugSnapshotViewControllerWillNavigateBackToPreviousSnapshot(self)
    }

    // MARK: Private

    private func focus(snapshot: KYSnapshot, callDelegate: Bool) {
        let topViewController = topDebugSnapshotViewController()
        if topViewController == self {
            snapshotView?.deselectAll()
            let subtreeViewController = Self(
                snapshot: snapshot,
                configuration: configuration,
                delegate: self
            )
            navigationController?.pushViewController(subtreeViewController, animated: true)
            if callDelegate {
                delegate?.debugSnapshotViewController(self, didFocusOnSnapshot: snapshot)
            }
        } else {
            topViewController.focus(snapshot: snapshot)
        }
    }

    private func topDebugSnapshotViewController() -> KYDebugSnapshotViewController {
        if let DebugSnapshotViewController = navigationController?.topViewController as? KYDebugSnapshotViewController {
            return DebugSnapshotViewController
        }
        return self
    }
}
