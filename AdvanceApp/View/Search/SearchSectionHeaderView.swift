//
//  MainViewController.swift
//  AdvanceApp
//
//  Created by luca on 7/29/25.
//

import UIKit

class SearchSectionHeaderView: UICollectionReusableView {
  static let id = "SearchSectionHeaderView"

  let label = UILabel().then {
    $0.font = .systemFont(ofSize: 24, weight: .semibold)
    $0.textColor = .gray
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupUI() {
    addSubview(label)

    label.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(8)
    }
  }

  func configure(with text: String) {
    label.text = text
  }
}
