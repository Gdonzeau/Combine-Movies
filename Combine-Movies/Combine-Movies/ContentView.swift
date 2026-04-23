//
//  ContentView.swift
//  Combine-Movies
//
//  Created by Guillaume on 23/04/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MovieSearchViewModel()
        
        var body: some View {
            NavigationStack {
                VStack(spacing: 16) {
                    // Champ de recherche
                    SearchBar(text: $viewModel.searchQuery)
                    
                    // Indicateur de chargement
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    // Message d'erreur
                    if let errorMessage = viewModel.errorMessage {
                        Text("⚠️ \(errorMessage)")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    // Liste des films
                    if viewModel.filteredMovies.isEmpty && !viewModel.searchQuery.isEmpty {
                        Text("Aucun film trouvé pour « \(viewModel.searchQuery) »")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    } else {
                        List(viewModel.filteredMovies) { movie in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(movie.title)
                                    .font(.headline)
                                Text("(\(movie.releaseYear))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    
                    Spacer()
                }
                .navigationTitle("🎬 Recherche Films")
            }
        }
}

#Preview {
    ContentView()
}
