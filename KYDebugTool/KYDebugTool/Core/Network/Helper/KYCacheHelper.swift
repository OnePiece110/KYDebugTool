//
//  KYCacheHelper.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import Foundation

enum KYCacheHelper {
    /// 确定响应的缓存存储策略。
    /// 当向客户端提供响应时，该函数用于告诉客户端
    /// 响应是否可缓存。
    /// - 参数：
    /// - request：生成响应的请求； 一定不能为零。
    /// - response：响应本身； 一定不能为零。
    /// - return：要使用的缓存存储策略。
    static func cacheStoragePolicy(for request: URLRequest, and response: HTTPURLResponse)
        -> URLCache.StoragePolicy {
        var cacheable: Bool
        var result: URLCache.StoragePolicy

        // First determine if the request is cacheable based on its status code.
        switch response.statusCode {
        case 200, 203, 206, 301, 304, 404, 410:
            cacheable = true
        default:
            cacheable = false
        }

        // If the response might be cacheable, look at the "Cache-Control" header in the response.
        if cacheable {
            let responseHeader = (response.allHeaderFields["Cache-Control"] as? String)?.lowercased()
            if let responseHeader, responseHeader.range(of: "no-store") != nil {
                cacheable = false
            }
        }

        // If we still think it might be cacheable, look at the "Cache-Control" header in the request.
        if cacheable {
            let requestHeader = (request.allHTTPHeaderFields?["Cache-Control"] as? String)?.lowercased()
            if let requestHeader,
               requestHeader.range(of: "no-store") != nil,
               requestHeader.range(of: "no-cache") != nil {
                cacheable = false
            }
        }

        // Use the cacheable flag to determine the result.
        if cacheable {
            // This code only caches HTTPS data in memory. This is in line with earlier versions of iOS.
            // Modern versions of iOS use file protection to protect the cache, and thus are happy to cache HTTPS on disk.
            // I've not made the corresponding change because it's nice to see all three cache policies in action.
            if request.url?.scheme?.lowercased() == "https" {
                result = .allowedInMemoryOnly
            } else {
                result = .allowed
            }
        } else {
            result = .notAllowed
        }

        return result
    }
}
