//
//  KYCrashViewModel.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import Foundation
import UIKit

final class KYCrashViewModel: NSObject {

    var data: [KYCrashModel] {
        KYCrashManager.recover(ofType: .nsexception) +
            KYCrashManager.recover(ofType: .signal)
    }

    func viewTitle() -> String {
        "Crashes"
    }

    func numberOfItems() -> Int {
        data.count
    }

    func dataSourceForItem(atIndex index: Int) -> (title: String, value: String) {
        let trace = data[index]
        return (
            title: trace.details.name,
            value: "\n     \(trace.details.date.formatted())"
        )
    }

    func handleClearAction() {
        KYCrashManager.deleteAll(ofType: .nsexception)
        KYCrashManager.deleteAll(ofType: .signal)
    }

    func handleDeleteItemAction(atIndex index: Int) {
        let crash = data[index]
        KYCrashManager.delete(crash: crash)
    }

    func emptyListDescriptionString() -> String {
        "No data found in the " + viewTitle()
    }
}
