//
//  LocationFooterView.swift
//  Weather
//
//  Created by 진재명 on 8/17/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import UIKit

class LocationFooterView: UIView {
    weak var versionLabel: UILabel!

    weak var addButton: UIButton!

    weak var temperatureUnitButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)

        let versionLabel = UILabel()
        self.versionLabel = versionLabel
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.font = .preferredFont(forTextStyle: .footnote)
        versionLabel.textColor = UIColor(named: "GRAY6")

        self.addSubview(versionLabel)

        NSLayoutConstraint.activate([
            versionLabel.centerXAnchor.constraint(equalTo: self.layoutMarginsGuide.centerXAnchor),
            self.layoutMarginsGuide.bottomAnchor.constraint(equalTo: versionLabel.bottomAnchor),
        ])

        let addButton = UIButton(type: .custom)
        self.addButton = addButton
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setImage(UIImage(named: "plus"), for: .normal)
        addButton.tintColor = UIColor(named: "GRAY6")

        self.addSubview(addButton)

        NSLayoutConstraint.activate([
            self.layoutMarginsGuide.trailingAnchor.constraint(equalTo: addButton.trailingAnchor, constant: 4.0),
            addButton.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerYAnchor),
        ])

        let temperatureUnitButton = UIButton(type: .custom)
        self.temperatureUnitButton = temperatureUnitButton
        temperatureUnitButton.translatesAutoresizingMaskIntoConstraints = false
        temperatureUnitButton.setImage(UIImage(named: "temperature"), for: .normal)
        temperatureUnitButton.tintColor = UIColor(named: "GRAY6")

        self.addSubview(temperatureUnitButton)

        NSLayoutConstraint.activate([
            temperatureUnitButton.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor, constant: 4.0),
            temperatureUnitButton.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerYAnchor),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError()
    }
}
