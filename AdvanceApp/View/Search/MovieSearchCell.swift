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
    $0.numberOfLines = 2
    $0.lineBreakMode = .byTruncatingTail
    // $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
  }
  

  private let artistLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 14)
    $0.textColor = .gray
    $0.numberOfLines = 1
    $0.lineBreakMode = .byTruncatingTail
    // $0.setContentHuggingPriority(.defaultLow, for: .vertical)
  }

  private let imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
    $0.layer.cornerRadius = 8
  }

  private let textStackView = UIStackView().then {
    $0.spacing = 4
    $0.axis = .vertical
    $0.alignment = .fill
    $0.distribution = .fill
    $0.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    $0.isLayoutMarginsRelativeArrangement = true
  }

  private let containerStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 6
    $0.alignment = .center
    $0.distribution = .fill
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    [trackLabel, artistLabel].forEach {
      textStackView.addArrangedSubview($0)
    }

    [imageView, textStackView].forEach {
      containerStackView.addArrangedSubview($0)
    }

    contentView.addSubview(containerStackView)

    // textStackView.snp.makeConstraints {
    //   $0.verticalEdges.equalToSuperview().inset(20)
    // }
    
    containerStackView.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(10)
    }

    imageView.snp.makeConstraints {
      $0.width.equalTo(80)
      $0.height.equalTo(imageView.snp.width)
    }
    textStackView.snp.makeConstraints {
      // $0.leading.trailing.equalToSuperview()
      $0.centerY.equalToSuperview()
    }

    contentView.layer.cornerRadius = 10
    contentView.backgroundColor = UIColor(red: 0.98, green: 0.91, blue: 0.84, alpha: 1.00)
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
