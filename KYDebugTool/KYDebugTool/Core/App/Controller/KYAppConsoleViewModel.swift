//
//  KYAppConsoleViewModel.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import Foundation

final class KYAppConsoleViewModel: NSObject, KYResourcesGenericListViewModel {

    private var data: [String] {
        KYLogIntercepter.shared.consoleOutput
    }

    private var filteredInfo = [String]()

    var isSearchActived: Bool = false

    var reloadData: (() -> Void)?

    func viewTitle() -> String {
        "Console"
    }

    func numberOfItems() -> Int {
        isSearchActived ? filteredInfo.count : data.count
    }

    func dataSourceForItem(atIndex index: Int) -> (title: String, value: String) {
        let info = isSearchActived ? filteredInfo[index] : data[index]
        return (title: info, value: "")
    }

    func handleClearAction() {
        KYLogIntercepter.shared.reset()
        filteredInfo.removeAll()
    }

    func handleDeleteItemAction(atIndex index: Int) {
        if isSearchActived {
            let info = filteredInfo.remove(at: index)
            KYLogIntercepter.shared.consoleOutput.removeAll(where: { $0 == info })
        } else {
            KYLogIntercepter.shared.consoleOutput.remove(at: index)
        }
    }

    func emptyListDescriptionString() -> String {
        "No data found in the " + "Console"
    }

    func filterContentForSearchText(_ searchText: String) {
        if searchText.isEmpty {
            filteredInfo = data
        } else {
            filteredInfo = data.filter {
                $0.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

extension KYAppConsoleViewModel: KYLogInterceptorDelegate {
    func logUpdated() {
        reloadData?()
    }
}
