//
//  ViewControllerUtils.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/24.
//

import UIKit

func getNearestAncestorViewController(responder: UIResponder) -> UIViewController? {
    if let viewController = responder as? UIViewController {
        return viewController
    } else if let nextResponder = responder.next {
        return getNearestAncestorViewController(responder: nextResponder)
    }
    return nil
}
