//
//  SearchViewModel.swift
//  AdvanceApp
//
//  Created by luca on 7/31/25.
//

import Foundation
import RxSwift

class SearchViewModel {
  private let disposeBag = DisposeBag()

  let userLocale = Locale.current.region
  let searchTextSubject = BehaviorSubject<String>(value: "")
  let podcastSubject = PublishSubject<[Podcast]>()
  let movieSubject = PublishSubject<[Podcast]>()

  init(initialText: String) {
    bindSearch()
  }

  func search(query: String) {
    searchTextSubject.onNext(query)
  }

  private func bindSearch() {
    searchTextSubject
      .distinctUntilChanged()
      .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
      .flatMapLatest { [weak self] text -> Observable<(movies: [Podcast], podcasts: [Podcast])> in
        guard let self = self else { return Observable.just(([], [])) }

        return Observable.zip(
          self.fetchPodcast(for: .movie, query: text),
          self.fetchPodcast(for: .podcast, query: text)
        ).map { movie, podcast in
          return (movies: movie, podcasts: podcast)
        }
      }
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] movies, podcasts in
        print("Search Results: movie: \(movies.count), podcast: \(podcasts.count)")
        self?.movieSubject.onNext(movies)
        self?.podcastSubject.onNext(podcasts)
      })
      .disposed(by: disposeBag)
  }

  private func fetchPodcast(for media: Media, query: String) -> Observable<[Podcast]> {
    let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

    guard
      let url = URL(
        string: "https://itunes.apple.com/search?term=\(encoded)&country=\(userLocale ?? "kr")&media=\(media.apiValue)"
      )
    else {
      return Observable.error(NetworkError.invalidUrl)
    }

    return NetworkManager.shared.fetch(url: url)
      .asObservable()
      .map { (response: PodcastResponse) in response.results }
  }
}
