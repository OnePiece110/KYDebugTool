//
//  UIWindow+.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/24.
//

import UIKit

extension UIWindow {
    
    static var currentWindow: UIWindow? {
        return UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }
    }
    
}

extension UIWindow {
    // MARK: - Constants

    private enum Constants {
        static let touchIndicatorViewMinAlpha: CGFloat = 0.6
        static var associatedTouchIndicators: UInt8 = 0
        static var associatedReusableTouchIndicators: UInt8 = 1
    }

    static var lastTouch: CGPoint?

    // MARK: - TouchIndicators property

    private var touchIndicators: NSMapTable<UITouch, KYTouchIndicatorView> {
        get {
            if let touchIndicators = objc_getAssociatedObject(self, &Constants.associatedTouchIndicators)
                as? NSMapTable<UITouch, KYTouchIndicatorView> {
                return touchIndicators
            } else {
                let touchIndicators = NSMapTable<UITouch, KYTouchIndicatorView>(
                    keyOptions: .weakMemory, valueOptions: .weakMemory
                )
                objc_setAssociatedObject(
                    self, &Constants.associatedTouchIndicators, touchIndicators,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                return touchIndicators
            }
        }
        set {
            objc_setAssociatedObject(
                self, &Constants.associatedTouchIndicators, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    // MARK: - ReusableTouchIndicators property

    private var reusableTouchIndicators: NSMutableSet {
        get {
            if
                let reusableTouchIndicators = objc_getAssociatedObject(
                    self,
                    &Constants.associatedReusableTouchIndicators
                ) as? NSMutableSet {
                return reusableTouchIndicators
            } else {
                let reusableTouchIndicators = NSMutableSet()
                objc_setAssociatedObject(
                    self,
                    &Constants.associatedReusableTouchIndicators,
                    reusableTouchIndicators,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                return reusableTouchIndicators
            }
        }
        set {
            objc_setAssociatedObject(
                self,
                &Constants.associatedReusableTouchIndicators,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    // MARK: - Method swizzling

    @objc class func ky_swizzleMethods() {
        DispatchQueue.once(token: "debugswift.uiwindow.ky_swizzleMethods") {
            let originalSelector = #selector(UIWindow.sendEvent(_:))
            let swizzledSelector = #selector(UIWindow.ky_sendEvent(_:))
            guard let originalMethod = class_getInstanceMethod(self, originalSelector),
                  let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            else {
                return
            }
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }

    // MARK: - Handling showing touches

    func setShowingTouchesEnabled(_ enabled: Bool) {
        if let enumerator = touchIndicators.objectEnumerator() {
            while let (_, touchIndicatorView) = enumerator.nextObject() as? (Any, KYTouchIndicatorView) {
                touchIndicatorView.isHidden = !enabled
            }
        }

        for case let touchIndicatorView as UIView in reusableTouchIndicators {
            touchIndicatorView.isHidden = !enabled
        }
    }

    func ky_handleTouches(_ touches: Set<UITouch>) {
        for touch in touches {
            ky_handleTouch(touch)
        }
    }

    func ky_handleTouch(_ touch: UITouch) {
        if touch.phase == .ended {
            Self.lastTouch = touch.location(in: nil)
        }

        guard KYUserInterfaceToolkit.shared.showingTouchesEnabled else { return }
        switch touch.phase {
        case .began:
            ky_addTouchIndicator(with: touch)
        case .moved:
            ky_moveTouchIndicator(with: touch)
        case .ended, .cancelled:
            ky_removeTouchIndicator(with: touch)
        default:
            break
        }
    }

    func ky_addTouchIndicator(with touch: UITouch) {
        guard let indicatorView = ky_availableTouchIndicatorView() else { return }
        indicatorView.isHidden = !KYUserInterfaceToolkit.shared.showingTouchesEnabled
        touchIndicators.setObject(indicatorView, forKey: touch)
        addSubview(indicatorView)
        indicatorView.center = touch.location(in: self)
        ky_handleTouchForce(touch)
    }

    func ky_availableTouchIndicatorView() -> KYTouchIndicatorView? {
        if let indicatorView = reusableTouchIndicators.anyObject() as? KYTouchIndicatorView {
            reusableTouchIndicators.remove(indicatorView)
            return indicatorView
        } else {
            return KYTouchIndicatorView.indicatorView()
        }
    }

    func ky_moveTouchIndicator(with touch: UITouch) {
        if let indicatorView = touchIndicators.object(forKey: touch) {
            indicatorView.center = touch.location(in: self)
            ky_handleTouchForce(touch)
        }
    }

    func ky_removeTouchIndicator(with touch: UITouch) {
        if let indicatorView = touchIndicators.object(forKey: touch) {
            indicatorView.removeFromSuperview()
            touchIndicators.removeObject(forKey: touch)
            reusableTouchIndicators.add(indicatorView)
        }
    }

    func ky_handleTouchForce(_ touch: UITouch) {
        if let indicatorView = touchIndicators.object(forKey: touch) {
            var indicatorViewAlpha: CGFloat = 1.0

            if traitCollection.forceTouchCapability == UIForceTouchCapability.available {
                indicatorViewAlpha =
                    Constants.touchIndicatorViewMinAlpha + (1.0 - Constants.touchIndicatorViewMinAlpha)
                        * touch.force / touch.maximumPossibleForce
            }
            indicatorView.alpha = indicatorViewAlpha
        }
    }

    // MARK: - UIDebuggingInformationOverlay

    @objc func ky_debuggingInformationOverlayInit() -> UIWindow {
        type(of: self).init()
    }

    @objc var state: UIGestureRecognizer.State {
        .ended
    }

    // MARK: - Swizzled Method

    @objc func ky_sendEvent(_ event: UIEvent) {
        if event.type == .touches {
            ky_handleTouches(event.allTouches!)
        }
        ky_sendEvent(event)
    }

    static var keyWindow: UIWindow? {
        UIApplication.shared.windows.first(where: \.isKeyWindow)
    }

    var _snapshot: UIImage? {
        guard Thread.isMainThread else { return nil }
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, .zero)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    var _snapshotWithTouch: UIImage? {
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, .zero)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        // Draw the original snapshot
        layer.render(in: context)

        if let circleCenter = Self.lastTouch {
            // Draw a circle in the center of the image
            let circleRadius: CGFloat = 20

            context.setLineWidth(2)
            context.setStrokeColor(UIColor.red.cgColor)
            context.addArc(
                center: circleCenter,
                radius: circleRadius,
                startAngle: 0,
                endAngle: CGFloat.pi * 2,
                clockwise: true
            )
            context.strokePath()
        }

        // Get the modified image
        let imageWithCircle = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return imageWithCircle
    }
}

// MARK: - DispatchQueue extension for once

extension DispatchQueue {
    private static var _onceTracker = [String]()

    class func once(token: String, block: () -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        if _onceTracker.contains(token) {
            return
        }

        _onceTracker.append(token)
        block()
    }
}

