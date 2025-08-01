//
//  Podcast.swift
//  AdvanceApp
//
//  Created by luca on 7/29/25.
//

// - trackName: 팟캐스트 이름
// - artistName: 가수명
// - artworkUrl100: 앨범재킷

struct PodcastResponse: Codable {
  let results: [Podcast]
}

struct Podcast: Codable {
  let trackName: String?
  let artistName: String?
  let artworkUrl: String?
  let kind: String?
  let artworkUrl600: String?
  
  enum CodingKeys: String, CodingKey {
    case trackName, artistName, kind, artworkUrl600
    case artworkUrl = "artworkUrl100"
  }
}
