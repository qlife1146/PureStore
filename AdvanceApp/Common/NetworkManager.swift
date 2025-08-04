//
//  NetworkManager.swift
//  AdvanceApp
//
//  Created by luca on 7/29/25.
//

import Alamofire
import Foundation
import RxSwift

enum NetworkError: Error {
  case invalidUrl
  case dataFetchFail
  case decodingFail
}

class NetworkManager {
  static let shared = NetworkManager()
  private init() {}

  func fetch<T: Decodable>(url: URL) -> Single<T> {
    return Single.create { observer in
      AF.request(url)
        .validate()
        .responseDecodable(of: T.self) { response in
          switch response.result {
          case .success(let value):
            observer(.success(value))
          case .failure(let error):
            observer(.failure(error))
          }
        }
      return Disposables.create()
    }
  }
}
