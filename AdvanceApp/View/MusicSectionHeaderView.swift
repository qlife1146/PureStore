//
//  MainViewController.swift
//  AdvanceApp
//
//  Created by luca on 7/29/25.
//

import SnapKit
import Then
import UIKit

class MusicSectionHeaderView: UICollectionReusableView {
  static let id = "MusicSectionHeaderView"

  let mainLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 20, weight: .bold)
  }

  let subLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 15, weight: .regular)
    $0.textColor = .gray
  }

  let labelStackView = UIStackView().then {
    $0.axis = .vertical
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    addSubview(labelStackView)
    [mainLabel, subLabel].forEach {
      labelStackView.addArrangedSubview($0)
    }
    labelStackView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.leading.equalToSuperview().inset(20)
      $0.trailing.equalToSuperview()
    }
  }
  
  func configure(with mainTitle: String, subTitle: String) {
    mainLabel.text = mainTitle
    subLabel.text = subTitle
  }
}
