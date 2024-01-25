//
//  KYFloatViewManager.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/24.
//

import UIKit

final class KYFloatViewManager: NSObject {

    static let shared = KYFloatViewManager()

    let bottomFloatView = KYBottomFloatView()
    let ballView = KYFloatBallView()
    let ballRedCancelView = KYBottomFloatView()

    private(set) var floatViewController: UIViewController?

    override required init() {
        super.init()
        KYWindowManager.rootNavigation?.delegate = self

        setup()
        setupClickEvent()
        observers()
    }

    static func setup(_ viewController: UIViewController) {
        shared.floatViewController = viewController
    }

    static func animate(success: Bool) {
        shared.ballView.animate(success: success)
    }

    static func reset() {
        shared.ballView.reset()
    }

    static func isShowing() -> Bool {
        shared.ballView.isShowing
    }

    static func show() {
        shared.ballView.show = true
    }

    static func remove() {
        shared.ballView.show = false
    }

    static func toggle() {
        KYFloatViewManager.shared.ballView.show.toggle()
    }

    static var isShowingDebuggerView = false {
        didSet {
            shared.ballView.isHidden = isShowingDebuggerView
        }
    }

    func observers() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "reloadHttp_DebugSwift"),
            object: nil,
            queue: .main
        ) { notification in
            if let success = notification.object as? Bool {
                Self.animate(success: success)
            }
        }
    }
}

extension KYFloatViewManager {
    private func setup() {
        bottomFloatView.frame = .init(
            x: KYContants.screenWidth, y: KYContants.screenHeight,
            width: KYContants.bottomViewFloatWidth, height: KYContants.bottomViewFloatHeight
        )
        KYWindowManager.window.addSubview(bottomFloatView)

        ballRedCancelView.frame = .init(
            x: KYContants.screenWidth, y: KYContants.screenHeight,
            width: KYContants.bottomViewFloatWidth, height: KYContants.bottomViewFloatHeight
        )
        ballRedCancelView.type = KYBottomFloatViewType.red
        KYWindowManager.window.addSubview(ballRedCancelView)

        ballView.frame = KYContants.ballRect
        ballView.delegate = self
    }

    private func setupClickEvent() {
        ballView.ballDidSelect = {
            KYWindowManager.presentDebugger()
        }
    }
}

extension KYFloatViewManager: UINavigationControllerDelegate {
    func navigationController(
        _: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            guard toVC == floatViewController else { return nil }
            return KYTransitionPush()
        } else if operation == .pop {
            guard fromVC == floatViewController else { return nil }
            return KYTransitionPop()
        } else {
            return nil
        }
    }
}

extension KYFloatViewManager: KYFloatViewDelegate {
    func floatViewBeginMove(floatView _: KYFloatBallView, point _: CGPoint) {
        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.ballRedCancelView.frame = CGRect(
                    x: KYContants.screenWidth - KYContants.bottomViewFloatWidth,
                    y: KYContants.screenHeight - KYContants.bottomViewFloatHeight,
                    width: KYContants.bottomViewFloatWidth,
                    height: KYContants.bottomViewFloatHeight
                )
            }
        ) { _ in }
    }

    func floatViewMoved(floatView _: KYFloatBallView, point _: CGPoint) {
        let transformBottomP = KYWindowManager.window.convert(
            ballView.center,
            to: ballRedCancelView
        )

        if transformBottomP.x > .zero, transformBottomP.y > .zero {
            let arcCenter = CGPoint(
                x: KYContants.bottomViewFloatWidth,
                y: KYContants.bottomViewFloatHeight
            )
            let distance =
                pow(transformBottomP.x - arcCenter.x, 2) + pow(transformBottomP.y - arcCenter.y, 2)
            let onArc = pow(arcCenter.x, 2)

            if distance <= onArc {
                if !ballRedCancelView.insideBottomSelected {
                    ballRedCancelView.insideBottomSelected = true
                }
            } else {
                if ballRedCancelView.insideBottomSelected {
                    ballRedCancelView.insideBottomSelected = false
                }
            }
        } else {
            if ballRedCancelView.insideBottomSelected {
                ballRedCancelView.insideBottomSelected = false
            }
        }
    }

    func floatViewCancelMove(floatView _: KYFloatBallView) {
        if ballRedCancelView.insideBottomSelected {
            ballView.show = false
        }

        UIView.animate(
            withDuration: KYContants.animationCancelMoveDuration,
            animations: {
                self.ballRedCancelView.frame = .init(
                    x: KYContants.screenWidth,
                    y: KYContants.screenHeight,
                    width: KYContants.bottomViewFloatWidth,
                    height: KYContants.bottomViewFloatHeight
                )
            }
        ) { _ in }
    }
}
