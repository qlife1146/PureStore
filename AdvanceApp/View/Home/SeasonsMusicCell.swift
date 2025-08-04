//
//  MainViewController.swift
//  AdvanceApp
//
//  Created by luca on 7/29/25.
//

import Then
import UIKit

class SeasonsMusicCell: UICollectionViewCell {
  static let id = "SeasonsMusicCell"

  private let imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
    $0.clipsToBounds = true
    $0.backgroundColor = .darkGray
    $0.layer.cornerRadius = 10

  }

  private let titleLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 17, weight: .bold)
  }

  private let artistLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 14, weight: .medium)
  }

  private let collectionLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 10, weight: .light)
    $0.textColor = .gray
  }

  private let textStackView = UIStackView().then {
    $0.axis = .vertical
    $0.distribution = .fillEqually
    $0.spacing = 4
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
  }

  private let fullStackView = UIStackView().then {
    $0.axis = .horizontal
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    contentView.addSubview(fullStackView)

    [titleLabel, artistLabel, collectionLabel].forEach {
      textStackView.addArrangedSubview($0)
    }

    [imageView, textStackView].forEach {
      fullStackView.addArrangedSubview($0)
    }

    fullStackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }

    imageView.snp.makeConstraints {
      $0.width.equalTo(imageView.snp.height)
      $0.trailing.equalTo(textStackView.snp.leading).offset(-10)
      // $0.height.lessThanOrEqualToSuperview().multipliedBy(0.7)
      // $0.height.equalTo(80)
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    imageView.image = nil
  }

  func configure(with music: Music) {
    guard let imagePath = music.artworkUrl else { return }
    guard let url = URL(string: imagePath) else { return }
    guard let trackName = music.trackName else { return }
    guard let artistName = music.artistName else { return }
    guard let collectionName = music.collectionName else { return }

    titleLabel.text = trackName
    artistLabel.text = artistName
    collectionLabel.text = collectionName

    DispatchQueue.global(qos: .userInitiated).async {
      if let data = try? Data(contentsOf: url) {
        if let image = UIImage(data: data) {
          DispatchQueue.main.async { [weak self] in
            self?.imageView.image = image
          }
        }
      }
    }
  }
}
