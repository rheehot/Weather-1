//
//  MainViewController.swift
//  Weather
//
//  Created by 진재명 on 8/14/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import CoreLocation
import os
import UIKit

class MainViewController: UIViewController {
    override func loadView() {
        let view = UIView()
        self.view = view
        view.backgroundColor = .white

        let toolbar = Toolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.leftButton?.addTarget(self, action: #selector(self.settingsButtonPressed(_:)), for: .touchUpInside)
        toolbar.rightButton?.addTarget(self, action: #selector(self.citiesButtonPressed(_:)), for: .touchUpInside)

        view.addSubview(toolbar)

        NSLayoutConstraint.activate([
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: toolbar.topAnchor, constant: 44.0),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: toolbar.bottomAnchor),
        ])
    }

    @objc func settingsButtonPressed(_: UIButton) {
        let settingsURL: URL! = URL(string: UIApplication.openSettingsURLString)
        assert(settingsURL != nil)

        guard UIApplication.shared.canOpenURL(settingsURL) else {
            fatalError()
        }

        UIApplication.shared.open(settingsURL)
    }

    @objc func citiesButtonPressed(_: UIButton) {
        let viewController = CitiesViewController()
        self.present(viewController, animated: true, completion: nil)
    }
}
