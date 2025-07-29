//
//  Music.swift
//  AdvanceApp
//
//  Created by luca on 7/29/25.
//

// - trackName: 곡명
// - artistName: 가수명
// - artworkUrl100: 앨범재킷

struct MusicResponse: Codable {
  let results: [Music]
}

struct Music: Codable {
  let trackName: String?
  let artistName: String?
  let artworkUrl: String?
  
  enum CodingKeys: String, CodingKey {
    case trackName, artistName
    case artworkUrl = "artworkUrl100"
  }
}
