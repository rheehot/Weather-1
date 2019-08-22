//
//  WeatherForecastTableViewCell.swift
//  Weather
//
//  Created by 진재명 on 8/22/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import UIKit

class WeatherForecastTableViewCell: UITableViewCell {
    var viewModel: WeatherForecastTableViewCellViewModel? {
        didSet {
            guard let viewModel = self.viewModel else {
                return
            }

            self.dateLabel.text = {
                let date: Date! = viewModel.forecast.date
                assert(date != nil)

                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .none

                return formatter.string(from: date)
            }()

            self.temperatureLabel.text = {
                let highTemperature: Double! = viewModel.forecast.highTemperature?.doubleValue
                assert(highTemperature != nil)

                let lowTemperature: Double! = viewModel.forecast.lowTemperature?.doubleValue
                assert(lowTemperature != nil)

                return "\(temperatureText(value: highTemperature)) / \(temperatureText(value: lowTemperature))"
            }()

            self.forecastLabel.text = viewModel.forecast.text
        }
    }

    func temperatureText(value: Double) -> String {
        let unit: UnitTemperature! = Temperature(rawValue: UserDefaults.standard.integer(forKey: Temperature.userDefaultsKey))?.unit
        assert(unit != nil)

        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1

        let value: String! = formatter.string(from: unit.converter.value(fromBaseUnitValue: value) as NSNumber)
        assert(value != nil)

        return "\(value!) \(unit.symbol)"
    }

    weak var dateLabel: UILabel!

    weak var temperatureLabel: UILabel!

    weak var forecastLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let dateLabel = UILabel()
        self.dateLabel = dateLabel
        dateLabel.font = .preferredFont(forTextStyle: .callout)

        let temperatureLabel = UILabel()
        self.temperatureLabel = temperatureLabel
        temperatureLabel.font = .preferredFont(forTextStyle: .body)

        let forecastLabel = UILabel()
        self.forecastLabel = forecastLabel
        forecastLabel.font = .preferredFont(forTextStyle: .body)

        let titleView = UIStackView(arrangedSubviews: [dateLabel, temperatureLabel])
        titleView.axis = .horizontal
        titleView.alignment = .center
        titleView.distribution = .equalSpacing

        let stackView = UIStackView(arrangedSubviews: [titleView, forecastLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
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

        UserDefaults.standard.addObserver(self, forKeyPath: Temperature.userDefaultsKey, options: [.new], context: self.temperatureContext)
    }

    let temperatureContext = UnsafeMutableRawPointer.allocate(byteCount: 0, alignment: 0)

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        switch context {
        case self.temperatureContext:
            self.temperatureLabel.text = {
                let highTemperature: Double! = self.viewModel?.forecast.highTemperature?.doubleValue
                assert(highTemperature != nil)

                let lowTemperature: Double! = self.viewModel?.forecast.lowTemperature?.doubleValue
                assert(lowTemperature != nil)

                return "\(temperatureText(value: highTemperature)) / \(temperatureText(value: lowTemperature))"
            }()
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: Temperature.userDefaultsKey)
        self.temperatureContext.deallocate()
    }

    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.dateLabel.text = nil
        self.temperatureLabel.text = nil
        self.forecastLabel.text = nil
    }
}
