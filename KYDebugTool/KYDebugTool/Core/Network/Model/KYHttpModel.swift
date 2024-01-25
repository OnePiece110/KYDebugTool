//
//  KYHttpModel.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import Foundation

enum KYRequestSerializer: UInt {
    case json = 0
    case form
}

final class KYHttpModel: NSObject {
    var url: URL?
    var requestData: Data?
    var responseData: Data?
    var requestId: String?
    var method: String?
    var statusCode: String?
    var mineType: String?
    var startTime: String?
    var endTime: String?
    var totalDuration: String?
    var isImage = false

    var requestHeaderFields: [String: Any]?
    var responseHeaderFields: [String: Any]?
    var isTag = false
    var isSelected = false
    var requestSerializer: KYRequestSerializer = .json
    var errorDescription: String?
    var errorLocalizedDescription: String?
    var size: String?
    var index: Int = .zero
    var id: String { String(index) }

    override init() {
        super.init()
        self.statusCode = "0"
        self.url = URL(string: "")
    }

    var isSuccess: Bool {
        errorDescription == nil || errorDescription?.isEmpty == true
    }
}
