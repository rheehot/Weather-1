//
//  WeatherLocationTableViewCell.swift
//  Weather
//
//  Created by 진재명 on 8/22/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import UIKit

class WeatherLocationTableViewCell: UITableViewCell {
    var viewModel: WeatherLocationTableViewCellViewModel? {
        didSet {
            guard let viewModel = self.viewModel else {
                return
            }

            assert(viewModel.weather.city != nil)
            self.cityLabel.text = "(\(viewModel.weather.city!))"

            assert(viewModel.weather.region != nil)
            self.regionLabel.text = viewModel.weather.region

            assert(viewModel.weather.country != nil)
            self.countryLabel.text = viewModel.weather.country
        }
    }

    weak var countryLabel: UILabel!

    weak var cityLabel: UILabel!

    weak var regionLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let cityLabel = UILabel()
        self.cityLabel = cityLabel
        cityLabel.font = .preferredFont(forTextStyle: .callout)

        let regionLabel = UILabel()
        self.regionLabel = regionLabel
        regionLabel.font = .preferredFont(forTextStyle: .largeTitle)

        let regionView = UIStackView(arrangedSubviews: [regionLabel, cityLabel])
        regionView.axis = .horizontal
        regionView.alignment = .center
        regionView.distribution = .equalSpacing
        regionView.spacing = 8

        let countryLabel = UILabel()
        self.countryLabel = countryLabel
        countryLabel.font = .preferredFont(forTextStyle: .title3)

        let stackView = UIStackView(arrangedSubviews: [regionView, countryLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 8

        self.contentView.addSubview(stackView)

        let constraints: [NSLayoutConstraint] = [
            stackView.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
            self.contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            self.contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
        ]
        .map { layoutConstraint in
            layoutConstraint.priority = .defaultHigh
            return layoutConstraint
        }

        NSLayoutConstraint.activate(constraints)
    }

    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.cityLabel.text = nil
        self.regionLabel.text = nil
        self.countryLabel.text = nil
    }
}
