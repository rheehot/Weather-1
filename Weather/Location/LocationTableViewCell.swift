//
//  LocationTableViewCell.swift
//  Weather
//
//  Created by 진재명 on 8/18/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {
    weak var titleLabel: UILabel!

    weak var subtitleLabel: UILabel!

    weak var temperatureLabel: UILabel!

    weak var updatedAtLabel: UILabel!
    
    func temperatureText(value: Double) -> String {
        guard let unit = Temperature(rawValue: UserDefaults.standard.integer(forKey: Temperature.userDefaultsKey))?.unit else {
            fatalError()
        }
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        
        guard let value = formatter.string(from: unit.converter.value(fromBaseUnitValue: value) as NSNumber) else {
            fatalError()
        }
        
        return "\(value) \(unit.symbol)"
    }

    var viewModel: LocationTableViewCellViewModel? {
        didSet {
            if let weather = self.viewModel?.location.weather {
                self.updatedAtLabel.text = {
                    guard let updatedAt = weather.location?.updatedAt else {
                        fatalError()
                    }

                    let formatter = DateFormatter()
                    formatter.dateStyle = .short
                    formatter.timeStyle = .short
                    return formatter.string(from: updatedAt)
                }()

                self.titleLabel.text = weather.city
                self.subtitleLabel.text = weather.text
                
                guard let value = weather.temperature?.doubleValue else {
                    fatalError()
                }
                self.temperatureLabel.text = self.temperatureText(value: value)
            } else {
                self.updatedAtLabel.text = "없음"
                self.titleLabel.text = self.viewModel?.location.title
                self.subtitleLabel.text = self.viewModel?.location.subtitle
                self.temperatureLabel.text = "없음"
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let updatedAtLabel = UILabel()
        self.updatedAtLabel = updatedAtLabel
        updatedAtLabel.font = .preferredFont(forTextStyle: .footnote)
        updatedAtLabel.textColor = UIColor(named: "GRAY5")

        let titleLabel = UILabel()
        self.titleLabel = titleLabel
        titleLabel.font = .preferredFont(forTextStyle: .title2)
        titleLabel.textColor = UIColor(named: "GRAY7")

        let subtitleLabel = UILabel()
        self.subtitleLabel = subtitleLabel
        subtitleLabel.font = .preferredFont(forTextStyle: .body)
        subtitleLabel.textColor = UIColor(named: "GRAY6")

        let contentView = UIStackView(arrangedSubviews: [subtitleLabel, titleLabel, updatedAtLabel])
        contentView.axis = .vertical
        contentView.alignment = .leading

        let temperatureLabel = UILabel()
        self.temperatureLabel = temperatureLabel
        temperatureLabel.font = .preferredFont(forTextStyle: .largeTitle)
        temperatureLabel.textColor = UIColor(named: "GRAY6")

        let stackView = UIStackView(arrangedSubviews: [contentView, temperatureLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing

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

    required init?(coder _: NSCoder) {
        fatalError()
    }
    
    let temperatureContext = UnsafeMutableRawPointer.allocate(byteCount: 0, alignment: 0)

    override func prepareForReuse() {
        super.prepareForReuse()

        self.updatedAtLabel.text = nil
        self.titleLabel.text = nil
        self.subtitleLabel.text = nil
        self.temperatureLabel.text = nil
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch context {
        case self.temperatureContext:
            guard let value = self.viewModel?.location.weather?.temperature?.doubleValue else {
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
}
