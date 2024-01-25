//
//  KYNetworkViewModel.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import Foundation

final class KYNetworkViewModel {

    var reachEnd = true
    var firstIn = true
    var reloadDataFinish = true

    var models = KYHttpDatasource.shared.httpModels
    var cacheModels = [KYHttpModel]()
    var searchModels = [KYHttpModel]()

    var networkSearchWord = ""

    func applyFilter() {
        cacheModels = KYHttpDatasource.shared.httpModels
        searchModels = cacheModels

        if networkSearchWord.isEmpty {
            models = cacheModels
        } else {
            searchModels = searchModels.filter {
                $0.url?.absoluteString.lowercased().contains(networkSearchWord.lowercased()) == true
            }

            models = searchModels
        }
    }

    func handleClearAction() {
        KYHttpDatasource.shared.removeAll()
        models.removeAll()
    }
}
