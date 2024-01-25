//
//  KYNetworkHelper.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import UIKit

final class KYNetworkHelper {
    static let shared = KYNetworkHelper()

    var mainColor: UIColor
    var protobufTransferMap: [String: [String]]?
    var isNetworkEnable: Bool

    private init() {
        self.mainColor = UIColor(hexString: "#42d459") ?? UIColor.green
        self.isNetworkEnable = false
    }

    func enable() {
        guard !isNetworkEnable else { return }
        isNetworkEnable = true
        KYCustomHTTPProtocol.start()
    }

    func disable() {
        guard isNetworkEnable else { return }
        isNetworkEnable = false
        KYCustomHTTPProtocol.stop()
    }
}
