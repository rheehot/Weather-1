//
//  WeatherConditionTableViewCell.swift
//  Weather
//
//  Created by 진재명 on 8/22/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import UIKit

class WeatherConditionTableViewCell: UITableViewCell {
    var viewModel: WeatherConditionTableViewCellViewModel? {
        didSet {
            guard let viewModel = self.viewModel else {
                return
            }

            assert(viewModel.weather.text != nil)
            self.conditionLabel.text = viewModel.weather.text

            let value: Double! = viewModel.weather.temperature?.doubleValue
            assert(value != nil)

            self.temperatureLabel.text = self.temperatureText(value: value)
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

    weak var conditionLabel: UILabel!

    weak var temperatureLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let conditionLabel = UILabel()
        self.conditionLabel = conditionLabel
        conditionLabel.font = .preferredFont(forTextStyle: .title3)

        let temperatureLabel = UILabel()
        self.temperatureLabel = temperatureLabel
        temperatureLabel.font = .preferredFont(forTextStyle: .largeTitle)

        let stackView = UIStackView(arrangedSubviews: [temperatureLabel, conditionLabel])
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

        UserDefaults.standard.addObserver(self, forKeyPath: Temperature.userDefaultsKey, options: [.new], context: self.temperatureContext)
    }

    let temperatureContext = UnsafeMutableRawPointer.allocate(byteCount: 0, alignment: 0)

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        switch context {
        case self.temperatureContext:
            guard let value = self.viewModel?.weather.temperature?.doubleValue else {
                return
            }
            self.temperatureLabel.text = self.temperatureText(value: value)
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

        self.conditionLabel.text = nil
        self.temperatureLabel.text = nil
    }
}
