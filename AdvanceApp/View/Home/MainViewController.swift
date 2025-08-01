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
  private var springMusicData: [Music] = []
  private var summerMusicData: [Music] = []
  private var autumnMusicData: [Music] = []
  private var winterMusicData: [Music] = []

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
    // 셀과 헤더 등록
    $0.register(SpringMusicCell.self, forCellWithReuseIdentifier: SpringMusicCell.id)
    $0.register(SeasonsMusicCell.self, forCellWithReuseIdentifier: SeasonsMusicCell.id)
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
    searchBar.delegate = self
  }

  private func bind() {
    viewModel.springSubject
      .observe(on: MainScheduler.instance)
      .subscribe(
        onNext: { [weak self] musics in
          self?.springMusicData = musics
          self?.collectionView.reloadSections(IndexSet(integer: Section.springMusic.rawValue))
        },
        onError: { error in
          print("Error: \(error)")
        }
      ).disposed(by: disposeBag)

    viewModel.summerSubject
      .observe(on: MainScheduler.instance)
      .subscribe(
        onNext: { [weak self] musics in
          self?.summerMusicData = musics
          self?.collectionView.reloadSections(IndexSet(integer: Section.summerMusic.rawValue))
        },
        onError: { error in
          print("Error: \(error)")
        }
      ).disposed(by: disposeBag)

    viewModel.autumnSubject
      .observe(on: MainScheduler.instance)
      .subscribe(
        onNext: { [weak self] musics in
          self?.autumnMusicData = musics
          self?.collectionView.reloadSections(IndexSet(integer: Section.autumnMusic.rawValue))
        },
        onError: { error in
          print("Error: \(error)")
        }
      ).disposed(by: disposeBag)

    viewModel.winterSubject
      .observe(on: MainScheduler.instance)
      .subscribe(
        onNext: { [weak self] musics in
          self?.winterMusicData = musics
          self?.collectionView.reloadSections(IndexSet(integer: Section.winterMusic.rawValue))
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
      $0.leading.equalTo(view.safeAreaLayoutGuide).inset(10)
      $0.trailing.equalTo(view.safeAreaLayoutGuide)
    }

    searchBar.snp.makeConstraints {
      $0.top.equalTo(label.snp.bottom).offset(0)
      $0.leading.equalTo(view.safeAreaLayoutGuide).inset(5)
      $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(5)
    }

    collectionView.snp.makeConstraints {
      $0.top.equalTo(searchBar.snp.bottom)
      $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
    }
  }

  private func createLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
      guard let section = Section(rawValue: sectionIndex) else { return nil }
      switch section {
      case .springMusic:
        return self?.springSectionLayout()
      case .summerMusic, .autumnMusic, .winterMusic:
        return self?.seasonsSectionLayout()
      }
    }
  }

  private func sectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
    let headerSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .estimated(44)
    )
    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: headerSize,
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top
    )
    return header
  }

  private func springSectionLayout() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalHeight(1.0)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(0.85),
      heightDimension: .fractionalHeight(0.5)
    )
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .groupPagingCentered
    section.interGroupSpacing = 10
    section.contentInsets = .init(top: 10, leading: 0, bottom: 20, trailing: 0)
    section.boundarySupplementaryItems = [sectionHeader()]

    return section
  }

  private func seasonsSectionLayout() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalHeight(0.3)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(0.85),
      heightDimension: .absolute(240)
    )
    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 3)
    group.interItemSpacing = .flexible(0)
    
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .groupPagingCentered
    section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
    section.boundarySupplementaryItems = [sectionHeader()]

    return section
  }
}

enum Section: Int, CaseIterable {
  case springMusic
  case summerMusic
  case autumnMusic
  case winterMusic

  var searchKeyword: String {
    switch self {
    case .springMusic: return "봄"
    case .summerMusic: return "여름"
    case .autumnMusic: return "가을"
    case .winterMusic: return "겨울"
    }
  }

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
      return min(springMusicData.count, 5)
    case .summerMusic:
      return min(summerMusicData.count, 9)
    case .autumnMusic:
      return min(autumnMusicData.count, 9)
    case .winterMusic:
      return min(winterMusicData.count, 9)
    default:
      return 0
    }
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let section = Section(rawValue: indexPath.section) else {
      return UICollectionViewCell()
    }

    switch section {
    case .springMusic:
      let cell =
        collectionView.dequeueReusableCell(
          withReuseIdentifier: SpringMusicCell.id,
          for: indexPath
        ) as! SpringMusicCell
      cell.configure(with: springMusicData[indexPath.item])
      return cell

    case .summerMusic:
      let cell =
        collectionView.dequeueReusableCell(
          withReuseIdentifier: SeasonsMusicCell.id,
          for: indexPath
        ) as! SeasonsMusicCell
      cell.configure(with: summerMusicData[indexPath.item])
      return cell

    case .autumnMusic:
      let cell =
        collectionView.dequeueReusableCell(
          withReuseIdentifier: SeasonsMusicCell.id,
          for: indexPath
        ) as! SeasonsMusicCell
      cell.configure(with: autumnMusicData[indexPath.item])
      return cell

    case .winterMusic:
      let cell =
        collectionView.dequeueReusableCell(
          withReuseIdentifier: SeasonsMusicCell.id,
          for: indexPath
        ) as! SeasonsMusicCell
      cell.configure(with: winterMusicData[indexPath.item])
      return cell
    }
  }

  func collectionView(
    _ collectionView: UICollectionView,
    viewForSupplementaryElementOfKind kind: String,
    at indexPath: IndexPath
  ) -> UICollectionReusableView {
    guard kind == UICollectionView.elementKindSectionHeader else {
      return UICollectionReusableView()
    }
    guard
      let headerView = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: MusicSectionHeaderView.id,
        for: indexPath
      ) as? MusicSectionHeaderView
    else {
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
 
extension MainViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let text = searchBar.text, !text.isEmpty else { return }
    let searchVC = SearchViewController(searchText: text)
    navigationController?.pushViewController(searchVC, animated: true)
    // searchBar.resignFirstResponder()
  }
}
