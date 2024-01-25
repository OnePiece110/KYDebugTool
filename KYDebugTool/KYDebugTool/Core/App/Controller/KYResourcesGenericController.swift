//
//  KYResourcesGenericController.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import UIKit

final class KYResourcesGenericController: KYBaseTableController {
    let viewModel: KYResourcesGenericListViewModel

    init(viewModel: KYResourcesGenericListViewModel) {
        self.viewModel = viewModel
        super.init(style: .grouped)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let backgroundLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = .zero
        return label
    }()

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        return searchController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.viewTitle()
        setupTableView()
        setupBackgroundLabel()
        setupSearch()
    }

    func setupTableView() {
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: .cell
        )
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .black
        guard viewModel.numberOfItems() != .zero, viewModel.isDeleteEnable else { return }
        addRightBarButton(
            image: .named("trash.circle", default: "Delete"),
            tintColor: .red
        ) { [weak self] in
            self?.showAlert(
                with: "Warning",
                title: "This action remove all data",
                leftButtonTitle: "Delete",
                leftButtonStyle: .destructive,
                leftButtonHandler: { _ in
                    self?.clearAction()
                },
                rightButtonTitle: "Cancel",
                rightButtonStyle: .cancel
            )
        }

        viewModel.reloadData = { [weak self] in
            self?.tableView.reloadData()
        }
    }

    func setupSearch() {
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    private func setupBackgroundLabel() {
        tableView.backgroundView = backgroundLabel
    }

    private func clearAction() {
        viewModel.handleClearAction()
        tableView.reloadData()
    }

    override func numberOfSections(in _: UITableView) -> Int {
        1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        let numberOfItems = viewModel.numberOfItems()

        backgroundLabel.text = numberOfItems == .zero ? viewModel.emptyListDescriptionString() : ""

        return numberOfItems
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .cell, for: indexPath)

        let dataSource = viewModel.dataSourceForItem(atIndex: indexPath.row)

        cell.setup(
            title: dataSource.title,
            subtitle: dataSource.value,
            image: viewModel.isCustomActionEnable ?
                    .named("chevron.right.square", default: "Action"):
                    .named("doc.on.doc", default: "Copy")
        )

        return cell
    }

    override func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
        viewModel.isDeleteEnable
    }

    override func tableView(
        _ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete, viewModel.isDeleteEnable {
            viewModel.handleDeleteItemAction(atIndex: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    override func tableView(
        _: UITableView, titleForDeleteConfirmationButtonForRowAt _: IndexPath
    ) -> String? {
        viewModel.isDeleteEnable ? "Delete" : nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

        UIView.animate(
            withDuration: 0.3,
            animations: {
                cell.alpha = 0.5
            }
        ) { _ in
            UIView.animate(withDuration: 0.3) {
                cell.alpha = 1.0
            }
        }

        if viewModel.isCustomActionEnable {
            viewModel.didTapItem(index: indexPath.row)
        } else {
            let title = cell.textLabel?.text ?? ""
            let contentToCopy = "\(title)"
            UIPasteboard.general.string = contentToCopy
        }
    }
}

extension KYResourcesGenericController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        viewModel.filterContentForSearchText(searchText)
        viewModel.isSearchActived = !searchText.isEmpty
        tableView.reloadData()
    }
}

protocol KYResourcesGenericListViewModel: AnyObject {
    var isSearchActived: Bool { get set }

    var isDeleteEnable: Bool { get }
    var isCustomActionEnable: Bool { get }

    var reloadData: (() -> Void)? { get set }

    func numberOfItems() -> Int

    func viewTitle() -> String

    func dataSourceForItem(atIndex index: Int) -> (title: String, value: String)

    func handleClearAction()

    func handleDeleteItemAction(atIndex index: Int)

    func emptyListDescriptionString() -> String

    func filterContentForSearchText(_ searchText: String)

    func didTapItem(index: Int)
}


extension KYResourcesGenericListViewModel {
    var isDeleteEnable: Bool { true }

    var isCustomActionEnable: Bool { false }

    func didTapItem(index: Int) {}
}
