//
//  SearchItemTableViewCell.swift
//  Weather
//
//  Created by 진재명 on 8/17/19.
//  Copyright © 2019 Jaemyeong Jin. All rights reserved.
//

import UIKit

class SearchItemTableViewCell: UITableViewCell {
    static let reuseIdentifier = "SearchItemTableViewCell"

    weak var titleLabel: UILabel?

    weak var subtitleLabel: UILabel?

    var viewModel: SearchItemTableViewCellViewModel? {
        didSet {
            self.titleLabel?.text = self.viewModel?.title
            self.subtitleLabel?.text = self.viewModel?.subtitle
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let titleLabel = UILabel()
        self.titleLabel = titleLabel
        titleLabel.font = .preferredFont(forTextStyle: .title2)
        titleLabel.textColor = UIColor(named: "GRAY7")
        titleLabel.numberOfLines = 0

        let subtitleLabel = UILabel()
        self.subtitleLabel = subtitleLabel
        subtitleLabel.font = .preferredFont(forTextStyle: .body)
        subtitleLabel.textColor = UIColor(named: "GRAY6")
        subtitleLabel.numberOfLines = 0

        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading

        self.contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
            self.contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            self.contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.titleLabel?.text = nil
        self.subtitleLabel?.text = nil
    }
}
