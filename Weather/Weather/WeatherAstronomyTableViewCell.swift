//
//  WeatherAstronomyTableViewCell.swift
//  Weather
//
//  Created by 진재명 on 8/22/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import UIKit

class WeatherAstronomyTableViewCell: UITableViewCell {
    var viewModel: WeatherAstronomyTableViewCellViewModel? {
        didSet {
            guard let viewModel = self.viewModel else {
                return
            }

            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short

            assert(viewModel.weather.sunrise != nil)
            self.sunriseLabel.text = "일출 \(formatter.string(from: viewModel.weather.sunrise!))"

            assert(viewModel.weather.sunset != nil)
            self.sunsetLabel.text = "일몰 \(formatter.string(from: viewModel.weather.sunset!))"
        }
    }

    weak var sunriseLabel: UILabel!

    weak var sunsetLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let sunriseLabel = UILabel()
        self.sunriseLabel = sunriseLabel
        sunriseLabel.font = .preferredFont(forTextStyle: .body)

        let sunsetLabel = UILabel()
        self.sunsetLabel = sunsetLabel
        sunsetLabel.font = .preferredFont(forTextStyle: .body)

        let stackView = UIStackView(arrangedSubviews: [sunriseLabel, sunsetLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
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

        self.sunriseLabel.text = nil
        self.sunsetLabel.text = nil
    }
}
