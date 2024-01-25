//
//  KYTransitionPop.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import UIKit

final class KYTransitionPop: NSObject, UIViewControllerAnimatedTransitioning {
    var transitionCtx: UIViewControllerContextTransitioning?

    func transitionDuration(using _: UIViewControllerContextTransitioning?)
        -> TimeInterval {
        KYContants.animationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        transitionCtx = transitionContext

        guard let fromVC = transitionContext.viewController(
            forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        else {
            return
        }

        let containerView = transitionContext.containerView
        containerView.addSubview(toVC.view)
        containerView.addSubview(fromVC.view)

        let ballRect = KYFloatViewManager.shared.ballView.frame
        let startAnimationPath = UIBezierPath(roundedRect: toVC.view.bounds, cornerRadius: 0.1)
        let endAnimationPath = UIBezierPath(
            roundedRect: ballRect, cornerRadius: ballRect.size.height / 2
        )

        let maskLayer = CAShapeLayer()
        maskLayer.path = endAnimationPath.cgPath
        fromVC.view.layer.mask = maskLayer

        let basicAnimation = CABasicAnimation(keyPath: "path")
        basicAnimation.fromValue = startAnimationPath.cgPath
        basicAnimation.toValue = endAnimationPath.cgPath
        basicAnimation.delegate = self
        basicAnimation.duration = KYContants.animationDuration
        basicAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        maskLayer.add(basicAnimation, forKey: "pathAnimation")
    }
}

// MARK: - Animation end callback

extension KYTransitionPop: CAAnimationDelegate {
    func animationDidStop(_: CAAnimation, finished _: Bool) {
        transitionCtx?.completeTransition(true)
        transitionCtx?.view(forKey: UITransitionContextViewKey.from)?.layer.mask = nil
        transitionCtx?.view(forKey: UITransitionContextViewKey.to)?.layer.mask = nil
        /// Show ball
        if KYFloatViewManager.shared.ballView.changeStatusInNextTransaction {
            KYFloatViewManager.shared.ballView.show = true
        } else {
            KYFloatViewManager.shared.ballView.changeStatusInNextTransaction = true
        }
    }
}
