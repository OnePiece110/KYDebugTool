//
//  KYReachabilityManager.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import Foundation
import CoreTelephony

struct KYReachabilityManager {

    private static var reachability = try? KYReachability()

    static var connection: KYNetworkType {
        reachability?.getNetworkType() ?? .unknownTechnology
    }
}
