//
//  WeatherViewController.swift
//  Weather
//
//  Created by 진재명 on 8/14/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController {
    let viewModel: WeatherViewModel

    var tableView: UITableView {
        let tableView: UITableView! = self.view as? UITableView
        assert(tableView != nil)
        return tableView
    }

    init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func loadView() {
        let tableView = UITableView()
        self.view = tableView
        tableView.separatorStyle = .none
        tableView.allowsSelection = false

        tableView.register(WeatherForecastTableViewCell.self,
                           forCellReuseIdentifier: WeatherForecastTableViewCellViewModel.reuseIdentifier)
        tableView.register(WeatherLocationTableViewCell.self,
                           forCellReuseIdentifier: WeatherLocationTableViewCellViewModel.reuseIdentifier)
        tableView.register(WeatherConditionTableViewCell.self,
                           forCellReuseIdentifier: WeatherConditionTableViewCellViewModel.reuseIdentifier)
        tableView.register(WeatherAstronomyTableViewCell.self,
                           forCellReuseIdentifier: WeatherAstronomyTableViewCellViewModel.reuseIdentifier)
        tableView.register(WeatherAtmosphereTableViewCell.self,
                           forCellReuseIdentifier: WeatherAtmosphereTableViewCellViewModel.reuseIdentifier)
        tableView.register(WeatherWindTableViewCell.self,
                           forCellReuseIdentifier: WeatherWindTableViewCellViewModel.reuseIdentifier)

        tableView.dataSource = self

        if let publicationDate = self.viewModel.location.weather?.publicationDate {
            let publicationDateLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 64.0))
            tableView.tableFooterView = publicationDateLabel
            publicationDateLabel.font = .preferredFont(forTextStyle: .footnote)
            publicationDateLabel.textAlignment = .center

            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short

            publicationDateLabel.text = formatter.string(from: publicationDate)
        }
    }
}

extension WeatherViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return self.viewModel.results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = self.viewModel.results[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: type(of: viewModel).reuseIdentifier, for: indexPath)

        switch (cell, viewModel) {
        case let (cell, viewModel) as (WeatherLocationTableViewCell, WeatherLocationTableViewCellViewModel):
            cell.viewModel = viewModel
        case let (cell, viewModel) as (WeatherForecastTableViewCell, WeatherForecastTableViewCellViewModel):
            cell.viewModel = viewModel
        case let (cell, viewModel) as (WeatherConditionTableViewCell, WeatherConditionTableViewCellViewModel):
            cell.viewModel = viewModel
        case let (cell, viewModel) as (WeatherAstronomyTableViewCell, WeatherAstronomyTableViewCellViewModel):
            cell.viewModel = viewModel
        case let (cell, viewModel) as (WeatherAtmosphereTableViewCell, WeatherAtmosphereTableViewCellViewModel):
            cell.viewModel = viewModel
        case let (cell, viewModel) as (WeatherWindTableViewCell, WeatherWindTableViewCellViewModel):
            cell.viewModel = viewModel
        default:
            fatalError()
        }

        return cell
    }
}
