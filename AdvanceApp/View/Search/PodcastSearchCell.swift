//
//  PodcastSearchCell.swift
//  AdvanceApp
//
//  Created by luca on 7/31/25.
//

import Then
import UIKit

class PodcastSearchCell: UICollectionViewCell {
  static let id = "PodcastSearchCell"

  private let trackLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 20, weight: .bold)
    $0.numberOfLines = 0
  }

  private let artistLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 14)
    $0.numberOfLines = 0
    $0.textColor = .gray
  }

  private let imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
    $0.layer.cornerRadius = 8
  }

  private let textStackView = UIStackView().then {
    $0.spacing = 6
    $0.axis = .vertical
    $0.alignment = .fill
    $0.distribution = .fill
  }

  private let containerStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
    $0.alignment = .fill
    $0.distribution = .fill
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    [trackLabel, artistLabel].forEach {
      textStackView.addArrangedSubview($0)
    }

    [textStackView, imageView].forEach {
      containerStackView.addArrangedSubview($0)
    }

    contentView.addSubview(containerStackView)

    containerStackView.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(10)
    }

    imageView.snp.makeConstraints {
      $0.height.lessThanOrEqualTo(imageView.snp.width).multipliedBy(0.8)
    }

    contentView.layer.cornerRadius = 10
    contentView.backgroundColor = UIColor(red: 0.91, green: 0.95, blue: 0.97, alpha: 1.00)
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
    guard let image600Path = podcast.artworkUrl600 else { return }
    guard let url600 = URL(string: image600Path) else { return }

    trackLabel.text = trackName
    artistLabel.text = artistName

    let currentTrackName = trackName

    DispatchQueue.global(qos: .userInitiated).async {
      if let data = try? Data(contentsOf: url600) {
        if let image = UIImage(data: data) {
          DispatchQueue.main.async { [weak self] in
            // 가끔 이미지가 중복으로 적용되는 경우 해소
            if self?.trackLabel.text == currentTrackName {
              self?.imageView.image = image
            }
          }
        }
      }
    }
  }
}
