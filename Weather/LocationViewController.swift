//
//  LocationViewController.swift
//  Weather
//
//  Created by 진재명 on 8/14/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

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
        let tableView = UITableView(frame: .zero, style: .plain)
        self.view = tableView

        tableView.register(LocationTableViewCell.self, forCellReuseIdentifier: LocationTableViewCellViewModel.reuseIdentifier)

        tableView.dataSource = self
        tableView.delegate = self

        let footerView = LocationFooterView()
        footerView.frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 64.0)
        tableView.tableFooterView = footerView
        footerView.addButton?.addTarget(self, action: #selector(self.addButtonPressed(_:)), for: .touchUpInside)
        footerView.temperatureUnitButton?.addTarget(self, action: #selector(self.temperatureUnitButtonPressed(_:)), for: .touchUpInside)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.resultsObservation = self.viewModel.observe(\.results, options: [.old, .new]) { _, change in
            assert(change.oldValue != nil)
            let oldValue = Set(change.oldValue!)

            assert(change.newValue != nil)
            let newValue = Set(change.newValue!)

            self.tableView.beginUpdates()

            self.tableView.insertRows(at: newValue.subtracting(oldValue).map { $0.indexPath }, with: .fade)
            self.tableView.reloadRows(at: newValue.intersection(oldValue).map { $0.indexPath }, with: .fade)
            self.tableView.deleteRows(at: oldValue.subtracting(newValue).map { $0.indexPath }, with: .fade)

            self.tableView.endUpdates()
        }
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
        self.dismiss(animated: true)
    }
}

extension LocationViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return self.viewModel.results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: type(of: self.viewModel.results[indexPath.row]).reuseIdentifier,
                                                 for: indexPath)

        if let cell = cell as? LocationTableViewCell {
            cell.viewModel = self.viewModel.results[indexPath.row]
        }

        return cell
    }
}

extension LocationViewController: UITableViewDelegate {}
