//
//  MainToolBar.swift
//  Weather
//
//  Created by 진재명 on 8/14/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import UIKit

class MainToolBar: UIView {
    weak var pageControl: UIPageControl!

    weak var settingsButton: UIButton!

    weak var locationButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor(named: "GRAY0")

        let settingsButton = UIButton(type: .custom)
        self.settingsButton = settingsButton
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.setImage(UIImage(named: "cog"), for: .normal)
        settingsButton.tintColor = UIColor(named: "GRAY6")

        self.addSubview(settingsButton)

        NSLayoutConstraint.activate([
            settingsButton.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor, constant: 4.0),
            settingsButton.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerYAnchor),
        ])

        let locationButton = UIButton(type: .custom)
        self.locationButton = locationButton
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        locationButton.setImage(UIImage(named: "list-ul-solid"), for: .normal)
        locationButton.tintColor = UIColor(named: "GRAY6")

        self.addSubview(locationButton)

        NSLayoutConstraint.activate([
            self.layoutMarginsGuide.trailingAnchor.constraint(equalTo: locationButton.trailingAnchor, constant: 4.0),
            locationButton.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerYAnchor),
        ])

        let pageControl = UIPageControl()
        self.pageControl = pageControl
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = UIColor(named: "GRAY6")
        pageControl.pageIndicatorTintColor = UIColor(named: "GRAY3")
        pageControl.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)

        self.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.leadingAnchor.constraint(equalTo: settingsButton.trailingAnchor, constant: 8),
            pageControl.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerYAnchor),
            locationButton.leadingAnchor.constraint(equalTo: pageControl.trailingAnchor, constant: 8),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let context: CGContext! = UIGraphicsGetCurrentContext()
        assert(context != nil)

        let color: UIColor! = UIColor(named: "GRAY3")
        assert(color != nil)
        context.setStrokeColor(color.cgColor)

        context.setLineWidth(1.0)
        context.strokeLineSegments(between: [CGPoint(x: rect.minX, y: rect.minY), CGPoint(x: rect.maxX, y: rect.minY)])
    }
}
