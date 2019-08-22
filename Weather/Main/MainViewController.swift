//
//  MainViewController.swift
//  Weather
//
//  Created by 진재명 on 8/14/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import CoreData
import os
import UIKit

class MainViewController: UIViewController {
    let viewModel: MainViewModel

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError()
    }

    weak var toolBar: MainToolBar!

    weak var pageViewController: UIPageViewController!

    override func loadView() {
        let view = UIView()
        self.view = view
        view.backgroundColor = .white

        let toolbar = MainToolBar()
        self.toolBar = toolbar
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.settingsButton?.addTarget(self, action: #selector(self.settingsButtonPressed(_:)), for: .touchUpInside)
        toolbar.locationButton?.addTarget(self, action: #selector(self.locationButtonPressed(_:)), for: .touchUpInside)
        toolbar.pageControl.addTarget(self, action: #selector(self.currentPageChanged), for: .valueChanged)

        view.addSubview(toolbar)

        NSLayoutConstraint.activate([
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: toolbar.topAnchor, constant: 44.0),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: toolbar.bottomAnchor),
        ])

        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageViewController = pageViewController
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.setViewControllers([MainEmptyViewController()],
                                              direction: .forward,
                                              animated: false)
        self.addChild(pageViewController)

        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(pageViewController.view)

        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: pageViewController.view.trailingAnchor),
            toolbar.topAnchor.constraint(equalTo: pageViewController.view.bottomAnchor),
        ])

        pageViewController.didMove(toParent: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.observation.append(self.viewModel.observe(\.currentPage, options: [.new]) { [weak self] _, change in
            guard let self = self else {
                return
            }

            let newValue: Int! = change.newValue
            assert(newValue != nil)

            self.toolBar.pageControl.currentPage = newValue
        })

        self.observation.append(self.viewModel.observe(\.results, options: [.new]) { [weak self] _, change in
            guard let self = self else {
                return
            }

            let newValue: [WeatherViewModel]! = change.newValue
            assert(newValue != nil)

            if !newValue.isEmpty {
                let currentPage = self.viewModel.currentPage < newValue.count - 1 ? self.viewModel.currentPage : newValue.count - 1
                self.viewModel.currentPage = currentPage
                self.pageViewController.setViewControllers([WeatherViewController(viewModel: newValue[currentPage])],
                                                           direction: .forward,
                                                           animated: false)
                self.toolBar.pageControl.numberOfPages = newValue.count
                self.toolBar.pageControl.currentPage = currentPage
            }
        })

        do {
            try self.viewModel.performFetch()
        } catch {
            self.errorOccurred(error)
        }
    }

    var observation: [NSKeyValueObservation] = []

    func errorOccurred(_ error: Error) {
        let alert = UIAlertController(title: "오류가 발생했습니다", message: "\(error)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true)
    }

    @objc func settingsButtonPressed(_: UIButton) {
        let settingsURL: URL! = URL(string: UIApplication.openSettingsURLString)
        assert(settingsURL != nil)
        assert(UIApplication.shared.canOpenURL(settingsURL))
        UIApplication.shared.open(settingsURL)
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

        let viewModel = LocationViewModel(managedObjectContext: delegate.persistentContainer.viewContext, weatherAPI: weatherAPI)
        let viewController = LocationViewController(viewModel: viewModel)
        self.present(viewController, animated: true)
    }

    @objc func currentPageChanged(_ sender: UIPageControl) {
        self.setCurrentPage(sender.currentPage, animated: true)
    }

    func setCurrentPage(_ currentPage: Int, animated: Bool) {
        self.pageViewController.setViewControllers([WeatherViewController(viewModel: self.viewModel.results[currentPage])],
                                                   direction: currentPage < self.viewModel.currentPage ? .reverse : .forward,
                                                   animated: animated)
        self.viewModel.currentPage = currentPage
    }
}

extension MainViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating _: Bool, previousViewControllers _: [UIViewController], transitionCompleted _: Bool) {
        let viewController: WeatherViewController! = pageViewController.viewControllers?.first as? WeatherViewController
        assert(viewController != nil)
        self.viewModel.currentPage = viewController.viewModel.index
    }
}

extension MainViewController: UIPageViewControllerDataSource {
    func pageViewController(_: UIPageViewController, viewControllerBefore _: UIViewController) -> UIViewController? {
        guard self.viewModel.currentPage > 0 else {
            return nil
        }
        return WeatherViewController(viewModel: self.viewModel.results[self.viewModel.currentPage - 1])
    }

    func pageViewController(_: UIPageViewController, viewControllerAfter _: UIViewController) -> UIViewController? {
        guard self.viewModel.currentPage < self.viewModel.results.count - 1 else {
            return nil
        }
        return WeatherViewController(viewModel: self.viewModel.results[self.viewModel.currentPage + 1])
    }
}
