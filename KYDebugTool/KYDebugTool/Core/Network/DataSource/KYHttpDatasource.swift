//
//  KYHttpDatasource.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import Foundation

final class KYHttpDatasource {
    static let shared = KYHttpDatasource()

    var httpModels: [KYHttpModel] = []

    func addHttpRequest(_ model: KYHttpModel) -> Bool {
        if model.url?.absoluteString.isEmpty == true {
            return false
        }

        if !KYDebugTool.Network.onlyURLs.isEmpty {
            for urlString in KYDebugTool.Network.onlyURLs {
                if model.url?.absoluteString.lowercased().contains(
                    urlString.lowercased()
                ) == false {
                    return false
                }
            }
        } else {
            for urlString in KYDebugTool.Network.ignoredURLs {
                if model.url?.absoluteString.lowercased().contains(
                    urlString.lowercased()
                ) == true {
                    return false
                }
            }
        }

        // Maximum number limit
        if httpModels.count >= 1000 {
            if !httpModels.isEmpty {
                httpModels.remove(at: 0)
            }
        }

        // Detect repeated
        guard !httpModels.contains(where: { $0.requestId == model.requestId }) else {
            return false
        }
        model.index = httpModels.count
        httpModels.append(model)
        return true
    }

    func removeAll() {
        httpModels.removeAll()
    }

    func remove(_ model: KYHttpModel) {
        for (index, obj) in httpModels.reversed().enumerated() {
            if obj.requestId == model.requestId {
                httpModels.remove(at: index)
            }
        }
    }
}

extension URLRequest {
    private enum AssociatedKeys {
        static var requestId = "requestId"
        static var startTime = "startTime"
    }

    var requestId: String {
        get {
            if let id = objc_getAssociatedObject(self, AssociatedKeys.requestId) as? String {
                return id
            } else {
                let newValue = UUID().uuidString
                objc_setAssociatedObject(
                    self, AssociatedKeys.requestId, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC
                )
                return newValue
            }
        }
        set {
            objc_setAssociatedObject(
                self, AssociatedKeys.requestId, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC
            )
        }
    }

    var startTime: NSNumber? {
        get {
            objc_getAssociatedObject(self, AssociatedKeys.startTime) as? NSNumber
        }
        set {
            objc_setAssociatedObject(
                self, AssociatedKeys.startTime, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}
