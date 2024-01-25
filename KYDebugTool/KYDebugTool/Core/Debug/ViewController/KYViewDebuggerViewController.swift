//
//  KYViewDebuggerViewController.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/24.
//

import UIKit

final class KYViewDebuggerViewController:
    UIViewController,
    KYDebugSnapshotViewControllerDelegate,
    KYHierarchyTableViewControllerDelegate {
    private let snapshot: KYSnapshot
    private let configuration: KYConfiguration

    private var pageViewController: UIPageViewController?

    private lazy var debugSnapshotViewController: KYDebugSnapshotViewController = { [unowned self] in
        return .init(
            snapshot: snapshot,
            configuration: configuration.snapshotViewConfiguration,
            delegate: self
        )
    }()

    private lazy var snapshotNavigationController: UINavigationController = {
        let navigationController = UINavigationController(
            rootViewController: debugSnapshotViewController
        )
        navigationController.navigationBar.isHidden = false
        navigationController.title = NSLocalizedString(
            "Snapshot",
            comment: "The title for the Snapshot tab"
        )
        return navigationController
    }()

    private lazy var hierarchyViewController: KYHierarchyTableViewController = {
        let viewController = KYHierarchyTableViewController(
            snapshot: snapshot,
            configuration: configuration.hierarchyViewConfiguration
        )
        viewController.delegate = self
        return viewController
    }()

    private lazy var hierarchyNavigationController: UINavigationController = {
        let navigationController = UINavigationController(
            rootViewController: hierarchyViewController
        )
        navigationController.navigationBar.isHidden = false
        navigationController.title = NSLocalizedString(
            "Hierarchy",
            comment: "The title for the Hierarchy tab"
        )

        return navigationController
    }()

    init(snapshot: KYSnapshot, configuration: KYConfiguration = KYConfiguration()) {
        self.snapshot = snapshot
        self.configuration = configuration

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if traitCollection.userInterfaceIdiom == .phone {
            configureSegmentedControl()
            configurePageViewController()
        } else {
            navigationItem.title = snapshot.element.shortDescription
            configureSplitViewController()
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done(sender:)))
    }

    // MARK: DebugSnapshotViewControllerDelegate

    func debugSnapshotViewController(_ viewController: KYDebugSnapshotViewController, didSelectSnapshot snapshot: KYSnapshot) {
        hierarchyViewController.selectRow(forSnapshot: snapshot)
    }

    func debugSnapshotViewController(_ viewController: KYDebugSnapshotViewController, didDeselectSnapshot snapshot: KYSnapshot) {
        hierarchyViewController.deselectRow(forSnapshot: snapshot)
    }

    func debugSnapshotViewController(_ viewController: KYDebugSnapshotViewController, didFocusOnSnapshot snapshot: KYSnapshot) {
        hierarchyNavigationController.popToRootViewController(animated: false)
        hierarchyViewController.focus(snapshot: snapshot)
    }

    func debugSnapshotViewControllerWillNavigateBackToPreviousSnapshot(_ viewController: KYDebugSnapshotViewController) {
        hierarchyNavigationController.popViewController(animated: true)
    }

    // MARK: HierarchyTableViewControllerDelegate

    func hierarchyTableViewController(_ viewController: KYHierarchyTableViewController, didSelectSnapshot snapshot: KYSnapshot) {
        debugSnapshotViewController.select(snapshot: snapshot)
    }

    func hierarchyTableViewController(_ viewController: KYHierarchyTableViewController, didDeselectSnapshot snapshot: KYSnapshot) {
        debugSnapshotViewController.deselect(snapshot: snapshot)
    }

    func hierarchyTableViewController(_ viewController: KYHierarchyTableViewController, didFocusOnSnapshot snapshot: KYSnapshot) {
        debugSnapshotViewController.focus(snapshot: snapshot)
    }

    func hierarchyTableViewControllerWillNavigateBackToPreviousSnapshot(_ viewController: KYHierarchyTableViewController) {
        snapshotNavigationController.popViewController(animated: true)
    }

    // MARK: Private

    private func configurePageViewController() {
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        showChildViewController(pageViewController)
        self.pageViewController = pageViewController
        selectViewController(index: .zero)
    }

    private func configureSplitViewController() {
        let splitViewController = UISplitViewController(nibName: nil, bundle: nil)
        splitViewController.viewControllers = [
            hierarchyNavigationController,
            snapshotNavigationController
        ]
        showChildViewController(splitViewController)
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
    }

    private func showChildViewController(_ childViewController: UIViewController) {
        addChild(childViewController)

        if let childView = childViewController.view {
            childView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(childView)
            NSLayoutConstraint.activate([
                childView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                childView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                childView.topAnchor.constraint(equalTo: view.topAnchor),
                childView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }

        childViewController.didMove(toParent: self)
    }

    private func configureSegmentedControl() {
        let segmentedControl = UISegmentedControl(items: [
            NSLocalizedString("Snapshot", comment: "The title for the Snapshot tab"),
            NSLocalizedString("Hierarchy", comment: "The title for the Hierarchy tab")
        ])
        segmentedControl.sizeToFit()
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged(sender:)), for: .valueChanged)
        navigationItem.title = nil
        navigationItem.titleView = segmentedControl
    }

    private func selectViewController(index: Int) {
        guard let pageViewController = pageViewController else {
            return
        }
        switch index {
        case 0:
            pageViewController.setViewControllers([snapshotNavigationController], direction: .reverse, animated: false, completion: nil)
        case 1:
            pageViewController.setViewControllers([hierarchyNavigationController], direction: .forward, animated: false, completion: nil)
        default:
            fatalError("Invalid view controller index \(index)")
            break
        }
    }

    // MARK: Actions

    @objc private func segmentChanged(sender: UISegmentedControl) {
        selectViewController(index: sender.selectedSegmentIndex)
    }

    @objc private func done(sender: UIBarButtonItem) {
        KYFloatViewManager.isShowingDebuggerView = false
        dismiss(animated: true)
    }
}
