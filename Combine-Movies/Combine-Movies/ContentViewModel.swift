//
//  ContentViewModel.swift
//  Combine-Movies
//
//  Created by Guillaume on 23/04/2026.
//

import Combine
import Foundation

/// ViewModel gérant la logique de recherche de films
/// Expose un flux réactif des films filtrés basé sur l'entrée utilisateur
class MovieSearchViewModel: ObservableObject {
    
    // MARK: Outputs (@Published pour les mises à jour UI)
    
    /// Champ de recherche - mises à jour en temps réel
    @Published var searchQuery: String = ""
    
    /// Liste des films filtrés
    @Published var filteredMovies: [Movie] = []
    
    /// État de chargement
    @Published var isLoading: Bool = false
    
    /// Message d'erreur à afficher
    @Published var errorMessage: String?
    
    // MARK: Propriétés privées
    
    private let movieService: MovieService
    
    /// Ensemble pour stocker les souscriptions Combine actives
    /// Les AnyCancellable sont conservés ici et automatiquement annulés
    /// lors de la destruction du ViewModel (ARC)
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Initialisation
    
    init(movieService: MovieService = MovieService()) {
        self.movieService = movieService
        setupSearchPipeline()
    }
    
    // MARK: Configuration du pipeline Combine
    
    /// Configure le pipeline réactif pour la recherche
    /// Chaîne : searchQuery -> debounce -> removeDuplicates -> fetch -> display
    private func setupSearchPipeline() {
        $searchQuery
            // 1. DEBOUNCE : attend 300ms après la dernière modification
            //    Réduit le nombre de requêtes API lors d'une saisie rapide
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            
            // 2. REMOVEDUPLICATE : ignore si la query ne change pas
            //    Évite les appels redondants
            .removeDuplicates()
            
            // 3. FLATMAP : effectue la requête pour chaque query valide
            //    flatMapLatestResult : annule la requête précédente si nouvelle query
            .flatMap { query in
                self.handleSearch(query)
            }
            
            // 4. RECEIVE ON MAIN : dispatch les résultats sur le main thread
            //    OBLIGATOIRE pour mettre à jour @Published properties
            .receive(on: DispatchQueue.main)
            
            // 5. SINK : s'abonne et traite les résultats
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                        self?.isLoading = false
                    case .finished:
                        // Normal pour un publisher fini
                        self?.isLoading = false
                    }
                },
                receiveValue: { [weak self] movies in
                    // Mise à jour du state UI
                    self?.filteredMovies = movies
                    self?.errorMessage = nil
                    self?.isLoading = false
                }
            )
            // 6. STORE : ajoute cette souscription à cancellables
            //    Garantit qu'elle sera annulée quand le ViewModel est détruit
            .store(in: &cancellables)
    }
    
    // MARK: Logique de recherche
    
    /// Effectue la recherche en fonction de la query
    /// - Parameter query: Chaîne de recherche
    /// - Returns: Publisher émettant les films ou une erreur
    private func handleSearch(_ query: String) -> AnyPublisher<[Movie], Never> {
        // Si la recherche est vide, retourne directement un tableau vide
        guard !query.isEmpty else {
            return Just([])
                .eraseToAnyPublisher()
        }
        
        // Affiche l'état de chargement
        self.isLoading = true
        
        // Effectue l'appel au service
        return movieService.fetchMovies(query: query)
            // CATCH : gère les erreurs sans terminer le pipeline
            .catch { error -> AnyPublisher<[Movie], Never> in
                // Log l'erreur (en production, utiliser un logger)
                print("❌ Erreur lors de la recherche : \(error)")
                // Retourne un tableau vide pour continuer
                return Just([])
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
