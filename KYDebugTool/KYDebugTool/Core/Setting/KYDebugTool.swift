//
//  KYDebugTool.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import CoreLocation
import UIKit

public struct KYDebugTool {
    public static func setup() {
        UIView.swizzleMethods()
        UIWindow.ky_swizzleMethods()
        URLSessionConfiguration.swizzleMethods()
        KYNetworkHelper.shared.enable()
        KYLogIntercepter.shared.start()
        
        KYCrashManager.register()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            KYFloatViewManager.setup(KYTabBarController())
        }

        KYLaunchTimeTracker.measureAppStartUpTime()
    }

    public static func show() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            KYFloatViewManager.show()
        }
    }

    public static func hide() {
        KYFloatViewManager.remove()
    }

    public static func toggle() {
        KYFloatViewManager.toggle()
    }
}

extension KYDebugTool {
    public enum Network {
        public static var ignoredURLs = [String]()
        public static var onlyURLs = [String]()
    }

    public enum Console {
        public static var ignoredLogs = [String]()
        public static var onlyLogs = [String]()
    }

    enum Debugger {
        @KYUserDefaultAccess(key: .debugger, defaultValue: true)
        public static var enable: Bool
    }
    
    public enum App {
        public static var customInfo: (() -> [KYCustomData])?
        public static var customAction: (() -> [KYCustomAction])?
    }
}
