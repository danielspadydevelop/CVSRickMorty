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
    var searchText = ""
    var isLoading = false
    var errorMessage: String?

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
            await performSearch(named: newValue)
        }
    }

    func performSearch(named name: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            characters = try await service.searchCharacters(named: name)
        } catch is CancellationError {
            return
        } catch {
            characters = []
            errorMessage = error.localizedDescription
        }
    }
}
