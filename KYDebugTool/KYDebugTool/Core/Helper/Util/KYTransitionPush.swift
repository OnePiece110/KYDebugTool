//
//  KYTransitionPush.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import UIKit

final class KYTransitionPush: NSObject, UIViewControllerAnimatedTransitioning {
    var transitionCtx: UIViewControllerContextTransitioning?

    func transitionDuration(using _: UIViewControllerContextTransitioning?)
        -> TimeInterval {
        KYContants.animationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        transitionCtx = transitionContext

        guard
            let fromVC = transitionContext.viewController(
                forKey: UITransitionContextViewControllerKey.from
            ),
            let toVC = transitionContext.viewController(
                forKey: UITransitionContextViewControllerKey.to
            )
        else {
            return
        }

        let containerView = transitionContext.containerView
        containerView.addSubview(fromVC.view)
        containerView.addSubview(toVC.view)

        let ballRect = KYFloatViewManager.shared.ballView.frame
        let startAnimationPath = UIBezierPath(
            roundedRect: ballRect,
            cornerRadius: ballRect.size.height / 2
        )
        let endAnimationPath = UIBezierPath(
            roundedRect: toVC.view.bounds,
            cornerRadius: 0.1
        )

        let maskLayer = CAShapeLayer()
        maskLayer.path = endAnimationPath.cgPath
        toVC.view.layer.mask = maskLayer

        let basicAnimation = CABasicAnimation(keyPath: "path")
        basicAnimation.fromValue = startAnimationPath.cgPath
        basicAnimation.toValue = endAnimationPath.cgPath
        basicAnimation.delegate = self
        basicAnimation.duration = KYContants.animationDuration
        basicAnimation.timingFunction = CAMediaTimingFunction(
            name: CAMediaTimingFunctionName.linear
        )
        maskLayer.add(basicAnimation, forKey: "pathAnimation")
        /// Hidden ball
        if KYFloatViewManager.shared.ballView.changeStatusInNextTransaction {
            KYFloatViewManager.shared.ballView.show = false
        } else {
            KYFloatViewManager.shared.ballView.changeStatusInNextTransaction = true
        }
    }
}

// MARK: - Animation end callback

extension KYTransitionPush: CAAnimationDelegate {
    func animationDidStop(_: CAAnimation, finished _: Bool) {
        transitionCtx?.completeTransition(true)
        transitionCtx?.view(forKey: UITransitionContextViewKey.from)?.layer.mask = nil
        transitionCtx?.view(forKey: UITransitionContextViewKey.to)?.layer.mask = nil
    }
}
