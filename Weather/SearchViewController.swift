//
//  SearchViewController.swift
//  Weather
//
//  Created by 진재명 on 8/17/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import MapKit
import os
import UIKit

class SearchViewController: UIViewController {
    let viewModel: SearchViewModel

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
        let tableView = UITableView()
        self.view = tableView

        tableView.register(SearchItemTableViewCell.self, forCellReuseIdentifier: SearchItemTableViewCellViewModel.reuseIdentifier)

        tableView.dataSource = self
        tableView.delegate = self

        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.searchController = {
            let searchController = UISearchController(searchResultsController: nil)

            searchController.obscuresBackgroundDuringPresentation = false
            searchController.hidesNavigationBarDuringPresentation = false

            searchController.searchResultsUpdater = self
            searchController.searchBar.delegate = self

            return searchController
        }()

        self.definesPresentationContext = true

        self.title = "검색"
    }

    func errorOccurred(_ error: Error) {
        let alert = UIAlertController(title: "Error Occurred", message: "\(error)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }

    var pendingSearchItem: DispatchWorkItem?
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return self.viewModel.results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: type(of: self.viewModel.results[indexPath.row]).reuseIdentifier,
                                                 for: indexPath)

        if let cell = cell as? SearchItemTableViewCell {
            cell.viewModel = self.viewModel.results[indexPath.row]
        }

        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.didSelect(at: indexPath) { result in
            switch result {
            case .success:
                self.presentingViewController?.dismiss(animated: true)
            case let .failure(error):
                DispatchQueue.main.async {
                    self.errorOccurred(error)
                }
            }
        }
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), !query.isEmpty else {
            return
        }

        self.pendingSearchItem?.cancel()

        let searchItem = DispatchWorkItem { [weak self] in
            guard let self = self else {
                return
            }

            self.viewModel.search(query: query) { results in
                switch results {
                case let .success(results):
                    let oldValue = Set(self.viewModel.results)

                    let newValue = Set(results)

                    DispatchQueue.main.async {
                        self.tableView.beginUpdates()

                        self.tableView.insertRows(at: newValue.subtracting(oldValue).map { $0.indexPath }, with: .fade)
                        self.tableView.reloadRows(at: newValue.intersection(oldValue).map { $0.indexPath }, with: .fade)
                        self.tableView.deleteRows(at: oldValue.subtracting(newValue).map { $0.indexPath }, with: .fade)

                        self.tableView.endUpdates()
                    }
                case let .failure(error):
                    DispatchQueue.main.async {
                        self.errorOccurred(error)
                    }
                }
            }

            self.pendingSearchItem = nil
        }
        self.pendingSearchItem = searchItem

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300),
                                      execute: searchItem)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_: UISearchBar) {
        self.presentingViewController?.dismiss(animated: true)
    }
}
