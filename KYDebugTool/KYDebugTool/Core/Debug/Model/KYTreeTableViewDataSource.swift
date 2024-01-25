//
//  KYTreeTableViewDataSource.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import UIKit

protocol KYTree {
    var children: [Self] { get }
}

final class KYTreeTableViewDataSource<TreeType: KYTree>: NSObject, UITableViewDataSource {
    typealias CellFactory = (UITableView /* tableView */, TreeType /* value */, Int /* depth */, IndexPath /* indexPath */, Bool /* isCollapsed */) -> UITableViewCell

    private let tree: TreeType
    private let cellFactory: CellFactory
    private let flattenedTree: [KYFlattenedTree<TreeType>]

    init(tree: TreeType, maxDepth: Int?, cellFactory: @escaping CellFactory) {
        self.tree = tree
        self.cellFactory = cellFactory
        self.flattenedTree = flatten(tree: tree, depth: 0, maxDepth: maxDepth)
    }

    func value(atIndexPath indexPath: IndexPath) -> TreeType {
        return flattenedTree[indexPath.row].value
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flattenedTree.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tree = flattenedTree[indexPath.row]
        return cellFactory(tableView, tree.value, tree.depth, indexPath, tree.isCollapsed)
    }
}

extension KYTreeTableViewDataSource where TreeType: AnyObject {
    func indexPath(forValue value: TreeType) -> IndexPath? {
        return flattenedTree
            .firstIndex { $0.value === value }
            .flatMap { IndexPath(row: $0, section: .zero) }
    }
}

private struct KYFlattenedTree<TreeType: KYTree> {
    let value: TreeType
    let depth: Int
    var isCollapsed = false

    init(value: TreeType, depth: Int) {
        self.value = value
        self.depth = depth
    }
}

private func flatten<TreeType: KYTree>(tree: TreeType, depth: Int = 0, maxDepth: Int?) -> [KYFlattenedTree<TreeType>] {
    let initial = [KYFlattenedTree<TreeType>(value: tree, depth: depth)]
    let childDepth = depth + 1
    if let maxDepth = maxDepth, childDepth > maxDepth {
        return initial
    } else {
        return tree.children.reduce(initial) { (result, child) in
            var newResult = result
            newResult.append(contentsOf: flatten(tree: child, depth: childDepth, maxDepth: maxDepth))
            return newResult
        }
    }
}
