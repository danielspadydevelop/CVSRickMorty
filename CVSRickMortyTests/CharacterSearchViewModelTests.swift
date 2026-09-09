//
//  CharacterSearchViewModelTests.swift
//  CVSRickMortyTests
//
//  Created by Daniel Spady on 9/9/26.
//

@testable import CVSRickMorty
import Foundation
import Testing

@Suite(.serialized)
struct CharacterSearchViewModelTests {

    private let characterJSON = """
        {
            "id": 1,
            "name": "Rick Sanchez",
            "status": "Alive",
            "species": "Human",
            "type": "",
            "origin": { "name": "Earth (C-137)", "url": "" },
            "image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
            "created": "2017-11-04T18:48:46.250Z"
        }
        """

    private func makeCharacter() throws -> Character {
        let data = try #require(characterJSON.data(using: .utf8))
        return try JSONDecoder().decode(Character.self, from: data)
    }

    @MainActor
    @Test("Successful search updates characters and clears any previous error")
    func successfulSearchUpdatesCharacters() async throws {
        let stub = CharacterServiceStub()
        stub.searchResultsToReturn = .success([try makeCharacter()])
        let viewModel = CharacterSearchViewModel(service: stub)

        await viewModel.performSearch(matching: CharacterQuery(name: "rick"))

        #expect(viewModel.characters.count == 1)
        #expect(viewModel.characters.first?.name == "Rick Sanchez")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @MainActor
    @Test("Failed search sets an error message and empties the results")
    func failedSearchSetsErrorMessage() async throws {
        let stub = CharacterServiceStub()
        stub.searchResultsToReturn = .failure(CharacterServiceError.unexpectedStatus(500))
        let viewModel = CharacterSearchViewModel(service: stub)

        await viewModel.performSearch(matching: CharacterQuery(name: "rick"))

        #expect(viewModel.characters.isEmpty)
        #expect(viewModel.errorMessage == "The server returned an unexpected status code: 500.")
        #expect(viewModel.isLoading == false)
    }

    @MainActor
    @Test("A 404 maps to a no-results state instead of an error")
    func notFoundMapsToNoResults() async throws {
        let stub = CharacterServiceStub()
        stub.searchResultsToReturn = .failure(CharacterServiceError.unexpectedStatus(404))
        let viewModel = CharacterSearchViewModel(service: stub)

        await viewModel.performSearch(matching: CharacterQuery(name: "xyz"))

        #expect(viewModel.characters.isEmpty)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.noResultsText == "No characters found for \"xyz\".")
    }

    @MainActor
    @Test("Clearing the search text empties results without calling the service")
    func clearingSearchTextEmptiesResults() async throws {
        let stub = CharacterServiceStub()
        stub.searchResultsToReturn = .success([try makeCharacter()])
        let viewModel = CharacterSearchViewModel(service: stub)

        await viewModel.performSearch(matching: CharacterQuery(name: "rick"))
        #expect(viewModel.characters.count == 1)

        viewModel.searchTextChanged("")

        #expect(viewModel.characters.isEmpty)
        #expect(viewModel.errorMessage == nil)
        #expect(stub.receivedQueries.map(\.name) == ["rick"])
    }

    @MainActor
    @Test("Rapid search text changes are debounced to a single latest search")
    func rapidChangesAreDebounced() async throws {
        let stub = CharacterServiceStub()
        stub.searchResultsToReturn = .success([try makeCharacter()])
        let viewModel = CharacterSearchViewModel(service: stub)

        viewModel.searchTextChanged("ri")
        viewModel.searchTextChanged("ric")
        viewModel.searchTextChanged("rick")
        try await Task.sleep(for: .milliseconds(500))

        #expect(stub.receivedQueries.map(\.name) == ["rick"])
        #expect(viewModel.characters.first?.name == "Rick Sanchez")
    }

    @MainActor
    @Test("Changing filters re-searches with the selected filters in the query")
    func filterChangesReSearchWithFilters() async throws {
        let stub = CharacterServiceStub()
        stub.searchResultsToReturn = .success([try makeCharacter()])
        let viewModel = CharacterSearchViewModel(service: stub)

        viewModel.searchText = "rick"
        viewModel.statusFilter = .alive
        viewModel.speciesFilter = .human
        viewModel.typeFilterText = "Genetic"
        viewModel.filtersChanged()
        try await Task.sleep(for: .milliseconds(500))

        let query = try #require(stub.receivedQueries.last)
        #expect(query.name == "rick")
        #expect(query.status == "alive")
        #expect(query.species == "Human")
        #expect(query.type == "Genetic")
    }
}
