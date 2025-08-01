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

class SearchViewController: UIViewController {
  private let viewModel: SearchViewModel
  private let disposeBag = DisposeBag()
  private let searchText: String

  private var podcastData: [Podcast] = []
  private var movieData: [Podcast] = []

  private lazy var label = UILabel().then {
    $0.text = searchText
    $0.font = .systemFont(ofSize: 40, weight: .heavy)
  }

  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
    $0.register(PodcastSearchCell.self, forCellWithReuseIdentifier: PodcastSearchCell.id)
    $0.register(MovieSearchCell.self, forCellWithReuseIdentifier: MovieSearchCell.id)
    $0
      .register(
        SearchSectionHeaderView.self,
        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
        withReuseIdentifier: SearchSectionHeaderView.id
      )
    $0.delegate = self
    $0.dataSource = self
    $0.backgroundColor = .systemBackground
  }

  init(searchText: String) {
    self.searchText = searchText
    self.viewModel = SearchViewModel(searchText: searchText)
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    bind()
    configureUI()
  }

  private func bind() {
    viewModel.podcastSubject
      .observe(on: MainScheduler.instance)
      .subscribe(
        onNext: { [weak self] datas in
          print("podcast: \(datas.count)")
          self?.podcastData = datas
          self?.collectionView.reloadSections(IndexSet(integer: Media.podcast.rawValue))
        },
        onError: { error in
          print("\(error)")
        }
      ).disposed(by: disposeBag)

    viewModel.movieSubject
      .observe(on: MainScheduler.instance)
      .subscribe(
        onNext: { [weak self] datas in
          print("movie: \(datas.count)")
          self?.movieData = datas
          self?.collectionView.reloadSections(IndexSet(integer: Media.movie.rawValue))
        },
        onError: { error in
          print("\(error)")
        }
      ).disposed(by: disposeBag)
  }

  private func configureUI() {
    view.backgroundColor = .systemBackground
    [label, collectionView].forEach {
      view.addSubview($0)
    }

    label.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(10)
      $0.leading.equalTo(view.safeAreaLayoutGuide).inset(10)
      $0.trailing.equalTo(view.safeAreaLayoutGuide)
    }

    collectionView.snp.makeConstraints {
      $0.top.equalTo(label.snp.bottom).inset(10)
      $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
    }
  }

  private func createLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
      guard let media = Media(rawValue: sectionIndex) else { return nil }
      switch media {
      case .podcast:
        return self?.podcastSectionLayout()
      case .movie:
        return self?.movieSectionLayout()
      }
    }
  }

  private func sectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
    let headerSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalHeight(0.2)
    )
    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: headerSize,
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top
    )
    return header
  }

  private func podcastSectionLayout() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .estimated(200)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(0.85),
      heightDimension: .estimated(200)
    )
    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .none
    section.interGroupSpacing = 10
    section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
    section.boundarySupplementaryItems = [sectionHeader()]

    return section
  }

  private func movieSectionLayout() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalHeight(1.0)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(0.85),
      heightDimension: .fractionalHeight(0.5)
    )
    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .none
    section.interGroupSpacing = 10
    section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
    section.boundarySupplementaryItems = [sectionHeader()]

    return section
  }

}

enum Media: Int, CaseIterable {
  case movie
  case podcast

  var title: String {
    switch self {
    case .podcast:
      return "Podcast"
    case .movie:
      return "Movie"
    }
  }
  
  var apiValue: String {
    switch self {
    case .podcast:
      return "podcast"
    case .movie:
      return "movie"
    }
  }
}

extension SearchViewController: UICollectionViewDelegate {

}

extension SearchViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    // 보여줄 데이터 양
    // podcastData.count = 전체
    // min(podcastData.count, 4) = 두 매개변수 비교해 더 적은 개수
    switch Media(rawValue: section) {
    case .podcast:
      return min(podcastData.count, 4)
    case .movie:
      return min(movieData.count, 4)
    default:
      return 0
    }
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let section = Media(rawValue: indexPath.section) else {
      return UICollectionViewCell()
    }

    switch section {
    case .podcast:
      let cell =
        collectionView.dequeueReusableCell(
          withReuseIdentifier: PodcastSearchCell.id,
          for: indexPath
        ) as! PodcastSearchCell
      cell.configure(with: podcastData[indexPath.item])
      return cell

    case .movie:
      let cell =
        collectionView.dequeueReusableCell(
          withReuseIdentifier: MovieSearchCell.id,
          for: indexPath
        ) as! MovieSearchCell
      cell.configure(with: movieData[indexPath.item])
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
        withReuseIdentifier: SearchSectionHeaderView.id,
        for: indexPath
      ) as? SearchSectionHeaderView
    else {
      return UICollectionReusableView()
    }
    
    let section = Media(rawValue: indexPath.section)
    
    switch section {
    case .podcast:
      headerView.configure(with: "Podcast")
    case .movie:
      headerView.configure(with: "Movie")
    default:
      headerView.configure(with: "")
    }
    
    return headerView
  }

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return Media.allCases.count
  }
}
