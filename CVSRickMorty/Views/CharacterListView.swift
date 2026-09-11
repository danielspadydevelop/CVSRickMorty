//
//  CharacterListView.swift
//  CVSRickMorty
//
//  Created by Daniel Spady on 9/9/26.
//

import SwiftUI

struct CharacterListView: View {
    @State private var viewModel = CharacterSearchViewModel(service: RickAndMortyAPIService())
    @State private var isShowingFilters = false
    @Namespace private var imageTransitionNamespace

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchBar(
                    text: viewModel.searchText,
                    prompt: "Search characters",
                    onTextChange: { viewModel.searchTextChanged($0) },
                    onCancel: { viewModel.searchCancelTapped() }
                )
                list
            }
            .navigationTitle("Rick and Morty")
            .navigationDestination(for: Character.self) { character in
                CharacterDetailView(character: character, namespace: imageTransitionNamespace)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Filters", systemImage: "line.3.horizontal.decrease.circle") {
                        isShowingFilters = true
                    }
                    .accessibilityLabel("Filter search results")
                }
            }
            .sheet(isPresented: $isShowingFilters) {
                filterSheet
                    .presentationDetents([.medium])
            }
        }
    }

    private var list: some View {
        List(viewModel.characters) { character in
            NavigationLink(value: character) {
                CharacterRowView(character: character, namespace: imageTransitionNamespace)
            }
        }
        .listStyle(.plain)
        .overlay { stateOverlay }
    }

    @ViewBuilder
    private var stateOverlay: some View {
        if viewModel.isLoading {
            ProgressView()
                .controlSize(.large)
                .accessibilityLabel("Loading characters")
        } else if let errorMessage = viewModel.errorMessage {
            ContentUnavailableView(
                "Search Failed",
                systemImage: "exclamationmark.triangle",
                description: Text(errorMessage)
            )
            .background(.background)
        } else if viewModel.characters.isEmpty {
            if let noResultsText = viewModel.noResultsText {
                ContentUnavailableView(
                    "No Results",
                    systemImage: "magnifyingglass",
                    description: Text(noResultsText)
                )
            } else if viewModel.searchText.isEmpty {
                ContentUnavailableView(
                    "Search Characters",
                    systemImage: "person.text.magnifyingglass",
                    description: Text("Type a name to find Rick and Morty characters.")
                )
            }
        }
    }

    private var filterSheet: some View {
        NavigationStack {
            Form {
                Picker("Status", selection: $viewModel.statusFilter) {
                    ForEach(StatusFilter.allCases, id: \.self) { filter in
                        Text(filter.displayName).tag(filter)
                    }
                }
                Picker("Species", selection: $viewModel.speciesFilter) {
                    ForEach(SpeciesFilter.allCases, id: \.self) { filter in
                        Text(filter.displayName).tag(filter)
                    }
                }
                TextField("Type", text: $viewModel.typeFilterText)
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isShowingFilters = false
                        viewModel.filtersChanged()
                    }
                }
            }
        }
    }
}

#Preview {
    CharacterListView()
}
