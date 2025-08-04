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
  private let disposeBag = DisposeBag()

  let userLocale = Locale.current.region
  let springSubject: BehaviorSubject = BehaviorSubject(value: [Music]())
  let summerSubject: BehaviorSubject = BehaviorSubject(value: [Music]())
  let autumnSubject: BehaviorSubject = BehaviorSubject(value: [Music]())
  let winterSubject: BehaviorSubject = BehaviorSubject(value: [Music]())

  init() {
    fetchMusic(for: .springMusic)
    fetchMusic(for: .summerMusic)
    fetchMusic(for: .autumnMusic)
    fetchMusic(for: .winterMusic)
  }

  func fetchMusic(for season: Section) {
    let keyword = season.searchKeyword

    guard
      let url = URL(
        string: "https://itunes.apple.com/search?term=\(keyword)&country=\(userLocale ?? "kr")&media=music"
      )
    else {
      springSubject.onError(NetworkError.invalidUrl)
      return
    }

    NetworkManager.shared.fetch(url: url)
      .subscribe(
        onSuccess: { [weak self] (musicResponse: MusicResponse) in
          // self?.musicSubject.onNext(musicResponse.results)
          switch season {
          case .springMusic:
            self?.springSubject.onNext(musicResponse.results)
          case .summerMusic:
            self?.summerSubject.onNext(musicResponse.results)
          case .autumnMusic:
            self?.autumnSubject.onNext(musicResponse.results)
          case .winterMusic:
            self?.winterSubject.onNext(musicResponse.results)
          }
        },
        onFailure: { [weak self] error in
          switch season {
          case .springMusic:
            self?.springSubject.onError(error)
          case .summerMusic:
            self?.summerSubject.onError(error)
          case .autumnMusic:
            self?.autumnSubject.onError(error)
          case .winterMusic:
            self?.winterSubject.onError(error)
          }
        }
      ).disposed(by: disposeBag)
  }
}
