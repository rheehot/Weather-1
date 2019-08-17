//
//  WeatherViewController.swift
//  Weather
//
//  Created by 진재명 on 8/14/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import os
import UIKit

class WeatherToolbar: UIView {}

class WeatherViewController: UIViewController {
    weak var toolbar: WeatherToolbar?

    override func loadView() {
        let view = UIView()
        self.view = view
        view.backgroundColor = .white

        let toolbar = WeatherToolbar()
        self.toolbar = toolbar
        toolbar.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(toolbar)

        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: toolbar.bottomAnchor),
        ])
    }
}
