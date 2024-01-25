//
//  KYCrashModel.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import UIKit

struct KYCrashModel: Codable, Equatable {
    let type: KYCrashType
    let details: Details
    let context: Context
    let traces: [Trace]

    init(
        type: KYCrashType,
        details: Details,
        context: Context = .builder(),
        traces: [Trace] = .builder()
    ) {
        self.type = type
        self.details = details
        self.context = context
        self.traces = traces
    }

    static func == (lhs: KYCrashModel, rhs: KYCrashModel) -> Bool {
        lhs.details.name == rhs.details.name
    }
}

extension KYCrashModel {
    struct Details: Codable {
        let name: String
        let date: Date
        let appVersion: String?
        let appBuild: String?
        let iosVersion: String
        let deviceModel: String
        let reachability: String

        static func builder(name: String) -> Self {
            .init(
                name: name,
                date: .init(),
                appVersion: KYUserInfo.getAppVersionInfo()?.detail,
                appBuild: KYUserInfo.getAppBuildInfo()?.detail,
                iosVersion: KYUserInfo.getIOSVersionInfo().detail,
                deviceModel: KYUserInfo.getDeviceModelInfo().detail,
                reachability: KYUserInfo.getReachability().detail
            )
        }
    }
}

extension KYCrashModel {
    struct Context: Codable {
        let image: Data?
        let consoleOutput: String

        var uiImage: UIImage? {
            guard let image else { return nil }
            return UIImage(data: image)
        }

        static func builder() -> Self {
            .init(
                image: UIWindow.keyWindow?._snapshotWithTouch?.pngData(),
                consoleOutput: KYLogIntercepter.shared.consoleOutput.reversed().joined(separator: "\n")
            )
        }
    }
}

extension KYCrashModel {
    struct Trace: Codable {
        let title: String
        let detail: String

        var info: KYUserInfo.Info {
            .init(title: title, detail: detail)
        }
    }
}

extension [KYCrashModel.Trace] {
    static func builder() -> Self {
        var traces = [KYCrashModel.Trace]()
        for symbol in Thread.callStackSymbols {
            var detail = ""
            if let className = KYTrace.classNameFromSymbol(symbol) {
                detail += "Class: \(className)\n"
            }
            if let fileInfo = KYTrace.fileInfoFromSymbol(symbol) {
                detail += """
                    File: \(fileInfo.file)\n,
                    Line: \(fileInfo.line)\n,
                    Function: \(fileInfo.function)\n
                """
            }

            let trace = KYCrashModel.Trace(
                title: symbol,
                detail: detail
            )
            traces.append(trace)
        }

        return traces
    }
}
