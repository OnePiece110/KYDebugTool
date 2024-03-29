//
//  KYUserInfo.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import UIKit

enum KYUserInfo {

    struct Info {
        let title: String
        let detail: String
    }

    static var infos: [Info] {
        [
            getAppVersionInfo(),
            getAppBuildInfo(),
            getBundleName(),
            getBundleId(),
            getScreenResolution(),
            getDeviceModelInfo(),
            getIOSVersionInfo(),
            getMeasureAppStartUpTime(),
            getReachability()
        ].compactMap { $0 }
    }

    static func getAppVersionInfo() -> Info? {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return nil
        }

        return Info(
            title: "App Version:",
            detail: "\(version)"
        )
    }

    static func getAppBuildInfo() -> Info? {
        guard let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        else {
            return nil
        }

        return Info(
            title: "Build Version:",
            detail: "Build: \(build)"
        )
    }

    static func getBundleName() -> Info? {
        guard let bundleName = Bundle.main.infoDictionary?["CFBundleName"] as? String else {
            return nil
        }

        return Info(
            title: "Bundle Name:",
            detail: "\(bundleName)"
        )
    }

    static func getBundleId() -> Info? {
        guard let bundleID = Bundle.main.bundleIdentifier else {
            return nil
        }

        return Info(
            title: "Bundle ID:",
            detail: "\(bundleID)"
        )
    }

    static func getScreenResolution() -> Info {
        let screen = UIScreen.main
        let bounds = screen.bounds
        let scale = screen.scale

        let screenWidth = bounds.size.width * scale
        let screenHeight = bounds.size.height * scale

        return .init(
            title: "Screen Resolution:",
            detail: "\(screenWidth) x \(screenHeight) points"
        )
    }

    static func getDeviceModelInfo() -> Info {
        let deviceModel = UIDevice.current.modelName
        return Info(
            title: "Device Model:",
            detail: deviceModel
        )
    }

    static func getIOSVersionInfo() -> Info {
        let iOSVersion = UIDevice.current.systemVersion
        return Info(
            title: "iOS Version:",
            detail: iOSVersion
        )
    }

    static func getMeasureAppStartUpTime() -> Info? {
        guard let launchStartTime = KYLaunchTimeTracker.launchStartTime else { return nil }

        return Info(
            title: "Initialization Time:",
            detail: String(format: "%.4lf%", launchStartTime) + " (s)"
        )
    }

    static func getReachability() -> Info {
        return Info(
            title: "Connection Type:",
            detail: KYReachabilityManager.connection.description
        )
    }
}
