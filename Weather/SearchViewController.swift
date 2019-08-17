//
//  SearchViewController.swift
//  Weather
//
//  Created by 진재명 on 8/17/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import os
import UIKit

class SearchViewController: UIViewController {
    var viewModel: SearchViewModel

    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError()
    }

    var tableView: UITableView {
        assert(self.view is UITableView)
        return self.view as! UITableView
    }

    override func loadView() {
        let tableView = UITableView(frame: .zero, style: .plain)
        self.view = tableView

        tableView.register(SearchItemTableViewCell.self, forCellReuseIdentifier: SearchItemTableViewCell.reuseIdentifier)

        tableView.dataSource = self
        tableView.delegate = self

        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.searchController = {
            let searchController = UISearchController(searchResultsController: nil)

            searchController.hidesNavigationBarDuringPresentation = false

            searchController.delegate = self
            searchController.searchResultsUpdater = self
            searchController.dimsBackgroundDuringPresentation = false

            searchController.searchBar.showsCancelButton = true
            searchController.searchBar.delegate = self

            return searchController
        }()

        self.definesPresentationContext = true

        self.title = "Search"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.observation.append(self.viewModel.observe(\.results) { [weak self] _, _ in
            guard let self = self else {
                return
            }
            self.tableView.reloadData()
        })

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.errorOccurred(_:)),
                                               name: SearchViewModel.errorOccurredNotification,
                                               object: self.viewModel)
    }

    @objc func errorOccurred(_ notification: Notification) {
        guard let error = notification.userInfo?[SearchViewModel.errorUserInfoKey] as? Error else {
            return
        }

        let alert = UIAlertController(title: "Error Occurred", message: "\(error)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }

    var observation: [NSKeyValueObservation] = []
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return self.viewModel.results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchItemTableViewCell.reuseIdentifier, for: indexPath)

        if let cell = cell as? SearchItemTableViewCell {
            cell.viewModel = self.viewModel.results[indexPath.row]
        }

        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {}
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        assert(searchController.searchBar.text != nil)
        self.viewModel.search(query: searchController.searchBar.text!)
    }
}

extension SearchViewController: UISearchControllerDelegate {}

extension SearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_: UISearchBar) {
        self.dismiss(animated: true)
    }
}
