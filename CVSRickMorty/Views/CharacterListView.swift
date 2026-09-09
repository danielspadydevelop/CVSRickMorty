//
//  CharacterListView.swift
//  CVSRickMorty
//
//  Created by Daniel Spady on 9/9/26.
//

import SwiftUI

struct CharacterListView: View {
    @State private var viewModel = CharacterSearchViewModel(service: RickAndMortyAPIService())

    var body: some View {
        NavigationStack {
            Group {
                if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Search Failed",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else {
                    content
                }
            }
            .navigationTitle("Rick and Morty")
            .searchable(text: $viewModel.searchText)
            .onChange(of: viewModel.searchText) { _, newValue in
                viewModel.searchTextChanged(newValue)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        List(viewModel.characters) { character in
            CharacterRowView(character: character)
        }
        .listStyle(.plain)
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .controlSize(.large)
            }
        }
        .overlay {
            if viewModel.characters.isEmpty, !viewModel.isLoading, viewModel.searchText.isEmpty {
                ContentUnavailableView(
                    "Search Characters",
                    systemImage: "person.text.magnifyingglass",
                    description: Text("Type a name to find Rick and Morty characters.")
                )
            }
        }
    }
}

#Preview {
    CharacterListView()
}
