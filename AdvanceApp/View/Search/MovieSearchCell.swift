//
//  MainViewController.swift
//  AdvanceApp
//
//  Created by luca on 7/29/25.
//

import Then
import UIKit

class MovieSearchCell: UICollectionViewCell {
  static let id = "MovieSearchCell"

  private let trackLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 20, weight: .bold)
  }

  private let artistLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 14)
    $0.textColor = .gray
  }

  private let imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
    $0.clipsToBounds = true
  }

  private let stackView = UIStackView().then {
    $0.layer.cornerRadius = 10
    $0.spacing = 6
    $0.axis = .vertical
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(stackView)

    [trackLabel, artistLabel, imageView].forEach {
      stackView.addArrangedSubview($0)
    }

    stackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    imageView.image = nil
  }

  func configure(with podcast: Podcast) {
    guard let trackName = podcast.trackName else { return }
    guard let artistName = podcast.artistName else { return }
    guard let imagePath = podcast.artworkUrl else { return }
    guard let url = URL(string: imagePath) else { return }

    trackLabel.text = trackName
    artistLabel.text = artistName

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
