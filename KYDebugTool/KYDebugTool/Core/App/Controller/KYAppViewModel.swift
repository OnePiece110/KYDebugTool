//
//  KYAppViewModel.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import UIKit

final class KYAppViewModel: NSObject {
    var infos: [KYUserInfo.Info] {
        KYUserInfo.infos
    }

    var customInfos: [KYCustomData] {
        KYDebugTool.App.customInfo?() ?? []
    }

    var customActions: [KYCustomAction] {
        KYDebugTool.App.customAction?() ?? []
    }

    func getTitle(for section: Int) -> String? {
        let data = KYAppViewController.Sections(rawValue: section)
        switch data {
        case .customData:
            return customInfos.isEmpty ? nil : data?.title
        case .customAction:
            return customActions.isEmpty ? nil : data?.title
        default:
            return data?.title
        }
    }
}
