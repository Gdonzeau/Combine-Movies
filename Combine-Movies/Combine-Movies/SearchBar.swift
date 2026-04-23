//
//  SearchBar.swift
//  Combine-Movies
//
//  Created by Guillaume on 23/04/2026.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
        
        var body: some View {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Rechercher un film...", text: $text)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                
                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
}

#Preview {
    SearchBar(text: .constant("Test"))
}
