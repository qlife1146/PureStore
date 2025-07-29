//
//  MainViewController.swift
//  AdvanceApp
//
//  Created by luca on 7/29/25.
//

import RxSwift
import SnapKit
import Then
import UIKit

class MainViewController: UIViewController {
  private let viewModel = MainViewModel()
  private let disposeBag = DisposeBag()
  private var musicData: [Music] = []
  // private var podcastData: [Podcast] = []

  private let label = UILabel().then {
    $0.text = "Music"
    $0.font = .systemFont(ofSize: 32, weight: .heavy)
  }

  private let searchBar = UISearchBar().then {
    $0.placeholder = "영화, 팟캐스트"
    $0.searchTextField.backgroundColor = .systemBackground
    $0.searchTextField.layer.cornerRadius = 10
    $0.searchTextField.layer.masksToBounds = true
    $0.searchBarStyle = .minimal
    // $0.backgroundImage = UIImage()
  }

  //private lazy var collectionView

  override func viewDidLoad() {
    super.viewDidLoad()
    bind()
    configureUI()
  }

  private func bind() {
    viewModel.musicSubject
      .observe(on: MainScheduler.instance)
      .subscribe(
        onNext: { [weak self] musics in
          self?.musicData = musics
          // self?.collectionView.?.reloadData()
        },
        onError: { error in
          print("Error: \(error)")
        }
      ).disposed(by: disposeBag)
  }

  private func configureUI() {
    view.backgroundColor = .systemBackground
    [label, searchBar].forEach {
      view.addSubview($0)
    }

    label.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(0)
      $0.leading.equalTo(view.safeAreaLayoutGuide).inset(15)
      $0.trailing.equalTo(view.safeAreaLayoutGuide)
    }

    searchBar.snp.makeConstraints {
      $0.top.equalTo(label.snp.bottom).offset(0)
      $0.leading.equalTo(label.snp.leading)
      $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(15)
    }
  }
}
