//
//  LocationViewController.swift
//  Weather
//
//  Created by 진재명 on 8/14/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import os
import UIKit

class LocationViewController: UIViewController {
    let viewModel: LocationViewModel

    init(viewModel: LocationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func loadView() {
        let tableView = UITableView()
        self.view = tableView

        tableView.register(LocationTableViewCell.self, forCellReuseIdentifier: LocationTableViewCellViewModel.reuseIdentifier)

        tableView.dataSource = self
        tableView.delegate = self
        
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)

        let footerView = LocationFooterView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 64.0))
        tableView.tableFooterView = footerView

        let version: String! = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        assert(version != nil)

        let build: String! = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        assert(build != nil)

        footerView.versionLabel.text = "\(version!) (\(build!))"
        footerView.addButton.addTarget(self, action: #selector(self.addButtonPressed(_:)), for: .touchUpInside)
        footerView.temperatureUnitButton.addTarget(self, action: #selector(self.temperatureUnitButtonPressed(_:)), for: .touchUpInside)
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        let dispatchGroup = DispatchGroup()
        
        self.viewModel.changeIsUserDriven = true
        
        self.viewModel.results.forEach { (viewModel) in
            dispatchGroup.enter()
            
            viewModel.updateLocation { (result) in
                if case .failure(let error) = result {
                    DispatchQueue.main.async {
                        self.errorOccurred(error)
                    }
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { [weak self] in
                guard let self = self else {
                    return
                }
                self.tableView.refreshControl?.endRefreshing()
                self.viewModel.changeIsUserDriven = false
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.willChangeContent(_:)),
                                               name: LocationViewModel.willChangeContentNotification,
                                               object: self.viewModel)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didChangeContent(_:)),
                                               name: LocationViewModel.didChangeContentNotification,
                                               object: self.viewModel)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didInsertObject(_:)),
                                               name: LocationViewModel.didInsertObjectNotification,
                                               object: self.viewModel)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didDeleteObject(_:)),
                                               name: LocationViewModel.didDeleteObjectNotification,
                                               object: self.viewModel)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didMoveObject(_:)),
                                               name: LocationViewModel.didMoveObjectNotification,
                                               object: self.viewModel)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didUpdateObject(_:)),
                                               name: LocationViewModel.didUpdateObjectNotification,
                                               object: self.viewModel)

        do {
            try self.viewModel.performFetch()
        } catch {
            self.errorOccurred(error)
        }
    }

    @objc func willChangeContent(_: Notification) {
        guard !self.viewModel.changeIsUserDriven else {
            return
        }
        self.tableView.beginUpdates()
    }

    @objc func didChangeContent(_: Notification) {
        guard !self.viewModel.changeIsUserDriven else {
            return
        }
        self.tableView.endUpdates()
    }

    @objc func didInsertObject(_ notification: Notification) {
        guard !self.viewModel.changeIsUserDriven else {
            return
        }

        let indexPath: IndexPath! = notification.userInfo?[LocationViewModel.newIndexPathUserInfoKey] as? IndexPath
        assert(indexPath != nil)

        self.tableView.insertRows(at: [indexPath], with: .fade)
    }

    @objc func didDeleteObject(_ notification: Notification) {
        guard !self.viewModel.changeIsUserDriven else {
            return
        }

        let indexPath: IndexPath! = notification.userInfo?[LocationViewModel.indexPathUserInfoKey] as? IndexPath
        assert(indexPath != nil)

        self.tableView.deleteRows(at: [indexPath], with: .fade)
    }

    @objc func didMoveObject(_ notification: Notification) {
        guard !self.viewModel.changeIsUserDriven else {
            return
        }

        let indexPath: IndexPath! = notification.userInfo?[LocationViewModel.indexPathUserInfoKey] as? IndexPath
        assert(indexPath != nil)

        let newIndexPath: IndexPath! = notification.userInfo?[LocationViewModel.newIndexPathUserInfoKey] as? IndexPath
        assert(newIndexPath != nil)

        self.tableView.deleteRows(at: [indexPath], with: .fade)
        self.tableView.insertRows(at: [indexPath], with: .fade)
    }

    @objc func didUpdateObject(_ notification: Notification) {
        guard !self.viewModel.changeIsUserDriven else {
            return
        }

        let indexPath: IndexPath! = notification.userInfo?[LocationViewModel.indexPathUserInfoKey] as? IndexPath
        assert(indexPath != nil)

        let newIndexPath: IndexPath! = notification.userInfo?[LocationViewModel.newIndexPathUserInfoKey] as? IndexPath
        assert(newIndexPath != nil)

        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }

    func errorOccurred(_ error: Error) {
        let alert = UIAlertController(title: "오류가 발생했습니다", message: "\(error)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true)
    }

    var tableView: UITableView {
        let tableView: UITableView! = self.view as? UITableView
        assert(tableView != nil)
        return tableView
    }

    @objc func addButtonPressed(_: UIButton) {
        let delegate: AppDelegate! = UIApplication.shared.delegate as? AppDelegate
        assert(delegate != nil)

        let viewModel = SearchViewModel(managedObjectContext: delegate.persistentContainer.newBackgroundContext())

        let viewController = UINavigationController(rootViewController: SearchViewController(viewModel: viewModel))

        self.present(viewController, animated: true)
    }

    @objc func temperatureUnitButtonPressed(_: UIButton) {
        let temperature: Temperature! = Temperature(rawValue: UserDefaults.standard.integer(forKey: Temperature.userDefaultsKey))
        assert(temperature != nil)

        switch temperature! {
        case .celsius:
            UserDefaults.standard.set(Temperature.fahrenheit.rawValue, forKey: Temperature.userDefaultsKey)
        case .fahrenheit:
            UserDefaults.standard.set(Temperature.celsius.rawValue, forKey: Temperature.userDefaultsKey)
        }
    }
}

extension LocationViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return self.viewModel.results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: type(of: self.viewModel.results[indexPath.row]).reuseIdentifier, for: indexPath)

        if let cell = cell as? LocationTableViewCell {
            cell.viewModel = self.viewModel.results[indexPath.row]
        }

        return cell
    }
}

extension LocationViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController: MainViewController! = self.presentingViewController as? MainViewController
        assert(viewController != nil)
        viewController.setCurrentPage(indexPath.row, animated: false)
        self.dismiss(animated: true)
    }

    func tableView(_: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, completionHandler in
            guard let self = self else {
                return
            }

            DispatchQueue.main.async {
                self.viewModel.changeIsUserDriven = true

                self.viewModel.deleteLocation(at: indexPath) { result in
                    let actionPerformed: Bool
                    switch result {
                    case .success:
                        self.tableView.beginUpdates()
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                        self.tableView.endUpdates()
                        actionPerformed = true
                    case let .failure(error):
                        self.errorOccurred(error)
                        actionPerformed = false
                    }
                    self.viewModel.changeIsUserDriven = false
                    completionHandler(actionPerformed)
                }
            }
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func tableView(_: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let updateAction = UIContextualAction(style: .normal, title: "업데이트") { [weak self] _, _, completionHandler in
            guard let self = self else {
                return
            }

            self.viewModel.updateLocation(at: indexPath) { result in
                DispatchQueue.main.async {
                    self.viewModel.changeIsUserDriven = true

                    let actionPerformed: Bool
                    switch result {
                    case .success:
                        self.tableView.beginUpdates()
                        self.tableView.reloadRows(at: [indexPath], with: .fade)
                        self.tableView.endUpdates()
                        actionPerformed = true
                    case let .failure(error):
                        self.errorOccurred(error)
                        actionPerformed = false
                    }
                    self.viewModel.changeIsUserDriven = false
                    completionHandler(actionPerformed)
                }
            }
        }
        
        
        return UISwipeActionsConfiguration(actions: [updateAction])
    }
}
