//
//  KYSwizzleSessionConfiguration.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import Foundation

extension URLSessionConfiguration {

    @objc
    static func swizzleMethods() {
        guard self == URLSessionConfiguration.self else {
            return
        }

        let defaultSessionConfiguration = class_getClassMethod(
            URLSessionConfiguration.self,
            #selector(getter: URLSessionConfiguration.default)
        )
        let swizzledDefaultSessionConfiguration = class_getClassMethod(
            URLSessionConfiguration.self,
            #selector(URLSessionConfiguration.swizzledDefaultSessionConfiguration)
        )

        method_exchangeImplementations(defaultSessionConfiguration!, swizzledDefaultSessionConfiguration!)

        let ephemeralSessionConfiguration = class_getClassMethod(
            URLSessionConfiguration.self,
            #selector(getter: URLSessionConfiguration.ephemeral)
        )
        let swizzledEphemeralSessionConfiguration = class_getClassMethod(
            URLSessionConfiguration.self,
            #selector(URLSessionConfiguration.swizzledEphemeralSessionConfiguration)
        )

        method_exchangeImplementations(ephemeralSessionConfiguration!, swizzledEphemeralSessionConfiguration!)
    }

    @objc
    private class func swizzledDefaultSessionConfiguration() -> URLSessionConfiguration {
        let configuration = swizzledDefaultSessionConfiguration()
        configuration.protocolClasses?.insert(KYCustomHTTPProtocol.self, at: .zero)
        URLProtocol.registerClass(KYCustomHTTPProtocol.self)
        return configuration
    }

    @objc
    private class func swizzledEphemeralSessionConfiguration() -> URLSessionConfiguration {
        let configuration = swizzledEphemeralSessionConfiguration()
        configuration.protocolClasses?.insert(KYCustomHTTPProtocol.self, at: .zero)
        URLProtocol.registerClass(KYCustomHTTPProtocol.self)
        return configuration
    }
}
