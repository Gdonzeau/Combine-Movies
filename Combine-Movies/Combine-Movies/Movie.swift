//
//  Movie.swift
//  Combine-Movies
//
//  Created by Guillaume on 23/04/2026.
//

import Foundation

// MARK: - Model
/// Modèle représentant un film
struct Movie: Identifiable, Codable {
    let id: String
    let title: String
    let releaseYear: Int
    let posterURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case releaseYear = "year"
        case posterURL = "poster"
    }
}
