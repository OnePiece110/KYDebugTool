//
//  KYAppCustomActionViewModel.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import Foundation

final class KYAppCustomActionViewModel: NSObject, KYResourcesGenericListViewModel {

    private var data: KYCustomAction
    private var filtered = KYCustomAction.Actions()

    init(data: KYCustomAction) {
        self.data = data
        super.init()
    }

    var isSearchActived: Bool = false
    var isDeleteEnable: Bool { false }
    var isCustomActionEnable: Bool { true }

    var reloadData: (() -> Void)?

    func viewTitle() -> String { data.title }

    func numberOfItems() -> Int {
        isSearchActived ? filtered.count : data.actions.count
    }

    func dataSourceForItem(atIndex index: Int) -> (title: String, value: String) {
        let info = isSearchActived ? filtered[index] : data.actions[index]
        return (title: info.title, value: "")
    }

    func handleClearAction() {}

    func handleDeleteItemAction(atIndex index: Int) {}

    func emptyListDescriptionString() -> String {
        "No data found in the " + data.title
    }

    func filterContentForSearchText(_ searchText: String) {
        if searchText.isEmpty {
            filtered = data.actions
        } else {
            filtered = data.actions.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    func didTapItem(index: Int) {
        if isSearchActived {
            filtered[index].action?()
        } else {
            data.actions[index].action?()
        }
    }
}
