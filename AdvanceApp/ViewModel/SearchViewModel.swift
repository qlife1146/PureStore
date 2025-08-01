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
  private let searchText: String

  let userLocale = Locale.current.region
  let podcastSubject: BehaviorSubject = BehaviorSubject(value: [Podcast]())
  let movieSubject: BehaviorSubject = BehaviorSubject(value: [Podcast]())

  init(searchText: String) {
    self.searchText = searchText
    fetchPodcast(for: .podcast)
    fetchPodcast(for: .movie)
  }

  func fetchPodcast(for media: Media) {
    let encodedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

    guard
      let url = URL(
        string:
          "https://itunes.apple.com/search?term=\(encodedSearchText ?? "")&country=\(userLocale ?? "kr")&media=\(media.apiValue)"
      )
    else {
      podcastSubject.onError(NetworkError.invalidUrl)
      return
    }

    NetworkManager.shared.fetch(url: url)
      .subscribe(
        onSuccess: { [weak self] (podcastResponse: PodcastResponse) in
          switch media {
          case .podcast:
            self?.podcastSubject.onNext(podcastResponse.results)
          case .movie:
            self?.movieSubject.onNext(podcastResponse.results)
          }
        },
        onFailure: { [weak self] error in
          switch media {
          case .podcast:
            self?.podcastSubject.onError(error)
          case .movie:
            self?.movieSubject.onError(error)
          }
        }
      ).disposed(by: disposeBag)
  }
}
