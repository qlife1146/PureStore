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
    guard let url = URL(string: "https://itunes.apple.com/search?term=\(searchWord)&country=\(userLocale ?? "noLocale")&media=music")
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
    guard let url = URL(string: "https://itunes.apple.com/search?term=\(searchWord)&country=\(userLocale ?? "no Locale")&media=movie&media=podcast")
    else {
      podcastSubject.onError(NetworkError.invalidUrl)
      return
    }

    NetworkManager.shared.fetch(url: url)
      .subscribe(
        onSuccess: { [weak self] (podcastResponse: PodcastResponse) in
          self?.podcastSubject.onNext(podcastResponse.results)
        },
        onFailure: { [weak self] error in
          self?.podcastSubject.onError(error)
        }
      ).disposed(by: disposeBag)
  }
}
