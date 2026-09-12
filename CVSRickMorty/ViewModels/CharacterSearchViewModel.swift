//
//  CharacterSearchViewModel.swift
//  CVSRickMorty
//
//  Created by Daniel Spady on 9/9/26.
//

import Foundation
import Observation

@Observable
final class CharacterSearchViewModel {
    private let service: any CharacterService
    private var searchTask: Task<Void, Never>?

    private(set) var characters: [Character] = []
    private(set) var noResultsText: String?
    private(set) var lastSavedSearchText = ""
    private(set) var searchText = ""
    var isLoading = false
    var errorMessage: String?
    var statusFilter: StatusFilter = .any
    var speciesFilter: SpeciesFilter = .any
    var typeFilterText = ""

    init(service: any CharacterService) {
        self.service = service
    }

    deinit {
        searchTask?.cancel()
    }

    func searchTextChanged(_ newValue: String) {
        searchTask?.cancel()
        searchText = newValue

        guard !newValue.isEmpty else {
            characters = []
            noResultsText = nil
            errorMessage = nil
            isLoading = false
            return
        }

        searchTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(300))
            } catch {
                return
            }
            await performSearch(matching: makeQuery(name: newValue))
        }
    }

    func searchCancelTapped() {
        searchTask?.cancel()
        let saved = lastSavedSearchText
        guard !saved.isEmpty else { return }

        searchText = saved
        if characters.isEmpty || noResultsText != nil || errorMessage != nil {
            Task { await performSearch(matching: makeQuery(name: saved)) }
        }
    }

    func filtersChanged() {
        let name = searchText.isEmpty ? lastSavedSearchText : searchText
        guard !name.isEmpty else { return }
        searchText = name
        searchTextChanged(name)
    }

    func performSearch(matching query: CharacterQuery) async {
        if !query.name.isEmpty {
            lastSavedSearchText = query.name
        }
        isLoading = true
        noResultsText = nil
        errorMessage = nil
        defer { isLoading = false }

        do {
            characters = try await service.searchCharacters(matching: query)
        } catch is CancellationError {
            return
        } catch CharacterServiceError.unexpectedStatus(404) {
            characters = []
            noResultsText = "No characters found for \"\(query.name)\"."
        } catch {
            characters = []
            errorMessage = error.localizedDescription
        }
    }

    private func makeQuery(name: String) -> CharacterQuery {
        let trimmedType = typeFilterText.trimmingCharacters(in: .whitespaces)
        return CharacterQuery(
            name: name,
            status: statusFilter.queryValue,
            species: speciesFilter.queryValue,
            type: trimmedType.isEmpty ? nil : trimmedType
        )
    }
}
