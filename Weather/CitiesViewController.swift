//
//  CitiesViewController.swift
//  Weather
//
//  Created by 진재명 on 8/14/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import UIKit

class CitiesViewController: UIViewController {
    override func loadView() {
        let tableView = UITableView(frame: .zero, style: .plain)
        self.view = tableView
        tableView.dataSource = self
        tableView.delegate = self

        let footerView = CitiesFooterView()
        footerView.frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 64.0)
        tableView.tableFooterView = footerView
        footerView.addButton?.addTarget(self, action: #selector(self.addButtonPressed(_:)), for: .touchUpInside)
    }

    var tableView: UITableView {
        assert(self.view is UITableView)
        return self.view as! UITableView
    }
    
    @objc func addButtonPressed(_ sender: UIButton) {
        let viewController = UINavigationController(rootViewController: SearchViewController())
        self.present(viewController, animated: true, completion: nil)
    }
}

extension CitiesViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
    }
}

extension CitiesViewController: UITableViewDelegate {}
