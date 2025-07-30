//
//  MainViewModel.swift
//  AdvanceApp
//
//  Created by luca on 7/29/25.
//

import Foundation
import RxSwift
import UIKit

class MainViewModel {
  let userLocale = Locale.current.region
  let searchWord = "봄"
  private let disposeBag = DisposeBag()

  let musicSubject: BehaviorSubject = BehaviorSubject(value: [Music]())
  let podcastSubject: BehaviorSubject = BehaviorSubject(value: [Podcast]())

  init() {
    fetchMusic()
    fetchPodcast()
  }

  func fetchMusic() {
    guard
      let url = URL(
        string: "https://itunes.apple.com/search?term=\(searchWord)&country=\(userLocale ?? "noLocale")&media=music"
      )
    else {
      musicSubject.onError(NetworkError.invalidUrl)
      return
    }

    NetworkManager.shared.fetch(url: url)
      .subscribe(
        onSuccess: { [weak self] (musicResponse: MusicResponse) in
          self?.musicSubject.onNext(musicResponse.results)
        },
        onFailure: { [weak self] error in
          self?.musicSubject.onError(error)
        }
      ).disposed(by: disposeBag)
  }

  func fetchPodcast() {
    let base = "https://itunes.apple.com/search?term=\(searchWord)&country=\(userLocale ?? "no Locale")"
    guard let movieUrl = URL(string: base + "&media=movie"),
      let podcastUrl = URL(string: base + "&media=podcast")
    else {
      podcastSubject.onError(NetworkError.invalidUrl)
      return
    }

    let movieObservable: Single<[Podcast]> = NetworkManager.shared.fetch(url: movieUrl)
      .map { (response: PodcastResponse) in response.results }
    let podcastObservable: Single<[Podcast]> = NetworkManager.shared.fetch(url: podcastUrl)
      .map { (response: PodcastResponse) in response.results }

    Single.zip(podcastObservable, movieObservable)
      .map { podcasts, movies in
        return podcasts + movies
      }
      .subscribe(
        onSuccess: { [weak self] merged in
          self?.podcastSubject.onNext(merged)
        },
        onFailure: { [weak self] error in self?.podcastSubject.onError(error) }
      ).disposed(by: disposeBag)
  }
}
