//
//  WeatherWindTableViewCell.swift
//  Weather
//
//  Created by 진재명 on 8/22/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import UIKit

class WeatherWindTableViewCell: UITableViewCell {
    var viewModel: WeatherWindTableViewCellViewModel? {
        didSet {
            guard let viewModel = self.viewModel else {
                return
            }

            assert(viewModel.weather.chill?.intValue != nil)
            self.chillLabel.text = "체감 온도 \(viewModel.weather.chill!.intValue)"

            assert(viewModel.weather.direction?.doubleValue != nil)
            self.directionLabel.text = "풍향 \(viewModel.weather.direction!.doubleValue)"

            assert(viewModel.weather.speed?.intValue != nil)
            self.speedLabel.text = "풍속 \(viewModel.weather.speed!.doubleValue)"
        }
    }

    weak var chillLabel: UILabel!

    weak var directionLabel: UILabel!

    weak var speedLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let chillLabel = UILabel()
        self.chillLabel = chillLabel
        chillLabel.font = .preferredFont(forTextStyle: .body)

        let directionLabel = UILabel()
        self.directionLabel = directionLabel
        directionLabel.font = .preferredFont(forTextStyle: .body)

        let speedLabel = UILabel()
        self.speedLabel = speedLabel
        speedLabel.font = .preferredFont(forTextStyle: .body)

        let stackView = UIStackView(arrangedSubviews: [chillLabel, directionLabel, speedLabel])
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

        self.chillLabel.text = nil
        self.directionLabel.text = nil
        self.speedLabel.text = nil
    }
}
