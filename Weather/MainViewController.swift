//
//  MainViewController.swift
//  Weather
//
//  Created by 진재명 on 8/14/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import CoreLocation
import MapKit
import os
import UIKit

class MainViewController: UIViewController {
    override func loadView() {
        let view = UIView()
        self.view = view
        view.backgroundColor = UIColor(red: .random(in: 0.0 ... 1.0),
                                       green: .random(in: 0.0 ... 1.0),
                                       blue: .random(in: 0.0 ... 1.0),
                                       alpha: 1.0)
    }
}
