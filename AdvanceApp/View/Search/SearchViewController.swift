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
  private var didInitialSearch: Bool = false

  private var podcastData: [Podcast] = []
  private var movieData: [Podcast] = []

  private lazy var searchKeywordLabel = UILabel().then {
    $0.text = searchText
    $0.font = .systemFont(ofSize: 40, weight: .heavy)
  }

  private let searchBar = UISearchBar().then {
    $0.placeholder = "영화, 팟캐스트"
    $0.searchTextField.backgroundColor = .systemBackground
    $0.searchTextField.layer.cornerRadius = 10
    $0.searchTextField.layer.masksToBounds = true
    $0.searchBarStyle = .minimal
    // $0.showsCancelButton = true
  }

  private let emptyLabel = UILabel().then {
    $0.text = "검색 결과를 찾을 수 없습니다."
    $0.textAlignment = .center
    $0.font = .systemFont(ofSize: 20, weight: .medium)
    $0.isHidden = true
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
    self.viewModel = SearchViewModel(initialText: searchText)
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    searchBar.becomeFirstResponder()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    searchBar.delegate = self
    navigationItem.hidesBackButton = true

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(keywordLabelTapped))
    searchKeywordLabel.isUserInteractionEnabled = true
    searchKeywordLabel.addGestureRecognizer(tapGesture)

    bind()
    configureUI()
    updateUI()

    viewModel.search(query: searchText)
  }

  private func bind() {
    viewModel.podcastSubject
      .observe(on: MainScheduler.instance)
      .subscribe(
        onNext: { [weak self] datas in
          print("podcast: \(datas.count)")
          self?.podcastData = datas
          self?.didInitialSearch = true
          guard let self = self else { return }
          self.collectionView.collectionViewLayout = self.createLayout()
          self.collectionView.reloadData()
          self.updateEmptyState()
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
          self?.didInitialSearch = true
          guard let self = self else { return }
          self.collectionView.collectionViewLayout = self.createLayout()
          self.collectionView.reloadData()
          self.updateEmptyState()
        },
        onError: { error in
          print("\(error)")
        }
      ).disposed(by: disposeBag)

    viewModel.searchTextSubject
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] newText in
        self?.searchKeywordLabel.text = newText
      }).disposed(by: disposeBag)
  }

  private func updateEmptyState() {
    guard didInitialSearch else {
      emptyLabel.isHidden = true
      collectionView.isHidden = false
      return
    }
    let hasPodcast = !podcastData.isEmpty
    let hasMovie = !movieData.isEmpty
    emptyLabel.isHidden = hasPodcast || hasMovie
    collectionView.isHidden = !emptyLabel.isHidden
  }

  private func configureUI() {
    view.backgroundColor = .systemBackground
    [searchKeywordLabel, searchBar, collectionView, emptyLabel].forEach {
      view.addSubview($0)
    }

    searchKeywordLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(10)
      $0.leading.equalToSuperview().inset(10)
      $0.trailing.equalToSuperview()
    }

    searchBar.snp.makeConstraints {
      $0.top.equalTo(searchKeywordLabel.snp.bottom).offset(5)
      $0.leading.trailing.equalToSuperview().inset(10)
    }

    collectionView.snp.makeConstraints {
      $0.top.equalTo(searchBar.snp.bottom)
      $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
    }

    emptyLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }

  @objc private func keywordLabelTapped() {
    navigationController?.popViewController(animated: true)
  }

  private func updateUI() {
    collectionView.collectionViewLayout = self.createLayout()
    collectionView.reloadData()
    updateEmptyState()
  }

  private func createLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
      guard let self = self else { return nil }

      let validSections = Media.allCases.reversed().filter {
        switch $0 {
        case .podcast: return !self.podcastData.isEmpty
        case .movie: return !self.movieData.isEmpty
        }
      }

      guard sectionIndex < validSections.count else { return nil }
      let media = validSections[sectionIndex]

      switch media {
      case .podcast: return self.podcastSectionLayout()
      case .movie: return self.movieSectionLayout()
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

  private func podcastSectionLayout() -> NSCollectionLayoutSection {
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
    group.contentInsets.leading = 30

    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .none
    section.interGroupSpacing = 20
    // section.contentInsets = .init(top: 0, leading: 30, bottom: 0, trailing: 30)
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
      heightDimension: .fractionalHeight(0.2)
    )
    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
    group.contentInsets.leading = 30

    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .none
    section.interGroupSpacing = 10
    // section.contentInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 10)
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
    let validSections = Media.allCases.reversed().filter {
      switch $0 {
      case .podcast: return !podcastData.isEmpty
      case .movie: return !movieData.isEmpty
      }
    }
    guard section < validSections.count else { return 0 }
    switch validSections[section] {
    case .podcast:
      return min(podcastData.count, 4)
    case .movie:
      return min(movieData.count, 4)
    }
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let validSections = Media.allCases.reversed().filter {
      switch $0 {
      case .podcast: return !podcastData.isEmpty
      case .movie: return !movieData.isEmpty
      }
    }
    guard indexPath.section < validSections.count else {
      return UICollectionViewCell()
    }
    let section = validSections[indexPath.section]

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

    let validSections = Media.allCases.reversed().filter {
      switch $0 {
      case .podcast: return !podcastData.isEmpty
      case .movie: return !movieData.isEmpty
      }
    }
    guard indexPath.section < validSections.count else {
      headerView.configure(with: "")
      return headerView
    }

    let section = validSections[indexPath.section]

    switch section {
    case .podcast:
      headerView.configure(with: "Podcast")
    case .movie:
      headerView.configure(with: "Movie")
    }

    return headerView
  }

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return Media.allCases.reversed().filter {
      switch $0 {
      case .podcast: return !podcastData.isEmpty
      case .movie: return !movieData.isEmpty
      }
    }.count
  }
}

extension SearchViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let query = searchBar.text, !query.isEmpty else { return }
    viewModel.search(query: query)
    searchBar.resignFirstResponder()
  }

  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    searchBar.showsCancelButton = true
  }

  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    searchBar.showsCancelButton = false
  }

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    searchBar.text = ""
    searchBar.showsCancelButton = false
  }
}
