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

        let footerView = LocationFooterView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 64.0))
        tableView.tableFooterView = footerView

        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        assert(version != nil)

        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        assert(build != nil)

        footerView.versionLabel.text = "\(version!)(\(build!))"
        footerView.addButton.addTarget(self, action: #selector(self.addButtonPressed(_:)), for: .touchUpInside)
        footerView.temperatureUnitButton.addTarget(self, action: #selector(self.temperatureUnitButtonPressed(_:)), for: .touchUpInside)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.resultsObservation = self.viewModel.observe(\.results, options: [.new, .old]) { [weak self] _, change in
            guard let self = self else {
                return
            }

            assert(change.oldValue != nil)
            let oldValue = Set(change.oldValue!)

            assert(change.newValue != nil)
            let newValue = Set(change.newValue!)

            DispatchQueue.main.async {
                self.tableView.beginUpdates()

                self.tableView.insertRows(at: newValue.subtracting(oldValue).map { $0.indexPath }, with: .fade)
                self.tableView.reloadRows(at: newValue.intersection(oldValue).map { $0.indexPath }, with: .fade)
                self.tableView.deleteRows(at: oldValue.subtracting(newValue).map { $0.indexPath }, with: .fade)

                self.tableView.endUpdates()
            }
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.errorOccurred(notification:)),
                                               name: LocationTableViewCellViewModel.errorOccurredNotification,
                                               object: nil)
    }

    @objc func errorOccurred(notification: Notification) {
        guard let error = notification.userInfo?[LocationTableViewCellViewModel.errorUserInfoKey] as? Error else {
            return
        }
        let alert = UIAlertController(title: "오류가 발생했습니다", message: "\(error)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true)
    }

    func errorOccurred(error: Error) {
        let alert = UIAlertController(title: "오류가 발생했습니다", message: "\(error)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true)
    }

    var resultsObservation: NSKeyValueObservation?

    var tableView: UITableView {
        assert(self.view is UITableView)
        return self.view as! UITableView
    }

    @objc func addButtonPressed(_: UIButton) {
        let delegate: AppDelegate! = UIApplication.shared.delegate as? AppDelegate
        assert(delegate != nil)

        let viewModel = SearchViewModel(managedObjectContext: delegate.persistentContainer.newBackgroundContext())

        let viewController = UINavigationController(rootViewController: SearchViewController(viewModel: viewModel))

        self.present(viewController, animated: true)
    }

    @objc func temperatureUnitButtonPressed(_: UIButton) {
        guard let temperature = Temperature(rawValue: UserDefaults.standard.integer(forKey: Temperature.userDefaultsKey)) else {
            fatalError()
        }

        switch temperature {
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
    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {
        self.dismiss(animated: true)
    }

    func tableView(_: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { _, _, completionHandler in
            self.viewModel.deleteLocation(at: indexPath) { [weak self] result in
                guard let self = self else {
                    return
                }

                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        completionHandler(true)
                    case let .failure(error):
                        self.errorOccurred(error: error)
                        completionHandler(false)
                    }
                }
            }
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func tableView(_: UITableView, leadingSwipeActionsConfigurationForRowAt _: IndexPath) -> UISwipeActionsConfiguration? {
        let updateAction = UIContextualAction(style: .normal, title: "업데이트") { _, _, _ in
        }
        return UISwipeActionsConfiguration(actions: [updateAction])
    }
}
