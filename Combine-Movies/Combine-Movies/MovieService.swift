//
//  MovieService.swift
//  Combine-Movies
//
//  Created by Guillaume on 23/04/2026.
//

import Combine
import Foundation

// MARK: - Service Layer
/// Service fictif pour récupérer les films
/// En production, ce service ferait des appels API réels
class MovieService {
    /// Base de données fictive de films
    private let mockDatabase: [Movie] = [
        Movie(id: "1", title: "The Shawshank Redemption", releaseYear: 1994, posterURL: nil),
        Movie(id: "2", title: "The Godfather", releaseYear: 1972, posterURL: nil),
        Movie(id: "3", title: "The Dark Knight", releaseYear: 2008, posterURL: nil),
        Movie(id: "4", title: "Inception", releaseYear: 2010, posterURL: nil),
        Movie(id: "5", title: "Interstellar", releaseYear: 2014, posterURL: nil),
        Movie(id: "6", title: "The Matrix", releaseYear: 1999, posterURL: nil),
        Movie(id: "7", title: "Pulp Fiction", releaseYear: 1994, posterURL: nil),
        Movie(id: "8", title: "Forrest Gump", releaseYear: 1994, posterURL: nil),
    ]
    
    /// Simule un appel API pour chercher des films
    /// - Parameter query: Chaîne de recherche (sensible à la casse)
    /// - Returns: AnyPublisher émettant un tableau de films ou une erreur
    func fetchMovies(query: String) -> AnyPublisher<[Movie], Error> {
        // Simule une latence réseau (300ms)
        let delay: UInt64 = 300_000_000 // nanosecondes
        
        return Just(query)
            .delay(for: .nanoseconds(Int(delay)), scheduler: RunLoop.main)
            .map { searchQuery in
                // Filtre la base de données fictive
                guard !searchQuery.isEmpty else { return [] }
                return self.mockDatabase.filter { movie in
                    movie.title.localizedCaseInsensitiveContains(searchQuery)
                }
            }
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

