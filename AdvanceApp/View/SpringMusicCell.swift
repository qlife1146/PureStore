//
//  MainViewController.swift
//  AdvanceApp
//
//  Created by luca on 7/29/25.
//

import Then
import UIKit

class SpringMusicCell: UICollectionViewCell {
  static let id = "SpringMusicCell"

  private let imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
    $0.backgroundColor = .darkGray
    $0.layer.cornerRadius = 10
    
  }

  private let titleLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 17, weight: .medium)
  }

  private let artistLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 13, weight: .light)
    $0.textColor = .gray
  }

  private let overlayStackView = UIStackView().then {
    $0.axis = .vertical
    $0.distribution = .fillEqually
    $0.backgroundColor = .white
    $0.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    $0.isLayoutMarginsRelativeArrangement = true
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(imageView)
    imageView.addSubview(overlayStackView)
    [titleLabel, artistLabel].forEach {
      overlayStackView.addArrangedSubview($0)
    }

    imageView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }

    overlayStackView.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
      // $0.height.equalTo(imageView.snp.height).dividedBy(3)
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
    
    titleLabel.text = trackName
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
