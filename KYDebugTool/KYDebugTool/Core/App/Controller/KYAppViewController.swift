//
//  KYAppViewController.swift
//  KYDebugTool
//
//  Created by Ye Keyon on 2024/1/25.
//

import UIKit

final class KYAppViewController: KYBaseController {
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .black
        tableView.separatorColor = .darkGray

        return tableView
    }()

    private let viewModel = KYAppViewModel()

    override init() {
        super.init()
        setup()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
    }

    func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: .cell
        )

        tableView.register(
            KYMenuSwitchTableViewCell.self,
            forCellReuseIdentifier: KYMenuSwitchTableViewCell.identifier
        )

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func setup() {
        title = "App"
        tabBarItem = UITabBarItem(
            title: title,
            image: .named("app"),
            tag: 4
        )
    }
}

extension KYAppViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .infos:
            return viewModel.infos.count
        case .customData:
            return viewModel.customInfos.count
        case .actions:
            return ActionInfo.allCases.count
        case .customAction:
            return viewModel.customActions.count
        case nil:
            return .zero
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        Sections.allCases.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: .cell,
            for: indexPath
        )
        switch Sections(rawValue: indexPath.section) {
        case .infos:
            let info = viewModel.infos[indexPath.row]
            cell.setup(
                title: info.title,
                description: info.detail,
                image: nil
            )
            return cell
        case .actions:
            cell.setup(
                title: ActionInfo.allCases[indexPath.row].title
            )
        case .customData:
            let info = viewModel.customInfos[indexPath.row]
            cell.setup(title: info.title)
            return cell

        case .customAction:
            let info = viewModel.customActions[indexPath.row]
            cell.setup(title: info.title)
            return cell

        case nil:
            break
        }

        return cell
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.getTitle(for: section)
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        80.0
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Sections(rawValue: indexPath.section) {
        case .customData:
            let data = viewModel.customInfos[indexPath.row]
            let viewModel = KYAppCustomInfoViewModel(data: data)
            let controller = KYResourcesGenericController(viewModel: viewModel)
            navigationController?.pushViewController(controller, animated: true)

        case .customAction:
            let data = viewModel.customActions[indexPath.row]
            let viewModel = KYAppCustomActionViewModel(data: data)
            let controller = KYResourcesGenericController(viewModel: viewModel)
            navigationController?.pushViewController(controller, animated: true)

        case .actions:
            switch ActionInfo(rawValue: indexPath.row) {
            case .console:
                let viewModel = KYAppConsoleViewModel()
                let controller = KYResourcesGenericController(viewModel: viewModel)
                navigationController?.pushViewController(controller, animated: true)
//            case .location:
//                break
            case .crash:
                let controller = KYCrashViewController()
                navigationController?.pushViewController(controller, animated: true)
            default: break
            }
        default:
            break
        }
    }
}

extension KYAppViewController {
    enum Sections: Int, CaseIterable {
        case actions
        case customAction
        case customData
        case infos

        var title: String? {
            switch self {
            case .infos:
                return "Device Info"
            case .actions:
                return "Actions"
            case .customData:
                return "Custom Data"
            case .customAction:
                return "Custom Actions"
            }
        }
    }
}

extension KYAppViewController {
    enum ActionInfo: Int, CaseIterable {
        case crash
        case console
//        case location

        var title: String {
            switch self {
//            case .location:
//                return "Simulated location"
            case .console:
                return "Console"
            case .crash:
                return "Crashes"
            }
        }
    }
}
