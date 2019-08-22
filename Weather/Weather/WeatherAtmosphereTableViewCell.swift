//
//  WeatherAtmosphereTableViewCell.swift
//  Weather
//
//  Created by 진재명 on 8/22/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import UIKit

class WeatherAtmosphereTableViewCell: UITableViewCell {
    var viewModel: WeatherAtmosphereTableViewCellViewModel? {
        didSet {
            guard let viewModel = self.viewModel else {
                return
            }

            assert(viewModel.weather.humidity?.intValue != nil)
            self.humidityLabel.text = "습도 \(viewModel.weather.humidity!.intValue)"

            assert(viewModel.weather.visibility?.doubleValue != nil)
            self.visibilityLabel.text = "가시거리 \(viewModel.weather.visibility!.doubleValue)"

            assert(viewModel.weather.pressure?.intValue != nil)
            self.pressureLabel.text = "기압 \(viewModel.weather.pressure!.doubleValue)"

            assert(viewModel.weather.rising?.intValue != nil)
            typealias BarometricPressure = YahooWeatherAPI.Response.CurrentObservation.Atmosphere.BarometricPressure
            let barometricPressure: BarometricPressure! = BarometricPressure(rawValue: viewModel.weather.rising!.intValue)
            assert(barometricPressure != nil)
            self.risingLabel.text = "기압상태 \(barometricPressure!)"
        }
    }

    weak var humidityLabel: UILabel!

    weak var visibilityLabel: UILabel!

    weak var pressureLabel: UILabel!

    weak var risingLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let humidityLabel = UILabel()
        self.humidityLabel = humidityLabel
        humidityLabel.font = .preferredFont(forTextStyle: .body)

        let visibilityLabel = UILabel()
        self.visibilityLabel = visibilityLabel
        visibilityLabel.font = .preferredFont(forTextStyle: .body)

        let pressureLabel = UILabel()
        self.pressureLabel = pressureLabel
        pressureLabel.font = .preferredFont(forTextStyle: .body)

        let risingLabel = UILabel()
        self.risingLabel = risingLabel
        risingLabel.font = .preferredFont(forTextStyle: .body)

        let stackView = UIStackView(arrangedSubviews: [humidityLabel, visibilityLabel, pressureLabel, risingLabel])
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

        self.humidityLabel.text = nil
        self.visibilityLabel.text = nil
        self.pressureLabel.text = nil
        self.risingLabel.text = nil
    }
}
