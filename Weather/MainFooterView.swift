//
//  MainFooterView.swift
//  Weather
//
//  Created by 진재명 on 8/14/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import UIKit

class MainFooterView: UIView {
    weak var pageControl: UIPageControl?

    weak var settingsButton: UIButton?

    weak var locationButton: UIButton?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor(named: "GRAY0")

        let pageControl = UIPageControl()
        self.pageControl = pageControl
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPage = 1
        pageControl.numberOfPages = 10
        pageControl.currentPageIndicatorTintColor = UIColor(named: "GRAY6")
        pageControl.pageIndicatorTintColor = UIColor(named: "GRAY3")

        self.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            pageControl.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerYAnchor),
        ])

        let settingsButton = UIButton(type: .system)
        self.settingsButton = settingsButton
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.setImage(UIImage(named: "cog"), for: .normal)
        settingsButton.tintColor = UIColor(named: "GRAY6")

        self.addSubview(settingsButton)

        NSLayoutConstraint.activate([
            settingsButton.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor, constant: 4.0),
            settingsButton.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerYAnchor),
        ])

        let locationButton = UIButton(type: .system)
        self.locationButton = locationButton
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        locationButton.setImage(UIImage(named: "list-ul-solid"), for: .normal)
        locationButton.tintColor = UIColor(named: "GRAY6")

        self.addSubview(locationButton)

        NSLayoutConstraint.activate([
            self.layoutMarginsGuide.trailingAnchor.constraint(equalTo: locationButton.trailingAnchor, constant: 4.0),
            locationButton.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerYAnchor),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let context: CGContext! = UIGraphicsGetCurrentContext()
        assert(context != nil)

        context.move(to: CGPoint(x: rect.minX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        context.setLineWidth(1.0)

        let gray3: UIColor! = UIColor(named: "GRAY3")
        assert(gray3 != nil)
        context.setStrokeColor(gray3.cgColor)

        context.strokePath()
    }
}
