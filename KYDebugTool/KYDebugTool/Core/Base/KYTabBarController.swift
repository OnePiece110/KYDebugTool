//
//  KYTabBarController.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/24.
//

import UIKit

class KYTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        configureNavigation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: KYContants.animationDuration) {
            KYWindowManager.showNavigationBar()
        }
    }

    private func configureTabBar() {
        let controllers: [UIViewController] = [
            KYNetworkViewController(),
//            PerformanceViewController(),
//            InterfaceViewController(),
//            ResourcesViewController(),
            KYAppViewController()
        ]

        viewControllers = controllers.map {
            UINavigationController(rootViewController: $0)
        }

        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = .gray
        tabBar.setBackgroundColor(color: .black)
        tabBar.addTopBorderWithColor(color: .gray, thickness: 0.3)
        overrideUserInterfaceStyle = .dark
    }

    private func configureNavigation() {
        navigationItem.hidesBackButton = true
        addRightBarButton(
            image: .named(
                "arrow.down.right.and.arrow.up.left",
                default: "Close"
            ),
            tintColor: .white
        ) { [weak self] in
            self?.closeButtonTapped()
        }
    }

    @objc private func closeButtonTapped() {
        KYWindowManager.removeDebugger()
    }
}
