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

  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
    $0.register(MusicCell.self, forCellWithReuseIdentifier: MusicCell.id)
    $0
      .register(
        MusicSectionHeaderView.self,
        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
        withReuseIdentifier: MusicSectionHeaderView.id
      )
    $0.delegate = self
    $0.dataSource = self
    $0.backgroundColor = .systemBackground
  }

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
          self?.collectionView.reloadData()
        },
        onError: { error in
          print("Error: \(error)")
        }
      ).disposed(by: disposeBag)
  }

  private func configureUI() {
    view.backgroundColor = .systemBackground
    [label, searchBar, collectionView].forEach {
      view.addSubview($0)
    }

    label.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(0)
      $0.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
      $0.trailing.equalTo(view.safeAreaLayoutGuide)
    }

    searchBar.snp.makeConstraints {
      $0.top.equalTo(label.snp.bottom).offset(0)
      $0.leading.equalTo(view.safeAreaLayoutGuide).inset(10)
      $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
    }
    
    collectionView.snp.makeConstraints {
      $0.top.equalTo(searchBar.snp.bottom)
      $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
    }
  }

  private func createLayout() -> UICollectionViewLayout {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalHeight(1.0)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(0.9),
      heightDimension: .fractionalHeight(0.5)
    )
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .groupPagingCentered
    section.interGroupSpacing = 10
    section.contentInsets = .init(top: 10, leading: 0, bottom: 20, trailing: 0)

    let headerSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .estimated(44)
    )
    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: headerSize,
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top
    )
    section.boundarySupplementaryItems = [header]

    return UICollectionViewCompositionalLayout(section: section)
  }
}

enum Section: Int, CaseIterable {
  case springMusic
  case summerMusic
  case autumnMusic
  case winterMusic

  var mainTitle: String {
    switch self {
    case .springMusic: return "봄 Best"
    case .summerMusic: return "여름"
    case .autumnMusic: return "가을"
    case .winterMusic: return "겨울"
    }
  }

  var subTitle: String {
    switch self {
    case .springMusic: return "봄에 어울리는 음악 Best 5"
    case .summerMusic: return "여름에 어울리는 음악"
    case .autumnMusic: return "가을에 어울리는 음악"
    case .winterMusic: return "겨울에 어울리는 음악"
    }
  }
}

extension MainViewController: UICollectionViewDelegate {

}

extension MainViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch Section(rawValue: section) {
    case .springMusic:
      return min(musicData.count, 5)
    default:
      return 0
    }
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard
      let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: MusicCell.id,
        for: indexPath
      ) as? MusicCell
    else {
      return UICollectionViewCell()
    }

    switch Section(rawValue: indexPath.section) {
    case .springMusic:
      cell.configure(with: musicData[indexPath.row])
    default:
      return UICollectionViewCell()
    }
    return cell
  }

  func collectionView(
    _ collectionView: UICollectionView,
    viewForSupplementaryElementOfKind kind: String,
    at indexPath: IndexPath
  ) -> UICollectionReusableView {
    guard kind == UICollectionView.elementKindSectionHeader else {
      return UICollectionReusableView()
    }
    guard let headerView = collectionView.dequeueReusableSupplementaryView(
      ofKind: kind,
      withReuseIdentifier: MusicSectionHeaderView.id,
      for: indexPath
    ) as? MusicSectionHeaderView else {
      return UICollectionReusableView()
    }
    let sectionType = Section.allCases[indexPath.section]
    headerView.configure(with: sectionType.mainTitle, subTitle: sectionType.subTitle)
    
    return headerView
  }

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return Section.allCases.count
  }
}
