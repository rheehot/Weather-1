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

        let footerView = MainFooterView()
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.settingsButton?.addTarget(self, action: #selector(self.settingsButtonPressed(_:)), for: .touchUpInside)
        footerView.locationButton?.addTarget(self, action: #selector(self.locationButtonPressed(_:)), for: .touchUpInside)

        view.addSubview(footerView)

        NSLayoutConstraint.activate([
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: footerView.topAnchor, constant: 44.0),
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: footerView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: footerView.bottomAnchor),
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

    func errorOccurred(_ error: Error) {
        let alert = UIAlertController(title: "오류가 발생했습니다", message: "\(error)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true)
    }

    @objc func locationButtonPressed(_: UIButton) {
        let delegate: AppDelegate! = UIApplication.shared.delegate as? AppDelegate
        assert(delegate != nil)

        let appID: String! = Bundle.main.object(forInfoDictionaryKey: "YahooAppID") as? String
        assert(appID != nil)

        let clientID: String! = Bundle.main.object(forInfoDictionaryKey: "YahooClientID") as? String
        assert(clientID != nil)

        let clientSecret: String! = Bundle.main.object(forInfoDictionaryKey: "YahooClientSecret") as? String
        assert(clientSecret != nil)

        let weatherAPI = YahooWeatherAPI(appID: appID, clientID: clientID, clientSecret: clientSecret)

        switch Result(catching: { try LocationViewModel(managedObjectContext: delegate.persistentContainer.newBackgroundContext(), weatherAPI: weatherAPI) }) {
        case let .success(viewModel):
            let viewController = LocationViewController(viewModel: viewModel)
            self.present(viewController, animated: true)
        case let .failure(error):
            self.errorOccurred(error)
        }
    }
}
