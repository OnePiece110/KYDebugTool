//
//  KYAppCustomInfoViewModel.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import Foundation

final class KYAppCustomInfoViewModel: NSObject, KYResourcesGenericListViewModel {

    private var data: KYCustomData
    private var filteredInfo = [KYCustomData.Info]()

    // MARK: - Initialization

    init(data: KYCustomData) {
        self.data = data
        super.init()
    }

    // MARK: - ViewModel

    var isSearchActived: Bool = false

    var reloadData: (() -> Void)?

    var isDeleteEnable: Bool { false }

    func viewTitle() -> String {
        data.title
    }

    func numberOfItems() -> Int {
        isSearchActived ? filteredInfo.count : data.infos.count
    }

    func dataSourceForItem(atIndex index: Int) -> (title: String, value: String) {
        let info = isSearchActived ? filteredInfo[index] : data.infos[index]
        return (title: info.title, value: info.subtitle)
    }

    func handleClearAction() {}

    func handleDeleteItemAction(atIndex index: Int) {}

    func emptyListDescriptionString() -> String {
        "No data found in the " + data.title
    }

    // MARK: - Search Functionality

    func filterContentForSearchText(_ searchText: String) {
        if searchText.isEmpty {
            filteredInfo = data.infos
        } else {
            filteredInfo = data.infos.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                    $0.subtitle.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
